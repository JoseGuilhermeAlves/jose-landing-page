import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/delivery/domain/delivery_status.dart';
import 'package:flutter/material.dart';

/// Timeline vertical com 4 passos representando o ciclo do pedido —
/// "Recebido", "Em preparo", "Saiu pra entrega", "Entregue". Cada
/// passo combina um circulo desenhado em painter (com check pra passos
/// completos) e um conector vertical pra continuidade visual.
class AuroraStatusTimeline extends StatelessWidget {
  const AuroraStatusTimeline({required this.activeStatus, super.key});

  final DeliveryStatus activeStatus;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    const all = DeliveryStatus.values;
    final activeIndex = all.indexOf(activeStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < all.length; i++)
          _Step(
            status: all[i],
            description: _descriptionFor(all[i]),
            isComplete: i < activeIndex,
            isCurrent: i == activeIndex,
            isLast: i == all.length - 1,
            colors: colors,
            textTheme: textTheme,
          ),
      ],
    );
  }

  static String _descriptionFor(DeliveryStatus s) {
    return switch (s) {
      DeliveryStatus.received => 'Pedido recebido pela banca.',
      DeliveryStatus.preparing => 'Banca separando e embalando.',
      DeliveryStatus.outForDelivery => 'A caminho do seu endereco.',
      DeliveryStatus.delivered => 'Entregue. Bom proveito.',
    };
  }
}

class _Step extends StatelessWidget {
  const _Step({
    required this.status,
    required this.description,
    required this.isComplete,
    required this.isCurrent,
    required this.isLast,
    required this.colors,
    required this.textTheme,
  });

  final DeliveryStatus status;
  final String description;
  final bool isComplete;
  final bool isCurrent;
  final bool isLast;
  final AppColorScheme colors;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    final activeColor = isComplete || isCurrent
        ? colors.primary
        : colors.onSurfaceMuted.withValues(alpha: 0.4);
    final titleColor = isComplete || isCurrent
        ? colors.onSurface
        : colors.onSurfaceMuted;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              RepaintBoundary(
                child: CustomPaint(
                  size: const Size(28, 28),
                  painter: _StepDotPainter(
                    fillColor: activeColor,
                    isComplete: isComplete,
                    isCurrent: isCurrent,
                    onPrimary: colors.onPrimary,
                  ),
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: isComplete ? colors.primary : colors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    status.label,
                    style: textTheme.titleSmall?.copyWith(
                      color: titleColor,
                      fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: textTheme.bodySmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDotPainter extends CustomPainter {
  _StepDotPainter({
    required this.fillColor,
    required this.isComplete,
    required this.isCurrent,
    required this.onPrimary,
  });

  final Color fillColor;
  final bool isComplete;
  final bool isCurrent;
  final Color onPrimary;

  late final Paint _fillPaint = Paint()
    ..color = fillColor
    ..style = PaintingStyle.fill;

  late final Paint _haloPaint = Paint()
    ..color = fillColor.withValues(alpha: 0.20)
    ..style = PaintingStyle.fill;

  late final Paint _checkPaint = Paint()
    ..color = onPrimary
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.2
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = (size.shortestSide / 2) - 3;

    if (isCurrent) {
      canvas.drawCircle(Offset(cx, cy), r + 4, _haloPaint);
    }
    canvas.drawCircle(Offset(cx, cy), r, _fillPaint);

    if (isComplete) {
      // Check curto no centro.
      canvas
        ..drawLine(
          Offset(cx - r * 0.4, cy + r * 0.05),
          Offset(cx - r * 0.05, cy + r * 0.35),
          _checkPaint,
        )
        ..drawLine(
          Offset(cx - r * 0.05, cy + r * 0.35),
          Offset(cx + r * 0.45, cy - r * 0.30),
          _checkPaint,
        );
    } else if (isCurrent) {
      // Ponto branco menor pra indicar "estamos aqui".
      canvas.drawCircle(
        Offset(cx, cy),
        r * 0.35,
        Paint()
          ..color = onPrimary
          ..style = PaintingStyle.fill,
      );
    }
  }

  @override
  bool shouldRepaint(_StepDotPainter old) {
    return old.fillColor != fillColor ||
        old.isComplete != isComplete ||
        old.isCurrent != isCurrent ||
        old.onPrimary != onPrimary;
  }
}
