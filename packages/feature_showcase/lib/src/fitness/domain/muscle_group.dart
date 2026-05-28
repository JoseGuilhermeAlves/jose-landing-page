/// Grupos musculares canonicos do mock Pulso. Limitado proposital —
/// sao os que a UI (heatmap, body diagram, exercise tagging) e os
/// catalogos referenciam. Nao tentar cobrir anatomia completa.
enum MuscleGroup {
  chest('Peito'),
  back('Costas'),
  shoulders('Ombros'),
  biceps('Biceps'),
  triceps('Triceps'),
  forearms('Antebracos'),
  quads('Quadriceps'),
  hamstrings('Posteriores'),
  glutes('Gluteos'),
  calves('Panturrilhas'),
  core('Core');

  const MuscleGroup(this.label);

  /// Rotulo curto em pt-br usado em chips, labels e tooltips.
  final String label;
}
