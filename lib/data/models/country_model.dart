import '../../domain/entities/country.dart';

class CountryCurrencyModel extends CountryCurrency {
  const CountryCurrencyModel({
    required super.code,
    required super.name,
    required super.symbol,
  });

  factory CountryCurrencyModel.fromJson(String code, dynamic json) {
    if (json is Map<String, dynamic>) {
      return CountryCurrencyModel(
        code: code,
        name: (json['name'] as String?)?.trim() ?? code,
        symbol: (json['symbol'] as String?)?.trim() ?? '',
      );
    }
    return CountryCurrencyModel(
      code: code,
      name: code,
      symbol: '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'code': code,
      'name': name,
      'symbol': symbol,
    };
  }
}

class CountryModel extends Country {
  const CountryModel({
    required super.commonName,
    required super.officialName,
    required super.nativeName,
    required super.tld,
    required super.capital,
    required super.population,
    required super.area,
    required super.region,
    required super.subregion,
    required super.latitude,
    required super.longitude,
    required super.currencies,
    required super.languages,
    required super.demonym,
    required super.flagPng,
    required super.flagSvg,
    required super.flagAlt,
    required super.timezones,
    required super.googleMapsUrl,
  });

  factory CountryModel.fromJson(Map<String, dynamic> json) {
    // 1. Nama: Common, Official, Native Name (ambil value pertama map nativeName)
    final nameMap = json['name'] is Map<String, dynamic>
        ? json['name'] as Map<String, dynamic>
        : const <String, dynamic>{};

    final commonName = (nameMap['common'] as String?)?.trim() ?? '-';
    final officialName = (nameMap['official'] as String?)?.trim() ?? commonName;

    String nativeName = '';
    final nativeNameMap = nameMap['nativeName'];
    if (nativeNameMap is Map<String, dynamic> && nativeNameMap.isNotEmpty) {
      final firstEntry = nativeNameMap.values.first;
      if (firstEntry is Map<String, dynamic>) {
        nativeName = (firstEntry['common'] as String?)?.trim() ??
            (firstEntry['official'] as String?)?.trim() ??
            '';
      }
    }
    if (nativeName.isEmpty) {
      nativeName = commonName;
    }

    // 2. TLD: List<String>
    final tldRaw = json['tld'];
    final List<String> tld = (tldRaw is List)
        ? tldRaw
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    // 3. Ibu Kota: String (ambil elemen pertama array capital; jika null/kosong fallback ke "-")
    final capitalRaw = json['capital'];
    final String capital = (capitalRaw is List &&
            capitalRaw.isNotEmpty &&
            capitalRaw.first != null &&
            capitalRaw.first.toString().trim().isNotEmpty)
        ? capitalRaw.first.toString().trim()
        : '-';

    // 4. Populasi: int
    final populationRaw = json['population'];
    final int population = (populationRaw is num) ? populationRaw.toInt() : 0;

    // 5. Luas Wilayah: double
    final areaRaw = json['area'];
    final double area = (areaRaw is num) ? areaRaw.toDouble() : 0.0;

    // 6. Region & Subregion: String
    final region = (json['region'] as String?)?.trim() ?? '-';
    final subregion = (json['subregion'] as String?)?.trim() ?? '-';

    // 7. Koordinat: double latitude, double longitude (dari field latlng)
    final latlngRaw = json['latlng'];
    double latitude = 0.0;
    double longitude = 0.0;
    if (latlngRaw is List && latlngRaw.isNotEmpty) {
      if (latlngRaw[0] is num) {
        latitude = (latlngRaw[0] as num).toDouble();
      }
      if (latlngRaw.length > 1 && latlngRaw[1] is num) {
        longitude = (latlngRaw[1] as num).toDouble();
      }
    }

    // 8. Mata Uang: List objek mata uang (ekstraksi dinamis dari Map currencies)
    final currenciesRaw = json['currencies'];
    final List<CountryCurrencyModel> currencies = [];
    if (currenciesRaw is Map<String, dynamic>) {
      currenciesRaw.forEach((code, currencyJson) {
        currencies.add(CountryCurrencyModel.fromJson(code, currencyJson));
      });
    }

    // 9. Bahasa: List<String> (ekstraksi values dari Map languages)
    final languagesRaw = json['languages'];
    final List<String> languages = [];
    if (languagesRaw is Map<String, dynamic>) {
      for (final value in languagesRaw.values) {
        if (value != null && value.toString().trim().isNotEmpty) {
          languages.add(value.toString().trim());
        }
      }
    }

    // 10. Demonim: String (dari demonyms.eng.m atau fallback)
    String demonym = '-';
    final demonymsRaw = json['demonyms'];
    if (demonymsRaw is Map<String, dynamic>) {
      final engDemonym = demonymsRaw['eng'];
      if (engDemonym is Map<String, dynamic>) {
        final male = engDemonym['m'] as String?;
        final female = engDemonym['f'] as String?;
        if (male != null && male.trim().isNotEmpty) {
          demonym = male.trim();
        } else if (female != null && female.trim().isNotEmpty) {
          demonym = female.trim();
        }
      }
    }

    // 11. Bendera: URL PNG, URL SVG, dan alt text
    final flagsRaw = json['flags'];
    String flagPng = '';
    String flagSvg = '';
    String flagAlt = '';

    if (flagsRaw is Map<String, dynamic>) {
      flagPng = (flagsRaw['png'] as String?)?.trim() ?? '';
      flagSvg = (flagsRaw['svg'] as String?)?.trim() ?? '';
      flagAlt = (flagsRaw['alt'] as String?)?.trim() ?? '';
    } else if (flagsRaw is List) {
      for (final item in flagsRaw) {
        if (item != null) {
          final url = item.toString().trim();
          if (url.endsWith('.png') || url.contains('/w320/')) {
            flagPng = url;
          } else if (url.endsWith('.svg')) {
            flagSvg = url;
          }
        }
      }
    }

    // Fallback otomatis menggunakan cca2 atau TLD ke FlagCDN jika URL masih kosong
    final cca2 = (json['cca2'] as String?)?.toLowerCase().trim() ?? '';
    if (flagPng.isEmpty && cca2.isNotEmpty) {
      flagPng = 'https://flagcdn.com/w320/$cca2.png';
    }
    if (flagSvg.isEmpty && cca2.isNotEmpty) {
      flagSvg = 'https://flagcdn.com/$cca2.svg';
    }
    if (flagPng.isEmpty && tld.isNotEmpty) {
      final code = tld.first.replaceAll('.', '').toLowerCase().trim();
      if (code.length == 2) {
        flagPng = 'https://flagcdn.com/w320/$code.png';
        flagSvg = 'https://flagcdn.com/$code.svg';
      }
    }

    // Normalisasi bendera: Hindari URL Wikimedia yang diblokir/rate-limited (khususnya Afghanistan)
    // dan gunakan FlagCDN yang stabil dan konsisten dengan seluruh negara lainnya.
    if (flagPng.contains('wikimedia.org') ||
        flagSvg.contains('wikimedia.org') ||
        cca2 == 'af' ||
        commonName.toLowerCase() == 'afghanistan') {
      flagPng = 'https://flagcdn.com/w320/af.png';
      flagSvg = 'https://flagcdn.com/af.svg';
    }

    // 12. Zona Waktu: List<String>
    final timezonesRaw = json['timezones'];
    final List<String> timezones = (timezonesRaw is List)
        ? timezonesRaw
            .where((e) => e != null)
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList()
        : <String>[];

    // 13. Tautan Google Maps: String (dari maps.googleMaps)
    final mapsRaw = json['maps'];
    String googleMapsUrl = '';
    if (mapsRaw is Map<String, dynamic>) {
      googleMapsUrl = (mapsRaw['googleMaps'] as String?)?.trim() ?? '';
    }

    return CountryModel(
      commonName: commonName,
      officialName: officialName,
      nativeName: nativeName,
      tld: tld,
      capital: capital,
      population: population,
      area: area,
      region: region.isNotEmpty ? region : '-',
      subregion: subregion.isNotEmpty ? subregion : '-',
      latitude: latitude,
      longitude: longitude,
      currencies: currencies,
      languages: languages,
      demonym: demonym,
      flagPng: flagPng,
      flagSvg: flagSvg,
      flagAlt: flagAlt,
      timezones: timezones,
      googleMapsUrl: googleMapsUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': {
        'common': commonName,
        'official': officialName,
        'nativeName': {
          'primary': {
            'common': nativeName,
            'official': officialName,
          }
        },
      },
      'tld': tld,
      'capital': [capital],
      'population': population,
      'area': area,
      'region': region,
      'subregion': subregion,
      'latlng': [latitude, longitude],
      'currencies': {
        for (final c in currencies)
          c.code: {
            'name': c.name,
            'symbol': c.symbol,
          }
      },
      'languages': {
        for (var i = 0; i < languages.length; i++) 'lang_$i': languages[i]
      },
      'demonyms': {
        'eng': {
          'm': demonym,
          'f': demonym,
        }
      },
      'flags': {
        'png': flagPng,
        'svg': flagSvg,
        'alt': flagAlt,
      },
      'timezones': timezones,
      'maps': {
        'googleMaps': googleMapsUrl,
      },
    };
  }
}
