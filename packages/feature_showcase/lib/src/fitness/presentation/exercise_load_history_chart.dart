import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';

/// Grafico de barras estilizado com a "progressao de carga" mockada
/// das ultimas 8 semanas pra um exercicio especifico. A semana atual
/// e destacada com cor primary cheia + halo; as anteriores ficam em
/// alpha baixo. O valor exato em kg aparece em label flutuante sobre
/// a barra atual.
///
/// Em produto real os pontos viriam de um historico persistido por
/// `(exerciseId, week)`. Aqui geramos deterministicamente a partir do
/// `seed` (hash do exerciseId) pra que cada exercicio tenha sua
/// curva propria mas estavel entre rebuilds.
class ExerciseLoadHistoryChart extends StatefulWidget {
  const ExerciseLoadHistoryChart({
    required this.currentWeightKg,
    required this.seed,
    this.height = 140,
    super.key,
  });

  /// Carga atual em kg (do `WorkoutExercise.weightKg`). E o ponto mais
  /// a direita do grafico, sempre destacado.
  final double currentWeightKg;

  /// Determina o "passado" mockado — exercicios diferentes recebem
  /// historicos diferentes mas reprodutiveis.
  final int seed;

  final double height;

  @override
  State<ExerciseLoadHistoryChart> createState() =>
      _ExerciseLoadHistoryChartState();
}

