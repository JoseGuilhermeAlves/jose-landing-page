import 'package:flutter/widgets.dart';

/// Metadado estatico de cada playground exibido na home do `/labs`.
/// Imutavel, sem Equatable — comparacao por instancia ja basta porque
/// o catalogo e canonico (lista const declarada no pacote feature_labs).
@immutable
class PlaygroundDescriptor {
  const PlaygroundDescriptor({
    required this.id,
    required this.label,
    required this.shortDescription,
    required this.routePath,
    required this.icon,
    required this.painterName,
  });

  /// Slug curto — usado em keys e ids.
  final String id;

  /// Titulo no card.
  final String label;

  /// Linha de descricao mostrada no card.
  final String shortDescription;

  /// Path absoluta da sub-rota (ex.: `/labs/particles`).
  final String routePath;

  final IconData icon;

  /// Nome da classe do painter — exibido como tag tecnica.
  final String painterName;
}
