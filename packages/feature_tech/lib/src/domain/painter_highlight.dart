import 'package:equatable/equatable.dart';

/// Painter custom do projeto exibido no destaque tecnico. Nome do
/// painter em monospace + role curta explicando onde ele aparece.
class PainterHighlight extends Equatable {
  const PainterHighlight({
    required this.name,
    required this.role,
    required this.location,
  });

  /// Nome da classe — renderizado em mono.
  final String name;

  /// O que ele faz, em uma frase.
  final String role;

  /// Pacote/feature em que vive — `animations` ou `feature_showcase/<mock>`.
  final String location;

  @override
  List<Object?> get props => [name, role, location];
}
