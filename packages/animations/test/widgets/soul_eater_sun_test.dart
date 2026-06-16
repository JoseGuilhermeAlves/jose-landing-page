import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(
    Widget child, {
    bool reduceMotion = false,
    double size = 500,
  }) => MediaQuery(
    data: MediaQueryData(disableAnimations: reduceMotion),
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: Center(
        child: SizedBox(width: size, height: size, child: child),
      ),
    ),
  );

  group('SoulEaterSun', () {
    testWidgets('renderiza e anima sem lancar', (tester) async {
      await tester.pumpWidget(wrap(const SoulEaterSun()));
      // Um frame pra registrar o ticker, outro pra rodar a animacao.
      await tester.pump(const Duration(milliseconds: 16));
      await tester.pump(const Duration(seconds: 1));

      expect(find.byType(SoulEaterSun), findsOneWidget);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('com reduce-motion para a animacao (pumpAndSettle conclui)', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const SoulEaterSun(), reduceMotion: true));
      await tester.pump();
      // Sem reduce-motion isso travaria (loop infinito); aqui deve concluir.
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('reconstroi a geometria ao mudar de tamanho sem lancar', (
      tester,
    ) async {
      await tester.pumpWidget(wrap(const SoulEaterSun()));
      await tester.pump(const Duration(milliseconds: 16));

      // Tamanho menor forca _ensureBuilt a recomputar paths/shaders/brasas.
      await tester.pumpWidget(wrap(const SoulEaterSun(), size: 220));
      await tester.pump(const Duration(milliseconds: 16));

      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox());
    });
  });
}
