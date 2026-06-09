import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/mesocycle_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_history_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_session_summary_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const template = MesocycleCatalog.pushA;

  LoggedSession finishedSession({String id = 'session-1'}) {
    return LoggedSession(
      id: id,
      templateId: template.id,
      startedAt: DateTime(2026, 5, 28, 9),
      finishedAt: DateTime(2026, 5, 28, 10),
      programWeek: 2,
      peakStrain: 13.4,
      sets: const {
        'bench-press': [
          SetEntry(
            id: 'b-1',
            index: 1,
            weightKg: 82,
            reps: 8,
            rpe: 8,
            completed: true,
          ),
          SetEntry(
            id: 'b-2',
            index: 2,
            weightKg: 86,
            reps: 6,
            rpe: 9,
            completed: true,
          ),
        ],
      },
    );
  }

  // Tema raiz ja carrega a AppColorsExtension da marca Pulso pra que
  // tanto a tela inicial quanto rotas empurradas (recap) resolvam
  // `context.colors` sem precisar reaplicar o Theme em cada push —
  // espelha o comportamento real (rotas herdam o tema raiz do app).
  final brandTheme = ThemeData.dark().copyWith(
    extensions: <ThemeExtension<dynamic>>[
      const AppColorsExtension(FitnessBrand.palette),
    ],
  );

  Widget wrap(Widget child, {FitnessBloc? bloc}) {
    return MaterialApp(
      theme: brandTheme,
      home: bloc == null
          ? child
          : BlocProvider.value(value: bloc, child: child),
    );
  }

  // O resumo e uma ListView mais alta que a superficie padrao (800x600);
  // as secoes de baixo (PRs, mapa muscular) ficam fora do viewport e nao
  // sao construidas pelos slivers preguicosos. Uma superficie alta as
  // materializa sem precisar scrollar — mesmo padrao dos testes de demo.
  Future<void> useTallSurface(WidgetTester tester) async {
    await tester.binding.setSurfaceSize(const Size(800, 1600));
    addTearDown(() => tester.binding.setSurfaceSize(null));
  }

  group('PulsoSessionSummaryPage', () {
    testWidgets('mostra KPIs, PRs e mapa muscular do treino', (tester) async {
      await useTallSurface(tester);
      await tester.pumpWidget(
        wrap(
          PulsoSessionSummaryPage(
            session: finishedSession(),
            template: template,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Treino concluído'), findsOneWidget);
      expect(find.text('VOLUME'), findsOneWidget);
      expect(find.text('SETS'), findsOneWidget);
      expect(find.text('RECORDES DA SESSÃO'), findsOneWidget);
      expect(find.text('MÚSCULOS TRABALHADOS'), findsOneWidget);
      // PR mais pesado (86kg x 6) deve aparecer.
      expect(find.text('86kg × 6'), findsOneWidget);
      expect(find.text('Voltar para Hoje'), findsOneWidget);
    });

    testWidgets('modo readOnly troca titulo e esconde CTA', (tester) async {
      await useTallSurface(tester);
      await tester.pumpWidget(
        wrap(
          PulsoSessionSummaryPage(
            session: finishedSession(),
            template: template,
            readOnly: true,
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Registro do treino'), findsOneWidget);
      expect(find.text('Voltar para Hoje'), findsNothing);
    });
  });

  group('PulsoHistoryPage', () {
    testWidgets('estado vazio quando nao ha treinos', (tester) async {
      await useTallSurface(tester);
      final bloc = FitnessBloc(initialDay: 1);
      addTearDown(bloc.close);
      await tester.pumpWidget(wrap(const PulsoHistoryPage(), bloc: bloc));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Nenhum treino registrado ainda'), findsOneWidget);
    });

    testWidgets('lista treinos finalizados e abre o recap', (tester) async {
      await useTallSurface(tester);
      final bloc = FitnessBloc(initialDay: 1);
      addTearDown(bloc.close);
      // Inicia e finaliza um treino pra popular o historico.
      bloc.add(SessionStarted(weekday: 1, now: DateTime(2026, 5, 28, 9)));
      await tester.pump(Duration.zero);
      bloc.add(SessionFinished(now: DateTime(2026, 5, 28, 10)));
      await tester.pump(Duration.zero);

      await tester.pumpWidget(wrap(const PulsoHistoryPage(), bloc: bloc));
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));

      expect(find.text('Histórico'), findsOneWidget);
      // O mesociclo padrao aponta pra semana 3 (currentWeekIndex=3), entao
      // a sessao arquivada carrega programWeek=3 — o card rotula "Semana 3".
      expect(find.textContaining('Semana 3'), findsOneWidget);
      expect(find.text('VOL'), findsOneWidget);
      expect(find.text('STRAIN'), findsOneWidget);

      // Tap abre o recap read-only.
      await tester.tap(find.byType(InkWell).first);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.text('Registro do treino'), findsOneWidget);
    });
  });
}
