import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('PixelFont', () {
    test('todo glifo mapeado tem 7 linhas dentro de 5 bits', () {
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
      const pairs = {
        'á': 'A',
        'ã': 'A',
        'â': 'A',
        'à': 'A',
        'é': 'E',
        'ê': 'E',
        'í': 'I',
        'ó': 'O',
        'ô': 'O',
        'õ': 'O',
        'ú': 'U',
        'ü': 'U',
        'ç': 'C',
        'Ç': 'C',
      };
      pairs.forEach((accented, base) {
        expect(
          PixelFont.rowsFor(accented),
          PixelFont.rowsFor(base),
          reason: '"$accented" deveria render como "$base"',
        );
        expect(
          PixelFont.rowsFor(accented),
          isNot(PixelFont.rowsFor(' ')),
          reason: '"$accented" nao pode virar espaco',
        );
      });
    });

    test('canRenderAll: latino/acento/numero/pontuacao sao renderaveis', () {
      expect(PixelFont.canRenderAll('ENGENHARIA'), isTrue);
      expect(PixelFont.canRenderAll('Olá, José! 2026'), isTrue);
      expect(PixelFont.canRenderAll('GitHub / LinkedIn'), isTrue);
    });

    test('canRenderAll: scripts fora do latino retornam false', () {
      expect(PixelFont.canRenderAll('日本語'), isFalse);
      expect(PixelFont.canRenderAll('Привет'), isFalse);
      expect(PixelFont.canRenderAll('技术'), isFalse);
      expect(PixelFont.canRenderAll('STAGE 技'), isFalse);
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
      expect(size.height, (PixelFont.glyphHeight * 2 + 2) * 3);
    });

    testWidgets('idioma nao-latino cai num Text real (nao some)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelText('日本語', color: Colors.pink, pixelSize: 5),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
      final text = tester.widget<Text>(find.byType(Text));
      expect(text.data, '日本語');
    });

    testWidgets('idioma latino NAO usa fallback (segue pixel/CustomPaint)', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: PixelText('STAGE', color: Colors.pink, pixelSize: 5),
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsNothing);
      expect(find.byType(CustomPaint), findsWidgets);
    });
  });
}
