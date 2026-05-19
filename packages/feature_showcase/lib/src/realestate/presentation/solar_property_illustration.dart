import 'package:feature_showcase/src/realestate/domain/property_type.dart';
import 'package:flutter/material.dart';

/// Ilustracao geometrica do imovel por [PropertyType] — substitui foto
/// real nos cards e na galeria do detalhe (3 angulos via [variant]).
/// Composicao em silhuetas planas com sombra simulada por gradiente,
/// no espirito de revistas de arquitetura ilustradas.
///
/// Performance: paints e gradientes cacheados; `shouldRepaint` so
/// dispara quando type, variant ou cores mudam.
class SolarPropertyIllustration extends StatelessWidget {
  const SolarPropertyIllustration({
    required this.type,
    this.variant = 0,
    this.foregroundColor,
    this.accentColor,
    this.backgroundColor,
    super.key,
  });

  final PropertyType type;

  /// Variacao do angulo na galeria do detalhe — 0 padrao (frente), 1
  /// perspectiva lateral, 2 vista superior. Cards usam sempre 0.
  final int variant;

  /// Cor principal da silhueta. Default = primary do tema.
  final Color? foregroundColor;

  /// Cor de destaque (telhado / vegetacao / acentos). Default =
  /// secondary do tema.
  final Color? accentColor;

  /// Cor de fundo da cena (chao / ceu sutil). Default = surfaceMuted.
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = foregroundColor ?? scheme.primary;
    final accent = accentColor ?? scheme.secondary;
    final bg = backgroundColor ?? scheme.surface;
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: _SolarPropertyIllustrationPainter(
          type: type,
          variant: variant,
          foregroundColor: fg,
          accentColor: accent,
          backgroundColor: bg,
        ),
      ),
    );
  }
}

class _SolarPropertyIllustrationPainter extends CustomPainter {
  _SolarPropertyIllustrationPainter({
    required this.type,
    required this.variant,
    required this.foregroundColor,
    required this.accentColor,
    required this.backgroundColor,
  });

  final PropertyType type;
  final int variant;
  final Color foregroundColor;
  final Color accentColor;
  final Color backgroundColor;

  late final Paint _fill = Paint()
    ..color = foregroundColor
    ..style = PaintingStyle.fill;

  late final Paint _accentFill = Paint()
    ..color = accentColor
    ..style = PaintingStyle.fill;

  late final Paint _shadeFill = Paint()
    ..color = foregroundColor.withValues(alpha: 0.75)
    ..style = PaintingStyle.fill;

