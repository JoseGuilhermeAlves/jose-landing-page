import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Ponto historico de um exercicio — uma semana.
class LoadHistoryPoint {
  const LoadHistoryPoint({
    required this.weekLabel,
    required this.weightKg,
    required this.repsTopSet,
    required this.rpe,
  });

  final String weekLabel;
  final double weightKg;
  final int repsTopSet;
  final double rpe;
}

/// Bar chart dark hairline com 8 semanas de historico de carga
/// + dots de RPE acima de cada barra. Conta uma historia de
/// progressao linear ate intensificacao + deload.
class ExerciseLoadHistoryChart extends StatelessWidget {
  const ExerciseLoadHistoryChart({
    required this.points,
    this.height = 180,
    super.key,
  });

  final List<LoadHistoryPoint> points;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: CustomPaint(painter: _LoadHistoryPainter(points: points)),
    );
  }
}

class _LoadHistoryPainter extends CustomPainter {
  _LoadHistoryPainter({required this.points});

  final List<LoadHistoryPoint> points;

  static final Paint _gridPaint = Paint()
    ..color = const Color(0xFF1F1F28)
    ..strokeWidth = 1;
  static final Paint _barPaint = Paint()
    ..color = const Color(0xFF00D982).withValues(alpha: 0.78);
  static final Paint _barCapPaint = Paint()..color = const Color(0xFF00D982);
  static final Paint _rpePaint = Paint()..style = PaintingStyle.fill;
  static final Paint _connectorPaint = Paint()
    ..color = const Color(0xFF5AC8FA).withValues(alpha: 0.6)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.isEmpty) return;
    const topPad = 24.0;
    const bottomPad = 28.0;
    const leftPad = 28.0;
    const rightPad = 8.0;
    final chartW = size.width - leftPad - rightPad;
    final chartH = size.height - topPad - bottomPad;

    final maxWeight = points
        .map((p) => p.weightKg)
        .reduce((a, b) => a > b ? a : b);
    final minWeight = points
        .map((p) => p.weightKg)
        .reduce((a, b) => a < b ? a : b);
    final span = (maxWeight - minWeight).clamp(1, double.infinity).toDouble();

    // Linhas guia horizontais (4).
    for (var i = 0; i <= 3; i++) {
      final y = topPad + chartH * (i / 3);
      canvas.drawLine(
        Offset(leftPad, y),
        Offset(size.width - rightPad, y),
        _gridPaint,
      );
    }

    // Labels Y (min e max).
    _drawAxisLabel(
      canvas,
      maxWeight.toStringAsFixed(0),
      const Offset(leftPad - 4, topPad - 8),
      anchorRight: true,
    );
    _drawAxisLabel(
      canvas,
      minWeight.toStringAsFixed(0),
      Offset(leftPad - 4, topPad + chartH - 8),
      anchorRight: true,
    );

    // Bars + RPE markers.
    final cellW = chartW / points.length;
    final barW = cellW * 0.5;
    final rpeCenters = <Offset>[];
    for (var i = 0; i < points.length; i++) {
      final p = points[i];
      final cx = leftPad + cellW * (i + 0.5);
      final norm = ((p.weightKg - minWeight) / span).clamp(0, 1).toDouble();
      final barHeight = chartH * (0.15 + norm * 0.85);
      final barRect = Rect.fromLTWH(
        cx - barW / 2,
        topPad + chartH - barHeight,
        barW,
        barHeight,
      );
      canvas
        ..drawRRect(
          RRect.fromRectAndRadius(barRect, const Radius.circular(3)),
          _barPaint,
        )
        // Cap luminoso topo da barra.
        ..drawRect(
          Rect.fromLTWH(cx - barW / 2, barRect.top, barW, 2.5),
          _barCapPaint,
        );

      // X label.
      _drawAxisLabel(
        canvas,
        p.weekLabel,
        Offset(cx, topPad + chartH + 8),
        center: true,
      );

      // RPE marker — circulo colorido topo + label opcional.
      final rpeY = topPad - 10 + (10 - p.rpe.clamp(0, 10)) * 1.4;
      final rpeColor = _rpeColor(p.rpe);
      _rpePaint.color = rpeColor;
      final rpeCenter = Offset(cx, rpeY.clamp(8, topPad - 4).toDouble());
      canvas.drawCircle(rpeCenter, 4, _rpePaint);
      rpeCenters.add(rpeCenter);
    }

    // Conector entre RPE pontos.
    if (rpeCenters.length > 1) {
      final path = Path()..moveTo(rpeCenters.first.dx, rpeCenters.first.dy);
      for (var i = 1; i < rpeCenters.length; i++) {
        path.lineTo(rpeCenters[i].dx, rpeCenters[i].dy);
      }
      canvas.drawPath(path, _connectorPaint);
    }

    // Legenda.
    _drawAxisLabel(
      canvas,
      'RPE',
      Offset(size.width - rightPad, 6),
      anchorRight: true,
    );
    _drawAxisLabel(
      canvas,
      'kg',
      Offset(leftPad - 4, topPad + chartH + 8),
      anchorRight: true,
    );
  }

  Color _rpeColor(double rpe) {
    if (rpe < 7) return const Color(0xFF5AC8FA);
    if (rpe < 8.5) return const Color(0xFFFFB020);
    return const Color(0xFFFF5C5C);
  }

  void _drawAxisLabel(
    Canvas canvas,
    String text,
    Offset pos, {
    bool center = false,
    bool anchorRight = false,
  }) {
    final tp = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: Color(0xFF7E7E8A),
          fontSize: 10,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          fontFamily: FitnessBrand.displayMonoFontFamily,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    var x = pos.dx;
    if (center) x -= tp.width / 2;
    if (anchorRight) x -= tp.width;
    tp.paint(canvas, Offset(x, pos.dy));
  }

  @override
  bool shouldRepaint(_LoadHistoryPainter old) => old.points != points;
}
