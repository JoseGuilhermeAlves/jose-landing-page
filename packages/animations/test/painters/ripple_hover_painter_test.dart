import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('RippleHoverPainter', () {
    RippleHoverPainter make({
      Offset center = const Offset(50, 50),
      double progress = 0.5,
      Color color = const Color(0xFF7C6BFF),
      double? maxRadius,
      double strokeWidth = 1.5,
    }) {
      return RippleHoverPainter(
        center: center,
        progress: progress,
        color: color,
        maxRadius: maxRadius,
        strokeWidth: strokeWidth,
      );
    }

    test('shouldRepaint volta true quando o progress muda', () {
      expect(make(progress: 0.2).shouldRepaint(make(progress: 0.6)), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('shouldRepaint reage a center, color, maxRadius, strokeWidth', () {
      expect(make(center: const Offset(10, 10)).shouldRepaint(make()), isTrue);
      expect(
        make(color: const Color(0xFFAA0000)).shouldRepaint(make()),
        isTrue,
      );
      expect(make(maxRadius: 200).shouldRepaint(make()), isTrue);
      expect(make(strokeWidth: 4).shouldRepaint(make()), isTrue);
    });

    test('progress fica clampeado em [0,1]', () {
      expect(make(progress: -1).progress, 0);
      expect(make(progress: 5).progress, 1);
    });

    test('hints: leve (isComplex false), anima (willChange true)', () {
      expect(make().isComplex, isFalse);
      expect(make().willChange, isTrue);
    });

    test('paint nao lanca em Size zero', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make().paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint e no-op em progress 0 (alpha cheio mas raio zero)', () {
      // Hard guard contra desenho fora de fase.
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(progress: 0).paint(canvas, const Size(120, 80));
      recorder.endRecording().dispose();
    });

    test('paint e no-op em progress 1 (alpha zero)', () {
      // Quando o ripple terminou, alpha e 0 e nao deve desenhar.
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(progress: 1).paint(canvas, const Size(120, 80));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      // make() ja vem com progress=0.5 por default.
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child: CustomPaint(painter: make()),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
