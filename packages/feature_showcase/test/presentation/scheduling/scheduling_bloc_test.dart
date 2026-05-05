import 'package:bloc_test/bloc_test.dart';
import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final today = DateTime(2026, 5, 4);
  final tomorrow = today.add(const Duration(days: 1));
  final morning = today.add(const Duration(hours: 10));
  final afternoon = today.add(const Duration(hours: 15));

  SchedulingBloc makeBloc({Set<DateTime>? preBooked}) =>
      SchedulingBloc(today: today, preBookedSlots: preBooked ?? const {});

  group('SchedulingBloc', () {
    test('estado inicial: selectedDate = today, sem userBookings', () {
      final bloc = makeBloc();
      expect(bloc.state.selectedDate, today);
      expect(bloc.state.userBookedSlots, isEmpty);
    });

    blocTest<SchedulingBloc, SchedulingState>(
      'SchedulingDateSelected atualiza selectedDate',
      build: makeBloc,
      act: (bloc) => bloc.add(SchedulingDateSelected(tomorrow)),
      verify: (bloc) => expect(bloc.state.selectedDate, tomorrow),
    );

    blocTest<SchedulingBloc, SchedulingState>(
      'SchedulingSlotBooked adiciona slot a userBookedSlots',
      build: makeBloc,
      act: (bloc) => bloc.add(SchedulingSlotBooked(morning)),
      verify: (bloc) {
        expect(bloc.state.userBookedSlots, contains(morning));
        // Status do slot vira booked
        final slot = bloc.state
            .slotsFor(today)
            .firstWhere((s) => s.start == morning);
        expect(slot.status, SlotStatus.booked);
      },
    );

    blocTest<SchedulingBloc, SchedulingState>(
      'SlotBooked num pre-booked eh ignorado (no-op, nao quebra invariante)',
      build: () => makeBloc(preBooked: {morning}),
      act: (bloc) => bloc.add(SchedulingSlotBooked(morning)),
      expect: () => <SchedulingState>[],
    );

    blocTest<SchedulingBloc, SchedulingState>(
      'SchedulingSlotCancelled remove de userBookedSlots',
      build: makeBloc,
      act: (bloc) => bloc
        ..add(SchedulingSlotBooked(morning))
        ..add(SchedulingSlotBooked(afternoon))
        ..add(SchedulingSlotCancelled(morning)),
      verify: (bloc) {
        expect(bloc.state.userBookedSlots, isNot(contains(morning)));
        expect(bloc.state.userBookedSlots, contains(afternoon));
      },
    );

    blocTest<SchedulingBloc, SchedulingState>(
      'cancelar slot que nao esta booked eh no-op',
      build: makeBloc,
      act: (bloc) => bloc.add(SchedulingSlotCancelled(morning)),
      expect: () => <SchedulingState>[],
    );

    test('bookings persistem ao mudar de data e voltar', () async {
      final bloc = makeBloc()
        ..add(SchedulingSlotBooked(morning))
        ..add(SchedulingDateSelected(tomorrow))
        ..add(SchedulingDateSelected(today));
      await Future<void>.delayed(Duration.zero);
      expect(bloc.state.userBookedSlots, contains(morning));
      await bloc.close();
    });
  });
}
