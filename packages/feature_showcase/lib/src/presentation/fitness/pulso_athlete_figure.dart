import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Ilustracao de atleta estilizada em pose de levantamento — silhueta
/// geometrica composta de circulos (cabeca, articulacoes) e capsulas
/// (membros). Usada no card "treino do dia" da home como hero visual
/// que reforca a tematica fitness.
///
/// Discreta animacao de "respiracao" (escala +-2% em 3s) pra nao
/// parecer estatica. Performance: anima com `Ticker` em loop, mas o
/// painter tem `shouldRepaint` curto e vive em `RepaintBoundary` no
/// caller.
class PulsoAthleteFigure extends StatefulWidget {
  const PulsoAthleteFigure({this.height = 140, this.color, super.key});

  /// Altura do canvas. Largura sai do aspectRatio (~0.85).
  final double height;

  /// Override de cor primaria. Quando null, usa `context.colors.primary`.
  final Color? color;

  @override
  State<PulsoAthleteFigure> createState() => _PulsoAthleteFigureState();
}

class _PulsoAthleteFigureState extends State<PulsoAthleteFigure>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final figureColor = widget.color ?? colors.primary;
    return RepaintBoundary(
      child: SizedBox(
        key: const Key('pulso-athlete-figure'),
        height: widget.height,
        child: AspectRatio(
          aspectRatio: 0.85,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              // "Respiracao": leve scale sinusoidal em torno de 1.
              final scale =
                  1.0 + math.sin(_controller.value * 2 * math.pi) * 0.02;
              return Transform.scale(
                scale: scale,
                child: CustomPaint(
                  painter: _PulsoAthleteFigurePainter(
                    bodyColor: figureColor,
                    accentColor: figureColor.withValues(alpha: 0.4),
                    barColor: colors.accent,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PulsoAthleteFigurePainter extends CustomPainter {
  _PulsoAthleteFigurePainter({
    required this.bodyColor,
    required this.accentColor,
    required this.barColor,
  });

  final Color bodyColor;
  final Color accentColor;
  final Color barColor;

  late final Paint _bodyPaint = Paint()
    ..color = bodyColor
    ..style = PaintingStyle.fill;

  late final Paint _barPaint = Paint()
    ..color = barColor
    ..style = PaintingStyle.fill;

  late final Paint _limbPaint = Paint()
    ..color = bodyColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 10
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  // Cacheado pra linhas de movimento; strokeWidth e setado em paint()
  // baseado no scale real do canvas.
  late final Paint _motionPaint = Paint()
    ..color = accentColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final scale = size.height;
    final cx = size.width / 2;
    Offset p(double x, double y) => Offset(cx + x * scale, y * scale);

    final strokeWidth = scale * 0.07;
    _limbPaint.strokeWidth = strokeWidth;

    // Pose: agachamento com barra elevada acima da cabeca (deadlift
    // final / overhead press hibrido). Levemente assimetrica pra dar
    // sensacao de movimento real.

    // Linhas de movimento atras da figura — 3 arcos suaves.
    _paintMotionLines(canvas, p, scale);

    // Pernas — duas linhas espessas formando "agachamento".
    canvas
      ..drawLine(p(-0.08, 0.95), p(-0.10, 0.65), _limbPaint) // canela esq
      ..drawLine(p(-0.10, 0.65), p(-0.04, 0.45), _limbPaint) // coxa esq
      ..drawLine(p(0.08, 0.95), p(0.10, 0.65), _limbPaint) // canela dir
      ..drawLine(p(0.10, 0.65), p(0.04, 0.45), _limbPaint); // coxa dir

    // Torso — capsula vertical mais grossa. Cabeca e bracos no mesmo
    // cascade pra evitar repeticao do receiver `canvas`.
    final torsoRect = Rect.fromCenter(
      center: p(0, 0.32),
      width: scale * 0.18,
      height: scale * 0.32,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(torsoRect, Radius.circular(scale * 0.06)),
        _bodyPaint,
      )
      // Cabeca — circulo no topo.
      ..drawCircle(p(0, 0.12), scale * 0.07, _bodyPaint)
      // Bracos elevados — sobem ate a barra.
      ..drawLine(p(-0.07, 0.20), p(-0.15, 0.05), _limbPaint)
      ..drawLine(p(0.07, 0.20), p(0.15, 0.05), _limbPaint);

    // Barra acima da cabeca — retangulo horizontal com pesos nas pontas.
    final barRect = Rect.fromCenter(
      center: p(0, 0.05),
      width: scale * 0.50,
      height: scale * 0.03,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(barRect, Radius.circular(scale * 0.01)),
      _barPaint,
    );

    // Pesos nas pontas da barra — capsulas verticais.
    final leftWeight = Rect.fromCenter(
      center: p(-0.22, 0.05),
      width: scale * 0.07,
      height: scale * 0.13,
    );
    final rightWeight = Rect.fromCenter(
      center: p(0.22, 0.05),
      width: scale * 0.07,
      height: scale * 0.13,
    );
    canvas
      ..drawRRect(
        RRect.fromRectAndRadius(leftWeight, Radius.circular(scale * 0.02)),
        _barPaint,
      )
      ..drawRRect(
        RRect.fromRectAndRadius(rightWeight, Radius.circular(scale * 0.02)),
        _barPaint,
      );
  }

  void _paintMotionLines(
    Canvas canvas,
    Offset Function(double x, double y) p,
    double scale,
  ) {
    _motionPaint.strokeWidth = scale * 0.015;
    canvas
      ..drawLine(p(-0.40, 0.30), p(-0.30, 0.30), _motionPaint)
      ..drawLine(p(-0.42, 0.42), p(-0.34, 0.42), _motionPaint)
      ..drawLine(p(0.30, 0.30), p(0.40, 0.30), _motionPaint)
      ..drawLine(p(0.34, 0.42), p(0.42, 0.42), _motionPaint);
  }

  @override
  bool shouldRepaint(_PulsoAthleteFigurePainter old) {
    return old.bodyColor != bodyColor ||
        old.accentColor != accentColor ||
        old.barColor != barColor;
  }
}
