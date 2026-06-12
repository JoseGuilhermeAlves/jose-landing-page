import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CosmosPainter', () {
    const planet = CosmosPlanet(
      id: 'p',
      canvasAnchor: Offset(0.5, 0.5),
      radiusPixels: 4,
      pattern: PlanetPattern.bands,
      palette: [Color(0xFFFFD27A), Color(0xFFB07A2C), Color(0xFF6B4818)],
    );

    const ringed = CosmosPlanet(
      id: 'r',
      canvasAnchor: Offset(0.25, 0.5),
      radiusPixels: 5,
      pattern: PlanetPattern.hemispheres,
      palette: [Color(0xFF5BC0EB), Color(0xFF2C6B85)],
      ring: PlanetRing(
        innerRadiusPixels: 7,
        outerRadiusPixels: 10,
        color: Color(0x885BC0EB),
      ),
    );

    const speckled = CosmosPlanet(
      id: 's',
      canvasAnchor: Offset(0.75, 0.5),
      radiusPixels: 3,
      pattern: PlanetPattern.speckled,
      palette: [Color(0xFFF87171), Color(0xFF7A1F1F)],
      moon: PlanetMoon(
        orbitRadiusPixels: 7,
        moonRadiusPixels: 1,
        color: Color(0xFFE8E8F0),
      ),
    );

    const nebula = CosmosNebula(
      canvasAnchor: Offset(0.3, 0.3),
      radiusPixels: 6,
      color: Color(0x447C6BFF),
    );

    const comet = CosmosComet(
      startAnchor: Offset(-0.1, 0.1),
      endAnchor: Offset(1.1, 0.6),
      tailLengthPixels: 6,
      color: Color(0xFFFFFFFF),
    );

    const galaxy = CosmosGalaxy(
      canvasAnchor: Offset(0.2, 0.8),
      radiusPixels: 40,
      coreColor: Color(0xFFFFE8C2),
      armColor: Color(0xFF9D3FFF),
      seed: 41,
    );

    const pulsar = CosmosPulsar(
      canvasAnchor: Offset(0.85, 0.2),
      coreColor: Color(0xFF99FFEC),
      beamColor: Color(0xFF0AC4FF),
      coreRadiusPixels: 2,
      beamLengthPixels: 30,
    );

    const belt = CosmosAsteroidBelt(
      canvasAnchor: Offset(0.6, 0.5),
      radiusPixels: 30,
      rockColor: Color(0xFFC9B59A),
      highlightColor: Color(0xFFFFE066),
      rockCount: 40,
      seed: 53,
    );

    const wisp = CosmosWisp(
      canvasAnchor: Offset(0.3, 0.25),
      radiusPixels: 20,
      colors: [Color(0xFF7FE9FF), Color(0xFFB78BFF)],
      blobCount: 4,
      seed: 71,
    );

    CosmosPainter make({
      double tick = 0,
      Color starColor = const Color(0xFFE8E8F0),
      double pixelSize = 4,
      List<CosmosPlanet> planets = const [planet, ringed, speckled],
      List<CosmosNebula> nebulas = const [nebula],
      List<CosmosGalaxy> galaxies = const [galaxy],
      List<CosmosPulsar> pulsars = const [pulsar],
      List<CosmosAsteroidBelt> asteroidBelts = const [belt],
      List<CosmosWisp> wisps = const [wisp],
      CosmosComet? comet$ = comet,
      List<Offset> pixelStars = const [Offset(0.1, 0.1), Offset(0.9, 0.9)],
    }) {
      return CosmosPainter(
        tick: tick,
        starColor: starColor,
        pixelSize: pixelSize,
        planets: planets,
        nebulas: nebulas,
        galaxies: galaxies,
        pulsars: pulsars,
        asteroidBelts: asteroidBelts,
        wisps: wisps,
        comet: comet$,
        pixelStars: pixelStars,
      );
    }

    test('shouldRepaint volta true quando tick muda', () {
      expect(make(tick: 0.1).shouldRepaint(make(tick: 0.5)), isTrue);
    });

    test('shouldRepaint volta false quando nada muda', () {
      expect(make().shouldRepaint(make()), isFalse);
    });

    test('shouldRepaint reage a starColor, pixelSize e cometa', () {
      expect(
        make(starColor: const Color(0xFFFF0000)).shouldRepaint(make()),
        isTrue,
      );
      expect(make(pixelSize: 8).shouldRepaint(make()), isTrue);
      expect(make(comet$: null).shouldRepaint(make()), isTrue);
    });

    test('shouldRepaint reage a mudancas em galaxias e pulsares', () {
      // Listas diferentes (nao identicas) devem disparar repaint.
      expect(
        make(galaxies: const []).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(pulsars: const []).shouldRepaint(make()),
        isTrue,
      );
    });

    test('shouldRepaint reage a mudancas em cinturoes e wisps', () {
      expect(
        make(asteroidBelts: const []).shouldRepaint(make()),
        isTrue,
      );
      expect(
        make(wisps: const []).shouldRepaint(make()),
        isTrue,
      );
    });

    test('paint nao lanca em Size zero', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(tick: 0.3).paint(canvas, Size.zero);
      recorder.endRecording().dispose();
    });

    test('paint nao lanca em tamanho realistico (1280x720)', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(tick: 0.5).paint(canvas, const Size(1280, 720));
      recorder.endRecording().dispose();
    });

    test('paint nao lanca com listas vazias', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      make(
        planets: const [],
        nebulas: const [],
        comet$: null,
        pixelStars: const [],
      ).paint(canvas, const Size(400, 300));
      recorder.endRecording().dispose();
    });

    test('paint dentro/fora da janela do cometa nao lanca', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      // dentro da janela default 0..0.18.
      make(tick: 0.05).paint(canvas, const Size(800, 600));
      // fora da janela.
      make(tick: 0.7).paint(canvas, const Size(800, 600));
      recorder.endRecording().dispose();
    });

    test('paint cobre todos os patterns sem lancar', () {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      const all = [
        CosmosPlanet(
          id: 'b',
          canvasAnchor: Offset(0.2, 0.3),
          radiusPixels: 5,
          pattern: PlanetPattern.bands,
          palette: [Color(0xFFAA0000), Color(0xFF770000), Color(0xFF330000)],
        ),
        CosmosPlanet(
          id: 'h',
          canvasAnchor: Offset(0.5, 0.5),
          radiusPixels: 5,
          pattern: PlanetPattern.hemispheres,
          palette: [Color(0xFF00AAFF), Color(0xFF003366)],
        ),
        CosmosPlanet(
          id: 's2',
          canvasAnchor: Offset(0.8, 0.7),
          radiusPixels: 5,
          pattern: PlanetPattern.speckled,
          palette: [Color(0xFF7C6BFF), Color(0xFF2A1E80)],
        ),
      ];
      CosmosPainter(
        tick: 0.4,
        starColor: const Color(0xFFE8E8F0),
        planets: all,
      ).paint(canvas, const Size(800, 600));
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
}
