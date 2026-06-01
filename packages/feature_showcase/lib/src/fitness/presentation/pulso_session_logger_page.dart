import 'package:design_system/design_system.dart';
import 'package:feature_showcase/src/fitness/data/exercises_catalog.dart';
import 'package:feature_showcase/src/fitness/domain/rest_timer.dart';
import 'package:feature_showcase/src/fitness/domain/session_template.dart';
import 'package:feature_showcase/src/fitness/domain/set_entry.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_bloc.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_brand.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_event.dart';
import 'package:feature_showcase/src/fitness/presentation/fitness_state.dart';
import 'package:feature_showcase/src/fitness/presentation/painters/pulso_set_complete_burst.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_copy.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_exercise_detail_page.dart';
import 'package:feature_showcase/src/fitness/presentation/pulso_swap_exercise_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'pulso_exercise_logging.dart';
part 'pulso_session_bottom_bars.dart';

/// Tela coracao do mock — loga sets em ritmo de treino real. Cada
/// exercicio tem N linhas de set com weight/reps/RPE editaveis e um
/// botao de complete que dispara strain + burst. Sticky bottom mostra
/// rest timer ativo ou CTA pra finalizar a sessao.
///
/// **Rest timer:** o countdown vive no FitnessBloc como
/// `state.restTimer`. Esta widget so dispara eventos (RestStarted,
/// RestExtended, RestSkipped) e le o sub-state — sem Timer local,
/// sem setState, sem gambiarra.
///
/// Os sub-widgets vivem em parts irmas: `pulso_exercise_logging.dart`
/// (card do exercicio + linha de set + steppers) e
/// `pulso_session_bottom_bars.dart` (barra de finalizar + rest timer).
class PulsoSessionLoggerPage extends StatelessWidget {
  const PulsoSessionLoggerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FitnessBloc, FitnessState>(
      builder: (context, state) {
        final session = state.activeSession;
        final template = state.todaysTemplate;
        if (session == null || template == null) {
          return const Scaffold(
            body: Center(child: Text('Sessão não iniciada.')),
          );
        }
        final restTimer = state.restTimer;
        return Scaffold(
          backgroundColor: context.colors.background,
          appBar: _LoggerAppBar(template: template, state: state),
          body: Padding(
            padding: const EdgeInsets.only(bottom: 92),
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: template.exercises.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, i) {
                final original = template.exercises[i];
                final effectiveId = state.effectiveExerciseId(original.id);
                final effective = effectiveId == original.id
                    ? original
                    : (ExercisesCatalog.byId(effectiveId) ?? original);
                return _ExerciseCard(
                  exercise: effective,
                  originalId: original.id,
                  prescribedWeight: state.prescribedWeightFor(original.id),
                  state: state,
                  onSetComplete: () => context.read<FitnessBloc>().add(
                    RestStarted(effective.restSeconds),
                  ),
                );
              },
            ),
          ),
          bottomNavigationBar: SafeArea(
            top: false,
            child: restTimer != null
                ? _RestTimerBanner(
                    timer: restTimer,
                    onAdjust: (delta) => context.read<FitnessBloc>().add(
                      RestExtended(delta),
                    ),
                    onSkip: () => context.read<FitnessBloc>().add(
                      const RestSkipped(),
                    ),
                  )
                : _FinishSessionBar(
                    totalSets: session.completedSetsCount,
                    totalVolumeKg: session.totalVolumeKg,
                    onFinish: () => _finishSession(context),
                  ),
          ),
        );
      },
    );
  }

  void _finishSession(BuildContext context) {
    context.read<FitnessBloc>().add(SessionFinished(now: DateTime.now()));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Sessão finalizada. Strain registrado.')),
    );
    Navigator.of(context).pop();
  }
}

class _LoggerAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _LoggerAppBar({required this.template, required this.state});
  final SessionTemplate template;
  final FitnessState state;

  @override
  Size get preferredSize => const Size.fromHeight(68);

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final week = state.program.currentWeek;
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      surfaceTintColor: colors.background,
      leading: IconButton(
        icon: Icon(Icons.close_rounded, color: colors.onSurface),
        onPressed: () => Navigator.of(context).maybePop(),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            template.label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            'Semana ${state.program.currentWeekIndex} · ${week?.label ?? "—"}',
            style: TextStyle(
              color: colors.onSurfaceMuted,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: AppSpacing.lg),
          child: Center(
            child: _Pill(
              label: '${state.exercisesCompleted}/${template.exercises.length}',
              color: colors.primary,
            ),
          ),
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  const _Pill({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w700,
          fontFamily: FitnessBrand.displayMonoFontFamily,
        ),
      ),
    );
  }
}
