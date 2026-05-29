/// Copy compartilhada do mock **Pulso** (fitness dark Whoop).
///
/// Centraliza apenas strings que **aparecem em mais de uma tela**.
/// Copy específica de cada página (header de boas-vindas, mensagem de
/// recovery contextual, etc.) permanece inline na widget — co-locada
/// com o layout. Esse arquivo NÃO é um string-table de produção; é um
/// agregador pragmático que evita inconsistência entre Hoje / Programa
/// / Recovery / Session logger / Exercise detail.
///
/// Convenção visual do mock: eyebrows e labels de seção em CAIXA ALTA
/// com letter-spacing larga; valores em monospace. As constantes
/// abaixo já vêm formatadas — quem consome só passa adiante.
abstract final class PulsoCopy {
  // Marca.
  static const String brandName = 'PULSO';

  // Eyebrows / section labels (reutilizados em múltiplas páginas).
  static const String eyebrowTodayWorkout = 'TREINO DE HOJE';
  static const String eyebrowProgram = 'PROGRAMA';
  static const String eyebrowRecovery = 'RECOVERY';
  static const String eyebrowContributors = 'CONTRIBUINTES';
  static const String eyebrowSleep = 'SONO';
  static const String eyebrowMuscleHeatmap = 'HEATMAP MUSCULAR';
  static const String eyebrowStrainHistory = 'STRAIN · 7 DIAS';
  static const String eyebrowPrescribedLoad = 'CARGA PRESCRITA';
  static const String eyebrowExecutionTempo = 'TEMPO DE EXECUÇÃO';
  static const String eyebrowLoadHistory = 'HISTÓRICO DE CARGA';
  static const String eyebrowTakeaway = 'TAKEAWAY';

  // Métricas curtas (chips / cards).
  static const String labelStrain = 'STRAIN';
  static const String labelStrainTarget = 'STRAIN ALVO';
  static const String labelHrv = 'HRV';
  static const String labelRhr = 'RHR';
  static const String labelSleep = 'SONO';
  static const String labelWeek = 'SEMANA';
  static const String labelFocus = 'FOCO';
  static const String labelIntensity = 'INTENSIDADE';
  static const String labelSets = 'SETS';
  static const String labelVolume = 'VOLUME';

  // CTAs.
  static const String startWorkout = 'Iniciar treino';
  static const String finishWorkout = 'Finalizar';
  static const String swapExercise = 'Trocar exercício';

  // Estado / mensagens.
  static const String restDayTitle = 'Dia de descanso';
  static const String restDayBody =
      'Use o dia pra mobilidade leve e sono prolongado.';
  static const String sessionNotStarted = 'Sessão não iniciada.';
  static const String exerciseNotFound = 'Exercício não encontrado.';
  static const String sessionFinishedSnack =
      'Sessão finalizada. Strain registrado.';

  // Recovery — copy contextual baseada na banda.
  static String recoveryAdvice(double percent) {
    if (percent < 34) {
      return 'Corpo pede pausa. Aceite o stiff hoje, pegue intensidade amanhã.';
    }
    if (percent < 67) {
      return 'Banda média. Mantenha o volume planejado, sem buscar PR.';
    }
    return 'Tudo verde. Use a janela pra trabalho intenso no padrão do mesociclo.';
  }

  static String muscleAdvice(double score) {
    if (score < 34) {
      return 'Cadeia trashada. Foque em alongamento e hidratação.';
    }
    if (score < 67) {
      return 'Banda média. Mantenha o trabalho na zona prescrita.';
    }
    return 'Boa janela. Use pra carga pesada se o plano pedir.';
  }

  // Dias da semana — usados em headers ("Segunda", "Terça"…).
  static const List<String> weekdayLabels = [
    'Segunda',
    'Terça',
    'Quarta',
    'Quinta',
    'Sexta',
    'Sábado',
    'Domingo',
  ];
}
