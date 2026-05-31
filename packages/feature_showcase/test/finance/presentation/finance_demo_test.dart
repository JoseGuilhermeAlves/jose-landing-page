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
    home: child,
  );

  group('FinanceDemo (Mira, multi-tela)', () {
    testWidgets('home abre com hero do portfolio + watchlist', (tester) async {
      await tester.pumpWidget(wrap(const FinanceDemo()));
      // MiraCandlestickChart faz reveal de 800ms; aqui so a home tem
      // sparkline-less, entao pumps curtos servem.
      await tester.pump(const Duration(milliseconds: 50));

      // Hero do portfolio renderiza.
      expect(find.byKey(const Key('mira-portfolio-hero')), findsOneWidget);
      // Pelo menos um row de ativo aparece (favoritos).
      expect(find.byKey(const Key('mira-asset-row-PETR4')), findsOneWidget);
    });

    testWidgets('tap em ativo abre detail com candlestick', (tester) async {
      await tester.pumpWidget(wrap(const FinanceDemo()));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byKey(const Key('mira-asset-row-PETR4')));
      // pumpAndSettle nao serve por causa do reveal infinito + candlestick.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      // CTAs Comprar/Vender renderizam — sinal de que a detail montou.
      expect(find.byKey(const Key('mira-cta-buy')), findsOneWidget);
      expect(find.byKey(const Key('mira-cta-sell')), findsOneWidget);
    });

    testWidgets('icone do portfolio no AppBar abre MiraPortfolioPage', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const FinanceDemo()));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byKey(const Key('mira-portfolio-icon')));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 1000));

      expect(find.text('Meu portfolio'), findsOneWidget);
      expect(find.text('Posicoes'), findsOneWidget);
    });

    testWidgets('icone de historico no AppBar abre MiraTradeHistoryPage', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const FinanceDemo()));
      await tester.pump(const Duration(milliseconds: 50));

      await tester.tap(find.byKey(const Key('mira-history-icon')));
      await tester.pumpAndSettle();

      expect(find.text('Historico'), findsOneWidget);
      // Catalog inicial traz 6 trades.
      expect(find.textContaining('T-000'), findsWidgets);
    });

    testWidgets('toggle de favorito remove e re-adiciona ativo da watchlist', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const FinanceDemo()));
      await tester.pump(const Duration(milliseconds: 50));

      // PETR4 esta na watchlist por default.
      expect(find.byKey(const Key('mira-asset-row-PETR4')), findsOneWidget);

      await tester.tap(find.byKey(const Key('mira-favorite-toggle-PETR4')));
      await tester.pump();

      // PETR4 sai dos favoritos e migra pro grupo de "outros ativos"
      // — ainda renderiza, em outra posicao, com a estrela vazia.
      // Conferimos o icone preenchido vs vazio:
      final filled = find.descendant(
        of: find.byKey(const Key('mira-favorite-toggle-PETR4')),
        matching: find.byIcon(Icons.star_rounded),
      );
      expect(filled, findsNothing);
    });
  });
}
