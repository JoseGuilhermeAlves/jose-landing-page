/// Strings genéricas pt-BR pra **affordances primitivos** usados por
/// widgets do design system e por features. NÃO carrega copy de
/// produto — copy específica de hero, about, mocks etc. permanece
/// inline na widget que a apresenta.
///
/// **Por que aqui:** essas strings acompanham os botões/inputs do
/// próprio design system (`AppButton`, futuros campos de form, banners
/// de erro). Centralizar permite que um mesmo "Cancelar" não vire
/// "Cancelar"/"cancelar"/"CANCELAR" espalhados pelo monorepo.
///
/// **Quando migrar pra i18n real:** se o projeto algum dia precisar de
/// outro locale (en, es), este arquivo é o primeiro a virar entrada
/// `.arb` pra `flutter_localizations` + `gen_l10n`. Por enquanto,
/// portfolio pt-BR único — `gen_l10n` seria ceremony prematuro.
///
/// Regras:
/// - Apenas strings reusáveis em ≥ 2 lugares.
/// - Sem placeholders dinâmicos complexos (nada de `Hello {name}`).
///   Esses ficam inline na widget.
/// - Capitalização consistente: primeira letra maiúscula em verbos
///   (Cancelar, Voltar), uppercase em status (CARREGANDO).
abstract final class CommonStrings {
  // Ações primárias / botões.
  static const String cancel = 'Cancelar';
  static const String back = 'Voltar';
  static const String close = 'Fechar';
  static const String continueAction = 'Continuar';
  static const String confirm = 'Confirmar';
  static const String retry = 'Tentar novamente';
  static const String loadMore = 'Carregar mais';
  static const String save = 'Salvar';
  static const String delete = 'Excluir';
  static const String edit = 'Editar';
  static const String share = 'Compartilhar';

  // Estados de UI.
  static const String loading = 'Carregando…';
  static const String empty = 'Sem itens por aqui.';
  static const String genericError =
      'Algo deu errado. Tente novamente em instantes.';

  // Affordances de navegação / chrome.
  static const String openInNew = 'Abrir em nova guia';
  static const String search = 'Buscar';

  // Acessibilidade — labels semânticos genéricos pra elementos sem
  // texto visível (ícones, dividers animados, etc.).
  static const String semanticsClose = 'Fechar';
  static const String semanticsLoadingSpinner = 'Carregando conteúdo';
}
