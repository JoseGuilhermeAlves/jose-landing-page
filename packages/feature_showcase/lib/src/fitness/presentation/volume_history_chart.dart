import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Historico mockado das 7 semanas anteriores. A semana atual entra
/// como ponto extra calculado em runtime a partir do `FitnessState`.
///
/// Valores em kg, escolhidos pra simular um atleta que vem subindo o
/// volume ao longo de dois meses (com uma deload na metade) — apenas
/// uma narrativa visual; sem semantica de produto.
abstract final class VolumeHistoryMock {
  /// Da semana mais antiga (`s-7`) ate a anterior (`s-1`). 7 entradas.
  static const List<double> priorWeeks = <double>[
    18500,
    19800,
    21200,
    20400,
    22600,
    23500,
    24100,
  ];
}

/// Card de evolucao do volume nas ultimas 8 semanas — encerra a aba
/// Progresso com o "tracker com graficos" prometido pelo PROJECT.md
/// §4.3. Stateful pra animar o draw-in uma unica vez no mount;
/// rebuilds disparados por mudanca de state nao reiniciam a animacao.
class VolumeHistoryChart extends StatefulWidget {
  const VolumeHistoryChart({required this.currentVolumeKg, super.key});

  /// Volume da semana corrente em kg. Vem do `FitnessState`. Pode ser
  /// zero quando o usuario ainda nao marcou nenhum set.
  final double currentVolumeKg;

  @override
  State<VolumeHistoryChart> createState() => _VolumeHistoryChartState();
}

