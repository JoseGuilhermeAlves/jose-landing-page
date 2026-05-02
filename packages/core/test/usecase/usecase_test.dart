import 'package:core/core.dart';
import 'package:flutter_test/flutter_test.dart';

class _DoubleUseCase extends UseCase<int, int> {
  const _DoubleUseCase();
  @override
  Future<Result<int>> call(int input) async => Result.success(input * 2);
}

class _AlwaysFailsUseCase extends UseCase<int, int> {
  const _AlwaysFailsUseCase();
  @override
  Future<Result<int>> call(int input) async =>
      const Result.failure(ValidationFailure(message: 'sempre falha'));
}

class _PingUseCase extends NoParamsUseCase<String> {
  const _PingUseCase();
  @override
  Future<Result<String>> call() async => const Result.success('pong');
}

void main() {
  group('UseCase', () {
    test('implementacao concreta retorna Result.success', () async {
      const usecase = _DoubleUseCase();
      final result = await usecase(21);
      expect(result, equals(const Result<int>.success(42)));
    });

    test('implementacao concreta retorna Result.failure', () async {
      const usecase = _AlwaysFailsUseCase();
      final result = await usecase(0);
      expect(result.isFailure, isTrue);
    });
  });

  group('NoParamsUseCase', () {
    test('chama sem argumentos e retorna Result', () async {
      const usecase = _PingUseCase();
      final result = await usecase();
      expect(result, equals(const Result<String>.success('pong')));
    });
  });
}
