import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PixelFont', () {
    test('todo glifo mapeado tem 7 linhas dentro de 5 bits', () {
      // Varre o alfabeto + digitos + pontuacao comum.
      const sample =
          r'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789 .,:;-_!?/\<>+=*()[]';
      for (final ch in sample.split('')) {
        final rows = PixelFont.rowsFor(ch);
        expect(rows, hasLength(PixelFont.glyphHeight), reason: 'glifo "$ch"');
        for (final r in rows) {
          expect(r, inInclusiveRange(0, 0x1F), reason: 'linha de "$ch"');
        }
      }
    });

    test('char desconhecido cai no glifo de espaco', () {
      expect(PixelFont.rowsFor('€'), PixelFont.rowsFor(' '));
    });

    test('minuscula mapeia pra maiuscula', () {
      expect(PixelFont.rowsFor('a'), PixelFont.rowsFor('A'));
    });

    test('acentos e cedilha caem na letra-base (nao viram buraco)', () {
      // Cobre o conjunto que aparece na copy pt-BR.
      const pairs = {
        'á': 'A', 'ã': 'A', 'â': 'A', 'à': 'A',
        'é': 'E', 'ê': 'E',
        'í': 'I',
        'ó': 'O', 'ô': 'O', 'õ': 'O',
        'ú': 'U', 'ü': 'U',
        'ç': 'C', 'Ç': 'C',
      };
      pairs.forEach((accented, base) {
        expect(
          PixelFont.rowsFor(accented),
          PixelFont.rowsFor(base),
          reason: '"$accented" deveria render como "$base"',
        );
        // E nunca virar espaco (buraco no texto).
        expect(
          PixelFont.rowsFor(accented),
          isNot(PixelFont.rowsFor(' ')),
          reason: '"$accented" nao pode virar espaco',
        );
      });
    });
  });

  group('PixelText', () {
    testWidgets('renderiza sem lancar e calcula tamanho intrinseco', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelText('PRESS START', color: Colors.pink, pixelSize: 5),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);

      final size = tester.getSize(find.byType(PixelText));
      expect(size.width, greaterThan(0));
      expect(size.height, PixelFont.glyphHeight * 5);
    });

    testWidgets('multiplas linhas crescem em altura', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelText('AB\nCD', color: Colors.cyan, pixelSize: 3),
            ),
          ),
        ),
      );

      final size = tester.getSize(find.byType(PixelText));
      // 2 linhas de 7 + 2 de lineSpacing = 16 dots * 3px = 48.
      expect(size.height, (PixelFont.glyphHeight * 2 + 2) * 3);
    });
  });
}
