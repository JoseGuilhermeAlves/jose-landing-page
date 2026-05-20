/// Lado da ordem — compra ou venda.
enum OrderSide {
  buy('Comprar'),
  sell('Vender');

  const OrderSide(this.label);
  final String label;
}

/// Tipo da ordem — mercado (executa no preco corrente) ou limite
/// (executa so quando o preco bater no `limitPrice`).
enum OrderType {
  market('A mercado'),
  limit('Limitada');

  const OrderType(this.label);
  final String label;
}
