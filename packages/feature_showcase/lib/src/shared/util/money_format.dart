/// Formatador BRL compartilhado pelos mocks do showcase. Recebe valor
/// em centavos (double, pra evitar erro de arredondamento) e devolve
/// "R$ 1.234,56" no padrao pt-BR. Vive em `shared/` porque mais de um
/// mock precisa (e-commerce e delivery hoje); o de imobiliaria mantem
/// implementacao privada propria por usar input em int.
String formatBrl(double priceCents) {
  final asReais = priceCents / 100;
  final integer = asReais.truncate();
  final cents = ((asReais - integer) * 100).round().toString().padLeft(2, '0');
  final intStr = _withThousands(integer);
  return 'R\$ $intStr,$cents';
}

String _withThousands(int value) {
  final s = value.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return buf.toString();
}
