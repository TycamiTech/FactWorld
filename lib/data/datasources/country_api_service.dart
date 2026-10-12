import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import '../../core/network/api_exceptions.dart';
import '../models/country_model.dart';

export '../../core/network/api_exceptions.dart';

class CountryApiService {
  final Dio _dio;

  static const String endpointFields =
      'name,tld,capital,population,area,region,subregion,latlng,currencies,languages,demonyms,flags,timezones,maps';

  // Endpoint Mirror REST Countries v3.1 berkecepatan tinggi via jsDelivr CDN
  static const String primaryUrl =
      'https://cdn.jsdelivr.net/gh/Diwanshumidha/Countries-Api@main/resources/countries.json';

  // Endpoint Cadangan via GitHub Raw
  static const String fallbackUrl =
      'https://raw.githubusercontent.com/Diwanshumidha/Countries-Api/main/resources/countries.json';

  // Fallback Offline Lokal
  static const String localAssetPath = 'assets/data/countries.json';

  CountryApiService({Dio? dio}) : _dio = dio ?? Dio();

  /// Mengambil seluruh data negara.
  /// Urutan prioritas:
  /// 1. CDN Mirror (jsDelivr)
  /// 2. Raw GitHub Mirror
  /// 3. Offline Bundled Asset (Local fallback)
  Future<List<CountryModel>> fetchAllCountries() async {
    // 1. Coba dari CDN
    try {
      return await _fetchFromUrl(primaryUrl);
    } catch (_) {
      // 2. Coba dari Raw GitHub
      try {
        return await _fetchFromUrl(fallbackUrl);
      } catch (_) {
        // 3. Fallback ke asset offline lokal
        return await _loadFromLocalAsset();
      }
    }
  }

  Future<List<CountryModel>> _fetchFromUrl(String url) async {
    final response = await _dio.get(
      url,
      options: Options(
        headers: {
          'Accept': 'application/json',
        },
        responseType: ResponseType.json,
      ),
    );

    dynamic data = response.data;
    if (data is String) {
      data = jsonDecode(data);
    }

    if (data is! List) {
      throw const DataParsingException(
        'Respons API tidak berformat List seperti yang diharapkan',
      );
    }

    return _parseCountryList(data);
  }

  Future<List<CountryModel>> _loadFromLocalAsset() async {
    try {
      final jsonString = await rootBundle.loadString(localAssetPath);
      final dynamic data = jsonDecode(jsonString);
      if (data is List) {
        return _parseCountryList(data);
      }
      throw const DataParsingException('Asset data negara tidak berformat List');
    } catch (e) {
      throw DataParsingException(
        'Gagal memuat data negara dari offline asset: $e',
        originalError: e,
      );
    }
  }

  List<CountryModel> _parseCountryList(List<dynamic> list) {
    return list.map((item) {
      if (item is Map<String, dynamic>) {
        return CountryModel.fromJson(item);
      } else if (item is Map) {
        return CountryModel.fromJson(Map<String, dynamic>.from(item));
      } else {
        throw const DataParsingException(
          'Format item negara dalam array tidak valid',
        );
      }
    }).toList();
  }
}
