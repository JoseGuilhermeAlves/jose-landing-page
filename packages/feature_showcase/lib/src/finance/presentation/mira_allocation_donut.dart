import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/finance/presentation/mira_brand.dart';
import 'package:feature_showcase/src/finance/util/mira_format.dart';
import 'package:flutter/material.dart';

/// Slice individual do donut. `weight` em proporcao [0..1] (a soma de
/// todos os slices deve fechar em 1, mas o painter normaliza por
/// seguranca). `color` ja resolvida — o caller decide a paleta.
class MiraAllocationSlice {
  const MiraAllocationSlice({
    required this.label,
    required this.weight,
    required this.color,
  });

  final String label;
  final double weight;
  final Color color;
}

/// Donut de alocacao do portfolio Mira — anel com slice por ativo,
/// total no centro (R$ grande + label "Patrimonio"), e legenda em
/// duas colunas abaixo. Anel reage com animacao de "preencher" no
/// primeiro frame (cada arc cresce do angulo inicial pra todo o
/// trecho dele em 900ms).
class MiraAllocationDonut extends StatefulWidget {
  const MiraAllocationDonut({
    required this.slices,
    required this.totalCents,
    this.diameter = 220,
    super.key,
  });

  final List<MiraAllocationSlice> slices;
  final int totalCents;
  final double diameter;

  @override
  State<MiraAllocationDonut> createState() => _MiraAllocationDonutState();
}

class _MiraAllocationDonutState extends State<MiraAllocationDonut>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: SizedBox(
            width: widget.diameter,
            height: widget.diameter,
            child: RepaintBoundary(
              child: CustomPaint(
                isComplex: true,
                willChange: true,
                painter: _MiraDonutPainter(
                  slices: widget.slices,
                  totalCents: widget.totalCents,
                  progress: _controller,
                  backgroundColor: colors.surfaceMuted,
                  surfaceColor: colors.surface,
                  textColor: colors.onSurface,
                  mutedColor: colors.onSurfaceMuted,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _Legend(slices: widget.slices),
      ],
    );
  }
}

class _MiraDonutPainter extends CustomPainter {
  _MiraDonutPainter({
    required this.slices,
    required this.totalCents,
    required this.progress,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.textColor,
    required this.mutedColor,
  }) : super(repaint: progress);

  final List<MiraAllocationSlice> slices;
  final int totalCents;
  final Animation<double> progress;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color textColor;
  final Color mutedColor;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    final ringWidth = radius * 0.22;
    final outer = radius;
    final inner = radius - ringWidth;
    final midRadius = (outer + inner) / 2;

    // Trilho de fundo do anel.
    canvas.drawCircle(
      center,
      midRadius,
      Paint()
        ..color = backgroundColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = ringWidth,
    );

    // Soma efetiva pra normalizar (caso o caller passe pesos que nao
    // fecham em 1).
    var totalWeight = 0.0;
    for (final s in slices) {
      totalWeight += s.weight;
    }
    if (totalWeight <= 0) return;

    final rect = Rect.fromCircle(center: center, radius: midRadius);
    var startAngle = -math.pi / 2;
    final p = progress.value.clamp(0.0, 1.0);

    // Folga de ~2deg entre slices pra criar respiro visual em vez de
    // costura dura. Round caps suavizam as pontas. So aplicamos a folga
    // quando ha mais de um slice (donut de 1 ativo continua um anel
    // fechado).
    final gap = slices.length > 1 ? 2 * math.pi / 180 : 0.0;

    for (final slice in slices) {
      final sliceSweep = (slice.weight / totalWeight) * 2 * math.pi;
      // Tira a folga do sweep visivel, deixando metade de cada lado, e
      // nunca deixa o trecho ficar negativo em slices muito finos.
      final visibleSweep = math.max(0.0, sliceSweep - gap);
      final sweep = visibleSweep * p;
      if (sweep <= 0) {
        startAngle += sliceSweep;
        continue;
      }
      final arcStart = startAngle + gap / 2;

      // Separador escuro por baixo — leve sombra interna que da
      // profundidade e marca a fronteira entre slices.
      canvas.drawArc(
        rect,
        arcStart,
        sweep,
        false,
        Paint()
          ..color = const Color(0x33000000)
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth
          ..strokeCap = StrokeCap.round,
      );

      canvas.drawArc(
        rect,
        arcStart,
        sweep,
        false,
        Paint()
          ..color = slice.color
          ..style = PaintingStyle.stroke
          ..strokeWidth = ringWidth - 1.5
          ..strokeCap = StrokeCap.round,
      );
      startAngle += sliceSweep;
    }

    _paintCenter(canvas, center, inner);
  }

  void _paintCenter(Canvas canvas, Offset center, double inner) {
    final labelTp = TextPainter(
      text: TextSpan(
        text: 'PATRIMONIO',
        style: TextStyle(
          color: mutedColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.4,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: inner * 2 * 0.8);

    final valueTp = TextPainter(
      text: TextSpan(
        text: formatMiraTotal(totalCents),
        style: TextStyle(
          color: textColor,
          fontSize: 22,
          fontWeight: FontWeight.w800,
          fontFamily: MiraBrand.monoFontFamily,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: inner * 2 * 0.9);

    final totalHeight = labelTp.size.height + 4 + valueTp.size.height;
    final top = center.dy - totalHeight / 2;
    labelTp.paint(canvas, Offset(center.dx - labelTp.size.width / 2, top));
    valueTp.paint(
      canvas,
      Offset(center.dx - valueTp.size.width / 2, top + labelTp.size.height + 4),
    );
  }

  @override
  bool shouldRepaint(_MiraDonutPainter old) {
    return !identical(old.slices, slices) ||
        old.totalCents != totalCents ||
        old.backgroundColor != backgroundColor ||
        old.surfaceColor != surfaceColor ||
        old.textColor != textColor ||
        old.mutedColor != mutedColor;
  }
}

class _Legend extends StatelessWidget {
  const _Legend({required this.slices});

  final List<MiraAllocationSlice> slices;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    return Wrap(
      spacing: AppSpacing.lg,
      runSpacing: AppSpacing.sm,
      children: [
        for (final slice in slices)
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: slice.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 6),
              Text(
                slice.label,
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                '${(slice.weight * 100).toStringAsFixed(1).replaceAll('.', ',')}%',
                style: textTheme.bodySmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontFamily: MiraBrand.monoFontFamily,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
