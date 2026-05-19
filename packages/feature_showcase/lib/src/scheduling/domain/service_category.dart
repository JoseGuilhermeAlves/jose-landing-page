/// Categorias de servico no mock Vitral — estudio que vende horas de
/// profissionais especializados. Cobre os tipos de servico mais
/// vendidos no recorte (consultoria, fotografia, design, marketing).
enum ServiceCategory {
  consulting('Consultoria', 'Sessoes 1:1 e workshops'),
  photography('Fotografia', 'Sessoes em estudio e externa'),
  design('Design', 'Identidade visual, UI e ilustracao'),
  marketing('Marketing', 'Planejamento e campanha');

  const ServiceCategory(this.label, this.description);

  /// Rotulo curto pra chips e cards.
  final String label;

  /// Frase descritiva pra hero/card da categoria.
  final String description;
}
