import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap({required Size size, required Widget child}) {
  return MediaQuery(
    data: MediaQueryData(size: size),
    child: Directionality(textDirection: TextDirection.ltr, child: child),
  );
}

void main() {
  group('AdaptiveLayout', () {
    testWidgets('mobile width renderiza widget mobile', (tester) async {
      await tester.pumpWidget(
        _wrap(
          size: const Size(375, 800),
          child: const AdaptiveLayout(
            mobile: Text('m'),
            tablet: Text('t'),
            desktop: Text('d'),
          ),
        ),
      );
      expect(find.text('m'), findsOneWidget);
      expect(find.text('t'), findsNothing);
    });

    testWidgets('desktop width usa desktop quando provido', (tester) async {
      await tester.pumpWidget(
        _wrap(
          size: const Size(1280, 800),
          child: const AdaptiveLayout(mobile: Text('m'), desktop: Text('d')),
        ),
      );
      expect(find.text('d'), findsOneWidget);
    });

    testWidgets('cai pra tablet quando desktop nao foi provido', (
      tester,
    ) async {
      await tester.pumpWidget(
        _wrap(
          size: const Size(1280, 800),
          child: const AdaptiveLayout(mobile: Text('m'), tablet: Text('t')),
        ),
      );
      expect(find.text('t'), findsOneWidget);
    });

    testWidgets('cai pra mobile quando nada mais foi provido', (tester) async {
      await tester.pumpWidget(
        _wrap(
          size: const Size(1600, 1000),
          child: const AdaptiveLayout(mobile: Text('m')),
        ),
      );
      expect(find.text('m'), findsOneWidget);
    });
  });
}
