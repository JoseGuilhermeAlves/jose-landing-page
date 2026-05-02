/// Exceptions internas usadas SO na borda data (datasources, http clients).
///
/// Repositories capturam estas e mapeiam para `Failure` antes de propagar
/// para domain. Nunca atravesse essas exceptions ate presentation.
class NetworkException implements Exception {
  const NetworkException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'NetworkException: $message';
}

class ServerException implements Exception {
  const ServerException({required this.message, this.cause, this.statusCode});

  final String message;
  final Object? cause;
  final int? statusCode;

  @override
  String toString() => 'ServerException($statusCode): $message';
}

class CacheException implements Exception {
  const CacheException({required this.message, this.cause});

  final String message;
  final Object? cause;

  @override
  String toString() => 'CacheException: $message';
}
