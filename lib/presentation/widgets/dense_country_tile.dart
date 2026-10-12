import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_theme.dart';
import '../../data/models/country_model.dart';

class DenseCountryTile extends StatelessWidget {
  final CountryModel country;
  final VoidCallback? onTap;

  const DenseCountryTile({
    super.key,
    required this.country,
    this.onTap,
  });

  /// Format angka populasi menjadi representasi ringkas (misal: 273.8M, 1.2B, 85.0K)
  static String formatCompactPopulation(int population) {
    if (population >= 1000000000) {
      final val = population / 1000000000;
      return '${val.toStringAsFixed(val >= 10 ? 0 : 1)}B';
    } else if (population >= 1000000) {
      final val = population / 1000000;
      return '${val.toStringAsFixed(val >= 10 ? 0 : 1)}M';
    } else if (population >= 1000) {
      final val = population / 1000;
      return '${val.toStringAsFixed(val >= 10 ? 0 : 1)}K';
    }
    return population.toString();
  }

  /// Format string mata uang (Simbol)
  String _formatCurrency() {
    if (country.currencies.isEmpty) return '-';
    final currency = country.currencies.first;
    if (currency.symbol.isNotEmpty) {
      return '${currency.code} (${currency.symbol})';
    }
    return currency.code.isNotEmpty ? currency.code : currency.name;
  }

  @override
  Widget build(BuildContext context) {
    final capitalText = country.capital != '-' ? country.capital : 'Tanpa Ibu Kota';
    final popText = formatCompactPopulation(country.population);
    final currencyText = _formatCurrency();

    // Sisi kanan: "Region · TLD"
    final tldText = country.tld.isNotEmpty ? country.tld.first : '';
    final rightMetaText = tldText.isNotEmpty
        ? '${country.region} · $tldText'
        : country.region;

    return InkWell(
      onTap: onTap,
      child: Container(
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
            // Sisi Kiri: Thumbnail bendera kecil (rasio 3:2, lebar ~36dp, tinggi 24dp)
            Hero(
              tag: 'flag_${country.commonName}',
              child: Container(
                width: 36,
                height: 24,
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(4),
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

            // Sisi Tengah: Nama & Subtitle Detail Spek
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Baris 1: Nama Umum (14sp bold #111827)
                  Text(
                    country.commonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF111827),
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),

                  const SizedBox(height: 3),

                  // Baris 2: "Ibu Kota · Populasi singkat · Mata Uang" (11.5sp, #6B7280)
                  Text(
                    '$capitalText · $popText · $currencyText',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF6B7280),
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Sisi Kanan: Region & TLD Badge (11.5sp)
            Text(
              rightMetaText,
              style: const TextStyle(
                fontSize: 11.5,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7280),
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
            size: 14,
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
      size: 14,
      color: Color(0xFF9CA3AF),
    );
  }
}
