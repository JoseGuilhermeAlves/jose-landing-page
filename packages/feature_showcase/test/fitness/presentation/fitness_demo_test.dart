import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Future<void> _pumpDemo(WidgetTester tester, {int today = 1}) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData.dark(),
        home: FitnessDemo(today: today),
      ),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
  }

  testWidgets('FitnessDemo renderiza shell + bottom nav', (tester) async {
    await _pumpDemo(tester);
    expect(find.text('PULSO'), findsOneWidget);
    // Bottom nav labels devem estar visiveis.
    expect(find.text('Hoje'), findsOneWidget);
    expect(find.text('Programa'), findsOneWidget);
    expect(find.text('Recovery'), findsOneWidget);
  });

  testWidgets('Bottom nav troca pra Programa e mostra timeline', (
    tester,
  ) async {
    await _pumpDemo(tester);
    await tester.tap(find.text('Programa'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('PROGRAMA'), findsAtLeast(1));
    expect(find.textContaining('Hipertrofia'), findsOneWidget);
  });

  testWidgets('Bottom nav troca pra Recovery e mostra dashboard', (
    tester,
  ) async {
    await _pumpDemo(tester);
    await tester.tap(find.text('Recovery'));
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump(const Duration(milliseconds: 900));
    expect(find.text('Como o corpo respondeu ontem.'), findsOneWidget);
  });

  testWidgets('CTA "Iniciar treino" renderiza na Today page', (tester) async {
    await _pumpDemo(tester);
    final cta = find.text('Iniciar treino');
    await tester.scrollUntilVisible(
      cta,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(cta, findsOneWidget);
  });
}
