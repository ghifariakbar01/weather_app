import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/utils/date_formatter_id.dart';

void main() {
  group('DateFormatterId.dayLabel', () {
    test('returns "Hari ini" when the date matches today', () {
      final today = DateTime(2026, 8, 20);
      expect(DateFormatterId.dayLabel(today, today: today), 'Hari ini');
    });

    test('ignores time-of-day when comparing to today', () {
      final today = DateTime(2026, 8, 20, 9, 30);
      final laterSameDay = DateTime(2026, 8, 20, 23, 0);
      expect(DateFormatterId.dayLabel(laterSameDay, today: today), 'Hari ini');
    });

    test('returns the short Indonesian day name for other dates', () {
      final today = DateTime(2026, 8, 20); // Kamis
      expect(
        DateFormatterId.dayLabel(DateTime(2026, 8, 21), today: today),
        'Jum',
      );
      expect(
        DateFormatterId.dayLabel(DateTime(2026, 8, 24), today: today),
        'Sen',
      );
    });
  });
}
