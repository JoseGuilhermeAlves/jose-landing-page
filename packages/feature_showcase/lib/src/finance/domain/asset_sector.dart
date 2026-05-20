/// Setor economico do ativo no mock Mira. Usado pra agrupar a
/// alocacao do portfolio no donut e filtrar a watchlist por categoria.
/// Lista enxuta — cobre os setores tipicos da B3 sem virar enciclopedia.
enum AssetSector {
  oil('Petroleo & Gas'),
  mining('Mineracao'),
  banking('Bancos'),
  retail('Varejo'),
  tech('Tecnologia'),
  industrial('Industria'),
  utilities('Energia & Saneamento'),
  food('Alimentos & Bebidas');

  const AssetSector(this.label);

  final String label;
}
