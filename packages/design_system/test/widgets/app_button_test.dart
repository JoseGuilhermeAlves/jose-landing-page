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
      await tester.tap(find.byType(AppButton));
      expect(taps, 1);
    });

    testWidgets('expoe Semantics como botao habilitado', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _wrap(AppButton(label: 'Ver projetos', onPressed: () {})),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('Ver projetos')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            isEnabled: true,
            hasTapAction: true,
            label: 'Ver projetos',
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('onPressed nulo desabilita o botao', (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(
          _wrap(const AppButton(label: 'desativo', onPressed: null)),
        );

        expect(
          tester.getSemantics(find.bySemanticsLabel('desativo')),
          matchesSemantics(
            isButton: true,
            hasEnabledState: true,
            label: 'desativo',
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('renderiza icone quando provido', (tester) async {
      await tester.pumpWidget(
        _wrap(
          AppButton(label: 'WhatsApp', icon: Icons.message, onPressed: () {}),
        ),
      );
      expect(find.byIcon(Icons.message), findsOneWidget);
    });
  });
}
