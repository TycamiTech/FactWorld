import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/country_model.dart';
import 'compact_key_value_row.dart';
import 'mini_metric_card.dart';
import 'tag_chip.dart';

class CountryDetailBottomSheet extends StatelessWidget {
  final CountryModel country;

  const CountryDetailBottomSheet({
    super.key,
    required this.country,
  });

  static void show(BuildContext context, CountryModel country) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CountryDetailBottomSheet(country: country),
    );
  }

  Future<void> _launchMaps(BuildContext context, String url) async {
    if (url.trim().isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tautan Google Maps tidak tersedia untuk negara ini.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    try {
      final uri = Uri.parse(url);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak dapat membuka aplikasi Google Maps atau peramban web.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal membuka tautan peta: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final numberFormat = NumberFormat.decimalPattern('id');
    final formattedPopulation = numberFormat.format(country.population);
    final formattedArea = numberFormat.format(country.area.round());

    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(14)),
          ),
          child: Column(
            children: [
              // Handle drag bar
              Center(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              // Content scrollable
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                  children: [
                    // Header: Nama & Kode
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                country.commonName,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                country.officialName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (country.googleMapsUrl.isNotEmpty)
                          IconButton(
                            icon: const Icon(
                              Icons.map_outlined,
                              size: 20,
                              color: AppTheme.accentBlue,
                            ),
                            tooltip: 'Buka di Google Maps',
                            onPressed: () =>
                                _launchMaps(context, country.googleMapsUrl),
                          ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // 1. Grid 2x2 MiniMetricCard
                    Row(
                      children: [
                        Expanded(
                          child: MiniMetricCard(
                            label: 'Populasi',
                            value: formattedPopulation,
                            icon: Icons.people_alt_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MiniMetricCard(
                            label: 'Luas Wilayah',
                            value: formattedArea,
                            unit: 'km²',
                            icon: Icons.square_foot_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: MiniMetricCard(
                            label: 'Koordinat',
                            value:
                                '${country.latitude.toStringAsFixed(1)}°, ${country.longitude.toStringAsFixed(1)}°',
                            icon: Icons.my_location_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: MiniMetricCard(
                            label: 'Demonim',
                            value: country.demonym,
                            icon: Icons.badge_outlined,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),
                    const Divider(height: 1, color: Color(0xFFE5E7EB)),
                    const SizedBox(height: 12),

                    // 2. Spesifikasi Detail menggunakan CompactKeyValueRow
                    const Text(
                      'Spesifikasi Geografis & Kenegaraan',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 8),

                    CompactKeyValueRow(
                      label: 'Nama Asli',
                      value: country.nativeName,
                    ),
                    CompactKeyValueRow(
                      label: 'Ibu Kota',
                      value: country.capital,
                    ),
                    CompactKeyValueRow(
                      label: 'Kawasan',
                      value: '${country.region} (${country.subregion})',
                    ),
                    CompactKeyValueRow(
                      label: 'Mata Uang',
                      value: country.currencies.isNotEmpty
                          ? country.currencies.map((c) => c.toString()).join(', ')
                          : '-',
                    ),

                    // Bahasa dengan TagChip
                    if (country.languages.isNotEmpty)
                      CompactKeyValueRow(
                        label: 'Bahasa Resmi',
                        valueWidget: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: country.languages
                              .map((lang) => TagChip(label: lang))
                              .toList(),
                        ),
                      ),

                    // TLD dengan TagChip
                    if (country.tld.isNotEmpty)
                      CompactKeyValueRow(
                        label: 'Domain (TLD)',
                        valueWidget: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: country.tld
                              .map((domain) => TagChip(label: domain))
                              .toList(),
                        ),
                      ),

                    // Zona Waktu dengan TagChip
                    if (country.timezones.isNotEmpty)
                      CompactKeyValueRow(
                        label: 'Zona Waktu',
                        valueWidget: Wrap(
                          spacing: 4,
                          runSpacing: 4,
                          children: country.timezones
                              .take(6)
                              .map((tz) => TagChip(label: tz))
                              .toList(),
                        ),
                      ),

                    const SizedBox(height: 16),

                    if (country.googleMapsUrl.isNotEmpty)
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          icon: const Icon(Icons.open_in_new, size: 15),
                          label: const Text('Buka Lokasi di Google Maps'),
                          onPressed: () =>
                              _launchMaps(context, country.googleMapsUrl),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
