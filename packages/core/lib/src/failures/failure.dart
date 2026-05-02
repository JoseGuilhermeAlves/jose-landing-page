import 'package:equatable/equatable.dart';

/// Erro de dominio. Atravessa as camadas em vez de exceptions.
///
/// Exceptions (NetworkException, etc.) so existem na borda data;
/// repositories convertem para Failure antes de subir pro domain.
sealed class Failure extends Equatable {
  const Failure({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  List<Object?> get props => [message, cause];

  @override
  bool? get stringify => true;
}

/// Sem conexao, timeout, DNS, etc.
final class NetworkFailure extends Failure {
  const NetworkFailure({required super.message, super.cause});
}

/// Servidor respondeu com erro (5xx, 4xx nao esperado).
final class ServerFailure extends Failure {
  const ServerFailure({required super.message, super.cause});
}

/// Falha em cache local (storage corrompido, chave nao encontrada).
final class CacheFailure extends Failure {
  const CacheFailure({required super.message, super.cause});
}

/// Input invalido (validacao de form, regra de negocio violada).
final class ValidationFailure extends Failure {
  const ValidationFailure({required super.message, super.cause});
}

/// Catch-all para erros nao categorizados. Usar com moderacao.
final class UnknownFailure extends Failure {
  const UnknownFailure({required super.message, super.cause});
}
