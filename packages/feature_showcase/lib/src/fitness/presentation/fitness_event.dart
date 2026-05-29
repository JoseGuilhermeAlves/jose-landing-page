import 'package:equatable/equatable.dart';

/// Eventos do bloc Pulso na versao dark Whoop. Antigos (FitnessSet
/// Completed/Undone/DaySelected/Reset) foram substituidos por um
/// fluxo de logger real — set entries com weight/reps/RPE — e por
/// eventos de recovery/strain.
sealed class FitnessEvent extends Equatable {
  const FitnessEvent();

  @override
  List<Object?> get props => const [];
}

/// Abre a sessao planejada pra `weekday` (1..7). Cria uma
/// [LoggedSession] vazia com sets default por exercicio. No-op se
/// ja existe sessao ativa pro mesmo template.
class SessionStarted extends FitnessEvent {
  const SessionStarted({required this.weekday, required this.now});
  final int weekday;
  final DateTime now;

  @override
  List<Object?> get props => [weekday, now];
}

/// Registra (ou atualiza) um set durante a sessao ativa. Se [setIndex]
/// nao existir ainda, o bloc cria; se existir, atualiza in-place.
/// O parametro `completed` controla se o set conta como concluido —
/// quando passa de false pra true, o strain accumulator avanca.
class SetLogged extends FitnessEvent {
  const SetLogged({
    required this.exerciseId,
    required this.setIndex,
    required this.weightKg,
    required this.reps,
    required this.rpe,
    required this.completed,
  });
  final String exerciseId;
  final int setIndex;
  final double weightKg;
  final int reps;
  final double rpe;
  final bool completed;

  @override
  List<Object?> get props => [
    exerciseId,
    setIndex,
    weightKg,
    reps,
    rpe,
    completed,
  ];
}

/// Troca um exercicio da sessao ativa por uma alternativa do swap
/// sheet. Mantem index original; novos sets sao criados pro
/// substituto.
class ExerciseSwapped extends FitnessEvent {
  const ExerciseSwapped({
    required this.originalExerciseId,
    required this.replacementExerciseId,
  });
  final String originalExerciseId;
  final String replacementExerciseId;

  @override
  List<Object?> get props => [originalExerciseId, replacementExerciseId];
}

/// Fecha a sessao ativa, congelando `finishedAt` e zerando o
/// `activeSession`. Snapshot da sessao continua acessivel via
/// historico (futuramente).
class SessionFinished extends FitnessEvent {
  const SessionFinished({required this.now});
  final DateTime now;

  @override
  List<Object?> get props => [now];
}

/// Foco do strip do ProgramPage (1..7).
class ProgramDaySelected extends FitnessEvent {
  const ProgramDaySelected(this.weekday);
  final int weekday;

  @override
  List<Object?> get props => [weekday];
}

/// Foco do timeline RecoveryPage (0 = hoje, -1 = ontem...).
class RecoveryHistorySelected extends FitnessEvent {
  const RecoveryHistorySelected(this.offsetDays);
  final int offsetDays;

  @override
  List<Object?> get props => [offsetDays];
}

/// Pull-to-refresh dos dados de recovery — pro mock so re-emite o
/// snapshot atual com timestamp novo. Mantido pra UI ter feedback.
class RecoveryRefreshed extends FitnessEvent {
  const RecoveryRefreshed();
}

/// Inicia o rest timer com [seconds]. Bloc dispara timer interno
/// que emite `RestTicked` a cada segundo. No-op se ja ha rest timer
/// ativo (pra evitar interromper countdown em curso).
class RestStarted extends FitnessEvent {
  const RestStarted(this.seconds);
  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

/// Tick interno do bloc (1Hz). Decrementa `state.restTimer.remaining`;
/// quando bate 0, o bloc cancela o timer e zera o sub-state.
class RestTicked extends FitnessEvent {
  const RestTicked();
}

/// Estende ou reduz o rest timer ativo em [seconds] segundos
/// (pode ser negativo). Ajusta total + remaining em paralelo pra
/// manter o ratio do progresso coerente.
class RestExtended extends FitnessEvent {
  const RestExtended(this.seconds);
  final int seconds;

  @override
  List<Object?> get props => [seconds];
}

/// Pula o rest timer da sessao ativa — cancela timer interno e
/// limpa sub-state.
class RestSkipped extends FitnessEvent {
  const RestSkipped();
}

/// Zera tudo — usado por testes e botao "reset demo" no debug.
class FitnessReset extends FitnessEvent {
  const FitnessReset();
}
