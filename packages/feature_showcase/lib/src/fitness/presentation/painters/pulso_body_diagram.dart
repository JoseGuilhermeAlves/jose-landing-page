import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_recovery.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Diagrama anatomico simplificado (vista frontal). Cada regiao e
/// pintada na cor da banda de recovery do grupo muscular
/// correspondente. Tap em uma regiao chama [onTap] com o
/// [MuscleGroup].
class PulsoBodyDiagram extends StatelessWidget {
  const PulsoBodyDiagram({
    required this.recovery,
    this.onTap,
    this.aspectRatio = 0.55,
    super.key,
  });

  final MuscleRecovery recovery;
  final void Function(MuscleGroup group)? onTap;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: LayoutBuilder(
        builder: (context, c) {
          return GestureDetector(
            onTapUp: onTap == null
                ? null
                : (details) {
                    final hit = _hitTest(details.localPosition, c.biggest);
                    if (hit != null) onTap!(hit);
                  },
            child: CustomPaint(
              painter: _BodyDiagramPainter(recovery: recovery),
              size: c.biggest,
            ),
          );
        },
      ),
    );
  }

  /// Mapeia coordenada local pra grupo muscular. Coordenadas
  /// normalizadas (0..1) em ambos os eixos.
  MuscleGroup? _hitTest(Offset local, Size size) {
    final x = local.dx / size.width;
    final y = local.dy / size.height;
    if (y < 0.1) return null;
    if (y < 0.18) return MuscleGroup.shoulders;
    if (y < 0.32) return MuscleGroup.chest;
    if (y < 0.42) {
      return (x < 0.3 || x > 0.7) ? MuscleGroup.biceps : MuscleGroup.core;
    }
    if (y < 0.55) {
      return (x < 0.3 || x > 0.7) ? MuscleGroup.forearms : MuscleGroup.core;
    }
    if (y < 0.72) return MuscleGroup.quads;
    if (y < 0.88) return MuscleGroup.calves;
    return null;
  }
}

class _BodyDiagramPainter extends CustomPainter {
  _BodyDiagramPainter({required this.recovery});

  final MuscleRecovery recovery;

