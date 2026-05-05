import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Result', () {
    group('construcao via factory', () {
      test('Result.success cria Success', () {
        const result = Result<int>.success(42);
        expect(result, isA<Success<int>>());
        expect(result.isSuccess, isTrue);
        expect(result.isFailure, isFalse);
      });

      test('Result.failure cria FailureResult', () {
        const result = Result<int>.failure(NetworkFailure(message: 'x'));
        expect(result, isA<FailureResult<int>>());
        expect(result.isSuccess, isFalse);
        expect(result.isFailure, isTrue);
      });
    });

    group('equatable', () {
      test('dois Success com mesmo valor sao iguais', () {
        const a = Result<int>.success(1);
        const b = Result<int>.success(1);
        expect(a, equals(b));
      });

      test('dois FailureResult com mesma Failure sao iguais', () {
        const a = Result<int>.failure(NetworkFailure(message: 'x'));
        const b = Result<int>.failure(NetworkFailure(message: 'x'));
        expect(a, equals(b));
      });

      test('Success != FailureResult mesmo com types iguais', () {
        const a = Result<int>.success(1);
        const b = Result<int>.failure(NetworkFailure(message: 'x'));
        expect(a, isNot(equals(b)));
      });
    });

    group('fold', () {
      test('Success chama onSuccess', () {
        const result = Result<int>.success(7);
        final out = result.fold(
          onSuccess: (v) => 'ok:$v',
          onFailure: (_) => 'fail',
        );
        expect(out, 'ok:7');
      });

      test('FailureResult chama onFailure', () {
        const result = Result<int>.failure(ServerFailure(message: 'boom'));
        final out = result.fold(
          onSuccess: (_) => 'ok',
          onFailure: (f) => 'fail:${f.message}',
        );
        expect(out, 'fail:boom');
      });
    });

    group('map', () {
      test('Success transforma o valor preservando o tipo Result', () {
        const result = Result<int>.success(3);
        final mapped = result.map((v) => v * 2);
        expect(mapped, equals(const Result<int>.success(6)));
      });

      test('FailureResult propaga sem chamar transform', () {
        var called = false;
        const result = Result<int>.failure(NetworkFailure(message: 'x'));
        final mapped = result.map<String>((v) {
          called = true;
          return v.toString();
        });
        expect(called, isFalse);
        expect(mapped.isFailure, isTrue);
      });
    });

    group('flatMap', () {
      test('Success encadeia outra operacao Result', () {
        const result = Result<int>.success(2);
        final chained = result.flatMap<int>((v) => Result.success(v + 10));
        expect(chained, equals(const Result<int>.success(12)));
      });

      test('Success pode encadear em FailureResult', () {
        const result = Result<int>.success(2);
        final chained = result.flatMap<int>(
          (v) => const Result.failure(ValidationFailure(message: 'invalido')),
        );
        expect(chained.isFailure, isTrue);
      });

      test('FailureResult propaga sem chamar transform', () {
        var called = false;
        const result = Result<int>.failure(NetworkFailure(message: 'x'));
        final chained = result.flatMap<int>((v) {
          called = true;
          return Result.success(v);
        });
        expect(called, isFalse);
        expect(chained.isFailure, isTrue);
      });
    });

    group('props (forca acesso ao Equatable.props)', () {
      // Equatable usa identical() antes de comparar props; com instancias
      // const canonicalizadas isso curto-circuita. Aqui forcamos o acesso
      // direto a `.props` pra cobrir os getters das duas variantes.
      test('Success expoe [value]', () {
        const result = Result<int>.success(42);
        expect(result.props, [42]);
      });

      test('FailureResult expoe [failure]', () {
        const failure = NetworkFailure(message: 'x');
        const result = Result<int>.failure(failure);
        expect(result.props, [failure]);
      });
    });

    test('switch exaustivo nas variantes', () {
      String describe(Result<int> r) => switch (r) {
            Success(:final value) => 'ok:$value',
            FailureResult(:final failure) => 'fail:${failure.message}',
          };

      expect(describe(const Result.success(5)), 'ok:5');
      expect(
        describe(const Result.failure(CacheFailure(message: 'c'))),
        'fail:c',
      );
    });
  });
}
