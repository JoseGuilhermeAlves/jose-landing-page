/// Paths das rotas do `/labs`. Declarados aqui (e nao no shell) para
/// que feature_labs nao dependa de apps/landing — o shell apenas
/// importa estas constantes ao configurar o `GoRouter`.
abstract final class LabsRoutePaths {
  static const String index = '/labs';

  static const String particles = '/labs/particles';
  static const String timeline = '/labs/timeline';
  static const String border = '/labs/border';
  static const String spinner = '/labs/spinner';
  static const String morphing = '/labs/morphing';
  static const String ripple = '/labs/ripple';
  static const String wave = '/labs/wave';

  /// Lista das paths em ordem do catalogo. Util pra registrar todas
  /// as sub-rotas de uma vez no GoRouter.
  static const List<String> playgroundPaths = [
    particles,
    timeline,
    border,
    spinner,
    morphing,
    ripple,
    wave,
  ];
}
