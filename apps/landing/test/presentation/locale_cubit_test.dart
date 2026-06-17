import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:landing/presentation/locale_cubit.dart';

void main() {
  group('LocaleCubit', () {
    test('resolve locale do sistema suportado (en-US -> en)', () {
      final cubit = LocaleCubit(systemLocale: const Locale('en', 'US'));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('en'));
    });

    test('resolve pt-BR pra pt', () {
      final cubit = LocaleCubit(systemLocale: const Locale('pt', 'BR'));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('pt'));
    });

    test('locale do sistema nao suportado cai em pt (fallback)', () {
      final cubit = LocaleCubit(systemLocale: const Locale('ar'));
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('pt'));
    });

    test('fallback e pt mesmo nao sendo o primeiro da lista gerada', () {
      expect(LocaleCubit.resolveLocale(const Locale('xx')), const Locale('pt'));
    });

    test('resolveLocale casa cada um dos 9 idiomas suportados', () {
      const codes = ['pt', 'en', 'es', 'fr', 'it', 'de', 'ru', 'ja', 'zh'];
      for (final code in codes) {
        expect(
          LocaleCubit.resolveLocale(Locale(code)).languageCode,
          code,
          reason: 'locale $code deveria resolver pra ele mesmo',
        );
      }
    });

    test('construtor padrao resolve pra um locale suportado', () {
      final cubit = LocaleCubit();
      addTearDown(cubit.close);

      expect(
        LocaleCubit.resolveLocale(cubit.state),
        cubit.state,
        reason: 'estado inicial deve estar entre os suportados',
      );
    });

    test('changeLocale emite os locales na ordem trocada', () {
      final cubit = LocaleCubit(systemLocale: const Locale('pt'));
      addTearDown(cubit.close);

      expectLater(
        cubit.stream,
        emitsInOrder(const [Locale('en'), Locale('ja')]),
      );

      cubit
        ..changeLocale(const Locale('en'))
        ..changeLocale(const Locale('ja'));
    });

    test(
      'locale repetido consecutivo nao re-emite (Cubit deduplica)',
      () async {
        final cubit = LocaleCubit(systemLocale: const Locale('pt'));
        addTearDown(cubit.close);

        final emitted = <Locale>[];
        final sub = cubit.stream.listen(emitted.add);

        cubit
          ..changeLocale(const Locale('en'))
          ..changeLocale(const Locale('en'))
          ..changeLocale(const Locale('es'));

        await Future<void>.delayed(Duration.zero);
        await sub.cancel();

        expect(emitted, const [Locale('en'), Locale('es')]);
      },
    );
  });
}
