# Aplikasi Cuaca (Flutter)

Aplikasi sederhana untuk menampilkan **suhu saat ini** di kota manapun, menggunakan [Open-Meteo API](https://open-meteo.com/) — gratis, tanpa API key.

## Fitur
- Cari kota
- Tampilkan suhu saat ini beserta kondisi cuaca (cerah, berawan, hujan, dll.)
- Tarik ke bawah (pull to refresh) untuk memperbarui data

## Cara Menjalankan
1. Pastikan Flutter SDK sudah terpasang (`flutter --version`)
2. Ekstrak file ini, lalu masuk ke foldernya:
   ```
   cd weather_app
   ```
3. Ambil dependensi:
   ```
   flutter pub get
   ```
4. Jalankan aplikasi:
   ```
   flutter run
   ```

## Struktur Proyek
```
lib/
  main.dart                     # Entry point aplikasi
  models/weather_data.dart      # Model data lokasi & cuaca
  services/weather_service.dart # Pemanggilan Open-Meteo API
  utils/weather_code_mapper.dart# Pemetaan kode cuaca ke ikon/teks
  screens/home_screen.dart      # Tampilan utama
```

## Sumber API
- Geocoding: https://geocoding-api.open-meteo.com/v1/search
- Cuaca: https://api.open-meteo.com/v1/forecast
