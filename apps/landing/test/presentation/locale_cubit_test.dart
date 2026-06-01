import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:landing/presentation/locale_cubit.dart';

void main() {
  group('LocaleCubit', () {
    test('estado inicial e pt-BR', () {
      final cubit = LocaleCubit();
      addTearDown(cubit.close);

      expect(cubit.state, const Locale('pt'));
    });

    test('changeLocale emite os locales na ordem trocada', () {
      final cubit = LocaleCubit();
      addTearDown(cubit.close);

      expectLater(
        cubit.stream,
        emitsInOrder(const [Locale('en'), Locale('ja')]),
      );

      cubit
        ..changeLocale(const Locale('en'))
        ..changeLocale(const Locale('ja'));
    });

    test('locale repetido consecutivo nao re-emite (Cubit deduplica)', () async {
      final cubit = LocaleCubit();
      addTearDown(cubit.close);

      final emitted = <Locale>[];
      final sub = cubit.stream.listen(emitted.add);

      cubit
        ..changeLocale(const Locale('en'))
        ..changeLocale(const Locale('en')) // repetido — nao re-emite
        ..changeLocale(const Locale('es'));

      await Future<void>.delayed(Duration.zero);
      await sub.cancel();

      expect(emitted, const [Locale('en'), Locale('es')]);
    });
  });
}
