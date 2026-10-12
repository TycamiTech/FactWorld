class AppConstants {
  AppConstants._();

  static const String appName = 'FactWorld';

  // REST Countries API v3.1
  static const String apiBaseUrl = 'https://restcountries.com/v3.1';
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 10000;

  // Optimized fields query parameter
  static const String endpointFields =
      'name,tld,capital,population,area,region,subregion,latlng,currencies,languages,demonyms,flags,timezones,maps';

  // Endpoints
  static const String allCountriesEndpoint = '/all';
  static const String searchByNameEndpoint = '/name';
  static const String searchByRegionEndpoint = '/region';
  static const String searchByCodeEndpoint = '/alpha';

  // Region filter options (Indonesian)
  static const List<String> regions = [
    'Semua',
    'Asia',
    'Eropa',
    'Afrika',
    'Amerika',
    'Oseania',
  ];
}
