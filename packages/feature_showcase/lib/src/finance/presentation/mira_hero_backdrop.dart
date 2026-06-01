import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Backdrop animado do hero da home Mira — estetica Bloomberg-terminal:
/// grid de colunas + ticks horizontais de preco no fundo, sparkline
/// ghost suave atravessando o canvas, pontos de glow pulsantes nas
/// intersecoes principais. Tudo em alpha baixo pra nao competir com o
/// conteudo do hero card (que vive sobre este backdrop).
///
/// Performance:
/// - `Listenable` passado ao `super(repaint:)` direto, evita build/layout
///   no pipeline a cada frame;
/// - Paints (grid, ticks, glow, shaders) cacheados como campos; os pontos
///   da sparkline ghost sao seedados (seed fixa, identicos todo frame),
///   computados uma vez — so o scroll horizontal e o wobble variam;
/// - `RepaintBoundary` no widget isola repaints da subarvore vizinha.
class MiraHeroBackdrop extends StatefulWidget {
  const MiraHeroBackdrop({required this.height, super.key});

  final double height;

  @override
  State<MiraHeroBackdrop> createState() => _MiraHeroBackdropState();
}

class _MiraHeroBackdropState extends State<MiraHeroBackdrop>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 14),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          isComplex: true,
          willChange: true,
          painter: _MiraHeroBackdropPainter(
            controller: _controller,
            background: colors.background,
            surface: colors.surface,
            grid: colors.border,
            glowUp: colors.success,
            glowAccent: colors.accent,
            line: colors.success,
            mutedLine: colors.onSurfaceMuted,
          ),
        ),
      ),
    );
  }
}

class _MiraHeroBackdropPainter extends CustomPainter {
  _MiraHeroBackdropPainter({
    required this.controller,
    required this.background,
    required this.surface,
    required this.grid,
    required this.glowUp,
    required this.glowAccent,
    required this.line,
    required this.mutedLine,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final Color background;
  final Color surface;
  final Color grid;
  final Color glowUp;
  final Color glowAccent;
  final Color line;
  final Color mutedLine;

  static const int columnCount = 14;
  static const int rowCount = 6;

  late final Paint _gridPaint = Paint()
    ..color = grid.withValues(alpha: 0.22)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.5;

  late final Paint _gridStrongPaint = Paint()
    ..color = grid.withValues(alpha: 0.45)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 0.8;

  late final Paint _sparklineFillPaint = Paint()
    ..color = glowUp.withValues(alpha: 0.06)
    ..style = PaintingStyle.fill;

  late final Paint _sparklineStrokePaint = Paint()
    ..color = glowUp.withValues(alpha: 0.55)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..strokeJoin = StrokeJoin.round
    ..strokeCap = StrokeCap.round
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.4);

  late final Paint _tickPaint = Paint()
    ..color = mutedLine.withValues(alpha: 0.5)
    ..strokeWidth = 1;

  // Halo + core dos glow dots — cor mutada por dot/frame, objeto reusado.
  final Paint _glowHaloPaint = Paint()
    ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
  final Paint _glowCorePaint = Paint();

  // Paints reusados pros shaders dependentes do rect (so o shader e
  // recriado por frame, nao o objeto Paint).
  final Paint _bgShaderPaint = Paint();
  final Paint _overlayShaderPaint = Paint();

  // Random-walk seedada (seed fixa) — identica todo frame, computada uma
  // vez. So o scroll horizontal (shift) e o wobble dependem do tempo.
  static const int _segmentCount = 36;
  late final List<double> _sparkPoints = _buildSparkPoints();
  final Path _sparkPath = Path();
  final Path _sparkFillPath = Path();

  static List<double> _buildSparkPoints() {
    final rng = math.Random(7);
    final points = <double>[];
    var v = 0.5;
    for (var i = 0; i < _segmentCount + 1; i++) {
      v += (rng.nextDouble() - 0.45) * 0.18;
      v = v.clamp(0.1, 0.9);
      points.add(v);
    }
    return points;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Fundo com gradient radial sutil — mais claro no centro-esquerda.
    final bgRect = Offset.zero & size;
    final radialGradient = RadialGradient(
      center: const Alignment(-0.4, -0.2),
      radius: 1.4,
      colors: [
        Color.lerp(background, surface, 0.4)!,
        background,
        Color.lerp(background, Colors.black, 0.25)!,
      ],
      stops: const [0, 0.55, 1],
    );
    _bgShaderPaint.shader = radialGradient.createShader(bgRect);
    canvas.drawRect(bgRect, _bgShaderPaint);

    _paintGrid(canvas, size);
    _paintTickMarks(canvas, size);
    _paintGhostSparkline(canvas, size);
    _paintGlowDots(canvas, size);
    _paintFadeOverlay(canvas, size);
  }

  /// Grid Bloomberg-style: linhas verticais densas + linhas horizontais
  /// largas. As verticais "deslizam" lentamente pra esquerda — efeito
  /// de fita rolando.
  void _paintGrid(Canvas canvas, Size size) {
    final progress = controller.value;
    final colSpacing = size.width / columnCount;
    final offset = (progress * colSpacing * 2) % colSpacing;

    for (var i = -1; i <= columnCount + 1; i++) {
      final x = i * colSpacing - offset;
      final paint = i % 4 == 0 ? _gridStrongPaint : _gridPaint;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    for (var i = 0; i <= rowCount; i++) {
      final y = i * (size.height / rowCount);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), _gridPaint);
    }
  }

