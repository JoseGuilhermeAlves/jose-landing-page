import 'package:feature_showcase/src/fitness/data/mesocycle_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/logged_session.dart';
import 'package:feature_showcase/src/fitness/domain/muscle_group.dart';
import 'package:feature_showcase/src/fitness/domain/session_summary.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SessionSummary', () {
    const template = MesocycleCatalog.pushA;

    SetEntry set({
      required int index,
      required double weight,
      required int reps,
      bool completed = true,
    }) {
      return SetEntry(
        id: 'set-$index',
        index: index,
        weightKg: weight,
        reps: reps,
        rpe: 8,
        completed: completed,
      );
    }

    LoggedSession buildSession() {
      return LoggedSession(
        id: 'session-test',
        templateId: template.id,
        startedAt: DateTime(2026, 5, 28, 9),
        finishedAt: DateTime(2026, 5, 28, 10, 5),
        programWeek: 2,
        peakStrain: 14.5,
        sets: {
          'bench-press': [
            set(index: 1, weight: 80, reps: 8),
            set(index: 2, weight: 85, reps: 6),
            // Set incompleto nao deve contar volume nem PR.
            set(index: 3, weight: 90, reps: 5, completed: false),
          ],
          'lateral-raise': [
            set(index: 1, weight: 12, reps: 15),
          ],
        },
      );
    }

    SessionSummary build() => SessionSummary.fromSession(
      session: buildSession(),
      template: template,
      nameOf: (id) => id == 'bench-press' ? 'Supino reto' : id,
    );

    test('conta apenas sets concluidos', () {
      final summary = build();
      // 2 do supino + 1 da elevacao lateral = 3.
      expect(summary.completedSets, 3);
    });

    test('volume total soma apenas sets concluidos', () {
      final summary = build();
      // 80*8 + 85*6 + 12*15 = 640 + 510 + 180 = 1330.
      expect(summary.totalVolumeKg, 1330);
    });

    test('PR de cada exercicio e o set concluido mais pesado', () {
      final summary = build();
      final benchPr = summary.prs.firstWhere(
        (pr) => pr.exerciseId == 'bench-press',
      );
      // O set de 90kg estava incompleto — PR e o de 85kg.
      expect(benchPr.weightKg, 85);
      expect(benchPr.reps, 6);
      expect(benchPr.exerciseName, 'Supino reto');
    });

    test('PRs ordenados por carga decrescente', () {
      final summary = build();
      expect(summary.prs.first.weightKg, 85);
      expect(summary.prs.last.weightKg, 12);
    });

    test('volume por musculo distribui no primario e acessorios', () {
      final summary = build();
      // bench-press: primario chest, acessorios triceps + shoulders.
      // Volume do supino = 640 + 510 = 1150 (sets concluidos).
      final chest = summary.volumePerMuscle[MuscleGroup.chest] ?? 0;
      expect(chest, greaterThan(0));
      // Primario recebe o volume integral; acessorios uma fracao menor.
      final triceps = summary.volumePerMuscle[MuscleGroup.triceps] ?? 0;
      expect(chest, greaterThan(triceps));
    });

    test('mostWorkedMuscle e o de maior volume', () {
      final summary = build();
      expect(summary.mostWorkedMuscle, MuscleGroup.chest);
    });

    test('strain delta vem do pico e impacta recovery', () {
      final summary = build();
      expect(summary.strainDelta, 14.5);
      expect(summary.recoveryImpactPercent, greaterThan(0));
      expect(summary.recoveryImpactPercent, lessThanOrEqualTo(40));
    });

    test('duracao deriva do intervalo da sessao', () {
      final summary = build();
      expect(summary.duration, const Duration(hours: 1, minutes: 5));
    });

    test('sessao vazia produz agregados zerados', () {
      final empty = LoggedSession(
        id: 'empty',
        templateId: template.id,
        startedAt: DateTime(2026, 5, 28, 9),
        finishedAt: DateTime(2026, 5, 28, 9, 10),
        programWeek: 1,
        peakStrain: 0,
        sets: const {},
      );
      final summary = SessionSummary.fromSession(
        session: empty,
        template: template,
        nameOf: (id) => id,
      );
      expect(summary.completedSets, 0);
      expect(summary.totalVolumeKg, 0);
      expect(summary.prs, isEmpty);
      expect(summary.mostWorkedMuscle, isNull);
    });
  });
}
