# 🌍 FactWorld

<p align="center">
  <img src="https://raw.githubusercontent.com/TycamiTech/FactWorld/main/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png" width="96" height="96" alt="FactWorld Logo" />
</p>

<p align="center">
  <b>Aplikasi Ensiklopedia Geografi & Fakta Negara Berkecepatan Tinggi</b><br />
  Dibangun dengan Flutter & Clean Architecture mengusung filosofi desain <i>High-Density Warm Minimalist</i>.
</p>

<p align="center">
  <a href="https://flutter.dev"><img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" /></a>
  <a href="https://dart.dev"><img src="https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white" alt="Dart" /></a>
  <a href="https://riverpod.dev"><img src="https://img.shields.io/badge/State_Management-Riverpod-0553B1?style=for-the-badge" alt="Riverpod" /></a>
  <a href="https://developer.android.com"><img src="https://img.shields.io/badge/Platform-Android-3DDC84?style=for-the-badge&logo=android&logoColor=white" alt="Android" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-blue.svg?style=for-the-badge" alt="License" /></a>
</p>

---

## 📌 Tentang Proyek

**FactWorld** adalah aplikasi Android berbasis Flutter yang menampilkan spesifikasi komprehensif dari 250 negara di seluruh dunia. Berbeda dengan aplikasi konvensional yang boros ruang dengan margin kartu besar, FactWorld mengusung estetika **High-Density Warm Minimalist**—memaksimalkan setiap piksel layar untuk efisiensi informasi dengan tipografi tajam, visual density padat, serta performa pencarian lokal instan tanpa jeda jaringan.

---

## ✨ Fitur Utama

- **🚀 Pencarian & Filter Instan di Memori (Zero Latency):**
  - Seluruh data 250 negara di-fetch sekali saat inisialisasi aplikasi.
  - Pencarian multi-atribut reaktif: nama umum (*common name*), nama resmi (*official name*), ibu kota (*capital*), hingga domain tingkat atas (*TLD*).
  - Filter benua/kawasan satu ketukan: **Semua**, **Asia**, **Eropa**, **Afrika**, **Amerika**, dan **Oseania**.
- **📊 13 Spesifikasi Data per Negara:**
  - Identitas Lengkap (Nama Umum, Resmi, Asli/Native, Demonim warga).
  - Metrik Kunci (Ibu Kota, Populasi berformat lokal, Luas Wilayah km², Mata Uang & Simbol).
  - Koordinat Geografis (Latitude & Longitude dengan format arah mata angin presisi).
  - Bahasa Resmi (multi-bahasa dengan chip adaptif).
  - Zona Waktu (UTC offsets).
  - Tautan langsung ke Google Maps via intent native Android.
- **🛡️ Ketahanan Data 3 Lapis (*Triple-Tier Resiliency*):**
  - **Tier 1 (CDN):** CDN jsDelivr global berkecepatan tinggi.
  - **Tier 2 (Fallback Online):** Mirror GitHub raw.
  - **Tier 3 (Offline Bundled Asset):** Dataset lokal terbundel (`assets/data/countries.json`), memastikan aplikasi tetap berfungsi penuh 100% saat perangkat offline atau mode pesawat.
- **🖼️ Rendering Bendera Tangguh (100% Uptime):**
  - Menggunakan `CachedNetworkImage` dengan fallback `SvgPicture`.
  - Fallback otomatis berbasis kode ISO `cca2` ke FlagCDN resmi untuk memastikan tidak ada bendera yang gagal dimuat.
- **🎨 Desain High-Density Warm Minimalist:**
  - Palet warna bersih & kontras: Latar `#F8F9FA`, Permukaan `#FFFFFF`, Teks `#111827` (Muted `#6B7280`), Aksen Biru `#2563EB`.
  - Komponen flat bergaris batas halus (border `0.5px - 1px #E5E7EB`) tanpa shadow tebal.
  - `DenseCountryTile` berukuran presisi 62dp dengan thumbnail rasio 3:2 dan transisi mulus `Hero Animation`.

---

## 🏗️ Arsitektur Proyek (Clean Architecture)

Proyek ini dibangun dengan pemisahan dependensi modular sesuai kaidah **Clean Architecture**:

