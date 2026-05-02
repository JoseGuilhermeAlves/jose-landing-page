import 'package:core/src/result/result.dart';

/// Contrato base de UseCase. Toda regra de negocio do domain implementa este
/// contrato e retorna um [Result] em vez de lancar exceptions.
abstract class UseCase<Out, In> {
  const UseCase();

  Future<Result<Out>> call(In input);
}

/// Variante para usecases sem entrada. Evita o sentinel `NoParams()`.
abstract class NoParamsUseCase<Out> {
  const NoParamsUseCase();

  Future<Result<Out>> call();
}
