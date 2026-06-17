/// Lista centralizada de rotas — qualquer feature que precise navegar
/// importa daqui em vez de hardcodar a string.
abstract final class RoutePaths {
  static const String home = '/';

  static const String notFoundFallback = '/404';

  /// Demo de um mock do showcase (`/demo/delivery`, `/demo/finance`,
  /// `/demo/realestate`). Como e uma rota go_router, a abertura entra no
  /// historico do navegador — o botao voltar fecha o mock em vez de sair.
  static const String demo = '/demo/:id';

  /// Monta o path concreto da rota [demo] pra um id de mock.
  static String demoFor(String id) => '/demo/$id';
}
