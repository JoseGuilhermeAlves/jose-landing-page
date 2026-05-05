/// Tipo de projeto que o cliente quer discutir. Eh o conjunto fixo do
/// dropdown do form de contato (PROJECT.md §4.5). O `label` e o que
/// aparece pro usuario.
enum ProjectType {
  newApp('App novo (do zero ao MVP)'),
  existingApp('Evoluir um app existente'),
  consulting('Consultoria tecnica / arquitetura'),
  other('Outro');

  const ProjectType(this.label);
  final String label;
}
