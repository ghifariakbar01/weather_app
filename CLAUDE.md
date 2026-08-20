# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

- Install dependencies: `flutter pub get`
- Run the app: `flutter run`
- Static analysis (uses `flutter_lints`): `flutter analyze`
- Run tests: `flutter test` (no `test/` directory exists yet — add tests under `test/`, mirroring the `lib/` layout, e.g. `test/utils/weather_code_mapper_test.dart`)
- Run a single test file: `flutter test test/path/to/some_test.dart`

## Architecture

This is a small single-screen Flutter app with no state management library — just `StatefulWidget` + `setState`. Data flows in one direction through four layers:

`screens/home_screen.dart` → `services/weather_service.dart` → `models/weather_data.dart`, with `utils/weather_code_mapper.dart` used purely for presentation.

- **`services/weather_service.dart`** — the only place that talks to the network (Open-Meteo API, no API key required). `searchLocations()` hits the geocoding endpoint, `getCurrentWeather()` hits the forecast endpoint. Both throw a plain `Exception` on non-200 responses; callers are expected to catch it.
- **`models/weather_data.dart`** — plain data classes (`Location`, `CurrentWeather`, `WeatherResult`) with `fromJson` factories. No behavior beyond parsing and the `Location.displayName` getter.
- **`utils/weather_code_mapper.dart`** — maps WMO weather codes (as returned by Open-Meteo) to Indonesian-language descriptions, `IconData`, and gradient `Color` lists for the background. Pure lookup functions, no state.
- **`screens/home_screen.dart`** — the entire UI and interaction logic lives in `_HomeScreenState`: debounced city search (500ms `Timer`), search results dropdown, loading/error/empty states, and pull-to-refresh. On `initState`, it silently pre-loads "Jakarta" as a default city.

There is currently one screen and no routing. UI strings and comments are in Indonesian — match that convention when touching `home_screen.dart`, `weather_service.dart`, or user-facing text.

## Coding style

Prioritize pure functions and minimize side effects: keep network calls confined to `WeatherService`, keep parsing/formatting logic (like `WeatherCodeMapper`) as static, input-in/output-out functions with no I/O or mutable state, and keep `_HomeScreenState` as the only place that holds mutable UI state.
