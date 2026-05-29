/// Pacote `core` — placeholder pra primitivos compartilhados do
/// monorepo (Failure, Result<T>, UseCase contract, exceptions de borda
/// data). Os primitivos foram removidos por estarem em código morto
/// (nenhuma feature importava). A casca permanece pra manter o ponto
/// canônico no topo da hierarquia (`core ← design_system ← animations
/// ← feature_*`) caso primitivos compartilhados sejam reintroduzidos.
library;
