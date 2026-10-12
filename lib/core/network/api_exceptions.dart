/// Base custom exception untuk interaksi API FactWorld
abstract class CountryApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  const CountryApiException(this.message, {this.statusCode, this.originalError});

  @override
  String toString() => '$runtimeType: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Kesalahan koneksi jaringan atau timeout
class NetworkException extends CountryApiException {
  const NetworkException(super.message, {super.statusCode, super.originalError});
}

/// Kesalahan respons dari server (4xx / 5xx)
class ServerException extends CountryApiException {
  const ServerException(super.message, {super.statusCode, super.originalError});
}

/// Kesalahan parsing atau formatting data JSON
class DataParsingException extends CountryApiException {
  const DataParsingException(super.message, {super.originalError});
}

/// Kesalahan jika data negara tidak ditemukan
class CountryNotFoundException extends CountryApiException {
  const CountryNotFoundException([super.message = 'Negara tidak ditemukan', int? statusCode = 404])
      : super(statusCode: statusCode);
}
