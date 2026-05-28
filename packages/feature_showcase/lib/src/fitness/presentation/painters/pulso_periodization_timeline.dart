import 'package:feature_showcase/src/fitness/domain/program.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Heatmap de periodizacao: 8 colunas (semanas) x 7 linhas (dias).
/// Celulas coloridas por intensidade prescrita; coluna da semana
/// atual destacada com borda. Tap em qualquer celula chama [onTap]
/// com (weekIndex, weekday) — UI externa controla detalhes.
class PulsoPeriodizationTimeline extends StatelessWidget {
  const PulsoPeriodizationTimeline({
    required this.program,
    this.onCellTap,
    this.selectedWeek,
    this.selectedWeekday,
    this.height = 240,
    super.key,
  });

  final Program program;
  final void Function(int weekIndex, int weekday)? onCellTap;
  final int? selectedWeek;
  final int? selectedWeekday;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        return SizedBox(
          height: height,
          width: c.maxWidth,
          child: GestureDetector(
            onTapUp: onCellTap == null
                ? null
                : (details) => _handleTap(details, c.maxWidth),
            child: CustomPaint(
              painter: _TimelinePainter(
                program: program,
                selectedWeek: selectedWeek ?? program.currentWeekIndex,
                selectedWeekday: selectedWeekday ?? 0,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleTap(TapUpDetails details, double width) {
    final cols = program.weeks.length;
    if (cols == 0) return;
    const headerWidth = 36.0;
    const rowHeaderH = 22.0;
    final usableW = width - headerWidth;
    final usableH = height - rowHeaderH;
    final cellW = usableW / cols;
    final cellH = usableH / 7;
    final x = details.localPosition.dx - headerWidth;
    final y = details.localPosition.dy - rowHeaderH;
    if (x < 0 || y < 0) return;
    final col = (x / cellW).floor().clamp(0, cols - 1);
    final row = (y / cellH).floor().clamp(0, 6);
    onCellTap!(col + 1, row + 1);
  }
}

class _TimelinePainter extends CustomPainter {
  _TimelinePainter({
    required this.program,
    required this.selectedWeek,
    required this.selectedWeekday,
  });

  final Program program;
  final int selectedWeek;
  final int selectedWeekday;

  static const List<String> _dayLabels = ['S', 'T', 'Q', 'Q', 'S', 'S', 'D'];

  static final Paint _cellPaint = Paint()..style = PaintingStyle.fill;
  static final Paint _selectedBorder = Paint()
    ..color = const Color(0xFFF2F2F5)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;
  static final Paint _currentWeekStroke = Paint()
    ..color = const Color(0xFF00D982)
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final cols = program.weeks.length;
    if (cols == 0) return;
    const headerWidth = 36.0;
    const colHeaderH = 22.0;
    final usableW = size.width - headerWidth;
    final usableH = size.height - colHeaderH;
    final cellW = usableW / cols;
    final cellH = usableH / 7;

    // Headers de coluna (semanas).
    for (var w = 0; w < cols; w++) {
      final week = program.weeks[w];
      final isCurrent = week.index == program.currentWeekIndex;
      final isSelected = week.index == selectedWeek;
      final color = isCurrent
          ? const Color(0xFF00D982)
          : isSelected
          ? const Color(0xFFF2F2F5)
          : const Color(0xFF7E7E8A);
      final tp = TextPainter(
        text: TextSpan(
          text: 'S${week.index}',
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: isCurrent || isSelected
                ? FontWeight.w700
                : FontWeight.w500,
            letterSpacing: 0.8,
            fontFamily: FitnessBrand.displayMonoFontFamily,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          headerWidth + cellW * w + (cellW - tp.width) / 2,
          (colHeaderH - tp.height) / 2,
        ),
      );
    }

    // Headers de linha (dias).
    for (var d = 0; d < 7; d++) {
      final tp = TextPainter(
        text: TextSpan(
          text: _dayLabels[d],
          style: const TextStyle(
            color: Color(0xFF7E7E8A),
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(
        canvas,
        Offset(
          (headerWidth - tp.width) / 2,
          colHeaderH + cellH * d + (cellH - tp.height) / 2,
        ),
      );
    }

    // Grid de celulas.
    for (var w = 0; w < cols; w++) {
      final week = program.weeks[w];
      for (var d = 0; d < 7; d++) {
        final weekday = d + 1;
        final hasSession = week.sessionFor(weekday) != null;
        final intensity = week.intensityMultiplier;
        final isDeload = week.isDeload;
        final color = !hasSession
            ? const Color(0xFF14141C)
            : _intensityColor(intensity, isDeload);
        final rect = Rect.fromLTWH(
          headerWidth + cellW * w + 1,
          colHeaderH + cellH * d + 1,
          cellW - 2,
          cellH - 2,
        );
        _cellPaint.color = color;
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(4)),
          _cellPaint,
        );

        final isSelectedCell =
            week.index == selectedWeek && weekday == selectedWeekday;
        if (isSelectedCell) {
          canvas.drawRRect(
            RRect.fromRectAndRadius(rect, const Radius.circular(4)),
            _selectedBorder,
          );
        }
      }

      // Highlight da semana atual: borda verde.
      if (week.index == program.currentWeekIndex) {
        final colRect = Rect.fromLTWH(
          headerWidth + cellW * w + 0.5,
          colHeaderH + 0.5,
          cellW - 1,
          cellH * 7 - 1,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(colRect, const Radius.circular(6)),
          _currentWeekStroke,
        );
      }
    }
  }

  Color _intensityColor(double multiplier, bool deload) {
    if (deload) return const Color(0xFF1F4D3A);
    // Mapeia 1.00..1.15 -> 0..1.
    final norm = ((multiplier - 1.0) / 0.15).clamp(0, 1).toDouble();
    // Blend de verde escuro -> verde brilhante.
    final base = const Color(0xFF1A3F2A);
    final hot = const Color(0xFF00D982);
    return Color.lerp(base, hot, norm) ?? base;
  }

  @override
  bool shouldRepaint(_TimelinePainter old) =>
      old.program != program ||
      old.selectedWeek != selectedWeek ||
      old.selectedWeekday != selectedWeekday;
}