class _VolumeHistoryChartState extends State<VolumeHistoryChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDuration.deliberate,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.standard,
  );

  @override
  void initState() {
    super.initState();
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    final values = <double>[
      ...VolumeHistoryMock.priorWeeks,
      widget.currentVolumeKg,
    ];
    final maxValue = values.reduce(math.max);
    final lastWeek = VolumeHistoryMock.priorWeeks.last;
    final inProgress = widget.currentVolumeKg < lastWeek * 0.5;
    final deltaPct = lastWeek == 0
        ? 0.0
        : ((widget.currentVolumeKg - lastWeek) / lastWeek) * 100;

    return Container(
      key: const Key('fitness-volume-history-card'),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Volume — 8 semanas',
                style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
              ),
              const Spacer(),
              if (inProgress)
                _Badge(
                  label: 'em andamento',
                  color: colors.onSurfaceMuted,
                  background: colors.surfaceMuted,
                  textTheme: textTheme,
                )
              else
                _Badge(
                  label: _formatDelta(deltaPct),
                  color: deltaPct >= 0 ? colors.primary : colors.warning,
                  background: (deltaPct >= 0 ? colors.primary : colors.warning)
                      .withValues(alpha: 0.16),
                  textTheme: textTheme,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _formatVolume(widget.currentVolumeKg),
            style: textTheme.headlineMedium?.copyWith(
              color: colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.6,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            height: 140,
            child: AnimatedBuilder(
              animation: _progress,
              builder: (context, _) {
                return CustomPaint(
                  size: Size.infinite,
                  painter: _VolumeChartPainter(
                    values: values,
                    maxValue: maxValue,
                    progress: _progress.value,
                    lineColor: colors.primary,
                    fillTop: colors.primary.withValues(alpha: 0.28),
                    fillBottom: colors.primary.withValues(alpha: 0),
                    dotColor: colors.primary.withValues(alpha: 0.55),
                    currentDotColor: colors.primary,
                    currentDotRing: colors.background,
                    haloColor: colors.primary.withValues(alpha: 0.22),
                    labelStyle: textTheme.labelSmall?.copyWith(
                      color: colors.onSurfaceMuted,
                      letterSpacing: 0.4,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _formatVolume(double kg) {
    if (kg <= 0) return '0 kg';
    if (kg >= 1000) return '${(kg / 1000).toStringAsFixed(1)} t';
    return '${kg.round()} kg';
  }

  static String _formatDelta(double pct) {
    final sign = pct >= 0 ? '+' : '';
    return '$sign${pct.toStringAsFixed(1)}% vs s-1';
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.label,
    required this.color,
    required this.background,
    required this.textTheme,
  });

  final String label;
  final Color color;
  final Color background;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Text(
        label,
        style: textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.4,
        ),
      ),
    );
  }
}

class _VolumeChartPainter extends CustomPainter {
  _VolumeChartPainter({
    required this.values,
    required this.maxValue,
    required this.progress,
    required this.lineColor,
    required this.fillTop,
    required this.fillBottom,
    required this.dotColor,
    required this.currentDotColor,
    required this.currentDotRing,
    required this.haloColor,
    required this.labelStyle,
  });

  static const List<String> _xLabels = <String>[
    's-7',
    's-6',
    's-5',
    's-4',
    's-3',
    's-2',
    's-1',
    'atual',
  ];

  static const double _labelStripHeight = 18;
  static const double _topPadding = 10;
  static const double _horizontalInset = 6;
  static const double _dotRadius = 3;
  static const double _currentDotRadius = 5.5;

  final List<double> values;
  final double maxValue;
  final double progress;
  final Color lineColor;
  final Color fillTop;
  final Color fillBottom;
  final Color dotColor;
  final Color currentDotColor;
  final Color currentDotRing;
  final Color haloColor;
  final TextStyle? labelStyle;

  // Paints cacheados como campos — instanciados uma unica vez por
  // construcao do painter; nao recriar em paint() (regra do projeto).
  late final Paint _linePaint = Paint()
    ..color = lineColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 2.4
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round;

  late final Paint _dotPaint = Paint()
    ..color = dotColor
    ..style = PaintingStyle.fill;

  late final Paint _currentDotPaint = Paint()
    ..color = currentDotColor
    ..style = PaintingStyle.fill;

  late final Paint _currentDotRingPaint = Paint()
    ..color = currentDotRing
    ..style = PaintingStyle.fill;

  late final Paint _haloPaint = Paint()
    ..color = haloColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final chartHeight = size.height - _labelStripHeight - _topPadding;
    if (chartHeight <= 0) return;

    final chartWidth = size.width - _horizontalInset * 2;
    final stepX = chartWidth / (values.length - 1);
    // Reserva espaco vertical pro ponto atual nao colidir com a borda.
    final usableHeight = chartHeight - _currentDotRadius * 2;
    final scale = maxValue <= 0 ? 0.0 : usableHeight / maxValue;

    final points = <Offset>[];
    for (var i = 0; i < values.length; i++) {
      final x = _horizontalInset + stepX * i;
      final y = _topPadding + usableHeight - (values[i] * scale);
      points.add(Offset(x, y));
    }

    // Curva suave via Catmull-Rom convertida em cubic Bezier.
    final linePath = _smoothPath(points);
    final fillPath = Path.from(linePath)
      ..lineTo(points.last.dx, _topPadding + chartHeight)
      ..lineTo(points.first.dx, _topPadding + chartHeight)
      ..close();

    final visibleEndX = _horizontalInset + chartWidth * progress;

    // Fill gradient — recriado a cada paint porque depende do
    // tamanho real do canvas, mas o shader em si nao guarda estado
    // alem dos parametros; barato no contexto do demo.
    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [fillTop, fillBottom],
      ).createShader(Rect.fromLTWH(0, _topPadding, size.width, chartHeight));

    canvas
      ..save()
      ..clipRect(Rect.fromLTWH(0, 0, visibleEndX, size.height))
      ..drawPath(fillPath, fillPaint)
      ..drawPath(linePath, _linePaint)
      ..restore();

    // Dots — pula os ainda nao revelados pela animacao.
    for (var i = 0; i < points.length; i++) {
      if (points[i].dx > visibleEndX + 0.5) break;
      final isCurrent = i == points.length - 1;
      if (isCurrent) {
        canvas
          ..drawCircle(points[i], _currentDotRadius + 5, _haloPaint)
          ..drawCircle(points[i], _currentDotRadius + 1.5, _currentDotRingPaint)
          ..drawCircle(points[i], _currentDotRadius, _currentDotPaint);
      } else {
        canvas.drawCircle(points[i], _dotRadius, _dotPaint);
      }
    }

    // Labels do eixo x — uma string por ponto, centralizada.
    final style = labelStyle ?? const TextStyle(fontSize: 10);
    for (var i = 0; i < points.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(text: _xLabels[i], style: style),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final dx = points[i].dx - textPainter.width / 2;
      final dy = _topPadding + chartHeight + 4;
      textPainter.paint(canvas, Offset(dx, dy));
    }
  }

  /// Converte uma lista de pontos em um path com cubic beziers
  /// suavizando os "bicos" — formula classica de Catmull-Rom.
  static Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i < points.length - 2 ? points[i + 2] : p2;

      final cp1 = Offset(
        p1.dx + (p2.dx - p0.dx) / 6,
        p1.dy + (p2.dy - p0.dy) / 6,
      );
      final cp2 = Offset(
        p2.dx - (p3.dx - p1.dx) / 6,
        p2.dy - (p3.dy - p1.dy) / 6,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p2.dx, p2.dy);
    }
    return path;
  }

  @override
  bool shouldRepaint(_VolumeChartPainter old) {
    return old.progress != progress ||
        old.maxValue != maxValue ||
        !listEquals(old.values, values) ||
        old.lineColor != lineColor;
  }

  static bool listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
