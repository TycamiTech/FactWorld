class CountryCurrency {
  final String code;
  final String name;
  final String symbol;

  const CountryCurrency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  @override
  String toString() => symbol.isNotEmpty ? '$name ($symbol)' : name;
}

class Country {
  final String commonName;
  final String officialName;
  final String nativeName;
  final List<String> tld;
  final String capital;
  final int population;
  final double area;
  final String region;
  final String subregion;
  final double latitude;
  final double longitude;
  final List<CountryCurrency> currencies;
  final List<String> languages;
  final String demonym;
  final String flagPng;
  final String flagSvg;
  final String flagAlt;
  final List<String> timezones;
  final String googleMapsUrl;

  const Country({
    required this.commonName,
    required this.officialName,
    required this.nativeName,
    required this.tld,
    required this.capital,
    required this.population,
    required this.area,
    required this.region,
    required this.subregion,
    required this.latitude,
    required this.longitude,
    required this.currencies,
    required this.languages,
    required this.demonym,
    required this.flagPng,
    required this.flagSvg,
    required this.flagAlt,
    required this.timezones,
    required this.googleMapsUrl,
  });
}
