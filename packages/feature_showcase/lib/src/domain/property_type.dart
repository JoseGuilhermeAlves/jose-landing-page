/// Tipo de imovel exibido no catalogo da demo. Apartamento e casa
/// continuam disponiveis por compat com testes legados; chacara e
/// terreno foram adicionados pelo mock Solar (interior).
enum PropertyType {
  apartment('Apartamento'),
  house('Casa'),
  chacara('Chacara'),
  land('Terreno');

  const PropertyType(this.label);
  final String label;
}
