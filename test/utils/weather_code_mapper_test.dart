import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/utils/weather_code_mapper.dart';

void main() {
  group('WeatherCodeMapper.description', () {
    test('returns the Indonesian label for known WMO codes', () {
      expect(WeatherCodeMapper.description(0), 'Cerah');
      expect(WeatherCodeMapper.description(3), 'Berawan');
      expect(WeatherCodeMapper.description(61), 'Hujan');
      expect(WeatherCodeMapper.description(95), 'Badai Petir');
    });

    test('returns the fallback label for unknown codes', () {
      expect(WeatherCodeMapper.description(-1), 'Tidak Diketahui');
      expect(WeatherCodeMapper.description(1000), 'Tidak Diketahui');
    });
  });

  group('WeatherCodeMapper.icon', () {
    test('picks a day/night variant for clear sky', () {
      expect(WeatherCodeMapper.icon(0, isDay: true), Icons.wb_sunny);
      expect(WeatherCodeMapper.icon(0, isDay: false), Icons.nightlight_round);
    });

    test('is not sensitive to isDay for codes without a night variant', () {
      expect(WeatherCodeMapper.icon(3, isDay: true), Icons.cloud);
      expect(WeatherCodeMapper.icon(3, isDay: false), Icons.cloud);
    });

    test('returns the fallback icon for unknown codes', () {
      expect(WeatherCodeMapper.icon(-1), Icons.help_outline);
    });
  });

  group('WeatherCodeMapper.gradientColors', () {
    test('returns a fixed dark gradient at night regardless of code', () {
      final night = [
        const Color(0xFF0F2027),
        const Color(0xFF203A43),
        const Color(0xFF2C5364),
      ];
      expect(WeatherCodeMapper.gradientColors(0, isDay: false), night);
      expect(WeatherCodeMapper.gradientColors(95, isDay: false), night);
    });

    test('returns a two-color gradient for known day codes', () {
      final gradient = WeatherCodeMapper.gradientColors(0, isDay: true);
      expect(gradient.length, 2);
    });

    test('returns the default gradient for unknown day codes', () {
      expect(
        WeatherCodeMapper.gradientColors(-1, isDay: true),
        WeatherCodeMapper.gradientColors(0, isDay: true),
      );
    });
  });
}
