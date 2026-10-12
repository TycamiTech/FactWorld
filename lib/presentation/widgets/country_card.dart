import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/country.dart';

class CountryCard extends StatelessWidget {
  final Country country;
  final VoidCallback? onTap;

  const CountryCard({
    super.key,
    required this.country,
    this.onTap,
  });

  Future<void> _launchMaps(BuildContext context, String? url) async {
    if (url == null || url.trim().isEmpty) {
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
            content: Text('Tidak dapat membuka aplikasi Google Maps atau browser.'),
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
    final badgeCode = country.tld.isNotEmpty
        ? country.tld.first.toUpperCase()
        : (country.demonym != '-' ? country.demonym : country.region);

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Flag Container
              Container(
                width: 44,
                height: 30,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: AppTheme.border, width: 0.8),
                ),
                clipBehavior: Clip.antiAlias,
                child: country.flagPng.isNotEmpty
                    ? CachedNetworkImage(
                        imageUrl: country.flagPng,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          color: AppTheme.borderSubtle,
                          alignment: Alignment.center,
                          child: const SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(strokeWidth: 1.5),
                          ),
                        ),
                        errorWidget: (context, url, error) => const Center(
                          child: Icon(
                            Icons.flag_outlined,
                            size: 16,
                            color: AppTheme.textMuted,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.flag_outlined,
                          size: 16,
                          color: AppTheme.textMuted,
                        ),
                      ),
              ),

              const SizedBox(width: 12),

              // Country Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Common Name & Badge
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            country.commonName,
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 5, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppTheme.borderSubtle,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            badgeCode,
                            style: const TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Capital & Region
                    Row(
                      children: [
                        if (country.capital != '-') ...[
                          Flexible(
                            child: Text(
                              country.capital,
                              style: Theme.of(context).textTheme.bodySmall,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppTheme.textMuted,
                            ),
                          ),
                        ],
                        Text(
                          country.region,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 3),

                    // Population & Area Stats
                    Row(
                      children: [
                        const Icon(
                          Icons.people_alt_outlined,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formattedPopulation,
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 10),
                        const Icon(
                          Icons.square_foot_outlined,
                          size: 12,
                          color: AppTheme.textMuted,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$formattedArea km²',
                          style: const TextStyle(
                            fontSize: 11,
                            color: AppTheme.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Action button: Google Maps
              if (country.googleMapsUrl.isNotEmpty)
                IconButton(
                  icon: const Icon(
                    Icons.map_outlined,
                    size: 18,
                    color: AppTheme.accentBlue,
                  ),
                  tooltip: 'Buka di Google Maps',
                  splashRadius: 18,
                  visualDensity: VisualDensity.compact,
                  onPressed: () =>
                      _launchMaps(context, country.googleMapsUrl),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