```
lib/
├── core/                       # Inti aplikasi (independen)
│   ├── constants/             # Konstanta API, endpoint, & daftar kawasan
│   ├── network/               # Konfigurasi Dio & hierarki Exception kustom
│   ├── theme/                 # AppTheme (High-Density Warm Minimalist M3)
│   └── utils/                 # Result type (Success/Failure) & helpers
├── data/                      # Lapisan data (implementasi konkret)
│   ├── datasources/           # CountryApiService (CDN, GitHub, Offline Asset)
│   ├── models/                # CountryModel dengan defensive null-safe parsing
│   └── repositories/          # Implementasi CountryRepositoryImpl
├── domain/                    # Lapisan bisnis inti (murni)
│   ├── entities/              # Country & CountryCurrency domain entity
│   └── repositories/          # Abstraksi interface CountryRepository
└── presentation/              # Lapisan antarmuka pengguna
    ├── providers/             # Riverpod state notifier (CountryState & filter logic)
    ├── screens/               # Layar utama (HomeScreen & DetailScreen)
    └── widgets/               # Komponen UI padat (DenseCountryTile, MiniMetricCard, dll.)
```

---

## 🛠️ Tech Stack & Dependensi

| Kategori | Paket / Teknologi | Deskripsi |
|---|---|---|
| **Framework** | [Flutter](https://flutter.dev) (SDK ^3.0.0) | Multi-platform framework modern |
| **State Management** | [flutter_riverpod](https://pub.dev/packages/flutter_riverpod) `^2.6.1` | Manajemen state deklaratif, reaktif, & testable |
| **Networking** | [dio](https://pub.dev/packages/dio) `^5.7.0` | HTTP client tangguh dengan interceptor |
| **Image Rendering** | [cached_network_image](https://pub.dev/packages/cached_network_image) `^3.4.1` | Caching gambar otomatis di penyimpanan lokal |
| **Vector Graphics** | [flutter_svg](https://pub.dev/packages/flutter_svg) `^2.0.17` | Rendering grafis vektor SVG untuk bendera |
| **URL & Intent** | [url_launcher](https://pub.dev/packages/url_launcher) `^6.3.1` | Membuka Google Maps & browser web eksternal |
| **Lokalisasi** | [intl](https://pub.dev/packages/intl) `^0.19.0` | Pemformatan angka ribuan desimal standar Indonesia |

---

## 💻 Memulai Pengembangan Lokal

### Prasyarat
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.20.0 atau lebih baru disarankan)
- [Android Studio / Android SDK](https://developer.android.com/studio) dengan build-tools & platform-tools
- Java JDK 17 (misal: Zulu JDK atau OpenJDK 17)

### Langkah Instalasi

1. **Clone repository ini:**
   ```bash
   git clone https://github.com/TycamiTech/FactWorld.git
   cd FactWorld
   ```

2. **Unduh seluruh dependensi paket:**
   ```bash
   flutter pub get
   ```

3. **Verifikasi kualitas kode (Linter & Type-Safety):**
   ```bash
   flutter analyze
   ```

4. **Jalankan rangkaian unit testing:**
   ```bash
   flutter test
   ```

5. **Jalankan aplikasi di perangkat Android atau Emulator:**
   ```bash
   flutter run
   ```

---

## 📦 Panduan Build APK Android

### 1. Build APK Universal (Release)
Menghasilkan satu file APK yang kompatibel dengan seluruh arsitektur prosesor Android:
```bash
flutter build apk --release
```
*Output: `build/app/outputs/flutter-apk/app-release.apk`*

### 2. Build APK Ramping per ABI (*Split per ABI*)
Menghasilkan ukuran file jauh lebih kecil (hemat kuota & ruang penyimpanan):
```bash
flutter build apk --split-per-abi
```
*Output:*
- `app-arm64-v8a-release.apk` (HP Android modern 64-bit)
- `app-armeabi-v7a-release.apk` (HP Android 32-bit)
- `app-x86_64-release.apk` (Emulator 64-bit)

---

## 🧪 Pengujian Otomatis (*Unit Testing*)

Proyek ini dilengkapi dengan unit test komprehensif di direktori `test/` yang memverifikasi:
- Filter region (Semua, Asia, Eropa, Afrika, Amerika, Oseania).
- Pencarian kata kunci substring nama umum, nama resmi, ibu kota, dan TLD.
- Defensive parsing bendera dari berbagai format array dan Map.
- Smoke test widget dengan provider scope override.

Untuk menjalankan pengujian:
```bash
flutter test
```

---

## 📄 Lisensi

Proyek ini dilisensikan di bawah [MIT License](LICENSE) - silakan gunakan, kembangkan, dan modifikasi secara bebas.

---

<p align="center">
  Dikembangkan dengan dedikasi oleh <b><a href="https://github.com/TycamiTech">TycamiTech</a></b>
</p>
