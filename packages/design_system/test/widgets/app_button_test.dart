import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('renderiza o label', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Falar no WhatsApp', onPressed: () {})),
      );
      expect(find.text('Falar no WhatsApp'), findsOneWidget);
    });

    testWidgets('chama onPressed ao tap', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(AppButton(label: 'CTA', onPressed: () => taps++)),
      );
      await tester.tap(find.text('CTA'));
      expect(taps, 1);
    });

    testWidgets('onPressed nulo deixa o botao desabilitado', (tester) async {
      var taps = 0;
      await tester.pumpWidget(
        _wrap(const AppButton(label: 'desativo', onPressed: null)),
      );
      // GestureDetector com onTap null nao chama nada — verificamos via Semantics.
      final semantics = tester.getSemantics(find.text('desativo'));
      expect(semantics.hasFlag(SemanticsFlag.isEnabled), isFalse);
      expect(taps, 0);
    });

    testWidgets('expoe Semantics como botao', (tester) async {
      await tester.pumpWidget(
        _wrap(AppButton(label: 'Ver projetos', onPressed: () {})),
      );
      final semantics = tester.getSemantics(find.text('Ver projetos'));
      expect(semantics.hasFlag(SemanticsFlag.isButton), isTrue);
    });

    testWidgets('renderiza icone quando provido', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(
            label: 'WhatsApp',
            icon: Icons.message,
            onPressed: () {},
          ),
        ),
      );
      expect(find.byIcon(Icons.message), findsOneWidget);
    });
  });
}