class _ExerciseLoadHistoryChartState extends State<ExerciseLoadHistoryChart>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: AppDuration.deliberate,
  );
  late final Animation<double> _progress = CurvedAnimation(
    parent: _controller,
    curve: AppCurves.standard,
  );

  late final List<double> _history = _buildHistory(
    seed: widget.seed,
    current: widget.currentWeightKg,
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

  /// Gera 7 valores passados + o atual. Curva: tendencia de subida com
  /// uma "deload" no meio (semana mais leve) — narrativa comum.
  /// Variacao por seed evita todos os exercicios terem mesma curva.
  static List<double> _buildHistory({
    required int seed,
    required double current,
  }) {
    // Base: 70% da carga atual, sobe ate 100% em curva quase linear,
    // com -8% na semana 4 (deload). Seed altera fase e amplitude.
    final phase = (seed % 7) / 7.0;
    final amp = 0.04 + ((seed >> 3) % 5) / 100;
    final values = <double>[];
    for (var i = 0; i < 7; i++) {
      final t = i / 6.0;
      // Tendencia base — subida suave de 0.72 ate 0.96.
      var v = 0.72 + t * 0.24;
      // Deload na semana ~3-4.
      if (i == 3) v -= 0.08;
      // Oscilacao pequena por seed.
      v += math.sin((t + phase) * math.pi * 2) * amp;
      values.add(v.clamp(0.55, 1.0) * current);
    }
    values.add(current);
    return values;
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;

    return RepaintBoundary(
      child: SizedBox(
        key: const Key('fitness-exercise-load-chart'),
        height: widget.height,
        child: AnimatedBuilder(
          animation: _progress,
          builder: (context, _) {
            return CustomPaint(
              size: Size.infinite,
              painter: _ExerciseLoadHistoryPainter(
                values: _history,
                progress: _progress.value,
                primary: colors.primary,
                accent: colors.primary.withValues(alpha: 0.3),
                halo: colors.primary.withValues(alpha: 0.18),
                track: colors.surfaceMuted,
                labelColor: colors.onSurface,
                axisLabelStyle: textTheme.labelSmall?.copyWith(
                  color: colors.onSurfaceMuted,
                  letterSpacing: 0.4,
                ),
                valueLabelStyle: textTheme.labelMedium?.copyWith(
                  color: colors.onSurface,
                  fontWeight: FontWeight.w700,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _ExerciseLoadHistoryPainter extends CustomPainter {
  _ExerciseLoadHistoryPainter({
    required this.values,
    required this.progress,
    required this.primary,
    required this.accent,
    required this.halo,
    required this.track,
    required this.labelColor,
    required this.axisLabelStyle,
    required this.valueLabelStyle,
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

  static const double _topPadding = 28; // espaco pro label flutuante
  static const double _bottomLabelStrip = 18;
  static const double _gap = 6;
  static const double _radius = 4;

  final List<double> values;
  final double progress;
  final Color primary;
  final Color accent;
  final Color halo;
  final Color track;
  final Color labelColor;
  final TextStyle? axisLabelStyle;
  final TextStyle? valueLabelStyle;

  // Paints cacheados como campos — mutamos cor in-place por barra.
  late final Paint _barPaint = Paint()..style = PaintingStyle.fill;
  late final Paint _trackPaint = Paint()
    ..color = track
    ..style = PaintingStyle.fill;
  late final Paint _haloPaint = Paint()
    ..color = halo
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.isEmpty || size.width <= 0 || size.height <= 0) return;

    final chartHeight = size.height - _topPadding - _bottomLabelStrip;
    if (chartHeight <= 0) return;

    final maxValue = values.reduce(math.max);
    final minValue = values.reduce(math.min);
    // Eixo y zoomado entre min e max pra deixar a variacao visivel.
    final yRange = math.max(maxValue - minValue * 0.85, maxValue * 0.05);
    final yBase = minValue * 0.85;

    final barWidth = (size.width - _gap * (values.length - 1)) / values.length;
    if (barWidth <= 0) return;

    final reveal = progress.clamp(0.0, 1.0);
    final lastIndex = values.length - 1;

    for (var i = 0; i < values.length; i++) {
      final x = i * (barWidth + _gap);
      final norm = ((values[i] - yBase) / yRange).clamp(0.0, 1.0);
      // Cada barra cresce em sequencia: divide o progresso em fatias.
      final barRevealStart = i / values.length;
      final barReveal = ((reveal - barRevealStart) * values.length)
          .clamp(0.0, 1.0);
      final fullHeight = norm * chartHeight;
      final barHeight = fullHeight * barReveal;

      // Track (sombra) — barra cheia em alpha baixo.
      final trackRect = Rect.fromLTWH(
        x,
        _topPadding,
        barWidth,
        chartHeight,
      );
      canvas.drawRRect(
        RRect.fromRectAndRadius(trackRect, const Radius.circular(_radius)),
        _trackPaint,
      );

      if (barHeight <= 0.5) continue;

      final isCurrent = i == lastIndex;
      final barRect = Rect.fromLTWH(
        x,
        _topPadding + chartHeight - barHeight,
        barWidth,
        barHeight,
      );

      if (isCurrent) {
        // Halo glow atras da barra atual.
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            barRect.inflate(4),
            const Radius.circular(_radius + 2),
          ),
          _haloPaint,
        );
      }

      _barPaint.color = isCurrent ? primary : accent;
      canvas.drawRRect(
        RRect.fromRectAndRadius(barRect, const Radius.circular(_radius)),
        _barPaint,
      );
    }

    // Label flutuante sobre a barra atual — so depois da animacao
    // alcancar a ultima fatia, pra nao "pop in" cedo.
    final lastBarStart = lastIndex / values.length;
    if (reveal >= lastBarStart) {
      _paintCurrentLabel(
        canvas,
        size,
        barWidth: barWidth,
        chartHeight: chartHeight,
        yRange: yRange,
        yBase: yBase,
      );
    }

    _paintAxisLabels(canvas, size, barWidth: barWidth);
  }

  void _paintCurrentLabel(
    Canvas canvas,
    Size size, {
    required double barWidth,
    required double chartHeight,
    required double yRange,
    required double yBase,
  }) {
    final lastIndex = values.length - 1;
    final x = lastIndex * (barWidth + _gap);
    final norm = ((values[lastIndex] - yBase) / yRange).clamp(0.0, 1.0);
    final barTop = _topPadding + chartHeight - norm * chartHeight;

    final text = '${values[lastIndex].toStringAsFixed(0)} kg';
    final textPainter = TextPainter(
      text: TextSpan(text: text, style: valueLabelStyle),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();

    final centerX = x + barWidth / 2;
    var labelX = centerX - textPainter.width / 2;
    // Mantem o label dentro do canvas.
    labelX = labelX.clamp(0.0, size.width - textPainter.width);

    textPainter.paint(canvas, Offset(labelX, barTop - 22));
  }

  void _paintAxisLabels(
    Canvas canvas,
    Size size, {
    required double barWidth,
  }) {
    for (var i = 0; i < values.length; i++) {
      final x = i * (barWidth + _gap);
      final tp = TextPainter(
        text: TextSpan(text: _xLabels[i], style: axisLabelStyle),
        textDirection: TextDirection.ltr,
        maxLines: 1,
      )..layout();
      final dx = x + barWidth / 2 - tp.width / 2;
      final dy = size.height - _bottomLabelStrip + 4;
      tp.paint(canvas, Offset(dx, dy));
    }
  }

  @override
  bool shouldRepaint(_ExerciseLoadHistoryPainter old) {
    return old.progress != progress ||
        old.primary != primary ||
        !_listEquals(old.values, values);
  }

  static bool _listEquals(List<double> a, List<double> b) {
    if (identical(a, b)) return true;
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
