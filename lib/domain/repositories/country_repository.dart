import '../../data/models/country_model.dart';

abstract class CountryRepository {
  /// Mengambil seluruh data negara dari REST Countries API melalui ApiService
  Future<List<CountryModel>> getCountries();
}
