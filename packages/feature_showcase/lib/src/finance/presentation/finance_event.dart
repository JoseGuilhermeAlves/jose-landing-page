import 'package:equatable/equatable.dart';
import 'package:feature_showcase/src/finance/domain/order_side.dart';

/// Eventos do mock Mira. Pequeno e fechado — sao apenas as 3 acoes
/// que o demo precisa: alternar favorito, executar trade, resetar.
sealed class FinanceEvent extends Equatable {
  const FinanceEvent();

  @override
  List<Object?> get props => [];
}

/// Toggle de favorito (watchlist) — aciona quando o usuario adiciona
/// ou remove um ativo da watchlist.
class FinanceFavoriteToggled extends FinanceEvent {
  const FinanceFavoriteToggled(this.assetId);
  final String assetId;

  @override
  List<Object?> get props => [assetId];
}

/// Executa uma ordem (compra ou venda). Em produto real, isso entraria
/// num matching engine; aqui executa instantaneo no preco passado.
/// Atualiza posicao + custo medio + adiciona ao historico de trades.
class FinanceTradeExecuted extends FinanceEvent {
  const FinanceTradeExecuted({
    required this.assetId,
    required this.side,
    required this.quantity,
    required this.priceCents,
  });

  final String assetId;
  final OrderSide side;
  final int quantity;
  final int priceCents;

  @override
  List<Object?> get props => [assetId, side, quantity, priceCents];
}

/// Altera o termo de busca da watchlist/catalogo na home. String vazia
/// limpa o filtro e volta a separacao watchlist / outros ativos. O
/// match e feito por simbolo, nome e setor do ativo.
class FinanceSearchQueryChanged extends FinanceEvent {
  const FinanceSearchQueryChanged(this.query);
  final String query;

  @override
  List<Object?> get props => [query];
}

/// Reseta o portfolio e o historico de trades pros valores iniciais
/// do catalogo. Util pro botao "Resetar demo" e pra testes.
class FinanceReset extends FinanceEvent {
  const FinanceReset();
}
