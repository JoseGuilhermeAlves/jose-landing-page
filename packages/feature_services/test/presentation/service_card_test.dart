import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:feature_services/feature_services.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );

  const service = Service(
    id: 'mobile',
    title: 'Apps mobile',
    description: 'Android nativo via Flutter.',
    icon: Icons.phone_android,
  );

  AnimatedBorderPainter currentBorder(WidgetTester tester) {
    final paints = tester
        .widgetList<CustomPaint>(
          find.descendant(
            of: find.byType(ServiceCard),
            matching: find.byType(CustomPaint),
          ),
        )
        .where((p) => p.foregroundPainter is AnimatedBorderPainter);
    return paints.first.foregroundPainter! as AnimatedBorderPainter;
  }

  group('ServiceCard', () {
    testWidgets('renderiza titulo, descricao e icone do Service', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 320,
            height: 220,
            child: ServiceCard(service: service),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Apps mobile'), findsOneWidget);
      expect(find.text('Android nativo via Flutter.'), findsOneWidget);
      expect(find.byIcon(Icons.phone_android), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('hover sobe progress da borda animada de 0 ate 1', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(
          const SizedBox(
            width: 320,
            height: 220,
            child: ServiceCard(service: service),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(currentBorder(tester).progress, 0);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.byType(ServiceCard)));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 150));
      final mid = currentBorder(tester).progress;
      expect(mid, greaterThan(0));
      expect(mid, lessThan(1));

      await tester.pump(const Duration(milliseconds: 600));
      expect(currentBorder(tester).progress, closeTo(1, 0.01));

      await gesture.moveTo(const Offset(-100, -100));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 600));
      expect(currentBorder(tester).progress, closeTo(0, 0.01));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe Semantics como botao com label do servico', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          wrap(
            SizedBox(
              width: 320,
              child: ServiceCard(service: service, onPressed: () {}),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          tester.getSemantics(find.bySemanticsLabel('Apps mobile')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            label: 'Apps mobile',
          ),
        );
      } finally {
        handle.dispose();
      }

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('tap chama onPressed quando provido', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 320,
            child: ServiceCard(service: service, onPressed: () => taps++),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byType(ServiceCard));
      expect(taps, 1);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
