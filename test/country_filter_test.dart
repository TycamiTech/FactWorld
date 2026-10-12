import 'package:flutter_test/flutter_test.dart';
import 'package:factworld/data/models/country_model.dart';
import 'package:factworld/presentation/providers/country_provider.dart';

void main() {
  group('CountryNotifier filterLogic Tests', () {
    const mockCountries = [
      CountryModel(
        commonName: 'Indonesia',
        officialName: 'Republic of Indonesia',
        nativeName: 'Indonesia',
        tld: ['.id'],
        capital: 'Jakarta',
        population: 273523615,
        area: 1904569.0,
        region: 'Asia',
        subregion: 'South-Eastern Asia',
        latitude: -5.0,
        longitude: 120.0,
        currencies: [
          CountryCurrencyModel(code: 'IDR', name: 'Indonesian rupiah', symbol: 'Rp')
        ],
        languages: ['Indonesian'],
        demonym: 'Indonesian',
        flagPng: 'https://flagcdn.com/w320/id.png',
        flagSvg: 'https://flagcdn.com/id.svg',
        flagAlt: 'Flag of Indonesia',
        timezones: ['UTC+07:00', 'UTC+08:00', 'UTC+09:00'],
        googleMapsUrl: 'https://goo.gl/maps/Indonesia',
      ),
      CountryModel(
        commonName: 'Germany',
        officialName: 'Federal Republic of Germany',
        nativeName: 'Deutschland',
        tld: ['.de'],
        capital: 'Berlin',
        population: 83240525,
        area: 357114.0,
        region: 'Europe',
        subregion: 'Western Europe',
        latitude: 51.0,
        longitude: 9.0,
        currencies: [
          CountryCurrencyModel(code: 'EUR', name: 'Euro', symbol: '€')
        ],
        languages: ['German'],
        demonym: 'German',
        flagPng: 'https://flagcdn.com/w320/de.png',
        flagSvg: 'https://flagcdn.com/de.svg',
        flagAlt: 'Flag of Germany',
        timezones: ['UTC+01:00'],
        googleMapsUrl: 'https://goo.gl/maps/Germany',
      ),
      CountryModel(
        commonName: 'Japan',
        officialName: 'Japan',
        nativeName: 'Nihon',
        tld: ['.jp'],
        capital: 'Tokyo',
        population: 125836021,
        area: 377930.0,
        region: 'Asia',
        subregion: 'Eastern Asia',
        latitude: 36.0,
        longitude: 138.0,
        currencies: [
          CountryCurrencyModel(code: 'JPY', name: 'Japanese yen', symbol: '¥')
        ],
        languages: ['Japanese'],
        demonym: 'Japanese',
        flagPng: 'https://flagcdn.com/w320/jp.png',
        flagSvg: 'https://flagcdn.com/jp.svg',
        flagAlt: 'Flag of Japan',
        timezones: ['UTC+09:00'],
        googleMapsUrl: 'https://goo.gl/maps/Japan',
      ),
    ];

    test('Filter by Region: Asia', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: '',
        region: 'Asia',
      );
      expect(result.length, 2);
      expect(result.map((c) => c.commonName), containsAll(['Indonesia', 'Japan']));
    });

    test('Filter by Region: Eropa (matches Europe)', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: '',
        region: 'Eropa',
      );
      expect(result.length, 1);
      expect(result.first.commonName, 'Germany');
    });

    test('Search by common name: "indo"', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'indo',
        region: 'Semua',
      );
      expect(result.length, 1);
      expect(result.first.commonName, 'Indonesia');
    });

    test('Search by official name: "Federal Republic"', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'Federal Republic',
        region: 'Semua',
      );
      expect(result.length, 1);
      expect(result.first.commonName, 'Germany');
    });

    test('Search by capital: "Tokyo"', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'Tokyo',
        region: 'Semua',
      );
      expect(result.length, 1);
      expect(result.first.commonName, 'Japan');
    });

    test('Search by TLD: ".id" and "id"', () {
      final withDot = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: '.id',
        region: 'Semua',
      );
      expect(withDot.length, 1);
      expect(withDot.first.commonName, 'Indonesia');

      final withoutDot = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'id',
        region: 'Semua',
      );
      expect(withoutDot.map((c) => c.commonName), contains('Indonesia'));
    });

    test('Combined filter: Query "a" and Region "Asia"', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'a',
        region: 'Asia',
      );
      // Both Indonesia and Japan are in Asia and contain 'a'
      expect(result.length, 2);
    });

    test('Combined filter: Query "Berlin" and Region "Asia" returns empty', () {
      final result = CountryNotifier.filterLogic(
        countries: mockCountries,
        query: 'Berlin',
        region: 'Asia',
      );
      expect(result.isEmpty, true);
    });

    test('Flag parsing: list of URLs and cca2 fallback', () {
      // 1. List format (as in countries.json)
      final modelFromList = CountryModel.fromJson({
        'name': {'common': 'Albania', 'official': 'Republic of Albania'},
        'cca2': 'AL',
        'flags': ['https://flagcdn.com/al.svg', 'https://flagcdn.com/w320/al.png'],
      });
      expect(modelFromList.flagPng, 'https://flagcdn.com/w320/al.png');
      expect(modelFromList.flagSvg, 'https://flagcdn.com/al.svg');

      // 2. Empty flags with cca2 fallback
      final modelFromCca2 = CountryModel.fromJson({
        'name': {'common': 'Albania'},
        'cca2': 'AL',
      });
      expect(modelFromCca2.flagPng, 'https://flagcdn.com/w320/al.png');
      expect(modelFromCca2.flagSvg, 'https://flagcdn.com/al.svg');
    });
  });
}
