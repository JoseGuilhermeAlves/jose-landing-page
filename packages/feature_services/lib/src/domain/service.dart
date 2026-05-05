import 'package:equatable/equatable.dart';
import 'package:flutter/widgets.dart';

/// Servico oferecido na landing — value object imutavel.
///
/// Eu intencionalmente nao usei `freezed` aqui porque a classe nao
/// participa de copias parciais nem de unioes seladas. `Equatable` ja
/// resolve igualdade/hashCode com a sobriedade necessaria.
@immutable
class Service extends Equatable {
  const Service({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
  });

  /// Identificador estavel — usado em testes e analytics futuros.
  final String id;
  final String title;
  final String description;
  final IconData icon;

  @override
  List<Object?> get props => [id, title, description, icon];

  @override
  String toString() => 'Service(id: $id, title: $title)';
}
