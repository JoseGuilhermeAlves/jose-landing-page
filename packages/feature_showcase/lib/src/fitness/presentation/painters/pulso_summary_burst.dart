import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Selo radial animado do cabecalho do resumo pos-treino: anel que
/// cresce com easing, raios irradiando e check no centro. Anima uma vez
/// na entrada da tela. Recebe o [Listenable] direto via
/// `super(repaint:)` pra pular build/layout a cada tick (regra de
/// performance dos painters do projeto).
class PulsoSummaryBurst extends StatelessWidget {
  const PulsoSummaryBurst({
    required this.color,
    this.progress,
    this.diameter = 96,
    super.key,
  });

  /// Cor base do selo (tipicamente o verde de recovery/primary).
  final Color color;

  /// Animacao 0..1. Quando null, o selo aparece estatico em 100% —
  /// usado no recap read-only do historico.
  final Animation<double>? progress;

  final double diameter;

  @override
  Widget build(BuildContext context) {
    final anim = progress;
    return SizedBox(
      width: diameter,
      height: diameter,
      child: CustomPaint(
        painter: _SummaryBurstPainter(
          color: color,
          progress: anim,
          staticValue: anim == null ? 1 : 0,
        ),
        size: Size.square(diameter),
      ),
    );
  }
}

class _SummaryBurstPainter extends CustomPainter {
  _SummaryBurstPainter({
    required this.color,
    required this.staticValue,
    this.progress,
  }) : super(repaint: progress);

  final Color color;
  final Animation<double>? progress;

  /// Valor fixo usado quando nao ha animacao (recap).
  final double staticValue;

  // Paints reutilizados — nenhum alocado dentro de paint().
  final Paint _ringPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _rayPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..isAntiAlias = true;
  final Paint _checkPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;
  final Paint _glowPaint = Paint()
    ..style = PaintingStyle.fill
    ..isAntiAlias = true;

  static const int _rayCount = 12;

  double get _value => progress?.value ?? staticValue;

  @override
  void paint(Canvas canvas, Size size) {
    final t = Curves.easeOutBack.transform(_value.clamp(0, 1).toDouble());
    final tLinear = _value.clamp(0.0, 1.0);
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;

    // Glow de fundo.
    _glowPaint.color = color.withValues(alpha: 0.12 * tLinear);
    canvas.drawCircle(center, radius * 0.9 * t, _glowPaint);

    // Anel principal crescendo.
    _ringPaint
      ..strokeWidth = radius * 0.08
      ..color = color.withValues(alpha: 0.9);
    canvas.drawCircle(center, radius * 0.62 * t, _ringPaint);

    // Raios irradiando — aparecem na segunda metade da animacao.
    final rayT = ((tLinear - 0.4) / 0.6).clamp(0.0, 1.0);
    _rayPaint
      ..strokeWidth = radius * 0.045
      ..color = color.withValues(alpha: 0.5 * rayT);
    for (var i = 0; i < _rayCount; i++) {
      final angle = (i / _rayCount) * math.pi * 2;
      final inner = radius * 0.72;
      final outer = radius * (0.78 + 0.16 * rayT);
      final dir = Offset(math.cos(angle), math.sin(angle));
      canvas.drawLine(center + dir * inner, center + dir * outer, _rayPaint);
    }

    // Check no centro — desenhado por ultimo, cresce de 30% a 100%.
    final checkT = ((tLinear - 0.3) / 0.7).clamp(0.0, 1.0);
    if (checkT > 0) {
      final r = radius * 0.62 * t;
      _checkPaint
        ..strokeWidth = radius * 0.07
        ..color = color;
      final p1 = center + Offset(-r * 0.34, r * 0.02);
      final p2 = center + Offset(-r * 0.08, r * 0.28);
      final p3 = center + Offset(r * 0.36, r * -0.26);
      final path = Path()..moveTo(p1.dx, p1.dy);
      // Primeira perna do check ate 50% do progresso, segunda depois.
      if (checkT <= 0.5) {
        final f = checkT / 0.5;
        path.lineTo(
          p1.dx + (p2.dx - p1.dx) * f,
          p1.dy + (p2.dy - p1.dy) * f,
        );
      } else {
        final f = (checkT - 0.5) / 0.5;
        path
          ..lineTo(p2.dx, p2.dy)
          ..lineTo(
            p2.dx + (p3.dx - p2.dx) * f,
            p2.dy + (p3.dy - p2.dy) * f,
          );
      }
      canvas.drawPath(path, _checkPaint);
    }
  }

  @override
  bool shouldRepaint(_SummaryBurstPainter old) =>
      old.color != color ||
      old.staticValue != staticValue ||
      old.progress != progress;
}
