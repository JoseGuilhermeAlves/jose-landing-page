import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Senoide horizontal animada — separador entre secoes da landing
/// (PROJECT.md §5.5). Decorativo e leve: amostragem proporcional a
/// largura, sem path complicado.
///
/// API:
/// - [phase] desloca a onda no eixo X (0..1 = um ciclo completo de
///   deslizar). Alimentar com um controller em loop produz o "fluir".
/// - [amplitude] em pixels, pico-a-zero (a altura total da onda e
///   `2 * amplitude`).
/// - [frequency] = numero de ciclos completos cobrindo a largura.
/// - [style] aceita `stroke` (linha) ou `fill` (preenche da onda pra
///   baixo, util como divisor entre fundos).
///
/// Performance:
/// - `Paint` cacheado;
/// - amostragem em passos de 2px (suave o bastante e barato);
/// - `shouldRepaint` minimo.
class WaveDividerPainter extends CustomPainter {
  WaveDividerPainter({
    required double phase,
    required this.color,
    this.amplitude = 8,
    this.frequency = 2,
    this.style = PaintingStyle.stroke,
    this.strokeWidth = 1.5,
    this.sampleStep = 2,
  }) : assert(amplitude >= 0, 'Amplitude negativa nao faz sentido'),
       assert(frequency > 0, 'Frequencia deve ser positiva'),
       assert(sampleStep > 0, 'sampleStep deve ser positivo'),
       // Phase e ciclica: aceita qualquer real, normaliza pra [0, 1).
       phase = _wrapUnit(phase);

  final double phase;
  final Color color;
  final double amplitude;
  final double frequency;

  /// `stroke` (default) desenha so a linha; `fill` preenche da onda
  /// pra borda inferior do canvas.
  final PaintingStyle style;
  final double strokeWidth;

  /// Passo em pixels entre amostras consecutivas no eixo X.
  final double sampleStep;

  late final Paint _paint = Paint()
    ..isAntiAlias = true
    ..color = color
    ..style = style
    ..strokeWidth = strokeWidth
    ..strokeCap = StrokeCap.round;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final width = size.width;
    final midY = size.height / 2;
    final phaseOffset = phase * 2 * math.pi;
    final omega = (frequency * 2 * math.pi) / width;

    final path = Path();
    var x = 0.0;
    final firstY = midY + amplitude * math.sin(phaseOffset);
    path.moveTo(x, firstY);
    while (x < width) {
      x = math.min(x + sampleStep, width);
      final y = midY + amplitude * math.sin(omega * x + phaseOffset);
      path.lineTo(x, y);
    }

    if (style == PaintingStyle.fill) {
      // Fecha pra baixo cobrindo a faixa abaixo da onda.
      path
        ..lineTo(width, size.height)
        ..lineTo(0, size.height)
        ..close();
    }

    canvas.drawPath(path, _paint);
  }

  /// Normaliza phase em [0, 1) pra que progresso de controller acima
  /// de 1 nao quebre nada.
  static double _wrapUnit(double v) {
    final f = v - v.floorToDouble();
    return f < 0 ? f + 1 : f;
  }

  @override
  bool shouldRepaint(covariant WaveDividerPainter old) {
    return old.phase != phase ||
        old.color != color ||
        old.amplitude != amplitude ||
        old.frequency != frequency ||
        old.style != style ||
        old.strokeWidth != strokeWidth ||
        old.sampleStep != sampleStep;
  }

  /// Hint para o `CustomPaint` host: linha simples, nao vale rasterizar.
  bool get isComplex => false;

  /// Hint para o `CustomPaint` host: anima continuamente.
  bool get willChange => true;
}
