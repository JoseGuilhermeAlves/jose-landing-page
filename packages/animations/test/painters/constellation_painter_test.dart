import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConstellationPainter', () {
    ConstellationPainter make({
      double tick = 0,
      Color starColor = const Color(0xFFE8E8F0),
      Color linkColor = const Color(0x227C6BFF),
      List<Constellation>? constellations,
      double starRadius = 1.6,
      double flareLength = 4.5,
      double linkStrokeWidth = 0.5,
    }) {
      return ConstellationPainter(
        tick: tick,
        starColor: starColor,
        linkColor: linkColor,
        constellations: constellations ?? KnownConstellations.all,
        starRadius: starRadius,
        flareLength: flareLength,
        linkStrokeWidth: linkStrokeWidth,
      );
    }

    test('shouldRepaint volta true quando tick muda', () {
      expect(make(tick: 0.2).shouldRepaint(make(tick: 0.6)), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('shouldRepaint reage a starColor, linkColor e radii', () {
      expect(
        make(starColor: const Color(0xFFFF0000)).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(linkColor: const Color(0xFF00FF00)).shouldRepaint(make()),
        isTrue,
      );
      expect(make(starRadius: 3).shouldRepaint(make()), isTrue);
      expect(make(flareLength: 8).shouldRepaint(make()), isTrue);
      expect(make(linkStrokeWidth: 1).shouldRepaint(make()), isTrue);
    });

    test('hints: leve (isComplex false), anima (willChange true)', () {
      expect(make().isComplex, isFalse);
      expect(make().willChange, isTrue);
    });

    test('paint nao lanca em Size zero', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(tick: 0.5).paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint nao lanca com lista de constelacoes vazia', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(constellations: const []).paint(canvas, const Size(800, 600));
      recorder.endRecording().dispose();
    });

    test('paint roda nas constelacoes do catalogo padrao sem lancar', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(tick: 0.3).paint(canvas, const Size(1280, 720));
      recorder.endRecording().dispose();
    });

    testWidgets('renderiza dentro de CustomPaint sem lancar', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: SizedBox(
            width: 800,
            height: 480,
            child: CustomPaint(painter: make(tick: 0.4)),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('KnownConstellations', () {
    test('catalogo padrao expoe Crux, Orion e Triangulo de Verao', () {
      final ids = KnownConstellations.all.map((c) => c.id).toList();
      expect(ids, containsAll(['crux', 'orion', 'summer_triangle']));
    });

    test('todas as constelacoes tem stars + edges nao vazios', () {
      for (final c in KnownConstellations.all) {
        expect(c.stars, isNotEmpty);
        expect(c.edges, isNotEmpty);
        // Todos os indices das edges precisam estar dentro de stars.
        for (final (a, b) in c.edges) {
          expect(a, lessThan(c.stars.length));
          expect(b, lessThan(c.stars.length));
        }
      }
    });
  });
}
