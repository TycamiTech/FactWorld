import 'package:dio/dio.dart';
import '../models/country_model.dart';
import 'country_api_service.dart';

abstract class CountryRemoteDataSource {
  Future<List<CountryModel>> getAllCountries();
  Future<List<CountryModel>> searchCountriesByName(String name);
  Future<List<CountryModel>> getCountriesByRegion(String region);
  Future<CountryModel> getCountryByCode(String code);
}

class CountryRemoteDataSourceImpl implements CountryRemoteDataSource {
  final Dio dio;
  final CountryApiService apiService;

  CountryRemoteDataSourceImpl({
    required this.dio,
    CountryApiService? apiService,
  }) : apiService = apiService ?? CountryApiService(dio: dio);

  @override
  Future<List<CountryModel>> getAllCountries() async {
    return apiService.fetchAllCountries();
  }

  @override
  Future<List<CountryModel>> searchCountriesByName(String name) async {
    final all = await getAllCountries();
    final lowerName = name.toLowerCase().trim();
    return all
        .where((c) =>
            c.commonName.toLowerCase().contains(lowerName) ||
            c.officialName.toLowerCase().contains(lowerName) ||
            c.nativeName.toLowerCase().contains(lowerName))
        .toList();
  }

  @override
  Future<List<CountryModel>> getCountriesByRegion(String region) async {
    final all = await getAllCountries();
    final lowerRegion = region.toLowerCase().trim();
    return all
        .where((c) => c.region.toLowerCase() == lowerRegion)
        .toList();
  }

  @override
  Future<CountryModel> getCountryByCode(String code) async {
    final all = await getAllCountries();
    final lowerCode = code.toLowerCase().trim();
    final match = all.where((c) =>
        c.tld.any((t) => t.toLowerCase().contains(lowerCode)) ||
        c.commonName.toLowerCase() == lowerCode);
    if (match.isEmpty) {
      throw const CountryNotFoundException();
    }
    return match.first;
  }
}
