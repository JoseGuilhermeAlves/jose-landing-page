import 'package:animations/animations.dart';
import 'package:design_system/design_system.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: child),
  );

  ParticleFieldPainter currentPainter(WidgetTester tester) {
    final paint = tester.widget<CustomPaint>(
      find.descendant(
        of: find.byType(ParticleField),
        matching: find.byType(CustomPaint),
      ),
    );
    return paint.painter! as ParticleFieldPainter;
  }

  group('ParticleField', () {
    testWidgets('renderiza com cor primaria do tema por default', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 200, height: 200, child: ParticleField())),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(find.byType(ParticleField), findsOneWidget);
      expect(currentPainter(tester).particleCount, greaterThan(0));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('avanca o tick continuamente (animacao em loop)', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 200, height: 200, child: ParticleField())),
      );
      await tester.pump(const Duration(milliseconds: 16));
      final t0 = currentPainter(tester).controller!.value;
      await tester.pump(const Duration(milliseconds: 200));
      final t1 = currentPainter(tester).controller!.value;
      expect(t1, isNot(equals(t0)));

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets('mouse hover atualiza pointer no painter', (tester) async {
      await tester.pumpWidget(
        wrap(const SizedBox(width: 300, height: 200, child: ParticleField())),
      );
      await tester.pump(const Duration(milliseconds: 16));

      expect(currentPainter(tester).pointerListenable!.value, isNull);

      final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
      await gesture.addPointer(location: Offset.zero);
      addTearDown(gesture.removePointer);

      await gesture.moveTo(tester.getCenter(find.byType(ParticleField)));
      await tester.pump(const Duration(milliseconds: 50));

      expect(currentPainter(tester).pointerListenable!.value, isNotNull);

      // sai da area limpa o pointer
      await gesture.moveTo(const Offset(-100, -100));
      await tester.pump(const Duration(milliseconds: 50));
      expect(currentPainter(tester).pointerListenable!.value, isNull);

      await tester.pumpWidget(const SizedBox());
    });

    testWidgets(
      'eventos rapidos do pointer sao throttled (chega 1 update por janela)',
      (tester) async {
        await tester.pumpWidget(
          wrap(const SizedBox(width: 300, height: 200, child: ParticleField())),
        );
        await tester.pump(const Duration(milliseconds: 16));

        final gesture = await tester.createGesture(
          kind: PointerDeviceKind.mouse,
        );
        await gesture.addPointer(location: Offset.zero);
        addTearDown(gesture.removePointer);

        final center = tester.getCenter(find.byType(ParticleField));

        // Disparo varios moves dentro de uma janela curta. Sem throttle,
        // o pointer do painter pularia para a ultima posicao a cada frame.
        // Com throttle, o painter so ve a primeira posicao da janela.
        await gesture.moveTo(center);
        await tester.pump(const Duration(milliseconds: 4));
        final firstPointer = currentPainter(tester).pointerListenable!.value;

        await gesture.moveTo(center + const Offset(20, 0));
        await tester.pump(const Duration(milliseconds: 4));
        await gesture.moveTo(center + const Offset(40, 0));
        await tester.pump(const Duration(milliseconds: 4));

        // Dentro da janela de throttle (default ~16ms), o pointer ainda
        // deve ser igual ao primeiro registrado.
        expect(
          currentPainter(tester).pointerListenable!.value,
          equals(firstPointer),
        );

        // Apos passar a janela, o proximo movimento e aceito.
        await tester.pump(const Duration(milliseconds: 30));
        await gesture.moveTo(center + const Offset(60, 0));
        await tester.pump(const Duration(milliseconds: 4));
        expect(
          currentPainter(tester).pointerListenable!.value,
          isNot(equals(firstPointer)),
        );

        await tester.pumpWidget(const SizedBox());
      },
    );
  });
}
