import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/network/api_client.dart';
import '../../data/datasources/country_api_service.dart';
import '../../data/models/country_model.dart';
import '../../data/repositories/country_repository_impl.dart';
import '../../domain/repositories/country_repository.dart';

/// State model untuk mengelola data negara, proses filter, dan status loading
class CountryState {
  final bool isLoading;
  final String? errorMessage;
  final List<CountryModel> allCountries;
  final List<CountryModel> filteredCountries;
  final String searchQuery;
  final String selectedRegion; // Default: 'Semua'

  const CountryState({
    this.isLoading = false,
    this.errorMessage,
    this.allCountries = const [],
    this.filteredCountries = const [],
    this.searchQuery = '',
    this.selectedRegion = 'Semua',
  });

  CountryState copyWith({
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    List<CountryModel>? allCountries,
    List<CountryModel>? filteredCountries,
    String? searchQuery,
    String? selectedRegion,
  }) {
    return CountryState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      allCountries: allCountries ?? this.allCountries,
      filteredCountries: filteredCountries ?? this.filteredCountries,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedRegion: selectedRegion ?? this.selectedRegion,
    );
  }
}

// -----------------------------------------------------------------------------
// Dependency Injection Providers
// -----------------------------------------------------------------------------

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

final countryApiServiceProvider = Provider<CountryApiService>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return CountryApiService(dio: apiClient.dio);
});

final countryRepositoryProvider = Provider<CountryRepository>((ref) {
  final apiService = ref.watch(countryApiServiceProvider);
  return CountryRepositoryImpl(apiService: apiService);
});

// -----------------------------------------------------------------------------
// Country State Notifier & Provider
// -----------------------------------------------------------------------------

final countryNotifierProvider =
    StateNotifierProvider<CountryNotifier, CountryState>((ref) {
  final repository = ref.watch(countryRepositoryProvider);
  return CountryNotifier(repository);
});

class CountryNotifier extends StateNotifier<CountryState> {
  final CountryRepository _repository;

  /// Pemetaan nama region lokal (Bahasa Indonesia) ke nilai region REST Countries API
  static const Map<String, String> regionMapping = {
    'Semua': 'All',
    'Asia': 'Asia',
    'Eropa': 'Europe',
    'Afrika': 'Africa',
    'Amerika': 'Americas',
    'Oseania': 'Oceania',
  };

  CountryNotifier(this._repository)
      : super(const CountryState(isLoading: true)) {
    loadCountries();
  }

  /// Memuat data negara dari API hanya satu kali saat startup aplikasi.
  /// Jika data sudah tersimpan di memory dan [forceRefresh] bernilai false,
  /// fungsi tidak akan melakukan request jaringan berulang.
  Future<void> loadCountries({bool forceRefresh = false}) async {
    if (!forceRefresh && state.allCountries.isNotEmpty) {
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true);

    try {
      final countries = await _repository.getCountries();

      // Urutkan alfabetis berdasarkan Nama Umum (commonName)
      final sortedCountries = List<CountryModel>.from(countries)
        ..sort((a, b) => a.commonName.compareTo(b.commonName));

      // Jalankan filter in-memory untuk query dan region yang sedang aktif
      final filtered = filterLogic(
        countries: sortedCountries,
        query: state.searchQuery,
        region: state.selectedRegion,
      );

      state = state.copyWith(
        isLoading: false,
        allCountries: sortedCountries,
        filteredCountries: filtered,
        clearError: true,
      );
    } on CountryApiException catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Terjadi kesalahan tidak terduga saat memuat data: $e',
      );
    }
  }

  /// Memperbarui kata kunci pencarian dan menyaring data secara instan di memori lokal
  void setSearchQuery(String query) {
    if (state.searchQuery == query) return;

    final filtered = filterLogic(
      countries: state.allCountries,
      query: query,
      region: state.selectedRegion,
    );

    state = state.copyWith(
      searchQuery: query,
      filteredCountries: filtered,
    );
  }

  /// Memperbarui region aktif dan menyaring data secara instan di memori lokal
  void setSelectedRegion(String region) {
    if (state.selectedRegion == region) return;

    final filtered = filterLogic(
      countries: state.allCountries,
      query: state.searchQuery,
      region: region,
    );

    state = state.copyWith(
      selectedRegion: region,
      filteredCountries: filtered,
    );
  }

  /// Menghapus kata kunci pencarian
  void clearSearchQuery() {
    setSearchQuery('');
  }

  /// Logika penyaringan in-memory reaktif tanpa delay jaringan.
  /// Menggabungkan:
  /// 1. Pencarian keyword: Nama Umum, Nama Resmi, Ibu Kota, atau TLD.
  /// 2. Filter Benua: 'Semua', 'Asia', 'Eropa', 'Afrika', 'Amerika', 'Oseania'.
  static List<CountryModel> filterLogic({
    required List<CountryModel> countries,
    required String query,
    required String region,
  }) {
    final cleanQuery = query.toLowerCase().trim();
    final queryWithoutDot = cleanQuery.replaceAll('.', '');

    final targetEnglishRegion =
        regionMapping[region]?.toLowerCase() ?? region.toLowerCase();

    return countries.where((country) {
      // 1. Verifikasi Filter Region
      final matchesRegion = _checkRegionMatch(
        countryRegion: country.region,
        targetRegion: region,
        targetEnglishRegion: targetEnglishRegion,
      );

      if (!matchesRegion) return false;

      // 2. Jika tidak ada query pencarian, loloskan berdasarkan filter region
      if (cleanQuery.isEmpty) return true;

      // 3. Pencarian Berdasarkan Nama Umum (commonName)
      if (country.commonName.toLowerCase().contains(cleanQuery)) {
        return true;
      }

      // 4. Pencarian Berdasarkan Nama Resmi (officialName)
      if (country.officialName.toLowerCase().contains(cleanQuery)) {
        return true;
      }

      // 5. Pencarian Berdasarkan Ibu Kota (capital)
      if (country.capital != '-' &&
          country.capital.toLowerCase().contains(cleanQuery)) {
        return true;
      }

      // 6. Pencarian Berdasarkan TLD (Top-Level Domain)
      for (final tld in country.tld) {
        final cleanTld = tld.toLowerCase();
        final cleanTldWithoutDot = cleanTld.replaceAll('.', '');
        if (cleanTld.contains(cleanQuery) ||
            cleanTldWithoutDot == queryWithoutDot) {
          return true;
        }
      }

      return false;
    }).toList();
  }

  static bool _checkRegionMatch({
    required String countryRegion,
    required String targetRegion,
    required String targetEnglishRegion,
  }) {
    if (targetRegion == 'Semua' || targetRegion == 'All' || targetRegion.isEmpty) {
      return true;
    }

    final lowerCountryRegion = countryRegion.toLowerCase();
    return lowerCountryRegion == targetEnglishRegion ||
        lowerCountryRegion == targetRegion.toLowerCase();
  }
}
