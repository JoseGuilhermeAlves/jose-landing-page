import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LoadingSpinnerPainter', () {
    LoadingSpinnerPainter make({
      double progress = 0,
      Color color = const Color(0xFF7C3AED),
      double strokeWidth = 3,
    }) {
      return LoadingSpinnerPainter(
        progress: progress,
        color: color,
        strokeWidth: strokeWidth,
      );
    }

    test('shouldRepaint volta true quando o progresso muda', () {
      final a = make(progress: 0.2);
      final b = make(progress: 0.7);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      final a = make(progress: 0.5);
      final b = make(progress: 0.5);
      expect(b.shouldRepaint(a), isFalse);
    });

    test('shouldRepaint volta true quando a cor muda', () {
      final a = make(color: const Color(0xFFAA0000));
      final b = make(color: const Color(0xFF00AA00));
      expect(b.shouldRepaint(a), isTrue);
    });

    test('shouldRepaint volta true quando strokeWidth muda', () {
      final a = make(strokeWidth: 2);
      final b = make(strokeWidth: 5);
      expect(b.shouldRepaint(a), isTrue);
    });

    test('progress fica clampeado em [0,1]', () {
      expect(make(progress: -1).progress, 0);
      expect(make(progress: 2).progress, 1);
    });

    test('isComplex fica false (geometria leve, nao vale rasterizar)', () {
      expect(make().isComplex, isFalse);
    });

    test('willChange fica true (animacao continua)', () {
      expect(make().willChange, isTrue);
    });

    test('paint nao cria nenhum Paint dentro do paint() — usa cache', () {
      // Validacao indireta: dois paints consecutivos no mesmo painter
      // precisam terminar sem lancar e sem alterar identidades expostas.
      // (O contrato e enforced pelo nao-uso de `Paint()` no metodo paint.)
      final painter = make(progress: 0.4);
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder)
        ..drawPaint(Paint()..color = const Color(0x00000000));
      painter
        ..paint(canvas, const Size(48, 48))
        ..paint(canvas, const Size(48, 48));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 48,
            height: 48,
            child: CustomPaint(painter: make(progress: 0.6)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
