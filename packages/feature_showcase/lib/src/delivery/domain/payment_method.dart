import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

/// Forma de pagamento mock do checkout Aurora. Sem gateway real — so a
/// narrativa de escolha. O `kind` define o glifo exibido na lista.
enum PaymentKind { creditCard, pix, cashOnDelivery }

@immutable
class PaymentMethod extends Equatable {
  const PaymentMethod({
    required this.id,
    required this.label,
    required this.detail,
    required this.kind,
  });

  final String id;

  /// Rotulo principal ("Cartao de credito", "Pix", "Dinheiro").
  final String label;

  /// Linha secundaria ("Final 4821", "Aprovacao na hora", "Na entrega").
  final String detail;

  final PaymentKind kind;

  /// Linha unica usada pelo pedido (`paymentLabel`): rotulo · detalhe.
  String get oneLine => '$label · $detail';

  @override
  List<Object?> get props => [id, label, detail, kind];
}
