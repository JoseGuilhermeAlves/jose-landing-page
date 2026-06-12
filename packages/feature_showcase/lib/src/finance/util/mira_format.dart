/// Helpers de formato locais ao mock Mira. Sao especificos do dominio
/// de investimentos (variacao em %, volume abreviado, preco com 2
/// casas) — nao reaproveitam pra outros mocks.
library;

import 'package:feature_showcase/src/shared/util/money_format.dart';

/// Formata centavos como "R$ 38,42" (numero puro com virgula decimal,
/// sem separador de milhar — precos da B3 raramente passam de 999,99
/// na unidade do papel, e moneyformat compartilhado usa ponto como
/// separador de milhar que prejudica o alinhamento mono).
String formatMiraPrice(int priceCents) {
  final reais = priceCents / 100;
  final integer = reais.truncate();
  final fraction = ((reais - integer) * 100).round().toString().padLeft(2, '0');
  return 'R\$ $integer,$fraction';
}

/// Formata variacao em pontos-base como "+2,15%" / "-0,87%".
String formatMiraChangePct(int bps) {
  final pct = bps / 100;
  final sign = bps >= 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

/// Formata volume com sufixo K/M/B — "234K", "1,2M", "32,7M".
/// Usado nos tooltips do candlestick e no cabecalho do detalhe.
String formatMiraVolume(int volume) {
  if (volume >= 1000000000) {
    return '${(volume / 1000000000).toStringAsFixed(1).replaceAll('.', ',')}B';
  }
  if (volume >= 1000000) {
    return '${(volume / 1000000).toStringAsFixed(1).replaceAll('.', ',')}M';
  }
  if (volume >= 1000) {
    return '${(volume / 1000).round()}K';
  }
  return volume.toString();
}

/// Formata um BRL "grande" (totais de portfolio, market value) com
/// separador de milhar tipo "R$ 12.345,67". Diferente de
/// `formatMiraPrice`, agrupa em milhares — mesma semantica do
/// `formatBrl` compartilhado, entao apenas delega.
String formatMiraTotal(int priceCents) => formatBrl(priceCents.toDouble());

/// Data abreviada "14/05" pros tooltips de candlestick e historico.
String formatMiraShortDate(DateTime ts) {
  final d = ts.day.toString().padLeft(2, '0');
  final m = ts.month.toString().padLeft(2, '0');
  return '$d/$m';
}

/// Data completa "14/05/2026 - 13:22" pros itens de historico de trade.
String formatMiraFullDate(DateTime ts) {
  final d = ts.day.toString().padLeft(2, '0');
  final m = ts.month.toString().padLeft(2, '0');
  final y = ts.year.toString();
  final hh = ts.hour.toString().padLeft(2, '0');
  final mm = ts.minute.toString().padLeft(2, '0');
  return '$d/$m/$y · $hh:$mm';
}
