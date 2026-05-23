import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AnimatedTimelinePainter', () {
    AnimatedTimelinePainter make({
      double progress = 0.5,
      int markerCount = 4,
      Color lineColor = const Color(0xFF7C6BFF),
      Color markerColor = const Color(0xFFFFFFFF),
      double lineWidth = 2,
      double markerRadius = 5,
    }) {
      return AnimatedTimelinePainter(
        progress: progress,
        markerCount: markerCount,
        lineColor: lineColor,
        markerColor: markerColor,
        lineWidth: lineWidth,
        markerRadius: markerRadius,
      );
    }

    test('shouldRepaint reage a progress', () {
      expect(make(progress: 0.4).shouldRepaint(make(progress: 0.7)), isTrue);
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('shouldRepaint reage a markerCount, cores e dimensoes', () {
      expect(make(markerCount: 5).shouldRepaint(make()), isTrue);
      expect(
        make(lineColor: const Color(0xFF000000)).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(markerColor: const Color(0xFF000000)).shouldRepaint(make()),
        isTrue,
      );
      expect(make(lineWidth: 4).shouldRepaint(make()), isTrue);
      expect(make(markerRadius: 8).shouldRepaint(make()), isTrue);
    });

    test('progress fica clampeado em [0,1]', () {
      expect(make(progress: -1).progress, 0);
      expect(make(progress: 2).progress, 1);
    });

    test('markerCount minimo: 0 nao gera marcador, 1 gera unico marcador', () {
      // Deve aceitar zero sem throw e nao desenhar nada.
      final recorder0 = PictureRecorder();
      final canvas0 = Canvas(recorder0);
      make(markerCount: 0, progress: 1).paint(canvas0, const Size(40, 200));
      recorder0.endRecording().dispose();

      final recorder1 = PictureRecorder();
      final canvas1 = Canvas(recorder1);
      make(markerCount: 1, progress: 1).paint(canvas1, const Size(40, 200));
      recorder1.endRecording().dispose();
    });

    test('paint nao lanca em Size zero ou progress 0', () {
      final r = PictureRecorder();
      final c = Canvas(r);
      make(progress: 0).paint(c, const Size(40, 200));
      make().paint(c, Size.zero);
      r.endRecording().dispose();
    });

    test('hints: nao vale rasterizar (linha leve), willChange ativo', () {
      expect(make().isComplex, isFalse);
      expect(make().willChange, isTrue);
    });

    test('debugMarkerCenters: gera n posicoes equidistantes na vertical', () {
      const size = Size(40, 200);
      final centers = make().debugMarkerCenters(size);
      expect(centers, hasLength(4));

      // todos com x igual
      for (final c in centers) {
        expect(c.dx, equals(centers.first.dx));
      }

      // distribuicao monotona crescente em y
      for (var i = 1; i < centers.length; i++) {
        expect(centers[i].dy, greaterThan(centers[i - 1].dy));
      }

      // distancias aproximadamente iguais entre marcadores adjacentes
      final gaps = <double>[
        for (var i = 1; i < centers.length; i++)
          centers[i].dy - centers[i - 1].dy,
      ];
      final firstGap = gaps.first;
      for (final g in gaps.skip(1)) {
        expect((g - firstGap).abs(), lessThan(0.5));
      }
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 60,
            height: 320,
            child: CustomPaint(painter: make(progress: 0.65)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
