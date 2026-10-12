import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/country_model.dart';
import '../widgets/compact_key_value_row.dart';
import '../widgets/mini_metric_card.dart';
import '../widgets/tag_chip.dart';

class DetailScreen extends StatelessWidget {
  final CountryModel country;

  const DetailScreen({
    super.key,
    required this.country,
  });

  Future<void> _launchMaps(BuildContext context) async {
    if (country.googleMapsUrl.trim().isEmpty) {
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
      final uri = Uri.parse(country.googleMapsUrl);
      final launched = await launchUrl(
        uri,
        mode: LaunchMode.externalApplication,
      );

      if (!launched && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Tidak dapat membuka aplikasi Google Maps atau peramban web.',
            ),
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

  String _formatCurrency() {
    if (country.currencies.isEmpty) return '-';
    return country.currencies.map((c) => c.toString()).join(', ');
  }

  @override
  Widget build(BuildContext context) {
    // Format angka lokal Indonesia (misal: 273.753.191)
    final numberFormat = NumberFormat.decimalPattern('id');
    final formattedPopulation = numberFormat.format(country.population);
    final formattedArea = numberFormat.format(country.area.round());
    final currencyText = _formatCurrency();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          country.commonName,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Color(0xFF111827),
          ),
        ),
        actions: [
          if (country.googleMapsUrl.isNotEmpty)
            IconButton(
              icon: const Icon(
                Icons.map_outlined,
                size: 20,
                color: AppTheme.accentBlue,
              ),
              tooltip: 'Buka di Google Maps',
              onPressed: () => _launchMaps(context),
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                children: [
                  // 1. Layout Informasi Atas: Bendera (~90dp lebar, Hero) berdampingan Nama Negara
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bendera Sedang (Lebar ~90dp, rasio 3:2, tinggi 60dp) dengan Hero animation
                        Hero(
                          tag: 'flag_${country.commonName}',
                          child: Container(
                            width: 90,
                            height: 60,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3F4F6),
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 0.5,
                              ),
                            ),
                            clipBehavior: Clip.antiAlias,
                            child: _buildFlagImage(),
                          ),
                        ),

                        const SizedBox(width: 12),

                        // Nama Negara & Identitas Utama
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Common Name
                              Text(
                                country.commonName,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF111827),
                                  height: 1.2,
                                  letterSpacing: -0.3,
                                ),
                              ),

                              const SizedBox(height: 3),

                              // Official Name
                              Text(
                                country.officialName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w400,
                                  color: Color(0xFF6B7280),
                                  height: 1.25,
                                ),
                              ),

                              const SizedBox(height: 4),

                              // Native Name & TLD Badge
                              Row(
                                children: [
                                  if (country.nativeName != country.commonName) ...[
                                    Expanded(
                                      child: Text(
                                        'Asli: ${country.nativeName}',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          fontSize: 11.5,
                                          fontWeight: FontWeight.w500,
                                          color: Color(0xFF4B5563),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                  ],
                                  if (country.tld.isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF3F4F6),
                                        borderRadius: BorderRadius.circular(4),
                                        border: Border.all(
                                          color: const Color(0xFFE5E7EB),
                                          width: 0.5,
                                        ),
                                      ),
                                      child: Text(
                                        country.tld.first,
                                        style: const TextStyle(
                                          fontSize: 10.5,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF2563EB),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 2. Grid 2x2 MiniMetricCard: Ibu Kota, Populasi, Luas Wilayah, Mata Uang
                  Row(
                    children: [
                      Expanded(
                        child: MiniMetricCard(
                          label: 'Ibu Kota',
                          value: country.capital,
                          icon: Icons.location_city_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MiniMetricCard(
                          label: 'Populasi',
                          value: formattedPopulation,
                          icon: Icons.people_alt_outlined,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: MiniMetricCard(
                          label: 'Luas Wilayah',
                          value: formattedArea,
                          unit: 'km²',
                          icon: Icons.square_foot_outlined,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: MiniMetricCard(
                          label: 'Mata Uang',
                          value: currencyText,
                          icon: Icons.monetization_on_outlined,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // 3. Bagian Geografi: Susunan CompactKeyValueRow
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Informasi Geografi & Wilayah',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 6),
                        CompactKeyValueRow(
                          label: 'Kawasan (Region)',
                          value: country.region,
                        ),
                        CompactKeyValueRow(
                          label: 'Subkawasan',
                          value: country.subregion,
                        ),
                        CompactKeyValueRow(
                          label: 'Koordinat',
                          value:
                              '${country.latitude.abs().toStringAsFixed(2)}° ${country.latitude >= 0 ? 'N' : 'S'}, ${country.longitude.abs().toStringAsFixed(2)}° ${country.longitude >= 0 ? 'E' : 'W'}',
                        ),
                        CompactKeyValueRow(
                          label: 'Demonim Warga',
                          value: country.demonym,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),

                  // 4. Bagian Bahasa Resmi & Zona Waktu (Wrap TagChip)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFFE5E7EB),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Bahasa Resmi
                        const Text(
                          'Bahasa Resmi',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (country.languages.isNotEmpty)
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: country.languages
                                .map((lang) => TagChip(
                                      label: lang,
                                      icon: Icons.language_outlined,
                                    ))
                                .toList(),
                          )
                        else
                          const Text(
                            'Tidak ada data bahasa resmi',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),

                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE5E7EB)),
                        const SizedBox(height: 10),

                        // Zona Waktu
                        const Text(
                          'Zona Waktu',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4B5563),
                          ),
                        ),
                        const SizedBox(height: 6),
                        if (country.timezones.isNotEmpty)
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: country.timezones
                                .map((tz) => TagChip(
                                      label: tz,
                                      icon: Icons.access_time_rounded,
                                    ))
                                .toList(),
                          )
                        else
                          const Text(
                            'Tidak ada data zona waktu',
                            style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF9CA3AF),
                            ),
                          ),

                        // Domain TLD jika ada lebih dari 1
                        if (country.tld.length > 1) ...[
                          const SizedBox(height: 12),
                          const Divider(height: 1, color: Color(0xFFE5E7EB)),
                          const SizedBox(height: 10),
                          const Text(
                            'Top-Level Domain (TLD)',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF4B5563),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 5,
                            runSpacing: 5,
                            children: country.tld
                                .map((tld) => TagChip(
                                      label: tld,
                                      icon: Icons.dns_outlined,
                                    ))
                                .toList(),
                          ),
                        ],
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),

            // 5. Tombol Bawah: FilledButton ramping (tinggi 42dp)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(
                  top: BorderSide(
                    color: Color(0xFFE5E7EB),
                    width: 0.5,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 42,
                child: FilledButton.icon(
                  icon: const Icon(Icons.map_outlined, size: 17),
                  label: const Text(
                    'Buka di Google Maps',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accentBlue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  onPressed: () => _launchMaps(context),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlagImage() {
    if (country.flagPng.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: country.flagPng,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          color: const Color(0xFFF3F4F6),
        ),
        errorWidget: (context, url, error) {
          if (country.flagSvg.isNotEmpty) {
            return SvgPicture.network(
              country.flagSvg,
              fit: BoxFit.cover,
              placeholderBuilder: (context) => Container(
                color: const Color(0xFFF3F4F6),
              ),
            );
          }
          return const Icon(
            Icons.flag_outlined,
            size: 24,
            color: Color(0xFF9CA3AF),
          );
        },
      );
    } else if (country.flagSvg.isNotEmpty) {
      return SvgPicture.network(
        country.flagSvg,
        fit: BoxFit.cover,
        placeholderBuilder: (context) => Container(
          color: const Color(0xFFF3F4F6),
        ),
      );
    }

    return const Icon(
      Icons.flag_outlined,
      size: 24,
      color: Color(0xFF9CA3AF),
    );
  }
}
