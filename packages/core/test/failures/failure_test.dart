import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Failure', () {
    test('subclasses with same message+cause sao iguais (equatable)', () {
      const a = NetworkFailure(message: 'sem internet');
      const b = NetworkFailure(message: 'sem internet');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('subclasses do mesmo tipo com messages diferentes sao distintas', () {
      const a = NetworkFailure(message: 'timeout');
      const b = NetworkFailure(message: 'dns');
      expect(a, isNot(equals(b)));
    });

    test('subclasses de tipos diferentes sao distintas mesmo com mesmo message', () {
      const a = NetworkFailure(message: 'erro');
      const b = ServerFailure(message: 'erro');
      expect(a, isNot(equals(b)));
    });

    test('cause faz parte da igualdade', () {
      const exception = FormatException('bad json');
      const a = ServerFailure(message: 'parse', cause: exception);
      const b = ServerFailure(message: 'parse', cause: exception);
      const c = ServerFailure(message: 'parse');
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('toString inclui runtimeType, message e cause', () {
      const failure = CacheFailure(message: 'chave nao encontrada', cause: 'key=user');
      final s = failure.toString();
      expect(s, contains('CacheFailure'));
      expect(s, contains('chave nao encontrada'));
      expect(s, contains('key=user'));
    });

    test('switch exaustivo cobre todas as variantes', () {
      String describe(Failure f) => switch (f) {
            NetworkFailure() => 'network',
            ServerFailure() => 'server',
            CacheFailure() => 'cache',
            ValidationFailure() => 'validation',
            UnknownFailure() => 'unknown',
          };

      expect(describe(const NetworkFailure(message: '')), 'network');
      expect(describe(const ServerFailure(message: '')), 'server');
      expect(describe(const CacheFailure(message: '')), 'cache');
      expect(describe(const ValidationFailure(message: '')), 'validation');
      expect(describe(const UnknownFailure(message: '')), 'unknown');
    });
  });
}
