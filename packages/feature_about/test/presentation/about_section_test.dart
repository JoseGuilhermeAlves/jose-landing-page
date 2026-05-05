import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 2400)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      home: MediaQuery(
        data: MediaQueryData(size: size),
        child: Scaffold(
          body: SizedBox.fromSize(
            size: size,
            child: SingleChildScrollView(child: child),
          ),
        ),
      ),
    );
  }

  group('AboutSection', () {
    testWidgets('renderiza bio com nome e parágrafo', (tester) async {
      await tester.pumpWidget(wrap(const AboutSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.textContaining('José Guilherme'), findsWidgets);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe DomainsGrid e StackBadges', (tester) async {
      await tester.pumpWidget(wrap(const AboutSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(DomainsGrid), findsOneWidget);
      expect(find.byType(StackBadges), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'inclui nota de escopo honesta (varejo end-to-end + demais em time)',
      (tester) async {
        await tester.pumpWidget(wrap(const AboutSection()));
        await tester.pump(const Duration(milliseconds: 16));

        // Nota de escopo deve mencionar tanto "ponta a ponta"
        // (varejo) quanto "time" (demais).
        expect(find.textContaining('ponta a ponta'), findsWidgets);
        expect(find.textContaining('time'), findsWidgets);

        await tester.pumpWidget(const SizedBox());
      },
    );

    testWidgets('expoe Semantics(header: true) na headline da secao',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const AboutSection()));
        await tester.pump(const Duration(milliseconds: 16));

        final headerSemantics = find.byWidgetPredicate(
          (w) => w is Semantics && (w.properties.header ?? false),
        );
        expect(headerSemantics, findsWidgets);
      } finally {
        handle.dispose();
      }

      await tester.pumpWidget(const SizedBox());
    });
  });
}
