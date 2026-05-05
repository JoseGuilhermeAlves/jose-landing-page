import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MorphingShapePainter', () {
    MorphingShapePainter make({
      double progress = 0,
      Color color = const Color(0xFF7C6BFF),
      PaintingStyle style = PaintingStyle.fill,
      double strokeWidth = 1.5,
      int sampleCount = 72,
    }) {
      return MorphingShapePainter(
        progress: progress,
        color: color,
        style: style,
        strokeWidth: strokeWidth,
        sampleCount: sampleCount,
      );
    }

    test('shouldRepaint volta true quando o progress muda', () {
      expect(make(progress: 0.7).shouldRepaint(make(progress: 0.3)), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make(progress: 0.4).shouldRepaint(make(progress: 0.4)), isFalse);
    });

    test('shouldRepaint reage a color, style, strokeWidth, sampleCount', () {
      expect(
        make(color: const Color(0xFF00FF00)).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(style: PaintingStyle.stroke).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(strokeWidth: 3).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(sampleCount: 36).shouldRepaint(make()),
        isTrue,
      );
    });

    test('progress fica clampeado em [0,1]', () {
      expect(make(progress: -0.5).progress, 0);
      expect(make(progress: 1.7).progress, 1);
    });

    test('sampleCount muito baixo dispara assert', () {
      expect(
        () => MorphingShapePainter(
          progress: 0.5,
          color: const Color(0xFF000000),
          sampleCount: 4,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('hints: leve (isComplex false), anima (willChange true)', () {
      expect(make().isComplex, isFalse);
      expect(make().willChange, isTrue);
    });

    test('paint nao lanca em Size zero', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(progress: 0.5).paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint nao lanca nos extremos do ciclo (progress 0 e 1)', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      // progress: 0 e o default do helper make().
      make().paint(canvas, const Size(100, 100));
      make(progress: 1).paint(canvas, const Size(100, 100));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 120,
            height: 120,
            child: CustomPaint(painter: make(progress: 0.4)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
