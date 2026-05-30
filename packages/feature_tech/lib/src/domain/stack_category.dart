/// Agrupamento das libs do stack pra apresentacao. Cada categoria
/// vira um cluster visual proprio na `TechSection`.
enum StackCategory {
  framework('Framework'),
  state('Estado'),
  routing('Rotas'),
  graphics('Graficos'),
  networking('Rede'),
  persistence('Persistencia'),
  codegen('Code Generation'),
  architecture('Arquitetura'),
  quality('Qualidade'),
  web('Web / PWA'),
  tooling('Tooling');

  const StackCategory(this.label);

  final String label;
}
