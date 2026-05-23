import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: SizedBox(width: 600, child: child)),
  );

  group('StackBadges', () {
    testWidgets('renderiza um chip para cada item de stack', (tester) async {
      await tester.pumpWidget(
        wrap(const StackBadges(stack: ['Flutter', 'Dart', 'Bloc'])),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.text('Flutter'), findsOneWidget);
      expect(find.text('Dart'), findsOneWidget);
      expect(find.text('Bloc'), findsOneWidget);
    });

    testWidgets('lista vazia: renderiza sem erro', (tester) async {
      await tester.pumpWidget(wrap(const StackBadges(stack: [])));
      expect(tester.takeException(), isNull);
    });
  });
}
