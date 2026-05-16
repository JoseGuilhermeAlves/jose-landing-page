import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Mostrador analogico animado — destaque tecnico do mock Vitral. O
/// ponteiro dos segundos roda em loop continuo (Listenable direto via
/// `super(repaint:)` pra pular build/layout). Os ponteiros das horas
/// e minutos sao parametrizados (`hour` e `minute`) — quando passados
/// como hora atual mock, comunicam "a agenda esta organizada agora".
///
/// Decisao de design: o relogio fica no hero da home pra reforcar a
/// metafora "tempo organizado". O painter e estatico para hour/minute
/// e so anima o ponteiro de segundos.
class VitralClockPainter extends StatefulWidget {
  const VitralClockPainter({
    required this.hour,
    required this.minute,
    required this.size,
    super.key,
  });

  /// Hora "fixa" exibida no mostrador (0..23). Os ponteiros de hora e
  /// minuto sao calculados a partir desses dois campos.
  final int hour;
  final int minute;

  /// Lado do canvas (mostrador e circular).
  final double size;

  @override
  State<VitralClockPainter> createState() => _VitralClockPainterState();
}

class _VitralClockPainterState extends State<VitralClockPainter>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 60),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: CustomPaint(
          painter: _VitralClockFacePainter(
            controller: _controller,
            hour: widget.hour,
            minute: widget.minute,
            faceColor: scheme.surface,
            ringColor: scheme.primary,
            tickColor: scheme.outline,
            hourHandColor: scheme.primary,
            minuteHandColor: scheme.primary,
            secondHandColor: scheme.secondary,
            centerColor: scheme.primary,
          ),
        ),
      ),
    );
  }
}

class _VitralClockFacePainter extends CustomPainter {
  _VitralClockFacePainter({
    required this.controller,
    required this.hour,
    required this.minute,
    required this.faceColor,
    required this.ringColor,
    required this.tickColor,
    required this.hourHandColor,
    required this.minuteHandColor,
    required this.secondHandColor,
    required this.centerColor,
  }) : super(repaint: controller);

  final Animation<double> controller;
  final int hour;
  final int minute;
  final Color faceColor;
  final Color ringColor;
  final Color tickColor;
  final Color hourHandColor;
  final Color minuteHandColor;
  final Color secondHandColor;
  final Color centerColor;

  late final Paint _facePaint = Paint()
    ..color = faceColor
    ..style = PaintingStyle.fill;

  late final Paint _ringPaint = Paint()
    ..color = ringColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = 4;

  late final Paint _tickPaint = Paint()
    ..color = tickColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  late final Paint _hourHandPaint = Paint()
    ..color = hourHandColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  late final Paint _minuteHandPaint = Paint()
    ..color = minuteHandColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round;

  late final Paint _secondHandPaint = Paint()
    ..color = secondHandColor
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeWidth = 1.4;

  late final Paint _centerFillPaint = Paint()
    ..color = centerColor
    ..style = PaintingStyle.fill;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = math.min(cx, cy) - 6;

    canvas
      ..drawCircle(Offset(cx, cy), r, _facePaint)
      ..drawCircle(Offset(cx, cy), r, _ringPaint);

    _paintTicks(canvas, Offset(cx, cy), r);
    _paintHourHand(canvas, Offset(cx, cy), r);
    _paintMinuteHand(canvas, Offset(cx, cy), r);
    _paintSecondHand(canvas, Offset(cx, cy), r);

    canvas.drawCircle(Offset(cx, cy), r * 0.06, _centerFillPaint);
  }

  /// 12 ticks principais (cardinais) e 48 pequenos entre eles.
  void _paintTicks(Canvas canvas, Offset center, double r) {
    for (var i = 0; i < 60; i++) {
      final angle = (i / 60) * 2 * math.pi - math.pi / 2;
      final isMajor = i % 5 == 0;
      _tickPaint.strokeWidth = isMajor ? 2.5 : 1;
      final outer = Offset(
        center.dx + math.cos(angle) * r,
        center.dy + math.sin(angle) * r,
      );
      final innerR = r - (isMajor ? r * 0.10 : r * 0.04);
      final inner = Offset(
        center.dx + math.cos(angle) * innerR,
        center.dy + math.sin(angle) * innerR,
      );
      canvas.drawLine(inner, outer, _tickPaint);
    }
  }

  void _paintHourHand(Canvas canvas, Offset center, double r) {
    // Hora deslocada pelos minutos pra dar continuidade.
    final hour12 = hour % 12;
    final angle =
        ((hour12 + minute / 60) / 12) * 2 * math.pi - math.pi / 2;
    final tip = Offset(
      center.dx + math.cos(angle) * r * 0.55,
      center.dy + math.sin(angle) * r * 0.55,
    );
    _hourHandPaint.strokeWidth = 5;
    canvas.drawLine(center, tip, _hourHandPaint);
  }

  void _paintMinuteHand(Canvas canvas, Offset center, double r) {
    final angle = (minute / 60) * 2 * math.pi - math.pi / 2;
    final tip = Offset(
      center.dx + math.cos(angle) * r * 0.80,
      center.dy + math.sin(angle) * r * 0.80,
    );
    _minuteHandPaint.strokeWidth = 3;
    canvas.drawLine(center, tip, _minuteHandPaint);
  }

  void _paintSecondHand(Canvas canvas, Offset center, double r) {
    // Linear pra cima de 60s. Pega o controller (0..1 em 60s).
    final progress = controller.value;
    final angle = progress * 2 * math.pi - math.pi / 2;
    final tip = Offset(
      center.dx + math.cos(angle) * r * 0.85,
      center.dy + math.sin(angle) * r * 0.85,
    );
    final tail = Offset(
      center.dx - math.cos(angle) * r * 0.15,
      center.dy - math.sin(angle) * r * 0.15,
    );
    canvas.drawLine(tail, tip, _secondHandPaint);
  }

  @override
  bool shouldRepaint(_VitralClockFacePainter old) {
    return old.hour != hour ||
        old.minute != minute ||
        old.faceColor != faceColor ||
        old.ringColor != ringColor ||
        old.tickColor != tickColor ||
        old.hourHandColor != hourHandColor ||
        old.minuteHandColor != minuteHandColor ||
        old.secondHandColor != secondHandColor ||
        old.centerColor != centerColor;
  }
}
