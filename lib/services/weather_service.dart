import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_data.dart';

/// Service ini menggunakan Open-Meteo API — API cuaca gratis
/// yang tidak memerlukan API key.
/// Dokumentasi: https://open-meteo.com/en/docs
class WeatherService {
  static const String _geocodingUrl =
      'https://geocoding-api.open-meteo.com/v1/search';
  static const String _forecastUrl =
      'https://api.open-meteo.com/v1/forecast';

  /// Mencari lokasi berdasarkan nama kota.
  Future<List<Location>> searchLocations(String query) async {
    if (query.trim().isEmpty) return [];

    final uri = Uri.parse(_geocodingUrl).replace(queryParameters: {
      'name': query,
      'count': '10',
      'language': 'id',
      'format': 'json',
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mencari lokasi (kode: ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = data['results'] as List<dynamic>?;

    if (results == null) return [];

    return results
        .map((item) => Location.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  /// Mengambil suhu saat ini beserta perkiraan 5 hari untuk sebuah lokasi.
  Future<WeatherResult> getCurrentWeather(Location location) async {
    final uri = Uri.parse(_forecastUrl).replace(queryParameters: {
      'latitude': location.latitude.toString(),
      'longitude': location.longitude.toString(),
      'current': 'temperature_2m,weather_code,is_day',
      'daily': 'weather_code,temperature_2m_max,temperature_2m_min',
      'forecast_days': '5',
      'timezone': 'auto',
    });

    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data cuaca (kode: ${response.statusCode})');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    final current = CurrentWeather.fromJson(
      data['current'] as Map<String, dynamic>,
    );

    final daily = DailyForecast.listFromJson(
      data['daily'] as Map<String, dynamic>,
    );

    return WeatherResult(
      location: location,
      current: current,
      daily: daily,
    );
  }
}
