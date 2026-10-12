import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../providers/country_provider.dart';
import '../widgets/dense_country_tile.dart';
import 'detail_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final countryState = ref.watch(countryNotifierProvider);
    final countryNotifier = ref.read(countryNotifierProvider.notifier);

    final totalCount = countryState.allCountries.length;
    final totalLabel = totalCount > 0 ? '$totalCount negara terdaftar' : '';

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        titleSpacing: 14,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/logo.png',
                width: 28,
                height: 28,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  AppConstants.appName,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16.5,
                    color: Color(0xFF111827),
                    letterSpacing: -0.3,
                  ),
                ),
                if (totalLabel.isNotEmpty) ...[
                  const SizedBox(height: 1),
                  Text(
                    totalLabel,
                    style: const TextStyle(
                      fontSize: 12.0,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.1,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, size: 20),
            tooltip: 'Segarkan data',
            onPressed: () {
              countryNotifier.loadCountries(forceRefresh: true);
            },
          ),
          const SizedBox(width: 4),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            color: const Color(0xFFE5E7EB),
            height: 1,
          ),
        ),
      ),
      body: Column(
        children: [
          // Baris Kontrol: Search Bar & Filter Region
          Container(
            color: AppTheme.surface,
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Search Bar Compact (Tinggi 40dp, Teks 13sp, Radius 8dp, Bg #F3F4F6)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: SizedBox(
                    height: 40,
                    child: TextField(
                      controller: _searchController,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF111827),
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: const Color(0xFFF3F4F6),
                        hintText: 'Cari nama umum, nama resmi, ibu kota, atau TLD...',
                        hintStyle: const TextStyle(
                          fontSize: 13,
                          color: Color(0xFF9CA3AF),
                          fontWeight: FontWeight.w400,
                        ),
                        prefixIcon: const Icon(
                          Icons.search,
                          size: 18,
                          color: Color(0xFF9CA3AF),
                        ),
                        prefixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 40,
                        ),
                        suffixIcon: _searchController.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 16),
                                splashRadius: 16,
                                color: const Color(0xFF6B7280),
                                onPressed: () {
                                  _searchController.clear();
                                  countryNotifier.clearSearchQuery();
                                },
                              )
                            : null,
                        suffixIconConstraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 40,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: const BorderSide(
                            color: Color(0xFF2563EB),
                            width: 1.2,
                          ),
                        ),
                      ),
                      onChanged: (value) {
                        countryNotifier.setSearchQuery(value);
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // 2. Baris Filter Horizontal untuk Pilihan Region (Chip padat)
                SizedBox(
                  height: 30,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: AppConstants.regions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 6),
                    itemBuilder: (context, index) {
                      final region = AppConstants.regions[index];
                      final isSelected = countryState.selectedRegion == region;
                      return ChoiceChip(
                        label: Text(region),
                        selected: isSelected,
                        showCheckmark: false,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? const Color(0xFF2563EB) : const Color(0xFF374151),
                        ),
                        backgroundColor: AppTheme.surface,
                        selectedColor: const Color(0xFFEFF6FF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                          side: BorderSide(
                            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE5E7EB),
                            width: isSelected ? 1 : 0.8,
                          ),
                        ),
                        onSelected: (selected) {
                          if (selected) {
                            countryNotifier.setSelectedRegion(region);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE5E7EB)),

          // 3. Body: Shimmer skeleton saat loading, empty state saat nihil, atau ListView DenseCountryTile
          Expanded(
            child: _buildBody(context, countryState, countryNotifier),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    CountryState state,
    CountryNotifier notifier,
  ) {
    // A. Shimmer Skeleton Loading Ringkas saat startup pertama
    if (state.isLoading && state.allCountries.isEmpty) {
      return _buildSkeletonLoading();
    }

    // B. Pesan Kesalahan Koneksi / Server
    if (state.errorMessage != null && state.allCountries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.cloud_off_rounded,
                size: 40,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 12),
              Text(
                'Gagal Memuat Data',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 6),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                icon: const Icon(Icons.refresh, size: 16),
                label: const Text('Coba Lagi'),
                onPressed: () {
                  notifier.loadCountries(forceRefresh: true);
                },
              ),
            ],
          ),
        ),
      );
    }

    // C. Pesan "Negara tidak ditemukan" saat pencarian / filter kosong
    if (state.filteredCountries.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off_rounded,
                size: 38,
                color: Color(0xFF9CA3AF),
              ),
              const SizedBox(height: 10),
              const Text(
                'Negara tidak ditemukan',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF111827),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                state.searchQuery.isNotEmpty
                    ? 'Tidak ditemukan hasil untuk "${state.searchQuery}" di Benua ${state.selectedRegion}'
                    : 'Tidak ada negara di Benua ${state.selectedRegion}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF6B7280),
                ),
              ),
              if (state.searchQuery.isNotEmpty || state.selectedRegion != 'Semua') ...[
                const SizedBox(height: 14),
                OutlinedButton(
                  onPressed: () {
                    _searchController.clear();
                    notifier.clearSearchQuery();
                    notifier.setSelectedRegion('Semua');
                  },
                  child: const Text('Reset Filter & Pencarian'),
                ),
              ],
            ],
          ),
        ),
      );
    }

    // D. ListView Builder yang me-render DenseCountryTile dengan navigasi tap ke DetailScreen
    return RefreshIndicator(
      color: AppTheme.accentBlue,
      onRefresh: () async {
        await notifier.loadCountries(forceRefresh: true);
      },
      child: ListView.builder(
        itemCount: state.filteredCountries.length,
        itemBuilder: (context, index) {
          final country = state.filteredCountries[index];
          return DenseCountryTile(
            country: country,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DetailScreen(country: country),
                ),
              );
            },
          );
        },
      ),
    );
  }

  /// Skeleton loader ringkas dengan tinggi 62dp serupa DenseCountryTile
  Widget _buildSkeletonLoading() {
    return ListView.builder(
      itemCount: 14,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Container(
          height: 62,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            border: Border(
              bottom: BorderSide(
                color: Color(0xFFE5E7EB),
                width: 0.5,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Skeleton bendera
              Container(
                width: 36,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: 12),
              // Skeleton teks
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 100 + (index % 4) * 22.0,
                      height: 12,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE5E7EB),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Container(
                      width: 160 + (index % 3) * 20.0,
                      height: 9,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3F4F6),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Skeleton region
              Container(
                width: 44,
                height: 10,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
