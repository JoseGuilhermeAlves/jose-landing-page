import 'dart:math' as math;

import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Bottom sheet de descanso entre sets — fluxo conhecido de qualquer
/// app de academia. Demonstra um painter dedicado (`_RestTimerRingPainter`)
/// e um cronometro suave (60fps via `Ticker`, com texto arredondado pra
/// segundo inteiro).
///
/// Comporta-se como modal nao-bloqueante: pode ser dispensado tocando
/// fora, tocando "Pular" ou esperando chegar a zero (auto-pop).
class RestTimerSheet extends StatefulWidget {
  const RestTimerSheet({
    required this.initialSeconds,
    required this.exerciseName,
    super.key,
  });

  /// Duracao inicial em segundos. Caller calcula a partir das reps do
  /// exercicio: <=8 reps -> 120s (forca), >8 -> 90s (hipertrofia).
  final int initialSeconds;

  /// Nome do exercicio que acabou de ser feito — exibido no header
  /// do sheet pra dar contexto.
  final String exerciseName;

  @override
  State<RestTimerSheet> createState() => _RestTimerSheetState();
}

class _RestTimerSheetState extends State<RestTimerSheet>
    with TickerProviderStateMixin {
  late final int _totalSeconds = widget.initialSeconds;
  late final DateTime _startedAt = DateTime.now();
  late final Ticker _ticker;
  Duration _elapsed = Duration.zero;
  // Acumula segundos adicionados via +15s pra estender o timer sem
  // tocar no `_totalSeconds` original (mantem o calculo de progress
  // sempre relativo ao novo total).
  int _adjustmentSeconds = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker(_onTick)..start();
  }

  void _onTick(Duration duration) {
    if (!mounted) return;
    setState(() {
      _elapsed = DateTime.now().difference(_startedAt);
    });
    if (_remainingSecondsExact <= 0) {
      _ticker.stop();
      Navigator.of(context).maybePop();
    }
  }

  /// Total real considerando ajustes (+15s / -15s).
  int get _effectiveTotal => _totalSeconds + _adjustmentSeconds;

  double get _remainingSecondsExact =>
      math.max(0, _effectiveTotal - _elapsed.inMilliseconds / 1000.0);

  int get _remainingSecondsCeil => _remainingSecondsExact.ceil();

  double get _progress {
    if (_effectiveTotal <= 0) return 0;
    return (_remainingSecondsExact / _effectiveTotal).clamp(0.0, 1.0);
  }

  void _adjust(int deltaSeconds) {
    setState(() {
      // Permite estender ou encurtar, mas nao deixa o efetivo negativo
      // (do contrario o auto-pop disparava imediatamente em -15s perto
      // do zero).
      final next = _adjustmentSeconds + deltaSeconds;
      final remainingIfApplied =
          _effectiveTotal + deltaSeconds - _elapsed.inMilliseconds / 1000.0;
      if (remainingIfApplied < 0) return;
      _adjustmentSeconds = next;
    });
  }

  void _skip() {
    _ticker.stop();
    Navigator.of(context).maybePop();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final textTheme = Theme.of(context).textTheme;
    final remaining = _remainingSecondsCeil;
    final mm = (remaining ~/ 60).toString();
    final ss = (remaining % 60).toString().padLeft(2, '0');

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.lg,
          AppSpacing.md,
          AppSpacing.lg,
          AppSpacing.xl,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 4,
              decoration: BoxDecoration(
                color: colors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            Text(
              'Descanso'.toUpperCase(),
              style: textTheme.labelSmall?.copyWith(
                color: colors.primary,
                letterSpacing: 1.4,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              widget.exerciseName,
              key: const Key('fitness-rest-timer-exercise-name'),
              style: textTheme.titleMedium?.copyWith(color: colors.onSurface),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.xl),
            SizedBox(
              width: 220,
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _RestTimerRingPainter(
                        progress: _progress,
                        activeColor: colors.primary,
                        trackColor: colors.surfaceMuted,
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '$mm:$ss',
                        key: const Key('fitness-rest-timer-display'),
                        style: textTheme.displayMedium?.copyWith(
                          color: colors.onSurface,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -2,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xxs),
                      Text(
                        'segundos restantes',
                        style: textTheme.labelMedium?.copyWith(
                          color: colors.onSurfaceMuted,
                          letterSpacing: 0.4,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _AdjustButton(
                  key: const Key('fitness-rest-timer-minus'),
                  label: '-15s',
                  onTap: () => _adjust(-15),
                  colors: colors,
                  textTheme: textTheme,
                ),
                const SizedBox(width: AppSpacing.md),
                _AdjustButton(
                  key: const Key('fitness-rest-timer-plus'),
                  label: '+15s',
                  onTap: () => _adjust(15),
                  colors: colors,
                  textTheme: textTheme,
                  accent: true,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            TextButton(
              key: const Key('fitness-rest-timer-skip'),
              onPressed: _skip,
              child: Text(
                'Pular descanso',
                style: textTheme.labelLarge?.copyWith(
                  color: colors.onSurfaceMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustButton extends StatelessWidget {
  const _AdjustButton({
    required this.label,
    required this.onTap,
    required this.colors,
    required this.textTheme,
    this.accent = false,
    super.key,
  });

  final String label;
  final VoidCallback onTap;
  final AppColorScheme colors;
  final TextTheme textTheme;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: accent ? colors.primary.withValues(alpha: 0.18) : colors.surface,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: accent ? colors.primary.withValues(alpha: 0.6) : colors.border,
        ),
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.full),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            label,
            style: textTheme.labelLarge?.copyWith(
              color: accent ? colors.primary : colors.onSurface,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.4,
            ),
          ),
        ),
      ),
    );
  }
}

class _RestTimerRingPainter extends CustomPainter {
  _RestTimerRingPainter({
    required this.progress,
    required this.activeColor,
    required this.trackColor,
  });

  static const double _strokeWidth = 12;

  final double progress;
  final Color activeColor;
  final Color trackColor;

  late final Paint _trackPaint = Paint()
    ..color = trackColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth;

  late final Paint _activePaint = Paint()
    ..color = activeColor
    ..style = PaintingStyle.stroke
    ..strokeWidth = _strokeWidth
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _strokeWidth / 2;

    canvas.drawCircle(center, radius, _trackPaint);

    if (progress <= 0) return;
    final rect = Rect.fromCircle(center: center, radius: radius);
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;
    canvas.drawArc(rect, startAngle, sweepAngle, false, _activePaint);
  }

  @override
  bool shouldRepaint(_RestTimerRingPainter old) {
    return old.progress != progress ||
        old.activeColor != activeColor ||
        old.trackColor != trackColor;
  }
}
