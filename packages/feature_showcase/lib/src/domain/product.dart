import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Produto do mock de e-commerce. Sem imagem real — emoji fica
/// graceful em qualquer renderer e mantem o demo leve.
@immutable
class Product extends Equatable {
  const Product({
    required this.id,
    required this.name,
    required this.priceCents,
    required this.emoji,
  });

  final String id;
  final String name;

  /// Preco em centavos (evita arredondamento de double).
  final double priceCents;

  /// Emoji "produto" — substituto leve pra imagem real no demo.
  final String emoji;

  /// Formatado como BRL: "R\$ 129,90".
  String get formattedPrice {
    final asReais = priceCents / 100;
    final integer = asReais.truncate();
    final cents = ((asReais - integer) * 100).round().toString().padLeft(2, '0');
    final intStr = _withThousands(integer);
    return 'R\$ $intStr,$cents';
  }

  static String _withThousands(int value) {
    final s = value.toString();
    final buf = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
      buf.write(s[i]);
    }
    return buf.toString();
  }

  @override
  List<Object?> get props => [id, name, priceCents, emoji];
}
