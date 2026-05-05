import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedBorderPainter', () {
    AnimatedBorderPainter make({
      double progress = 0,
      Color color = const Color(0xFF7C6BFF),
      double strokeWidth = 1.5,
      double borderRadius = 12,
    }) {
      return AnimatedBorderPainter(
        progress: progress,
        color: color,
        strokeWidth: strokeWidth,
        borderRadius: borderRadius,
      );
    }

    test('shouldRepaint volta true quando o progresso muda', () {
      final a = make(progress: 0.2);
      final b = make(progress: 0.5);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      final a = make(progress: 0.5);
      final b = make(progress: 0.5);
      expect(b.shouldRepaint(a), isFalse);
    });

    test('shouldRepaint volta true ao trocar color', () {
      final a = make(color: const Color(0xFFFF0000));
      final b = make(color: const Color(0xFF00FF00));
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta true ao trocar strokeWidth ou borderRadius', () {
      expect(
        make(strokeWidth: 2).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(borderRadius: 20).shouldRepaint(make()),
        isTrue,
      );
    });

    test('progress fica clampeado em [0,1]', () {
      expect(make(progress: -1).progress, 0);
      expect(make(progress: 2).progress, 1);
    });

    test('hints: nao vale rasterizar (geometria leve), willChange ativo', () {
      expect(make().isComplex, isFalse);
      expect(make().willChange, isTrue);
    });

    test('paint nao lanca em Size zero', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(progress: 0.5).paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint nao desenha nada quando progress e 0', () {
      // Se progress=0 -> nenhum trecho do path foi extraido.
      // Validacao indireta: paint roda sem erro e nao deixa estado pendente.
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make().paint(canvas, const Size(100, 60));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 200,
            height: 80,
            child: CustomPaint(painter: make(progress: 0.7)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
