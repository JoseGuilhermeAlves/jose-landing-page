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

    group('SchedulingAppointmentConfirmed', () {
      final appointment = Appointment(
        id: 'VIT-0001',
        serviceId: 'sv-discovery',
        serviceName: 'Discovery 1h',
        specialistId: 's-sofia',
        specialistName: 'Sofia A.',
        slot: morning,
        durationMinutes: 60,
        priceCents: 28000,
      );

      blocTest<SchedulingBloc, SchedulingState>(
        'adiciona ao confirmedAppointments e ao userBookedSlots',
        build: makeBloc,
        act: (bloc) =>
            bloc.add(SchedulingAppointmentConfirmed(appointment)),
        verify: (bloc) {
          expect(bloc.state.confirmedAppointments, hasLength(1));
          expect(bloc.state.confirmedAppointments.first.id, 'VIT-0001');
          expect(bloc.state.userBookedSlots, contains(morning));
        },
      );

      blocTest<SchedulingBloc, SchedulingState>(
        'idempotente: confirmar o mesmo id duas vezes nao duplica',
        build: makeBloc,
        act: (bloc) => bloc
          ..add(SchedulingAppointmentConfirmed(appointment))
          ..add(SchedulingAppointmentConfirmed(appointment)),
        verify: (bloc) {
          expect(bloc.state.confirmedAppointments, hasLength(1));
        },
      );

      blocTest<SchedulingBloc, SchedulingState>(
        'ignora confirmacao se slot ja esta em preBookedSlots',
        build: () => makeBloc(preBooked: {morning}),
        act: (bloc) =>
            bloc.add(SchedulingAppointmentConfirmed(appointment)),
        verify: (bloc) {
          expect(bloc.state.confirmedAppointments, isEmpty);
          expect(bloc.state.userBookedSlots, isEmpty);
        },
      );

      test(
        'nextAppointment retorna o mais cedo entre varios confirmados',
        () async {
          final later = Appointment(
            id: 'VIT-0002',
            serviceId: 'sv-foto-produto',
            serviceName: 'Sessao de produto em estudio',
            specialistId: 's-lucas',
            specialistName: 'Lucas M.',
            slot: afternoon,
            durationMinutes: 120,
            priceCents: 89000,
          );
          final bloc = makeBloc()
            ..add(SchedulingAppointmentConfirmed(later))
            ..add(SchedulingAppointmentConfirmed(appointment));
          await Future<void>.delayed(Duration.zero);
          expect(bloc.state.nextAppointment?.slot, morning);
          await bloc.close();
        },
      );
    });
  });
}
