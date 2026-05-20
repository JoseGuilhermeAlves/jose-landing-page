import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

/// Decisao arquitetural exibida em card. Mantida deliberadamente curta:
/// titulo + body de 2 frases. Detalhe completo vive em PROJECT.md.
class ArchDecision extends Equatable {
  const ArchDecision({
    required this.id,
    required this.title,
    required this.body,
    required this.icon,
  });

  final String id;
  final String title;
  final String body;
  final IconData icon;

  @override
  List<Object?> get props => [id, title, body, icon];
}
