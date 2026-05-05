import 'package:design_system/design_system.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
        theme: AppTheme.dark(),
        home: child,
      );

  // Ancora deterministica.
  final today = DateTime(2026, 5, 4);

  Widget makeDemo({Set<DateTime>? preBooked}) {
    return SchedulingDemo(today: today, preBookedSlots: preBooked ?? const {});
  }

  group('SchedulingDemo', () {
    testWidgets('renderiza strip de 14 dias', (tester) async {
      await tester.pumpWidget(wrap(makeDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byKey(const Key('scheduling-day-chip')),
        findsAtLeast(14),
      );
    });

    testWidgets('renderiza 18 slots para o dia selecionado', (tester) async {
      await tester.pumpWidget(wrap(makeDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      expect(
        find.byKey(const Key('scheduling-slot-tile')),
        findsNWidgets(18),
      );
    });

    testWidgets('tap em slot livre faz dele booked (label muda)',
        (tester) async {
      await tester.pumpWidget(wrap(makeDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      // Tap no primeiro slot — comeca free, deve virar booked.
      await tester.tap(find.byKey(const Key('scheduling-slot-tile')).first);
      await tester.pump(const Duration(milliseconds: 50));

      expect(find.text('Reservado'), findsAtLeast(1));
    });

    testWidgets('tap num slot ja booked cancela (volta pra livre)',
        (tester) async {
      await tester.pumpWidget(wrap(makeDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      final firstSlot = find.byKey(const Key('scheduling-slot-tile')).first;

      // Reserva
      await tester.tap(firstSlot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Reservado'), findsAtLeast(1));

      // Cancela
      await tester.tap(firstSlot);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Reservado'), findsNothing);
    });

    testWidgets('tap num slot indisponivel nao reserva', (tester) async {
      // Pre-bloqueia o primeiro slot do dia.
      final preBookedSlot = today.add(const Duration(hours: 9));
      await tester.pumpWidget(wrap(makeDemo(preBooked: {preBookedSlot})));
      await tester.pump(const Duration(milliseconds: 16));

      await tester.tap(find.byKey(const Key('scheduling-slot-tile')).first);
      await tester.pump();

      expect(find.text('Reservado'), findsNothing);
      expect(find.textContaining('ndispon'), findsAtLeast(1));
    });

    testWidgets('tap em outra data troca os slots exibidos', (tester) async {
      await tester.pumpWidget(wrap(makeDemo()));
      await tester.pump(const Duration(milliseconds: 16));

      // Reserva um slot do dia 1
      await tester.tap(find.byKey(const Key('scheduling-slot-tile')).first);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Reservado'), findsAtLeast(1));

      // Vai pra dia 2
      await tester.tap(find.byKey(const Key('scheduling-day-chip')).at(1));
      await tester.pump(const Duration(milliseconds: 50));

      // Os slots do dia 2 nao incluem a reserva (estado por dia).
      expect(find.text('Reservado'), findsNothing);

      // Voltando pro dia 1, a reserva persiste
      await tester.tap(find.byKey(const Key('scheduling-day-chip')).first);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.text('Reservado'), findsAtLeast(1));
    });
  });
}
