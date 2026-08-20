import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_data.dart';

void main() {
  group('DailyForecast.listFromJson', () {
    test('parses parallel arrays into one DailyForecast per day', () {
      final daily = {
        'time': ['2026-08-20', '2026-08-21', '2026-08-22'],
        'weather_code': [0, 61, 95],
        'temperature_2m_max': [31.5, 28.0, 26.2],
        'temperature_2m_min': [24.1, 23.4, 22.9],
      };

      final forecasts = DailyForecast.listFromJson(daily);

      expect(forecasts, hasLength(3));
      expect(forecasts[0].date, DateTime.parse('2026-08-20'));
      expect(forecasts[0].weatherCode, 0);
      expect(forecasts[0].tempMax, 31.5);
      expect(forecasts[0].tempMin, 24.1);
      expect(forecasts[2].weatherCode, 95);
      expect(forecasts[2].tempMax, 26.2);
    });

    test('returns an empty list when time is empty', () {
      final daily = {
        'time': <String>[],
        'weather_code': <int>[],
        'temperature_2m_max': <double>[],
        'temperature_2m_min': <double>[],
      };

      expect(DailyForecast.listFromJson(daily), isEmpty);
    });
  });
}
