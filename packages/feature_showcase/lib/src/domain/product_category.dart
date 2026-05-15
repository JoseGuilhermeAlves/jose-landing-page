/// Categoria editorial do produto do mock Garoa (cafe-livraria). O
/// catalogo da loja e curado em torno dessas categorias — diferente
/// da loja eclectica original, faz a marca soar coerente.
enum ProductCategory {
  /// Cafes em grao e moidos.
  coffee('Cafes', 'Em grao e moidos, torra propria'),

  /// Livros e diarios curados.
  bookshop('Livraria', 'Tiragens curtas, ensaio e poesia'),

  /// Papelaria — cadernos, canetas, papel.
  stationery('Papelaria', 'Cadernos, canetas e papel'),

  /// Objetos de mesa — canecas, prensas, bules.
  tabletop('Mesa', 'Caneca, prensa francesa, bule');

  const ProductCategory(this.label, this.description);

  /// Rotulo curto pra chips e cards (ex.: "Cafes").
  final String label;

  /// Frase descritiva pra hero da categoria.
  final String description;
}