  /// Tick marks pequenos nos cantos das celulas — densidade
  /// cartografica.
  void _paintTickMarks(Canvas canvas, Size size) {
    final colSpacing = size.width / columnCount;
    final rowSpacing = size.height / rowCount;

    for (var i = 0; i <= rowCount; i++) {
      final y = i * rowSpacing;
      for (var j = 0; j <= columnCount; j += 2) {
        final x = j * colSpacing;
        canvas.drawLine(Offset(x - 2, y), Offset(x + 2, y), _tickPaint);
      }
    }
  }

  /// Sparkline "fantasma" — random walk seedado, anima horizontalmente
  /// com o tempo. Da sensacao de mercado vivo no fundo.
  void _paintGhostSparkline(Canvas canvas, Size size) {
    final progress = controller.value;
    final points = _sparkPoints;

    final dx = size.width / _segmentCount;
    final shift = progress * dx * 6; // velocidade do "scroll"
    final centerY = size.height * 0.62;
    final amplitude = size.height * 0.3;

    _sparkPath
      ..reset()
      ..moveTo(-shift, centerY - (points[0] - 0.5) * amplitude);
    for (var i = 1; i < points.length; i++) {
      final x = i * dx - shift;
      // Adiciona oscilacao sutil temporal pra cada ponto se mover um pouco.
      final wobble = math.sin(progress * 2 * math.pi + i) * 2;
      final y = centerY - (points[i] - 0.5) * amplitude + wobble;
      _sparkPath.lineTo(x, y);
    }

    _sparkFillPath
      ..reset()
      ..addPath(_sparkPath, Offset.zero)
      ..lineTo(size.width + 20, size.height)
      ..lineTo(-shift, size.height)
      ..close();

    canvas
      ..drawPath(_sparkFillPath, _sparklineFillPaint)
      ..drawPath(_sparkPath, _sparklineStrokePaint);
  }

  /// Glow dots pulsando — marcadores de preco no eixo direito que
  /// simulam alerts/triggers. Posicoes em alturas distintas.
  void _paintGlowDots(Canvas canvas, Size size) {
    final progress = controller.value;
    final dots = <(double, double, Color, double)>[
      (0.92, 0.32, glowAccent, 0),
      (0.92, 0.58, glowUp, 0.4),
      (0.92, 0.78, glowUp, 0.8),
    ];

    for (final dot in dots) {
      final x = dot.$1 * size.width;
      final y = dot.$2 * size.height;
      final color = dot.$3;
      final phase = dot.$4;
      final pulse = 0.5 + 0.5 * math.sin((progress + phase) * 2 * math.pi);
      final radius = 2.5 + pulse * 1.8;
      final haloRadius = 6 + pulse * 6;

      _glowHaloPaint.color = color.withValues(alpha: 0.18 * pulse);
      _glowCorePaint.color = color;
      canvas
        ..drawCircle(Offset(x, y), haloRadius, _glowHaloPaint)
        ..drawCircle(Offset(x, y), radius, _glowCorePaint);
    }
  }

  /// Overlay de fade lateral — escurece nas bordas pra "ancorar" o
  /// olhar no centro onde o hero card vai ficar.
  void _paintFadeOverlay(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final overlay = LinearGradient(
      colors: [
        background.withValues(alpha: 0.6),
        Colors.transparent,
        background.withValues(alpha: 0.7),
      ],
      stops: const [0, 0.35, 1],
    );
    _overlayShaderPaint.shader = overlay.createShader(rect);
    canvas.drawRect(rect, _overlayShaderPaint);
  }

  @override
  bool shouldRepaint(_MiraHeroBackdropPainter old) {
    return old.background != background ||
        old.surface != surface ||
        old.grid != grid ||
        old.glowUp != glowUp ||
        old.glowAccent != glowAccent ||
        old.line != line ||
        old.mutedLine != mutedLine;
  }
}
