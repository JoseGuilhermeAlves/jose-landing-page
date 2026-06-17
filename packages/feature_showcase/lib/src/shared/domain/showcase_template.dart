import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Template demonstravel por nicho (PROJECT.md §4.3) — delivery,
/// imobiliaria, finance. Cada um e um sub-flow dentro da feature;
/// quando `hasDemo == false`, o card fica listado como "em breve".
@immutable
class ShowcaseTemplate extends Equatable {
  const ShowcaseTemplate({
    required this.id,
    required this.label,
    required this.description,
    required this.icon,
    required this.hasDemo,
  });

  final String id;
  final String label;
  final String description;
  final IconData icon;

  /// Quando false, o card mostra badge "em breve" e tap nao abre nada.
  final bool hasDemo;

  @override
  List<Object?> get props => [id, label, description, icon, hasDemo];

  @override
  String toString() =>
      'ShowcaseTemplate(id: $id, label: $label, hasDemo: $hasDemo)';
}
