import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // O hero, o relogio e o backdrop tem animacoes em loop infinito,
  // entao todos os pumps deste arquivo usam Duration explicito —
  // pumpAndSettle nao terminaria.

  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    locale: const Locale('pt'),
    home: child,
  );

  // Ancora deterministica.
  final today = DateTime(2026, 5, 4);

  /// Viewport mais alto pra que o hero + proximo agendamento +
  /// categorias + lista de profissionais caibam sem precisar scrollar
  /// nos taps.
  Future<void> useLargeSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(900, 1700));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('SchedulingDemo (Vitral, multi-tela)', () {
    testWidgets('home abre com hero da marca e card de "sem agendamento"', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await tester.pumpWidget(wrap(SchedulingDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('vitral-cta-services')), findsOneWidget);
      // Sem confirmacao ainda — exibe placeholder.
      expect(find.text('Sem agendamentos por enquanto'), findsOneWidget);
    });

    testWidgets('tap em "Ver servicos" abre o catalogo com filtros', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await tester.pumpWidget(wrap(SchedulingDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('vitral-cta-services')));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      expect(find.byKey(const Key('vitral-filter-all')), findsOneWidget);
      expect(find.byKey(const Key('vitral-filter-consulting')), findsOneWidget);
    });

    testWidgets('tap em servico empurra calendario com strip de 14 dias', (
      tester,
    ) async {
      await useLargeSurface(tester);
      await tester.pumpWidget(wrap(SchedulingDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Vai pra lista de servicos.
      await tester.tap(find.byKey(const Key('vitral-cta-services')));
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Tap no primeiro card de servico.
      await tester.tap(
        find.byKey(const Key('vitral-service-card-sv-discovery')),
      );
      for (var i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 50));
      }

      // Strip de 14 dias (renderiza um chip por dia).
      expect(find.byKey(const Key('scheduling-day-chip')), findsNWidgets(14));
      // 18 slots horarios (9h-17:30, intervalo de 30 min).
      expect(find.byKey(const Key('scheduling-slot-tile')), findsNWidgets(18));
      // CTA Continuar desabilitado antes de selecionar slot.
      expect(find.byKey(const Key('vitral-calendar-continue')), findsOneWidget);
    });

    testWidgets(
      'fluxo end-to-end: servico → slot → confirmar → home com card',
      (tester) async {
        await useLargeSurface(tester);
        // Sem pre-booking pra garantir que o primeiro slot esta livre.
        await tester.pumpWidget(
          wrap(SchedulingDemo(today: today, preBookedSlots: const {})),
        );
        await tester.pump(const Duration(milliseconds: 16));

        // 1) Home → catalogo
        await tester.tap(find.byKey(const Key('vitral-cta-services')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // 2) Catalogo → calendario do servico
        await tester.tap(
          find.byKey(const Key('vitral-service-card-sv-discovery')),
        );
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // 3) Calendario: tap no primeiro slot livre + Continuar
        await tester.tap(find.byKey(const Key('scheduling-slot-tile')).first);
        await tester.pump(const Duration(milliseconds: 50));
        await tester.tap(find.byKey(const Key('vitral-calendar-continue')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // 4) Confirmacao: tap no CTA
        expect(
          find.byKey(const Key('vitral-confirmation-title')),
          findsOneWidget,
        );
        await tester.tap(find.byKey(const Key('vitral-confirmation-confirm')));
        for (var i = 0; i < 20; i++) {
          await tester.pump(const Duration(milliseconds: 50));
        }

        // 5) Voltou pra home — card de proximo agendamento aparece.
        expect(
          find.byKey(const Key('vitral-next-appointment-card')),
          findsOneWidget,
        );
      },
    );
  });
}
