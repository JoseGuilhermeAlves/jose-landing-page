import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Corretor responsavel pelo imovel no mock Solar. Sem foto real —
/// avatar e desenhado via monograma. Telefone e e-mail sao mock
/// reconheciveis como "decorativos".
@immutable
class Broker extends Equatable {
  const Broker({
    required this.id,
    required this.name,
    required this.creci,
    required this.phone,
    required this.email,
  });

  final String id;

  /// Nome composto curto ("Maria L." / "Carlos B.") — preserva
  /// privacidade no mock.
  final String name;

  /// Numero CRECI mock pra dar veracidade.
  final String creci;

  final String phone;
  final String email;

  /// Iniciais para o monograma no avatar.
  String get monogram {
    final parts = name.split(RegExp(r'\s+'));
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, creci, phone, email];
}
