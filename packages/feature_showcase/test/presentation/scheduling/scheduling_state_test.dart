import 'package:feature_showcase/feature_showcase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // 2026-05-04 (segunda) — ancora deterministica para tests.
  final today = DateTime(2026, 5, 4);

  SchedulingState makeState({
    DateTime? selectedDate,
    Set<DateTime>? preBookedSlots,
    Set<DateTime>? userBookedSlots,
  }) {
    return SchedulingState(
      today: today,
      selectedDate: selectedDate ?? today,
      preBookedSlots: preBookedSlots ?? const {},
      userBookedSlots: userBookedSlots ?? const {},
    );
  }

  group('SlotStatus', () {
    test('expoe os 3 estados: free, booked, unavailable', () {
      expect(
        SlotStatus.values,
        containsAll([
          SlotStatus.free,
          SlotStatus.booked,
          SlotStatus.unavailable,
        ]),
      );
    });
  });

  group('SchedulingState.availableDates', () {
    test('inicia com 14 dias a partir de today (inclusive)', () {
      final dates = makeState().availableDates;
      expect(dates, hasLength(14));
      expect(dates.first, today);
      expect(dates.last, today.add(const Duration(days: 13)));
    });

    test('todas as datas tem hora zerada (so dia)', () {
      for (final d in makeState().availableDates) {
        expect(d.hour, 0);
        expect(d.minute, 0);
        expect(d.second, 0);
      }
    });
  });

  group('SchedulingState.slotsFor', () {
    test('gera 18 slots de 9h ate 17:30 em janelas de 30 min', () {
      final slots = makeState().slotsFor(today);
      expect(slots, hasLength(18));
      expect(slots.first.start.hour, 9);
      expect(slots.first.start.minute, 0);
      expect(slots[1].start.hour, 9);
      expect(slots[1].start.minute, 30);
      expect(slots.last.start.hour, 17);
      expect(slots.last.start.minute, 30);
    });

    test('slot pre-booked vira unavailable', () {
      final preBooked = today.add(const Duration(hours: 10));
      final slots = makeState(preBookedSlots: {preBooked}).slotsFor(today);
      final mapped = {for (final s in slots) s.start: s.status};
      expect(mapped[preBooked], SlotStatus.unavailable);
    });

    test('slot user-booked vira booked', () {
      final slot = today.add(const Duration(hours: 11, minutes: 30));
      final slots = makeState(userBookedSlots: {slot}).slotsFor(today);
      final mapped = {for (final s in slots) s.start: s.status};
      expect(mapped[slot], SlotStatus.booked);
    });

    test('slot sem nada -> free', () {
      final slots = makeState().slotsFor(today);
      for (final s in slots) {
        expect(s.status, SlotStatus.free);
      }
    });

    test('preBookedSlots tem precedencia sobre userBookedSlots', () {
      // Defesa: se um slot aparece em ambos (caso degenerado),
      // unavailable vence — protege contra inconsistencia.
      final slot = today.add(const Duration(hours: 10));
      final slots = makeState(
        preBookedSlots: {slot},
        userBookedSlots: {slot},
      ).slotsFor(today);
      final mapped = {for (final s in slots) s.start: s.status};
      expect(mapped[slot], SlotStatus.unavailable);
    });
  });
}
