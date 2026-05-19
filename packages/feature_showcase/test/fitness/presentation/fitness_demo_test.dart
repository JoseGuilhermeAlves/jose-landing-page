import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(theme: AppTheme.dark(), home: child);

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

  group('PulsoHomePage (dashboard de entrada)', () {
    testWidgets(
      'abre na home com greeting, workout card, rings e diagrama corporal',
      (tester) async {
        await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
        await tester.pump(const Duration(milliseconds: 16));

        // Header com greeting e marca
        expect(find.byKey(const Key('pulso-home-greeting')), findsOneWidget);
        expect(find.textContaining('Pulso'), findsOneWidget);

        // Card "treino de hoje" com silhueta de atleta + CTA
        expect(
          find.byKey(const Key('pulso-home-workout-card')),
          findsOneWidget,
        );
        expect(find.byKey(const Key('pulso-athlete-figure')), findsOneWidget);
        expect(find.byKey(const Key('pulso-home-cta')), findsOneWidget);

        // Activity rings (3 metricas) e diagrama corporal (musculos
        // do dia destacados — segunda tem treino, entao aparece).
        expect(find.byKey(const Key('pulso-activity-rings')), findsOneWidget);
        expect(find.byKey(const Key('pulso-body-diagram')), findsOneWidget);
      },
    );

    testWidgets('tap no CTA "Iniciar treino" leva ao Scaffold com TabBar', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const FitnessDemo(today: today)));
      await tester.pump(const Duration(milliseconds: 16));

      // Antes do CTA: workout card visivel, TabBar nao.
      expect(find.byKey(const Key('pulso-home-workout-card')), findsOneWidget);
      expect(find.text('Hoje'), findsNothing);

      // Scroll pra garantir CTA dentro do viewport (em 800x600 o
      // conteudo todo da home nao cabe sem scroll).
      await tester.ensureVisible(find.byKey(const Key('pulso-home-cta')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('pulso-home-cta')));
      // pumpAndSettle estoura porque varios widgets animam em loop;
      // pumps explicitos dao tempo de setState propagar e do AppBar
      // /TabBar montar.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Depois: TabBar renderizada, home nao mais.
      expect(find.text('Hoje'), findsOneWidget);
      expect(find.text('Semana'), findsOneWidget);
      expect(find.text('Progresso'), findsOneWidget);
      expect(find.byKey(const Key('pulso-home-workout-card')), findsNothing);
    });

    testWidgets('tap na seta de voltar do AppBar retorna pra home', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      // Inicia na TabBar (skipHome).
      expect(find.text('Hoje'), findsOneWidget);

      await tester.tap(find.byKey(const Key('fitness-back-to-home')));
      // Mesmo motivo do teste anterior — animacoes em loop quebram
      // pumpAndSettle.
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 300));

      // Voltou pra home — workout card visivel novamente.
      expect(find.byKey(const Key('pulso-home-workout-card')), findsOneWidget);
      expect(find.text('Hoje'), findsNothing);
    });
  });

  group('FitnessDemo (multi-tab)', () {
    testWidgets('abre na aba Hoje com greeting + hero card', (tester) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
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

    testWidgets('tap em "Iniciar treino" na aba Hoje muda para a aba Semana', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('fitness-today-start-button')));
      await tester.pumpAndSettle();

      // Conteudo da aba Semana fica visivel
      expect(find.byKey(const Key('fitness-day-chip')), findsNWidgets(7));
    });

    testWidgets('aba Semana renderiza strip de 7 dias', (tester) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      expect(find.byKey(const Key('fitness-day-chip')), findsNWidgets(7));
    });

    testWidgets('aba Semana renderiza um card por exercicio do dia', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      // Plano da segunda tem 4 exercicios (peito e triceps).
      expect(find.byKey(const Key('fitness-exercise-card')), findsNWidgets(4));
    });

    testWidgets('tap em set dot marca como concluido', (tester) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      expect(find.text('0 / 4'), findsAtLeast(1));

      await tester.tap(find.byKey(const Key('fitness-set-dot')).first);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('1 / 4'), findsAtLeast(1));
    });

    testWidgets('tap num set ja marcado desfaz', (tester) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
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

    testWidgets('aba Semana: tap em outro dia troca lista de exercicios', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToSemana(tester);

      // Dia 4 (quinta) e descanso na catalog padrao.
      await tester.tap(find.byKey(const Key('fitness-day-chip')).at(3));
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Dia de descanso'), findsOneWidget);
      expect(find.byKey(const Key('fitness-exercise-card')), findsNothing);
    });

    testWidgets('reset zera o progresso semanal', (tester) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
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

    testWidgets('aba Progresso renderiza percent grande + barras por dia', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToProgresso(tester);

      expect(find.byKey(const Key('fitness-progress-percent')), findsOneWidget);
      // Stats: sequencia, volume, sets/dia
      expect(find.text('Sequencia'.toUpperCase()), findsOneWidget);
      expect(find.text('Volume'.toUpperCase()), findsOneWidget);
      expect(find.text('Sets/dia'.toUpperCase()), findsOneWidget);
    });

    testWidgets(
      'tap no chip de descanso abre rest timer sheet com display de tempo',
      (tester) async {
        await tester.pumpWidget(
          wrap(const FitnessDemo(today: today, skipHome: true)),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await goToSemana(tester);

        // Plano da segunda tem 4 exercicios, logo 4 chips. Pega o
        // primeiro (supino reto, 8 reps -> 120s = "2:00").
        await tester.tap(find.byKey(const Key('fitness-rest-chip')).first);
        // Pulses adicionais pra deixar o modal entrar e o Ticker
        // estabilizar; pumpAndSettle estoura porque o Ticker fica
        // emitindo frames sem fim.
        await tester.pump(const Duration(milliseconds: 250));
        await tester.pump(const Duration(milliseconds: 250));

        expect(
          find.byKey(const Key('fitness-rest-timer-display')),
          findsOneWidget,
        );
        expect(
          find.byKey(const Key('fitness-rest-timer-exercise-name')),
          findsOneWidget,
        );
        // Display arranca em 2:00 (supino reto: 8 reps -> 120s).
        // Le o widget direto pelo key pra nao confundir com o chip do
        // card (que tambem mostra "2:00" como duracao padrao).
        final displayText = tester.widget<Text>(
          find.byKey(const Key('fitness-rest-timer-display')),
        );
        expect(displayText.data, '2:00');

        // Dispensa o sheet via "Pular" pro Ticker parar antes do teardown.
        await tester.tap(find.byKey(const Key('fitness-rest-timer-skip')));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.pump(const Duration(milliseconds: 300));

        expect(
          find.byKey(const Key('fitness-rest-timer-display')),
          findsNothing,
        );
      },
    );

    testWidgets('aba Progresso renderiza card de historico de volume', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const FitnessDemo(today: today, skipHome: true)),
      );
      await tester.pump(const Duration(milliseconds: 16));
      await goToProgresso(tester);

      // Scroll pra alcancar o card no fim do conteudo.
      await tester.scrollUntilVisible(
        find.byKey(const Key('fitness-volume-history-card')),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      await tester.pumpAndSettle();

      expect(
        find.byKey(const Key('fitness-volume-history-card')),
        findsOneWidget,
      );
      // Header textual do card e badge "em andamento" (estado inicial
      // sem sets concluidos -> volume zero).
      expect(find.textContaining('Volume'), findsAtLeast(1));
      expect(find.text('em andamento'), findsOneWidget);
    });
  });

  group('ExerciseDetailPage (push do card da aba Semana)', () {
    testWidgets(
      'tap no card de exercicio empurra detail com sumario, historico e musculos',
      (tester) async {
        await tester.pumpWidget(
          wrap(const FitnessDemo(today: today, skipHome: true)),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await goToSemana(tester);

        // Tap no card do supino reto (primeiro exercicio de segunda).
        await tester.tap(
          find.byKey(const Key('fitness-exercise-card-tap')).first,
        );
        // pumpAndSettle estoura por painters em loop; alguns pumps
        // explicitos dao tempo do route push + animacao terminar.
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));

        // Sumario card (sets/reps/carga em destaque) presente.
        expect(
          find.byKey(const Key('exercise-detail-today-card')),
          findsOneWidget,
        );
        // Painter de historico de carga renderizado.
        expect(
          find.byKey(const Key('fitness-exercise-load-chart')),
          findsOneWidget,
        );
        // Botao de voltar do detail no AppBar.
        expect(
          find.byKey(const Key('exercise-detail-back')),
          findsOneWidget,
        );
        // Body diagram do exercicio.
        expect(
          find.byKey(const Key('pulso-body-diagram')),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'tap em set tile dentro do detail marca o set no bloc compartilhado',
      (tester) async {
        await tester.pumpWidget(
          wrap(const FitnessDemo(today: today, skipHome: true)),
        );
        await tester.pump(const Duration(milliseconds: 16));
        await goToSemana(tester);

        await tester.tap(
          find.byKey(const Key('fitness-exercise-card-tap')).first,
        );
        await tester.pump(const Duration(milliseconds: 100));
        await tester.pump(const Duration(milliseconds: 400));

        // No detail: contador comeca em 0/4. O card da aba Semana
        // continua na arvore por baixo do push, entao o texto aparece
        // 2x — basta confirmar a presenca.
        expect(find.text('0 / 4'), findsNWidgets(2));

        await tester.tap(
          find.byKey(const Key('exercise-detail-set-tile')).first,
        );
        await tester.pump(const Duration(milliseconds: 50));

        // Apos o tap, o bloc compartilhado avanca pra 1 — tanto o card
        // sob o push quanto o detail mostram o novo valor.
        expect(find.text('1 / 4'), findsNWidgets(2));
      },
    );
  });
}
