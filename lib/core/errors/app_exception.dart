class AppException implements Exception {
  final String message;
  final int? statusCode;

  const AppException(this.message, {this.statusCode});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  const NetworkException([String message = 'No internet connection'])
      : super(message);
}

class ServerException extends AppException {
  const ServerException([String message = 'Server error', int? statusCode])
      : super(message, statusCode: statusCode);
}

class ParseException extends AppException {
  const ParseException([String message = 'Failed to parse data'])
      : super(message);
}