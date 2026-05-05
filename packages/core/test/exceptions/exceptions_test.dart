import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NetworkException', () {
    test('expoe message e cause; e Exception', () {
      const cause = FormatException('socket fechou');
      const ex = NetworkException(message: 'sem internet', cause: cause);
      expect(ex, isA<Exception>());
      expect(ex.message, 'sem internet');
      expect(ex.cause, same(cause));
    });

    test('cause e opcional', () {
      const ex = NetworkException(message: 'timeout');
      expect(ex.cause, isNull);
    });

    test('toString inclui prefixo do tipo e message', () {
      const ex = NetworkException(message: 'timeout');
      expect(ex.toString(), 'NetworkException: timeout');
    });
  });

  group('ServerException', () {
    test('expoe message, cause e statusCode; e Exception', () {
      const cause = FormatException('json invalido');
      const ex = ServerException(
        message: 'parse falhou',
        cause: cause,
        statusCode: 500,
      );
      expect(ex, isA<Exception>());
      expect(ex.message, 'parse falhou');
      expect(ex.cause, same(cause));
      expect(ex.statusCode, 500);
    });

    test('cause e statusCode sao opcionais', () {
      const ex = ServerException(message: 'erro');
      expect(ex.cause, isNull);
      expect(ex.statusCode, isNull);
    });

    test('toString inclui statusCode (mesmo quando null)', () {
      const ex = ServerException(message: 'erro');
      expect(ex.toString(), 'ServerException(null): erro');

      const withCode = ServerException(message: 'forbidden', statusCode: 403);
      expect(withCode.toString(), 'ServerException(403): forbidden');
    });
  });

  group('CacheException', () {
    test('expoe message e cause; e Exception', () {
      const ex = CacheException(message: 'storage corrompido', cause: 'ioerr');
      expect(ex, isA<Exception>());
      expect(ex.message, 'storage corrompido');
      expect(ex.cause, 'ioerr');
    });

    test('cause e opcional', () {
      const ex = CacheException(message: 'chave nao encontrada');
      expect(ex.cause, isNull);
    });

    test('toString inclui prefixo do tipo e message', () {
      const ex = CacheException(message: 'chave nao encontrada');
      expect(ex.toString(), 'CacheException: chave nao encontrada');
    });
  });

  test('os tres exception types sao distintos por runtime type', () {
    const a = NetworkException(message: 'x');
    const b = ServerException(message: 'x');
    const c = CacheException(message: 'x');
    expect(a.runtimeType, isNot(equals(b.runtimeType)));
    expect(a.runtimeType, isNot(equals(c.runtimeType)));
    expect(b.runtimeType, isNot(equals(c.runtimeType)));
  });
}
