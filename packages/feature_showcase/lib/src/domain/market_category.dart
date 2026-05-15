/// Categorias de produto no mock Aurora. Cobrem o catalogo de
/// hortifruti/emporio com uma granularidade que justifica as bancas
/// (cada banca atende uma ou duas categorias).
enum MarketCategory {
  fruits('Frutas', 'Da estacao, colhidas pra entrega'),
  greens('Verduras', 'Folhas, ervas e raizes'),
  bakery('Padaria', 'Pao do dia, fermentacao natural'),
  dairy('Laticinios', 'Queijo, manteiga, iogurte'),
  pantry('Mercearia', 'Graos, azeite, conserva');

  const MarketCategory(this.label, this.description);

  /// Rotulo curto pra chips e cards.
  final String label;

  /// Frase descritiva pra hero/card da categoria.
  final String description;
}
