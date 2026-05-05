import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WaveDividerPainter', () {
    WaveDividerPainter make({
      double phase = 0,
      Color color = const Color(0xFF7C6BFF),
      double amplitude = 8,
      double frequency = 2,
      PaintingStyle style = PaintingStyle.stroke,
      double strokeWidth = 1.5,
      double sampleStep = 2,
    }) {
      return WaveDividerPainter(
        phase: phase,
        color: color,
        amplitude: amplitude,
        frequency: frequency,
        style: style,
        strokeWidth: strokeWidth,
        sampleStep: sampleStep,
      );
    }

    test('phase e wrapped em [0, 1)', () {
      // make() default phase=0, idem make(phase: 1) (wrap).
      expect(make().phase, 0);
      expect(make(phase: 1).phase, 0);
      expect(make(phase: 1.25).phase, closeTo(0.25, 1e-9));
      expect(make(phase: -0.25).phase, closeTo(0.75, 1e-9));
    });

    test('shouldRepaint volta true quando phase muda', () {
      expect(make(phase: 0.1).shouldRepaint(make(phase: 0.5)), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make(phase: 0.4).shouldRepaint(make(phase: 0.4)), isFalse);
    });

    test('shouldRepaint reage aos demais campos', () {
      expect(
        make(color: const Color(0xFFFF0000)).shouldRepaint(make()),
        isTrue,
      );
      expect(make(amplitude: 16).shouldRepaint(make()), isTrue);
      expect(make(frequency: 4).shouldRepaint(make()), isTrue);
      expect(make(style: PaintingStyle.fill).shouldRepaint(make()), isTrue);
      expect(make(strokeWidth: 3).shouldRepaint(make()), isTrue);
      expect(make(sampleStep: 4).shouldRepaint(make()), isTrue);
    });

    test('asserts: amplitude negativa, frequencia <=0, sampleStep <=0', () {
      expect(
        () => WaveDividerPainter(
          phase: 0,
          color: const Color(0xFF000000),
          amplitude: -1,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => WaveDividerPainter(
          phase: 0,
          color: const Color(0xFF000000),
          frequency: 0,
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => WaveDividerPainter(
          phase: 0,
          color: const Color(0xFF000000),
          sampleStep: 0,
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
      make().paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint roda em ambos PaintingStyle (stroke e fill)', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make().paint(canvas, const Size(200, 40));
      make(style: PaintingStyle.fill).paint(canvas, const Size(200, 40));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 320,
            height: 40,
            child: CustomPaint(painter: make(phase: 0.3)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
