import 'package:design_system/src/typography/pixel_font.dart';
import 'package:flutter/material.dart';

/// Texto renderizado com a fonte bitmap [PixelFont] — cada ponto da
/// matriz 5x7 vira um retangulo no Canvas. Display tipografico da
/// identidade Arcade; use pra headlines, HUD e labels curtos (corpo de
/// leitura continua fica numa fonte normal, legivel).
///
/// Suporta multiplas linhas (`\n`). O widget calcula o proprio tamanho
/// intrinseco a partir do texto e do [pixelSize]; o painter monta uma
/// unica `Path` com todos os pontos acesos e desenha em um drawPath (com
/// glow opcional por baixo). Geometria so recalcula quando texto/escala
/// mudam — `shouldRepaint` compara campo a campo.
class PixelText extends StatelessWidget {
  const PixelText(
    this.text, {
    required this.color,
    this.pixelSize = 4,
    this.letterSpacing = 1,
    this.lineSpacing = 2,
    this.glowColor,
    this.glowBlur = 6,
    this.align = TextAlign.left,
    super.key,
  });

  /// Texto a desenhar. `\n` quebra linha. Case-insensitive (all-caps).
  final String text;

  /// Cor dos pixels acesos.
  final Color color;

  /// Lado de cada pixel-fonte, em px logicos. Controla o "tamanho" do texto.
  final double pixelSize;

  /// Espaco entre glifos, em pixels-fonte.
  final double letterSpacing;

  /// Espaco entre linhas, em pixels-fonte.
  final double lineSpacing;

  /// Cor do glow (halo neon). Nulo = sem glow.
  final Color? glowColor;

  /// Raio do blur do glow.
  final double glowBlur;

  /// Alinhamento horizontal entre linhas de larguras diferentes.
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    // Idiomas com script fora do alfabeto latino (japones, chines, russo...)
    // nao tem glifo na fonte bitmap 5x7 — sairiam em branco. Nesses casos
    // renderiza numa fonte real, estilizada pra preservar o ar arcade
    // (all-caps, bold, glow). Latino/numeros/pontuacao seguem em pixel.
    if (!PixelFont.canRenderAll(text)) {
      return _FallbackText(
        text: text,
        color: color,
        pixelSize: pixelSize,
        letterSpacing: letterSpacing,
        glowColor: glowColor,
        glowBlur: glowBlur,
        align: align,
      );
    }

    final lines = text.split('\n');

    // Largura de cada linha em pixels-fonte; a maior define a largura do box.
    var maxLineDots = 0.0;
    for (final line in lines) {
      if (line.isEmpty) continue;
      final dots =
          line.length * PixelFont.glyphWidth +
          (line.length - 1) * letterSpacing;
      if (dots > maxLineDots) maxLineDots = dots;
    }
    final heightDots =
        lines.length * PixelFont.glyphHeight + (lines.length - 1) * lineSpacing;

    final size = Size(maxLineDots * pixelSize, heightDots * pixelSize);

    return CustomPaint(
      size: size,
      painter: _PixelTextPainter(
        lines: lines,
        color: color,
        pixelSize: pixelSize,
        letterSpacing: letterSpacing,
        lineSpacing: lineSpacing,
        glowColor: glowColor,
        glowBlur: glowBlur,
        align: align,
      ),
    );
  }
}

/// Fallback de [PixelText] pra scripts sem glifo bitmap (CJK, cirilico...).
/// Aproxima o display arcade com fonte real: all-caps, peso forte, glow via
/// `shadows` e tamanho derivado do `pixelSize` (altura ~ glifo 5x7).
class _FallbackText extends StatelessWidget {
  const _FallbackText({
    required this.text,
    required this.color,
    required this.pixelSize,
    required this.letterSpacing,
    required this.glowColor,
    required this.glowBlur,
    required this.align,
  });

  final String text;
  final Color color;
  final double pixelSize;
  final double letterSpacing;
  final Color? glowColor;
  final double glowBlur;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    final fontSize = pixelSize * PixelFont.glyphHeight;
    return Text(
      text.toUpperCase(),
      textAlign: align,
      style: TextStyle(
        color: color,
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        letterSpacing: letterSpacing * pixelSize,
        height: 1.1,
        shadows: glowColor != null
            ? [Shadow(color: glowColor!, blurRadius: glowBlur)]
            : null,
      ),
    );
  }
}

class _PixelTextPainter extends CustomPainter {
  _PixelTextPainter({
    required this.lines,
    required this.color,
    required this.pixelSize,
    required this.letterSpacing,
    required this.lineSpacing,
    required this.glowColor,
    required this.glowBlur,
    required this.align,
  }) : _fill = Paint()..color = color {
    if (glowColor != null) {
      _glow = Paint()
        ..color = glowColor!
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, glowBlur);
    }
  }

  final List<String> lines;
  final Color color;
  final double pixelSize;
  final double letterSpacing;
  final double lineSpacing;
  final Color? glowColor;
  final double glowBlur;
  final TextAlign align;

  final Paint _fill;
  Paint? _glow;

  // Path de todos os pixels acesos — montada uma vez por instancia (o
  // painter e recriado quando o texto muda).
  Path? _path;

  Path _buildPath(Size size) {
    final path = Path();
    final lineHeightDots = PixelFont.glyphHeight + lineSpacing;

    for (var li = 0; li < lines.length; li++) {
      final line = lines[li];
      // Offset horizontal da linha conforme alinhamento.
      final lineWidthDots = line.isEmpty
          ? 0.0
          : line.length * PixelFont.glyphWidth +
                (line.length - 1) * letterSpacing;
      final freeDots = size.width / pixelSize - lineWidthDots;
      final startXDots = switch (align) {
        TextAlign.center => freeDots / 2,
        TextAlign.right || TextAlign.end => freeDots,
        _ => 0.0,
      };
      final lineTopDots = li * lineHeightDots;

      for (var ci = 0; ci < line.length; ci++) {
        final rows = PixelFont.rowsFor(line[ci]);
        final glyphLeftDots =
            startXDots + ci * (PixelFont.glyphWidth + letterSpacing);
        for (var ry = 0; ry < PixelFont.glyphHeight; ry++) {
          final bits = rows[ry];
          for (var cx = 0; cx < PixelFont.glyphWidth; cx++) {
            // bit 4 (0x10) = coluna 0 (esquerda).
            final on = (bits & (1 << (PixelFont.glyphWidth - 1 - cx))) != 0;
            if (!on) continue;
            path.addRect(
              Rect.fromLTWH(
                (glyphLeftDots + cx) * pixelSize,
                (lineTopDots + ry) * pixelSize,
                pixelSize,
                pixelSize,
              ),
            );
          }
        }
      }
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    final path = _path ??= _buildPath(size);
    if (_glow != null) canvas.drawPath(path, _glow!);
    canvas.drawPath(path, _fill);
  }

  @override
  bool shouldRepaint(_PixelTextPainter oldDelegate) =>
      oldDelegate.lines.join('\n') != lines.join('\n') ||
      oldDelegate.color != color ||
      oldDelegate.pixelSize != pixelSize ||
      oldDelegate.letterSpacing != letterSpacing ||
      oldDelegate.lineSpacing != lineSpacing ||
      oldDelegate.glowColor != glowColor ||
      oldDelegate.glowBlur != glowBlur ||
      oldDelegate.align != align;
}
