import 'package:dio/dio.dart';
import '../constants/app_constants.dart';

class ApiClient {
  final Dio dio;

  ApiClient({Dio? customDio})
      : dio = customDio ??
            Dio(
              BaseOptions(
                baseUrl: AppConstants.apiBaseUrl,
                connectTimeout:
                    const Duration(milliseconds: AppConstants.connectTimeoutMs),
                receiveTimeout:
                    const Duration(milliseconds: AppConstants.receiveTimeoutMs),
                headers: {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json',
                },
              ),
            ) {
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
      ),
    );
  }
}
