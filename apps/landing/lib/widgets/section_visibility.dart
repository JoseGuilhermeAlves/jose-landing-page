import 'package:flutter/material.dart';
import 'package:visibility_detector/visibility_detector.dart';

/// Pausa todos os tickers de uma secao da home quando ela sai do
/// viewport — a landing soma ~16 `AnimationController`s em `repeat()`
/// (particulas, cosmos, constelacoes, neon headline, wave dividers,
/// previews do showcase). Sem isso, tudo anima o tempo inteiro mesmo
/// fora da tela, queimando CPU/GPU e bateria.
///
/// Mecanica: `VisibilityDetector` reporta a fracao visivel; o `TickerMode`
/// abaixo habilita/desabilita os tickers criados pela subarvore
/// (`SingleTickerProviderStateMixin` e afins respeitam `TickerMode.of`).
/// Controllers em `repeat()` apenas ficam mudos enquanto desabilitados e
/// retomam ao voltar — sem estado extra nos filhos.
///
/// Tambem respeita a preferencia de acessibilidade "reduzir animacoes"
/// do sistema (`MediaQuery.disableAnimationsOf`): com ela ativa, os
/// tickers ficam desabilitados mesmo com a secao visivel.
///
/// Estado inicial e "visivel" — evita um primeiro frame congelado antes
/// do callback do detector e mantem testes de widget (que nunca disparam
/// o callback agendado) com o comportamento atual.
class SectionVisibility extends StatefulWidget {
  const SectionVisibility({required this.id, required this.child, super.key});

  /// Identificador estavel da secao — vira a `Key` do detector (o
  /// `VisibilityDetector` exige key unica pra rastrear o elemento).
  final String id;

  final Widget child;

  @override
  State<SectionVisibility> createState() => _SectionVisibilityState();
}

class _SectionVisibilityState extends State<SectionVisibility> {
  bool _visible = true;

  void _onVisibilityChanged(VisibilityInfo info) {
    if (!mounted) return;
    final visible = info.visibleFraction > 0;
    if (visible != _visible) setState(() => _visible = visible);
  }

  @override
  Widget build(BuildContext context) {
    final disableAnimations = MediaQuery.disableAnimationsOf(context);
    return VisibilityDetector(
      key: Key('section-visibility-${widget.id}'),
      onVisibilityChanged: _onVisibilityChanged,
      child: TickerMode(
        enabled: _visible && !disableAnimations,
        child: widget.child,
      ),
    );
  }
}
