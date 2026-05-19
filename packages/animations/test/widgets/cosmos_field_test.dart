import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: child),
      );

  CosmosPainter currentPainter(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(CosmosField),
        matching: find.byType(CustomPaint),
      ),
    );
    return paint.painter! as CosmosPainter;
  }

  group('CosmosField', () {
    testWidgets('builda com defaults da paleta dark', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 800, height: 480, child: CosmosField())),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(CosmosField), findsOneWidget);
      final painter = currentPainter(tester);
      expect(painter.planets, hasLength(3));
      expect(painter.nebulas, hasLength(2));
      expect(painter.comet, isNotNull);
      expect(painter.pixelStars, hasLength(18));

      // Defaults da paleta: pelo menos um planeta tem ring, pelo menos
      // um tem moon. Sem isso o "cosmos" perde a graca.
      expect(painter.planets.any((p) => p.ring != null), isTrue);
      expect(painter.planets.any((p) => p.moon != null), isTrue);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('avanca o tick continuamente (animacao em loop)',
        (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 400, height: 240, child: CosmosField())),
      );
      await tester.pump(const Duration(milliseconds: 16));
      final tick1 = currentPainter(tester).tick;

      await tester.pump(const Duration(milliseconds: 250));
      final tick2 = currentPainter(tester).tick;
      expect(tick2, isNot(equals(tick1)));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('overrides de planetas/nebulas/cometa sao respeitados',
        (tester) async {
      const planets = [
        CosmosPlanet(
          id: 'only',
          canvasAnchor: Offset(0.5, 0.5),
          radiusPixels: 4,
          pattern: PlanetPattern.bands,
          palette: [Color(0xFFAA0000)],
        ),
      ];
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 400,
            height: 240,
            child: CosmosField(
              planets: planets,
              nebulas: [],
              comet: null,
              pixelStars: [],
            ),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      final painter = currentPainter(tester);
      expect(painter.planets, hasLength(1));
      expect(painter.planets.first.id, 'only');
      expect(painter.nebulas, isEmpty);
      expect(painter.comet, isNull);
      expect(painter.pixelStars, isEmpty);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('respeita pixelSize custom', (tester) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 400,
            height: 240,
            child: CosmosField(pixelSize: 6),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));
      expect(currentPainter(tester).pixelSize, 6);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('dispose nao deixa ticker pendurado', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 200, height: 120, child: CosmosField())),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.pumpWidget(const SizedBox());
      expect(tester.takeException(), isNull);
    });
  });
}
