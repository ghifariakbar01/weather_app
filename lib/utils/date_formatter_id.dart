/// Pemformat tanggal Bahasa Indonesia, tanpa dependensi paket `intl`.
class DateFormatterId {
  static const List<String> _shortDayNames = [
    'Sen',
    'Sel',
    'Rab',
    'Kam',
    'Jum',
    'Sab',
    'Min',
  ];

  static const List<String> _fullDayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  /// Label hari singkat untuk [date], atau 'Hari ini' bila [date] sama
  /// dengan [today] (default: hari ini di zona waktu lokal).
  static String dayLabel(DateTime date, {DateTime? today}) {
    final reference = today ?? DateTime.now();
    if (_isSameDate(date, reference)) return 'Hari ini';
    return _shortDayNames[date.weekday - 1];
  }

  /// Format lengkap, misal 'Kamis, 20 Agustus'.
  static String fullDateLabel(DateTime date) {
    return '${_fullDayNames[date.weekday - 1]}, ${date.day} '
        '${_monthNames[date.month - 1]}';
  }

  static bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}