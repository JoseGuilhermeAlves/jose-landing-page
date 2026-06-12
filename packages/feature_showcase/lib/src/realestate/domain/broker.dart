import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Corretor responsavel pelo imovel no mock Solar. Headshot real entra
/// via [photoAsset]; quando ausente, o avatar cai no monograma desenhado
/// (`ShowcaseMonogramAvatar`). Telefone e e-mail sao mock reconheciveis como
/// "decorativos".
///
/// Campos `role`, `bio`, `yearsActive` e `photoAsset` sao aditivos com
/// default vazio/zero — preservam compat com qualquer construcao legada
/// que so passava id/name/creci/phone/email.
@immutable
class Broker extends Equatable {
  const Broker({
    required this.id,
    required this.name,
    required this.creci,
    required this.phone,
    required this.email,
    this.role = '',
    this.bio = '',
    this.yearsActive = 0,
    this.photoAsset,
  });

  final String id;

  /// Nome composto curto ("Maria L." / "Carlos B.") — preserva
  /// privacidade no mock.
  final String name;

  /// Numero CRECI mock pra dar veracidade.
  final String creci;

  final String phone;
  final String email;

  /// Papel/especialidade ("Especialista em chacaras") — eyebrow no
  /// perfil. Vazio em corretores legados.
  final String role;

  /// Bio editorial pro perfil do corretor (1-2 frases). Vazio em
  /// corretores legados.
  final String bio;

  /// Anos de atuacao — vira stat no perfil. 0 quando nao se aplica.
  final int yearsActive;

  /// Caminho do headshot (relativo ao pacote `feature_showcase`). Null
  /// cai no monograma desenhado via `ShowcaseMonogramAvatar` no `ShowcasePhoto`.
  final String? photoAsset;

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
