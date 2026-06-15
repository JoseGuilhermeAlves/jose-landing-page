import 'package:design_system/design_system.dart';
import 'package:feature_about/feature_about.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child, {Size size = const Size(1280, 2400)}) {
    return MaterialApp(
      theme: AppTheme.dark(),
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      locale: const Locale('pt'),
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
    testWidgets('renderiza bio em prosa: lead e linhas-fato', (tester) async {
      await tester.pumpWidget(wrap(const AboutSection()));
      await tester.pump(const Duration(milliseconds: 32));

      // Nome/titulo vivem no hero+nav (texto-primeiro aqui, sem bio-card).
      // Lead + linhas-fato escaneaveis + fecho de escopo.
      expect(find.textContaining('mesma régua'), findsOneWidget);
      expect(
        find.textContaining('Varejo B2B', findRichText: true),
        findsWidgets,
      );
      expect(
        find.textContaining('Fintech de larga escala', findRichText: true),
        findsWidgets,
      );
      expect(
        find.textContaining('Backend permanece com o time'),
        findsOneWidget,
      );

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('compoe DomainConstellation e DeliveryBlock', (tester) async {
      await tester.pumpWidget(wrap(const AboutSection()));
      await tester.pump(const Duration(milliseconds: 32));

      expect(find.byType(DomainConstellation), findsOneWidget);
      expect(find.byType(DeliveryBlock), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('DeliveryBlock carrega 3 eyebrows (entrega/craft/colab)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const AboutSection()));
      await tester.pump(const Duration(milliseconds: 32));

      // Eyebrows agora em fonte pixel (PixelText, nao Text).
      Finder pixel(String t) =>
          find.byWidgetPredicate((w) => w is PixelText && w.text == t);
      expect(pixel('ENTREGA'), findsOneWidget);
      expect(pixel('CRAFT'), findsOneWidget);
      expect(pixel('COLABORAÇÃO'), findsOneWidget);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('expoe Semantics(header: true) na headline da secao', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const AboutSection()));
        await tester.pump(const Duration(milliseconds: 32));

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
