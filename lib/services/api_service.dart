import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../core/constants/app_constants.dart';
import '../core/errors/app_exception.dart';

class ApiService {
  final http.Client _client;
  bool _isDisposed = false;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  Future<dynamic> get(String endpoint) async {
    if (_isDisposed) {
      throw const AppException('Service is no longer available.');
    }

    final uri = Uri.parse('${AppConstants.baseUrl}$endpoint');

    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else if (response.statusCode >= 400 && response.statusCode < 500) {
        throw ServerException(
          'Request failed. Please try again.',
          response.statusCode,
        );
      } else if (response.statusCode >= 500) {
        throw ServerException(
          'Server is not responding. Please try later.',
          response.statusCode,
        );
      } else {
        throw ServerException(
          'Unexpected error occurred.',
          response.statusCode,
        );
      }
    } on TimeoutException {
      throw const NetworkException('Request timed out. Please try again.');
    } on SocketException {
      throw const NetworkException('No internet connection.');
    } on http.ClientException {
      throw const NetworkException('Connection failed. Check your internet.');
    } on FormatException {
      throw const ParseException('Invalid response from server.');
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException('Something went wrong: $e');
    }
  }

  void dispose() {
    if (!_isDisposed) {
      _isDisposed = true;
      _client.close();
    }
  }
}