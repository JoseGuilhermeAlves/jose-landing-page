import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:flutter/material.dart';

/// Visualizador de tempo de execucao do exercicio. Quatro segmentos
/// horizontais representam fases [eccentric, pausa baixa, concentric,
/// pausa alta]. Cabecote luminoso percorre os segmentos em loop com
/// duracao proporcional aos segundos de cada fase. Inspiracao: Caliber,
/// Hevy.
class PulsoTempoBars extends StatefulWidget {
  const PulsoTempoBars({
    required this.tempoSeconds,
    this.height = 56,
    this.labels = const ['Negativa', 'Pausa', 'Positiva', 'Pausa'],
    super.key,
  });

  /// Lista de 4 valores [eccentric, pause, concentric, pause] em segundos.
  final List<int> tempoSeconds;
  final double height;
  final List<String> labels;

  @override
  State<PulsoTempoBars> createState() => _PulsoTempoBarsState();
}

class _PulsoTempoBarsState extends State<PulsoTempoBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late int _totalMillis;

  @override
  void initState() {
    super.initState();
    _totalMillis = _computeTotal(widget.tempoSeconds);
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: _totalMillis),
    )..repeat();
  }

  static int _computeTotal(List<int> tempo) {
    var sum = 0;
    for (final v in tempo) {
      sum += v;
    }
    if (sum < 1) sum = 1;
    return sum * 1000;
  }

  @override
  void didUpdateWidget(covariant PulsoTempoBars old) {
    super.didUpdateWidget(old);
    if (old.tempoSeconds != widget.tempoSeconds) {
      _totalMillis = _computeTotal(widget.tempoSeconds);
      _controller
        ..duration = Duration(milliseconds: _totalMillis)
        ..reset()
        ..repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: SizedBox(
        height: widget.height,
        width: double.infinity,
        child: CustomPaint(
          painter: _TempoBarsPainter(
            tempo: widget.tempoSeconds,
            labels: widget.labels,
            progress: _controller,
          ),
        ),
      ),
    );
  }
}

class _TempoBarsPainter extends CustomPainter {
  _TempoBarsPainter({
    required this.tempo,
    required this.labels,
    required this.progress,
  }) : super(repaint: progress);

  final List<int> tempo;
  final List<String> labels;
  final Animation<double> progress;

  static final Paint _trackPaint = Paint()..color = const Color(0xFF1A1A22);
  static final Paint _activePaint = Paint()..color = const Color(0xFF00D982);
  static final Paint _cursorPaint = Paint()..color = const Color(0xFFF2F2F5);

  // TextPainters cacheados — labels e segundos sao estaticos por
  // instancia (tempo/labels novos criam painter novo); so o estado
  // ativo troca a cor, entao mantemos as duas variantes prontas.
  // Relayout acontece apenas quando o canvas muda de tamanho.
  final List<TextPainter?> _idleLabels = [];
  final List<TextPainter?> _activeLabels = [];
  final List<TextPainter?> _secsLabels = [];
  Size _textLayoutSize = Size.zero;

  static TextPainter _labelPainter(String text, Color color, double maxWidth) {
    return TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout(maxWidth: maxWidth);
  }

  void _rebuildTextPainters(List<double> widths) {
    _idleLabels.clear();
    _activeLabels.clear();
    _secsLabels.clear();
    for (var i = 0; i < tempo.length; i++) {
      if (i >= labels.length) {
        _idleLabels.add(null);
        _activeLabels.add(null);
        _secsLabels.add(null);
        continue;
      }
      final text = labels[i].toUpperCase();
      _idleLabels.add(_labelPainter(text, const Color(0xFF7E7E8A), widths[i]));
      _activeLabels.add(
        _labelPainter(text, const Color(0xFFF2F2F5), widths[i]),
      );
      _secsLabels.add(
        TextPainter(
          text: TextSpan(
            text: tempo[i].toString(),
            style: const TextStyle(
              color: Color(0xFFF2F2F5),
              fontSize: 13,
              fontWeight: FontWeight.w600,
              fontFamily: FitnessBrand.displayMonoFontFamily,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout(),
      );
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    const gap = 6.0;
    const barHeight = 14.0;
    final barY = (size.height - barHeight) / 2;
    final total = tempo.fold<int>(0, (acc, v) => acc + v);
    if (total == 0) return;

    final available = size.width - gap * (tempo.length - 1);
    var x = 0.0;
    final t = progress.value;
    final widths = tempo.map((v) => (v / total) * available).toList();
    if (size != _textLayoutSize) {
      _textLayoutSize = size;
      _rebuildTextPainters(widths);
    }
    var cumulative = 0.0;

    for (var i = 0; i < tempo.length; i++) {
      final segWidth = widths[i];
      final segStart = cumulative;
      final segEnd = cumulative + segWidth;
      final segProgress = ((t * available) - segStart).clamp(0.0, segWidth);
      final isActive = (t * available) >= segStart && (t * available) <= segEnd;

      // Track.
      final trackRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, barY, segWidth, barHeight),
        const Radius.circular(4),
      );
      canvas.drawRRect(trackRect, _trackPaint);

      // Preenchimento ativo.
      if (segProgress > 0) {
        _activePaint.color = i.isEven
            ? const Color(0xFF00D982) // eccentric/concentric
            : const Color(0xFF5AC8FA); // pausas
        final fillRect = RRect.fromRectAndRadius(
          Rect.fromLTWH(x, barY, segProgress, barHeight),
          const Radius.circular(4),
        );
        canvas.drawRRect(fillRect, _activePaint);
      }

      // Cursor luminoso quando ativo.
      if (isActive) {
        final cx = x + segProgress;
        canvas.drawCircle(Offset(cx, barY + barHeight / 2), 5, _cursorPaint);
      }

      // Label inferior — variante ativa/idle pre-layoutada.
      final tp = isActive ? _activeLabels[i] : _idleLabels[i];
      if (tp != null) {
        tp.paint(
          canvas,
          Offset(x + (segWidth - tp.width) / 2, barY + barHeight + 6),
        );
      }

      // Segundos no topo.
      final secs = _secsLabels[i];
      if (secs != null) {
        secs.paint(
          canvas,
          Offset(x + (segWidth - secs.width) / 2, barY - secs.height - 4),
        );
      }

      x += segWidth + gap;
      cumulative += segWidth;
    }
  }

  @override
  bool shouldRepaint(_TempoBarsPainter old) =>
      old.tempo != tempo || old.labels != labels;
}
