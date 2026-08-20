class Location {
  final String name;
  final String country;
  final double latitude;
  final double longitude;
  final String? admin1; // provinsi/negara bagian

  Location({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.admin1,
  });

  factory Location.fromJson(Map<String, dynamic> json) {
    return Location(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      admin1: json['admin1'],
    );
  }

  String get displayName {
    if (admin1 != null && admin1!.isNotEmpty && admin1 != name) {
      return '$name, $admin1, $country';
    }
    return '$name, $country';
  }
}

class CurrentWeather {
  final double temperature;
  final int weatherCode;
  final DateTime time;
  final bool isDay;

  CurrentWeather({
    required this.temperature,
    required this.weatherCode,
    required this.time,
    required this.isDay,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num).toDouble(),
      weatherCode: json['weather_code'] as int,
      time: DateTime.parse(json['time']),
      isDay: json['is_day'] == 1,
    );
  }
}

class DailyForecast {
  final DateTime date;
  final int weatherCode;
  final double tempMax;
  final double tempMin;

  DailyForecast({
    required this.date,
    required this.weatherCode,
    required this.tempMax,
    required this.tempMin,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> daily, int index) {
    return DailyForecast(
      date: DateTime.parse(daily['time'][index] as String),
      weatherCode: daily['weather_code'][index] as int,
      tempMax: (daily['temperature_2m_max'][index] as num).toDouble(),
      tempMin: (daily['temperature_2m_min'][index] as num).toDouble(),
    );
  }

  /// Mengubah respons daily (kolom paralel) dari Open-Meteo menjadi
  /// daftar [DailyForecast], satu per hari.
  static List<DailyForecast> listFromJson(Map<String, dynamic> daily) {
    final times = daily['time'] as List<dynamic>;
    return List.generate(
      times.length,
      (index) => DailyForecast.fromJson(daily, index),
    );
  }
}

class WeatherResult {
  final Location location;
  final CurrentWeather current;
  final List<DailyForecast> daily;

  WeatherResult({
    required this.location,
    required this.current,
    required this.daily,
  });
}