  static final Paint _outlinePaint = Paint()
    ..color = const Color(0xFF26262F)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.2;
  static final Paint _fillPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _bgPaint = Paint()..color = const Color(0xFF111116);

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    // Background sutil pra destacar silhueta sem peso.
    final bgRect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(12),
    );
    canvas.drawRRect(bgRect, _bgPaint);

    // Cabeca.
    final headRect = Rect.fromCircle(
      center: Offset(w * 0.5, h * 0.075),
      radius: h * 0.058,
    );
    _fillPaint.color = const Color(0xFF1A1A22);
    canvas.drawOval(headRect, _fillPaint);
    canvas.drawOval(headRect, _outlinePaint);

    // Ombros.
    final shoulders = Path()
      ..moveTo(w * 0.28, h * 0.16)
      ..quadraticBezierTo(w * 0.5, h * 0.13, w * 0.72, h * 0.16)
      ..lineTo(w * 0.78, h * 0.22)
      ..lineTo(w * 0.22, h * 0.22)
      ..close();
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.shoulders),
    ).withValues(alpha: 0.6);
    canvas.drawPath(shoulders, _fillPaint);
    canvas.drawPath(shoulders, _outlinePaint);

    // Peito.
    final chest = Path()
      ..moveTo(w * 0.26, h * 0.22)
      ..lineTo(w * 0.74, h * 0.22)
      ..lineTo(w * 0.72, h * 0.36)
      ..lineTo(w * 0.28, h * 0.36)
      ..close();
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.chest),
    ).withValues(alpha: 0.6);
    canvas.drawPath(chest, _fillPaint);
    canvas.drawPath(chest, _outlinePaint);

    // Linha entre peitorais.
    canvas.drawLine(
      Offset(w * 0.5, h * 0.22),
      Offset(w * 0.5, h * 0.36),
      _outlinePaint,
    );

    // Bracos sup (biceps).
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.biceps),
    ).withValues(alpha: 0.6);
    final leftBicep = Path()
      ..moveTo(w * 0.22, h * 0.22)
      ..lineTo(w * 0.13, h * 0.30)
      ..lineTo(w * 0.13, h * 0.42)
      ..lineTo(w * 0.22, h * 0.42)
      ..close();
    final rightBicep = Path()
      ..moveTo(w * 0.78, h * 0.22)
      ..lineTo(w * 0.87, h * 0.30)
      ..lineTo(w * 0.87, h * 0.42)
      ..lineTo(w * 0.78, h * 0.42)
      ..close();
    canvas.drawPath(leftBicep, _fillPaint);
    canvas.drawPath(rightBicep, _fillPaint);
    canvas.drawPath(leftBicep, _outlinePaint);
    canvas.drawPath(rightBicep, _outlinePaint);

    // Bracos inf (forearms).
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.forearms),
    ).withValues(alpha: 0.6);
    final leftFore = Path()
      ..moveTo(w * 0.13, h * 0.42)
      ..lineTo(w * 0.10, h * 0.55)
      ..lineTo(w * 0.20, h * 0.55)
      ..lineTo(w * 0.22, h * 0.42)
      ..close();
    final rightFore = Path()
      ..moveTo(w * 0.87, h * 0.42)
      ..lineTo(w * 0.90, h * 0.55)
      ..lineTo(w * 0.80, h * 0.55)
      ..lineTo(w * 0.78, h * 0.42)
      ..close();
    canvas.drawPath(leftFore, _fillPaint);
    canvas.drawPath(rightFore, _fillPaint);
    canvas.drawPath(leftFore, _outlinePaint);
    canvas.drawPath(rightFore, _outlinePaint);

    // Core.
    final core = Path()
      ..moveTo(w * 0.28, h * 0.36)
      ..lineTo(w * 0.72, h * 0.36)
      ..lineTo(w * 0.66, h * 0.55)
      ..lineTo(w * 0.34, h * 0.55)
      ..close();
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.core),
    ).withValues(alpha: 0.6);
    canvas.drawPath(core, _fillPaint);
    canvas.drawPath(core, _outlinePaint);

    // Linha central do core.
    canvas.drawLine(
      Offset(w * 0.5, h * 0.36),
      Offset(w * 0.5, h * 0.55),
      _outlinePaint,
    );

    // Quads.
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.quads),
    ).withValues(alpha: 0.6);
    final leftQuad = Path()
      ..moveTo(w * 0.34, h * 0.55)
      ..lineTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.46, h * 0.72)
      ..lineTo(w * 0.48, h * 0.55)
      ..close();
    final rightQuad = Path()
      ..moveTo(w * 0.66, h * 0.55)
      ..lineTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.54, h * 0.72)
      ..lineTo(w * 0.52, h * 0.55)
      ..close();
    canvas.drawPath(leftQuad, _fillPaint);
    canvas.drawPath(rightQuad, _fillPaint);
    canvas.drawPath(leftQuad, _outlinePaint);
    canvas.drawPath(rightQuad, _outlinePaint);

    // Calves.
    _fillPaint.color = FitnessBrand.recoveryColor(
      recovery.scoreFor(MuscleGroup.calves),
    ).withValues(alpha: 0.6);
    final leftCalf = Path()
      ..moveTo(w * 0.30, h * 0.72)
      ..lineTo(w * 0.30, h * 0.88)
      ..lineTo(w * 0.46, h * 0.88)
      ..lineTo(w * 0.46, h * 0.72)
      ..close();
    final rightCalf = Path()
      ..moveTo(w * 0.70, h * 0.72)
      ..lineTo(w * 0.70, h * 0.88)
      ..lineTo(w * 0.54, h * 0.88)
      ..lineTo(w * 0.54, h * 0.72)
      ..close();
    canvas.drawPath(leftCalf, _fillPaint);
    canvas.drawPath(rightCalf, _fillPaint);
    canvas.drawPath(leftCalf, _outlinePaint);
    canvas.drawPath(rightCalf, _outlinePaint);

    // Pes (sem cor — so silhueta).
    _fillPaint.color = const Color(0xFF1A1A22);
    final leftFoot = Rect.fromLTWH(w * 0.30, h * 0.88, w * 0.16, h * 0.04);
    final rightFoot = Rect.fromLTWH(w * 0.54, h * 0.88, w * 0.16, h * 0.04);
    canvas.drawRRect(
      RRect.fromRectAndRadius(leftFoot, const Radius.circular(4)),
      _fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rightFoot, const Radius.circular(4)),
      _fillPaint,
    );
  }

  @override
  bool shouldRepaint(_BodyDiagramPainter old) => old.recovery != recovery;
}
