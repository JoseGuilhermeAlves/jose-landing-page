/// Formatadores BRL compartilhados pelos mocks do showcase.
///
/// Variacoes deliberadas que NAO moram aqui: `formatMiraPrice`
/// (cotacao sem separador de milhar, pro alinhamento mono do book) —
/// ver `finance/util/mira_format.dart`.
library;

/// Recebe valor em centavos (double, pra evitar erro de arredondamento)
/// e devolve "R$ 1.234,56" no padrao pt-BR. Usado por delivery (Aurora),
/// totais do Mira e preco dos imoveis do Solar.
String formatBrl(double priceCents) {
  final asReais = priceCents / 100;
  final integer = asReais.truncate();
  final cents = ((asReais - integer) * 100).round().toString().padLeft(2, '0');
  final intStr = formatThousands(integer);
  return 'R\$ $intStr,$cents';
}

/// Variante sem centavos — "R$ 1.250" — pra labels compactos onde o
/// decimal so adiciona ruido (ex.: slider de preco maximo do Solar).
String formatBrlWhole(int priceCents) =>
    'R\$ ${formatThousands(priceCents ~/ 100)}';

/// Agrupa um inteiro em milhares com ponto ("1234567" -> "1.234.567").
String formatThousands(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
