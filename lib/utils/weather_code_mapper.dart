import 'package:flutter/material.dart';

/// Memetakan kode cuaca WMO (dipakai Open-Meteo) ke deskripsi Bahasa Indonesia
/// dan ikon yang sesuai.
class WeatherCodeMapper {
  static String description(int code) {
    switch (code) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Sebagian Cerah';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Berawan';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
      case 53:
      case 55:
        return 'Gerimis';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
      case 63:
      case 65:
        return 'Hujan';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
        return 'Salju';
      case 77:
        return 'Butiran Salju';
      case 80:
      case 81:
      case 82:
        return 'Hujan Deras';
      case 85:
      case 86:
        return 'Hujan Salju Deras';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir dengan Hujan Es';
      default:
        return 'Tidak Diketahui';
    }
  }

  static IconData icon(int code, {bool isDay = true}) {
    switch (code) {
      case 0:
        return isDay ? Icons.wb_sunny : Icons.nightlight_round;
      case 1:
      case 2:
        return isDay ? Icons.wb_cloudy : Icons.nights_stay;
      case 3:
        return Icons.cloud;
      case 45:
      case 48:
        return Icons.foggy;
      case 51:
      case 53:
      case 55:
      case 56:
      case 57:
        return Icons.grain;
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return Icons.water_drop;
      case 66:
      case 67:
        return Icons.ac_unit;
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return Icons.ac_unit;
      case 95:
      case 96:
      case 99:
        return Icons.thunderstorm;
      default:
        return Icons.help_outline;
    }
  }

  static List<Color> gradientColors(int code, {bool isDay = true}) {
    if (!isDay) {
      return [const Color(0xFF0F2027), const Color(0xFF203A43), const Color(0xFF2C5364)];
    }
    switch (code) {
      case 0:
      case 1:
        return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
      case 2:
      case 3:
        return [const Color(0xFF757F9A), const Color(0xFFD7DDE8)];
      case 45:
      case 48:
        return [const Color(0xFFBDC3C7), const Color(0xFF2C3E50)];
      case 51:
      case 53:
      case 55:
      case 61:
      case 63:
      case 65:
      case 80:
      case 81:
      case 82:
        return [const Color(0xFF4B6CB7), const Color(0xFF182848)];
      case 71:
      case 73:
      case 75:
      case 77:
      case 85:
      case 86:
        return [const Color(0xFFE6DADA), const Color(0xFF274046)];
      case 95:
      case 96:
      case 99:
        return [const Color(0xFF373B44), const Color(0xFF4286f4)];
      default:
        return [const Color(0xFF56CCF2), const Color(0xFF2F80ED)];
    }
  }
}
