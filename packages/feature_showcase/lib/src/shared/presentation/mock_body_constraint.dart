import 'package:flutter/material.dart';

/// Largura maxima do conteudo dos mocks em viewport larga. Valor alto
/// o suficiente pra que o demo preencha bem a tela em desktop/web sem
/// esticar texto a ponto de quebrar leitura.
const double kMockMaxWidth = 960;

/// Envolve o body de uma pagina mock com constraint responsiva.
/// Em mobile (< 600 lp) nao restringe — o conteudo preenche a
/// viewport naturalmente. Em desktop/web centraliza com
/// [kMockMaxWidth] pra manter legibilidade sem parecer app minusculo.
class MockBodyConstraint extends StatelessWidget {
  const MockBodyConstraint({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    if (width < 600) return child;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMockMaxWidth),
        child: child,
      ),
    );
  }
}
