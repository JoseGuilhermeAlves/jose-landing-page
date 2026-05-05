import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: Scaffold(body: Center(child: child)),
      );

  group('LoadingSpinner', () {
    testWidgets('respeita o size pedido', (tester) async {
      await tester.pumpWidget(wrap(const LoadingSpinner(size: 64)));
      final size = tester.getSize(find.byType(LoadingSpinner));
      expect(size, const Size(64, 64));
    });

    testWidgets('expoe Semantics liveRegion com label "Carregando"',
        (tester) async {
      final handle = tester.ensureSemantics();
      try {
        await tester.pumpWidget(wrap(const LoadingSpinner()));
        await tester.pump(const Duration(milliseconds: 16));

        expect(
          tester.getSemantics(find.bySemanticsLabel('Carregando')),
          matchesSemantics(
            label: 'Carregando',
            isLiveRegion: true,
          ),
        );
      } finally {
        handle.dispose();
      }
    });

    testWidgets('avanca o progresso entre frames (animacao em loop)',
        (tester) async {
      await tester.pumpWidget(wrap(const LoadingSpinner()));
      await tester.pump(const Duration(milliseconds: 16));

      LoadingSpinnerPainter painterAt() {
        final paint = tester.widget<CustomPaint>(
          find.descendant(
            of: find.byType(LoadingSpinner),
            matching: find.byType(CustomPaint),
          ),
        );
        return paint.painter! as LoadingSpinnerPainter;
      }

      final p0 = painterAt().progress;
      await tester.pump(const Duration(milliseconds: 200));
      final p1 = painterAt().progress;

      expect(p1, isNot(equals(p0)));

      // limpa o controller pendente para nao vazar timer no teardown
      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('usa color do parametro quando provida', (tester) async {
      await tester.pumpWidget(
        wrap(const LoadingSpinner(color: Color(0xFFFF00FF))),
      );
      await tester.pump(const Duration(milliseconds: 16));

      final paint = tester.widget<CustomPaint>(
        find.descendant(
          of: find.byType(LoadingSpinner),
          matching: find.byType(CustomPaint),
        ),
      );
      final painter = paint.painter as LoadingSpinnerPainter?;
      expect(painter, isNotNull);
      expect(painter!.color, const Color(0xFFFF00FF));

      await tester.pumpWidget(const SizedBox());
    });
  });
}
