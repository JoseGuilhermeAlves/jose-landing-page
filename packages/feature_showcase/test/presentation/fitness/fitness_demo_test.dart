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

  group('FitnessDemo', () {
    testWidgets('renderiza strip de 7 dias', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byKey(const Key('fitness-day-chip')),
        findsNWidgets(7),
      );
    });

    testWidgets('renderiza um card pra cada exercicio do dia',
        (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Plano da segunda tem 4 exercicios (peito e triceps).
      expect(
        find.byKey(const Key('fitness-exercise-card')),
        findsNWidgets(4),
      );
    });

    testWidgets('tap em set dot marca como concluido', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // 0/4 inicialmente no primeiro exercicio (supino, 4 sets).
      expect(find.text('0 / 4'), findsAtLeast(1));

      await tester.tap(find.byKey(const Key('fitness-set-dot')).first);
      await tester.pump(const Duration(milliseconds: 50));

      // Agora 1/4 — texto antigo deixa de existir, novo aparece.
      expect(find.text('1 / 4'), findsAtLeast(1));
    });

    testWidgets('tap num set ja marcado desfaz', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      final firstDot = find.byKey(const Key('fitness-set-dot')).first;

      await tester.tap(firstDot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('1 / 4'), findsAtLeast(1));

      await tester.tap(firstDot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('0 / 4'), findsAtLeast(1));
    });

    testWidgets('tap em outro dia troca lista de exercicios',
        (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Dia 4 (quinta) e descanso na catalog padrao — chip de descanso.
      // Procura o chip de quinta e clica.
      await tester.tap(find.byKey(const Key('fitness-day-chip')).at(3));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Dia de descanso'), findsOneWidget);
      expect(find.byKey(const Key('fitness-exercise-card')), findsNothing);
    });

    testWidgets('reset zera o progresso semanal', (tester) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Marca 2 sets em exercicios diferentes.
      await tester.tap(find.byKey(const Key('fitness-set-dot')).first);
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byKey(const Key('fitness-weekly-percent')), findsOneWidget);
      // Sanity — depois de 1 set marcado, percent ja nao e 0%.
      expect(find.text('0%'), findsNothing);

      await tester.tap(find.byKey(const Key('fitness-reset-button')));
      await tester.pumpAndSettle();

      expect(find.text('0%'), findsOneWidget);
    });
  });
}
