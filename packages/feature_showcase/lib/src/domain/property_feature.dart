/// Caracteristicas listaveis do imovel no mock Solar. Cada uma vira
/// um chip/glyph no detalhe; o painter `SolarFeatureIcon` desenha o
/// glifo por feature.
enum PropertyFeature {
  pool('Piscina'),
  garage('Vaga coberta'),
  garden('Jardim'),
  balcony('Varanda'),
  suite('Suite'),
  barbecue('Churrasqueira'),
  solar('Aquecimento solar'),
  borehole('Poco artesiano');

  const PropertyFeature(this.label);
  final String label;
}
