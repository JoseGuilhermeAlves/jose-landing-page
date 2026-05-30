import 'package:design_system/l10n/generated/app_localizations.dart';

/// Copy compartilhada do mock **Pulso** (fitness dark Whoop).
///
/// Centraliza strings que aparecem em mais de uma tela, resolvendo
/// via AppLocalizations. Callers passam `context.l10n` uma vez e
/// acessam getters tipados.
class PulsoCopy {
  const PulsoCopy(this._l10n);

  final AppLocalizations _l10n;

  String get brandName => 'PULSO';

  String get eyebrowTodayWorkout => _l10n.pulso_eyebrowTodayWorkout;
  String get eyebrowProgram => _l10n.pulso_eyebrowProgram;
  String get eyebrowRecovery => _l10n.pulso_eyebrowRecovery;
  String get eyebrowContributors => _l10n.pulso_eyebrowContributors;
  String get eyebrowSleep => _l10n.pulso_eyebrowSleep;
  String get eyebrowMuscleHeatmap => _l10n.pulso_eyebrowMuscleHeatmap;
  String get eyebrowStrainHistory => _l10n.pulso_eyebrowStrainHistory;
  String get eyebrowPrescribedLoad => _l10n.pulso_eyebrowPrescribedLoad;
  String get eyebrowExecutionTempo => _l10n.pulso_eyebrowExecutionTempo;
  String get eyebrowLoadHistory => _l10n.pulso_eyebrowLoadHistory;
  String get eyebrowTakeaway => _l10n.pulso_eyebrowTakeaway;

  String get labelStrain => _l10n.pulso_labelStrain;
  String get labelStrainTarget => _l10n.pulso_labelStrainTarget;
  String get labelHrv => _l10n.pulso_labelHrv;
  String get labelRhr => _l10n.pulso_labelRhr;
  String get labelSleep => _l10n.pulso_labelSleep;
  String get labelWeek => _l10n.pulso_labelWeek;
  String get labelFocus => _l10n.pulso_labelFocus;
  String get labelIntensity => _l10n.pulso_labelIntensity;
  String get labelSets => _l10n.pulso_labelSets;
  String get labelVolume => _l10n.pulso_labelVolume;

  String get startWorkout => _l10n.pulso_ctaStartWorkout;
  String get finishWorkout => _l10n.pulso_ctaFinish;
  String get swapExercise => _l10n.pulso_ctaSwapExercise;

  String get restDayTitle => _l10n.pulso_restDayTitle;
  String get restDayBody => _l10n.pulso_restDayBody;
  String get sessionNotStarted => _l10n.pulso_errorSessionNotStarted;
  String get exerciseNotFound => _l10n.pulso_errorExerciseNotFound;
  String get sessionFinishedSnack => _l10n.pulso_snackbarSessionFinished;

  String recoveryAdvice(double percent) {
    if (percent < 34) return _l10n.pulso_recoveryAdviceLow;
    if (percent < 67) return _l10n.pulso_recoveryAdviceMedium;
    return _l10n.pulso_recoveryAdviceHigh;
  }

  String muscleAdvice(double score) {
    if (score < 34) return _l10n.pulso_muscleAdviceLow;
    if (score < 67) return _l10n.pulso_muscleAdviceMedium;
    return _l10n.pulso_muscleAdviceHigh;
  }

  List<String> get weekdayLabels => [
    _l10n.pulso_weekdayMon,
    _l10n.pulso_weekdayTue,
    _l10n.pulso_weekdayWed,
    _l10n.pulso_weekdayThu,
    _l10n.pulso_weekdayFri,
    _l10n.pulso_weekdaySat,
    _l10n.pulso_weekdaySun,
  ];
}
