import '../../domain/repositories/country_repository.dart';
import '../datasources/country_api_service.dart';
import '../models/country_model.dart';

class CountryRepositoryImpl implements CountryRepository {
  final CountryApiService apiService;

  CountryRepositoryImpl({required this.apiService});

  @override
  Future<List<CountryModel>> getCountries() async {
    return await apiService.fetchAllCountries();
  }
}
