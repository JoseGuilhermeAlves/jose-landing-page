/// Tipo de imovel exibido no catalogo da demo.
enum PropertyType {
  apartment('Apartamento'),
  house('Casa');

  const PropertyType(this.label);
  final String label;
}
