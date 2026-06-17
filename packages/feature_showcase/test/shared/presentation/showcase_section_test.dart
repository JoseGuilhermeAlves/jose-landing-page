import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: Scaffold(body: SingleChildScrollView(child: child)),
  );

  // O preview de cada gabinete ja renderiza o widget de demo do mock
  // (home real). Ao abrir o demo fullscreen, passa a haver duas
  // instancias do mesmo tipo — preview + modal.
  Future<void> tapCabinetAndSettle(WidgetTester tester, String id) async {
    final cabinet = find.byKey(Key('showcase-cabinet-$id'));
    await tester.ensureVisible(cabinet);
    await tester.pump(const Duration(milliseconds: 50));
    await tester.tap(cabinet);
    // pumpAndSettle nao serve: os mocks tem painters em loop infinito.
    // Pumps fixos cobrem o push da MaterialPageRoute.
    for (var i = 0; i < 12; i++) {
      await tester.pump(const Duration(milliseconds: 50));
    }
  }

  group('ShowcaseSection', () {
    testWidgets('renderiza um ArcadeCabinet pra cada nicho do catalogo', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ArcadeCabinet), findsNWidgets(3));
    });

    testWidgets('preview renderiza a home real de cada mock', (tester) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      // Cada nicho tem o widget de demo renderizado na tela do gabinete.
      expect(find.byType(DeliveryDemo), findsOneWidget);
      expect(find.byType(RealEstateDemo), findsOneWidget);
      expect(find.byType(FinanceDemo), findsOneWidget);
    });

    testWidgets('tap no gabinete delivery abre o DeliveryDemo fullscreen', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      await tapCabinetAndSettle(tester, 'delivery');

      // Preview (offstage apos abrir o modal) + modal fullscreen.
      // skipOffstage:false conta os dois e prova que a rota foi empurrada.
      expect(find.byType(DeliveryDemo, skipOffstage: false), findsNWidgets(2));
    });

    testWidgets(
      'tap no gabinete imobiliaria abre o RealEstateDemo fullscreen',
      (tester) async {
        await tester.pumpWidget(wrap(const ShowcaseSection()));
        await tester.pump(const Duration(milliseconds: 16));

        await tapCabinetAndSettle(tester, 'realestate');

        expect(
          find.byType(RealEstateDemo, skipOffstage: false),
          findsNWidgets(2),
        );
      },
    );

    testWidgets('tap no gabinete finance abre o FinanceDemo fullscreen', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const ShowcaseSection()));
      await tester.pump(const Duration(milliseconds: 16));

      await tapCabinetAndSettle(tester, 'finance');

      expect(find.byType(FinanceDemo, skipOffstage: false), findsNWidgets(2));
    });
  });
}
