import 'package:core/src/failures/failure.dart';
import 'package:equatable/equatable.dart';

/// Either-style: representa sucesso ou falha sem usar exceptions.
///
/// Use `Result.success(value)` ou `Result.failure(failure)` para construir.
/// Casamento exaustivo via `switch` nas subclasses [Success] / [FailureResult].
sealed class Result<T> extends Equatable {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(Failure failure) = FailureResult<T>;

  bool get isSuccess => this is Success<T>;
  bool get isFailure => this is FailureResult<T>;

  /// Reduz para um valor unico, exigindo handler dos dois lados.
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  });

  /// Transforma o valor de sucesso. Se ja for falha, propaga inalterada.
  Result<R> map<R>(R Function(T value) transform);

  /// Encadeia outra operacao que tambem retorna Result.
  Result<R> flatMap<R>(Result<R> Function(T value) transform);
}

final class Success<T> extends Result<T> {
  const Success(this.value);

  final T value;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onSuccess(value);

  @override
  Result<R> map<R>(R Function(T value) transform) =>
      Success<R>(transform(value));

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      transform(value);

  @override
  List<Object?> get props => [value];
}

final class FailureResult<T> extends Result<T> {
  const FailureResult(this.failure);

  final Failure failure;

  @override
  R fold<R>({
    required R Function(T value) onSuccess,
    required R Function(Failure failure) onFailure,
  }) => onFailure(failure);

  @override
  Result<R> map<R>(R Function(T value) transform) => FailureResult<R>(failure);

  @override
  Result<R> flatMap<R>(Result<R> Function(T value) transform) =>
      FailureResult<R>(failure);

  @override
  List<Object?> get props => [failure];
}
