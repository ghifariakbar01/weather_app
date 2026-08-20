import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import '../models/weather_data.dart';
import '../services/weather_service.dart';
import '../utils/date_formatter_id.dart';
import '../utils/weather_code_mapper.dart';

const double _hPadding = 20;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final WeatherService _service = WeatherService();
  final TextEditingController _searchController = TextEditingController();

  Timer? _debounce;
  List<Location> _searchResults = [];
  bool _isSearching = false;
  bool _isLoadingWeather = false;
  String? _errorMessage;
  WeatherResult? _weatherResult;

  @override
  void initState() {
    super.initState();
    // Kota default agar tampilan tidak kosong saat pertama dibuka.
    _loadDefaultCity();
  }

  Future<void> _loadDefaultCity() async {
    setState(() => _isLoadingWeather = true);
    try {
      final results = await _service.searchLocations('Jakarta');
      if (results.isNotEmpty) {
        await _selectLocation(results.first);
      }
    } catch (_) {
      // Gagal senyap; pengguna tetap bisa mencari kota sendiri.
    } finally {
      if (mounted) setState(() => _isLoadingWeather = false);
    }
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _performSearch(query);
    });
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _isSearching = true);
    try {
      final results = await _service.searchLocations(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
          _searchResults = [];
        });
      }
    }
  }

  Future<void> _selectLocation(Location location) async {
    FocusScope.of(context).unfocus();
    setState(() {
      _isLoadingWeather = true;
      _errorMessage = null;
      _searchResults = [];
      _searchController.clear();
    });
    try {
      final result = await _service.getCurrentWeather(location);
      if (mounted) {
        setState(() {
          _weatherResult = result;
          _isLoadingWeather = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Gagal memuat cuaca. Periksa koneksi internet Anda.';
          _isLoadingWeather = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final code = _weatherResult?.current.weatherCode ?? 0;
    final isDay = _weatherResult?.current.isDay ?? true;
    final gradientColors = WeatherCodeMapper.gradientColors(code, isDay: isDay);

    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradientColors,
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(_hPadding, 12, _hPadding, 0),
                child: _buildSearchBar(),
              ),
              if (_searchResults.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(_hPadding, 8, _hPadding, 0),
                  child: _buildSearchResults(),
                ),
              Expanded(
                child: RefreshIndicator(
                  color: Colors.white,
                  backgroundColor: Colors.black.withValues(alpha: 0.2),
                  onRefresh: () async {
                    if (_weatherResult != null) {
                      await _selectLocation(_weatherResult!.location);
                    }
                  },
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    child: _buildBody(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return _GlassPanel(
      borderRadius: 18,
      opacity: 0.16,
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        cursorColor: Colors.white,
        decoration: InputDecoration(
          hintText: 'Cari kota...',
          hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          suffixIcon: _isSearching
              ? const Padding(
                  padding: EdgeInsets.all(14.0),
                  child: SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                )
              : null,
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return _GlassPanel(
      borderRadius: 18,
      opacity: 0.16,
      padding: EdgeInsets.zero,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: 260),
        child: ListView.separated(
          shrinkWrap: true,
          padding: EdgeInsets.zero,
          itemCount: _searchResults.length,
          separatorBuilder: (_, __) => Divider(
            height: 1,
            color: Colors.white.withValues(alpha: 0.15),
          ),
          itemBuilder: (context, index) {
            final loc = _searchResults[index];
            return ListTile(
              leading: Icon(
                Icons.location_on_outlined,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              title: Text(
                loc.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                loc.displayName,
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
              onTap: () => _selectLocation(loc),
            );
          },
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoadingWeather) {
      return const Center(
        key: ValueKey('loading'),
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    if (_errorMessage != null) {
      return _buildMessageState(
        key: const ValueKey('error'),
        icon: Icons.error_outline,
        message: _errorMessage!,
      );
    }

    if (_weatherResult == null) {
      return _buildMessageState(
        key: const ValueKey('empty'),
        icon: Icons.cloud_outlined,
        message: 'Cari nama kota untuk melihat suhunya.',
      );
    }

    return LayoutBuilder(
      key: const ValueKey('weather'),
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(_hPadding, 24, _hPadding, 24),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: _buildCurrentTemperature()),
          ),
        );
      },
    );
  }

  Widget _buildMessageState({
    required Key key,
    required IconData icon,
    required String message,
  }) {
    return LayoutBuilder(
      key: key,
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(icon, size: 56, color: Colors.white.withValues(alpha: 0.7)),
                    const SizedBox(height: 16),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCurrentTemperature() {
    final weather = _weatherResult!;
    final current = weather.current;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          weather.location.displayName,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DateFormatterId.fullDateLabel(current.time),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 36),
        Icon(
          WeatherCodeMapper.icon(current.weatherCode, isDay: current.isDay),
          size: 96,
          color: Colors.white,
        ),
        const SizedBox(height: 8),
        Text(
          '${current.temperature.round()}°',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 88,
            fontWeight: FontWeight.w300,
            letterSpacing: -2,
            height: 1,
          ),
        ),
        const SizedBox(height: 12),
        _Pill(text: WeatherCodeMapper.description(current.weatherCode)),
        if (weather.daily.isNotEmpty) ...[
          const SizedBox(height: 28),
          _buildFiveDayForecast(weather.daily),
        ],
      ],
    );
  }

  Widget _buildFiveDayForecast(List<DailyForecast> daily) {
    return _GlassPanel(
      borderRadius: 20,
      opacity: 0.14,
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          for (var i = 0; i < daily.length; i++) ...[
            _buildForecastRow(daily[i]),
            if (i != daily.length - 1)
              Divider(
                height: 1,
                indent: 20,
                endIndent: 20,
                color: Colors.white.withValues(alpha: 0.12),
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildForecastRow(DailyForecast day) {
    final isToday = DateFormatterId.dayLabel(day.date) == 'Hari ini';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              DateFormatterId.dayLabel(day.date),
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
          Icon(
            WeatherCodeMapper.icon(day.weatherCode),
            color: Colors.white.withValues(alpha: 0.9),
            size: 22,
          ),
          const Spacer(),
          Text(
            '${day.tempMin.round()}°',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.65),
              fontSize: 15,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '${day.tempMax.round()}°',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu efek kaca buram (frosted glass) — dipakai untuk search bar,
/// daftar hasil pencarian, dan kartu perkiraan 5 hari agar konsisten.
class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double borderRadius;
  final double opacity;
  final EdgeInsetsGeometry padding;

  const _GlassPanel({
    required this.child,
    required this.borderRadius,
    required this.opacity,
    this.padding = const EdgeInsets.symmetric(horizontal: 16),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: opacity),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

/// Chip kecil untuk deskripsi cuaca saat ini.
class _Pill extends StatelessWidget {
  final String text;

  const _Pill({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          color: Colors.white,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}