  late final Paint _windowFill = Paint()
    ..color = backgroundColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Pano de fundo com gradiente sutil ceu->chao pra dar profundidade.
    final bgRect = Offset.zero & size;
    final bgGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        backgroundColor,
        Color.lerp(backgroundColor, accentColor, 0.10) ?? backgroundColor,
      ],
    ).createShader(bgRect);
    canvas.drawRect(bgRect, Paint()..shader = bgGradient);

    switch (type) {
      case PropertyType.house:
        _paintHouse(canvas, size);
      case PropertyType.chacara:
        _paintChacara(canvas, size);
      case PropertyType.land:
        _paintLand(canvas, size);
      case PropertyType.apartment:
        _paintApartment(canvas, size);
    }
  }

  /// Casa — silhueta de telhado triangular + corpo retangular + porta
  /// + janelas. Variants reposicionam o sol e adicionam arvore lateral.
  void _paintHouse(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    // Chao.
    final ground = Rect.fromLTWH(0, h * 0.78, w, h * 0.22);
    canvas.drawRect(ground, _shadeFill);

    // Sol — posicao varia por variant.
    final sunCx = variant == 1 ? w * 0.22 : w * 0.78;
    final sunCy = h * (variant == 2 ? 0.18 : 0.22);
    canvas.drawCircle(Offset(sunCx, sunCy), h * 0.06, _accentFill);

    // Arvore lateral no variant 1.
    if (variant == 1) {
      _paintTree(canvas, Offset(w * 0.85, h * 0.78), h * 0.22);
    }
    if (variant == 2) {
      // Vista "superior" — adiciona piscina simbolica ao lado.
      final pool = Rect.fromLTWH(w * 0.62, h * 0.62, w * 0.20, h * 0.12);
      canvas.drawRRect(
        RRect.fromRectAndRadius(pool, const Radius.circular(6)),
        Paint()..color = accentColor.withValues(alpha: 0.5),
      );
    }

    // Corpo da casa.
    final body = Rect.fromLTWH(w * 0.18, h * 0.45, w * 0.50, h * 0.33);
    canvas.drawRect(body, _fill);

    // Telhado triangular.
    final roof = Path()
      ..moveTo(w * 0.12, h * 0.45)
      ..lineTo(w * 0.43, h * 0.20)
      ..lineTo(w * 0.74, h * 0.45)
      ..close();
    canvas.drawPath(roof, _accentFill);

    // Chamine.
    final chimney = Rect.fromLTWH(w * 0.55, h * 0.26, w * 0.04, h * 0.10);
    canvas.drawRect(chimney, _fill);

    // Porta.
    final door = Rect.fromLTWH(w * 0.38, h * 0.60, w * 0.10, h * 0.18);
    // Janelas.
    canvas
      ..drawRect(door, _accentFill)
      ..drawRect(
        Rect.fromLTWH(w * 0.22, h * 0.52, w * 0.10, h * 0.10),
        _windowFill,
      )
      ..drawRect(
        Rect.fromLTWH(w * 0.54, h * 0.52, w * 0.10, h * 0.10),
        _windowFill,
      );
  }

  /// Chacara — casa menor + arvores + horizonte com colina.
  void _paintChacara(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Colina ao fundo.
    final hill = Path()
      ..moveTo(0, h * 0.72)
      ..quadraticBezierTo(w * 0.35, h * 0.45, w * 0.70, h * 0.65)
      ..quadraticBezierTo(w * 0.90, h * 0.75, w, h * 0.70)
      ..lineTo(w, h)
      ..lineTo(0, h)
      ..close();

    // Sol.
    final sunCx = variant == 1 ? w * 0.20 : w * 0.78;
    // Casa central pequena.
    final bodyX = variant == 1 ? w * 0.40 : w * 0.30;
    final body = Rect.fromLTWH(bodyX, h * 0.55, w * 0.30, h * 0.30);
    final roof = Path()
      ..moveTo(bodyX - w * 0.04, h * 0.55)
      ..lineTo(bodyX + w * 0.15, h * 0.36)
      ..lineTo(bodyX + w * 0.34, h * 0.55)
      ..close();
    canvas
      ..drawPath(hill, _shadeFill)
      // Chao.
      ..drawRect(
        Rect.fromLTWH(0, h * 0.85, w, h * 0.15),
        Paint()..color = accentColor.withValues(alpha: 0.85),
      )
      ..drawCircle(Offset(sunCx, h * 0.20), h * 0.05, _accentFill)
      ..drawRect(body, _fill)
      ..drawPath(roof, _accentFill)
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.04, h * 0.62, w * 0.08, h * 0.08),
        _windowFill,
      )
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.18, h * 0.62, w * 0.08, h * 0.08),
        _windowFill,
      )
      ..drawRect(
        Rect.fromLTWH(bodyX + w * 0.11, h * 0.74, w * 0.07, h * 0.11),
        _accentFill,
      );

    // Duas arvores ladeando.
    _paintTree(canvas, Offset(w * 0.12, h * 0.85), h * 0.32);
    _paintTree(canvas, Offset(w * 0.86, h * 0.85), h * 0.28);
  }

  /// Terreno — lote vazio com cerca + horizonte. Sem casa.
  void _paintLand(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Horizonte com mata ao fundo.
    final mata = Path()
      ..moveTo(0, h * 0.55)
      ..quadraticBezierTo(w * 0.20, h * 0.40, w * 0.45, h * 0.52)
      ..quadraticBezierTo(w * 0.70, h * 0.62, w, h * 0.50)
      ..lineTo(w, h * 0.65)
      ..lineTo(0, h * 0.65)
      ..close();
    canvas
      ..drawPath(mata, _shadeFill)
      // Chao em accent.
      ..drawRect(
        Rect.fromLTWH(0, h * 0.65, w, h * 0.35),
        Paint()..color = accentColor.withValues(alpha: 0.75),
      )
      // Sol.
      ..drawCircle(Offset(w * 0.78, h * 0.22), h * 0.05, _accentFill);

    // Cerca esquemática — postes e duas linhas horizontais.
    final fencePaint = Paint()
      ..color = foregroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = w * 0.012
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i <= 6; i++) {
      final x = w * 0.10 + (w * 0.80) * (i / 6);
      canvas.drawLine(
        Offset(x, h * 0.66),
        Offset(x, h * 0.88),
        fencePaint,
      );
    }
    canvas
      ..drawLine(
        Offset(w * 0.10, h * 0.72),
        Offset(w * 0.90, h * 0.72),
        fencePaint,
      )
      ..drawLine(
        Offset(w * 0.10, h * 0.82),
        Offset(w * 0.90, h * 0.82),
        fencePaint,
      );

    // Placa "vende-se" simbolica.
    final signX = variant == 1 ? w * 0.20 : w * 0.70;
    final signRect = Rect.fromLTWH(signX, h * 0.50, w * 0.16, h * 0.12);
    canvas
      ..drawRect(signRect, _fill)
      ..drawRect(
        Rect.fromLTWH(signX + w * 0.07, h * 0.62, w * 0.02, h * 0.20),
        _fill,
      );
  }

  /// Apartamento — predio com janelas em grade.
  void _paintApartment(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Chao.
    canvas.drawRect(
      Rect.fromLTWH(0, h * 0.82, w, h * 0.18),
      _shadeFill,
    );

    // Sol.
    final sunCx = variant == 1 ? w * 0.18 : w * 0.82;
    // Corpo do predio.
    final body = Rect.fromLTWH(w * 0.25, h * 0.18, w * 0.50, h * 0.64);
    canvas
      ..drawCircle(Offset(sunCx, h * 0.20), h * 0.05, _accentFill)
      ..drawRect(body, _fill)
      // Cobertura — faixa accent no topo.
      ..drawRect(
        Rect.fromLTWH(w * 0.22, h * 0.18, w * 0.56, h * 0.04),
        _accentFill,
      );

    // Janelas em grade 4 colunas x 6 linhas; pula linha do meio
    // pra simular varanda.
    const cols = 4;
    const rows = 6;
    final cellW = w * 0.50 / cols;
    final cellH = h * 0.60 / rows;
    for (var r = 0; r < rows; r++) {
      for (var c = 0; c < cols; c++) {
        if (r == 3) continue; // andar de varanda
        final x = w * 0.25 + c * cellW + cellW * 0.18;
        final y = h * 0.22 + r * cellH + cellH * 0.18;
        canvas.drawRect(
          Rect.fromLTWH(x, y, cellW * 0.64, cellH * 0.50),
          _windowFill,
        );
      }
    }
    // Varanda corrida na linha pulada.
    canvas.drawRect(
      Rect.fromLTWH(
        w * 0.25 + cellW * 0.12,
        h * 0.22 + 3 * cellH + cellH * 0.10,
        w * 0.50 - cellW * 0.24,
        cellH * 0.50,
      ),
      Paint()..color = accentColor.withValues(alpha: 0.7),
    );
  }

  /// Arvore esquematica — copa circular + tronco. Centro [base] no
  /// chao; [height] inclui copa.
  void _paintTree(Canvas canvas, Offset base, double height) {
    final trunkW = height * 0.12;
    final trunkH = height * 0.30;
    final trunk = Rect.fromLTWH(
      base.dx - trunkW / 2,
      base.dy - trunkH,
      trunkW,
      trunkH,
    );
    canvas
      ..drawRect(trunk, _shadeFill)
      ..drawCircle(
        Offset(base.dx, base.dy - trunkH - height * 0.25),
        height * 0.30,
        _accentFill,
      );
  }

  @override
  bool shouldRepaint(_SolarPropertyIllustrationPainter old) {
    return old.type != type ||
        old.variant != variant ||
        old.foregroundColor != foregroundColor ||
        old.accentColor != accentColor ||
        old.backgroundColor != backgroundColor;
  }
}
