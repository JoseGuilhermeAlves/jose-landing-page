import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      );

  // 1 = segunda (dia com treino na catalog padrao).
  const today = 1;

  /// Switch para a aba Semana — necessario antes de checar conteudo
  /// que vive nessa aba (day-chip, exercise-card, set-dot).
  Future<void> goToSemana(WidgetTester tester) async {
    await tester.tap(find.text('Semana'));
    await tester.pumpAndSettle();
  }

  /// Switch para a aba Progresso.
  Future<void> goToProgresso(WidgetTester tester) async {
    await tester.tap(find.text('Progresso'));
    await tester.pumpAndSettle();
  }

  group('FitnessDemo (multi-tab)', () {
    testWidgets('abre na aba Hoje com greeting + hero card', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Marca "Pulso" no AppBar
      expect(find.text('Pulso'), findsOneWidget);

      // Aba Hoje renderiza greeting (uppercased no widget),
      // label do dia e hero card.
      expect(find.textContaining('BOM TREINO'), findsOneWidget);
      expect(find.textContaining('Hoje, segunda'), findsOneWidget);
      expect(find.byKey(const Key('fitness-today-hero-card')), findsOneWidget);
      expect(
        find.byKey(const Key('fitness-today-start-button')),
        findsOneWidget,
      );
    });

    testWidgets(
      'tap em "Iniciar treino" na aba Hoje muda para a aba Semana',
      (tester) async {
        await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
        await tester.pump(const Duration(milliseconds: 16));

        await tester
            .tap(find.byKey(const Key('fitness-today-start-button')));
        await tester.pumpAndSettle();

        // Conteudo da aba Semana fica visivel
        expect(
          find.byKey(const Key('fitness-day-chip')),
          findsNWidgets(7),
        );
      },
    );

    testWidgets('aba Semana renderiza strip de 7 dias', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      expect(find.byKey(const Key('fitness-day-chip')), findsNWidgets(7));
    });

    testWidgets('aba Semana renderiza um card por exercicio do dia',
        (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      // Plano da segunda tem 4 exercicios (peito e triceps).
      expect(
        find.byKey(const Key('fitness-exercise-card')),
        findsNWidgets(4),
      );
    });

    testWidgets('tap em set dot marca como concluido', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      expect(find.text('0 / 4'), findsAtLeast(1));

      await tester.tap(find.byKey(const Key('fitness-set-dot')).first);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('1 / 4'), findsAtLeast(1));
    });

    testWidgets('tap num set ja marcado desfaz', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      final firstDot = find.byKey(const Key('fitness-set-dot')).first;

      await tester.tap(firstDot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('1 / 4'), findsAtLeast(1));

      await tester.tap(firstDot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('0 / 4'), findsAtLeast(1));
    });

    testWidgets(
      'aba Semana: tap em outro dia troca lista de exercicios',
      (tester) async {
        await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
        await tester.pump(const Duration(milliseconds: 16));
        await goToSemana(tester);

        // Dia 4 (quinta) e descanso na catalog padrao.
        await tester.tap(find.byKey(const Key('fitness-day-chip')).at(3));
        await tester.pump(const Duration(milliseconds: 50));

        expect(find.text('Dia de descanso'), findsOneWidget);
        expect(
          find.byKey(const Key('fitness-exercise-card')),
          findsNothing,
        );
      },
    );

    testWidgets('reset zera o progresso semanal', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      await tester.tap(find.byKey(const Key('fitness-set-dot')).first);
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('fitness-weekly-percent')), findsOneWidget);
      expect(find.text('0%'), findsNothing);

      // Reset esta no AppBar — visivel em qualquer aba.
      await tester.tap(find.byKey(const Key('fitness-reset-button')));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('aba Progresso renderiza percent grande + barras por dia',
        (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));
      await goToProgresso(tester);

      expect(
        find.byKey(const Key('fitness-progress-percent')),
        findsOneWidget,
      );
      // Stats: sequencia, volume, sets/dia
      expect(find.text('Sequencia'.toUpperCase()), findsOneWidget);
      expect(find.text('Volume'.toUpperCase()), findsOneWidget);
      expect(find.text('Sets/dia'.toUpperCase()), findsOneWidget);
    });
  });
}
