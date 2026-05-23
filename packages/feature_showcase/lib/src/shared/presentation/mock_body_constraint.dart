import 'package:flutter/material.dart';

/// Largura maxima do conteudo dos mocks quando exibidos em viewport
/// larga (web/desktop). Simula dimensao de dispositivo mobile — os
/// mocks sao demos de apps moveis, nao dashboards desktop.
const double kMockMaxWidth = 480;

/// Envolve o body de uma pagina mock com constraint de largura maxima
/// e centralizacao horizontal. Em viewport estreita (<= [kMockMaxWidth])
/// nao altera nada; em viewport larga centraliza o conteudo.
class MockBodyConstraint extends StatelessWidget {
  const MockBodyConstraint({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: kMockMaxWidth),
        child: child,
      ),
    );
  }
}
