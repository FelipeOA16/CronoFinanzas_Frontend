import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../errors/exceptions.dart';

class ApiClient {
  final Dio dio;

  ApiClient(this.dio);

  Future<T> handleRequest<T>(Future<Response<T>> Function() request) async {
    try {
      final response = await request();
      return response.data as T;
    } on DioException catch (e) {
      if (kDebugMode) {
        // Never log response.data as it may contain tokens or sensitive payloads.
        debugPrint(
          '[ApiClient] DioException type=${e.type} status=${e.response?.statusCode}',
        );
      }
      throw _handleDioError(e);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('[ApiClient] Unexpected exception: ${e.runtimeType}');
      }
      throw UnknownException(e.toString());
    }
  }

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return NetworkException('Connection timeout');

      case DioExceptionType.connectionError:
        return NetworkException('No internet connection');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = _extractErrorMessage(error.response?.data);

        if (statusCode == 401) {
          return UnauthorizedException(message);
        } else if (statusCode == 422) {
          return ValidationException(message);
        } else if (statusCode != null) {
          return ServerException(message, statusCode);
        }
        return ServerException(message);

      case DioExceptionType.cancel:
        return UnknownException('Request cancelled');

      default:
        return UnknownException(error.message ?? 'Unknown error');
    }
  }

  String _extractErrorMessage(dynamic data) {
    if (data == null) return 'Server error';

    if (data is Map<String, dynamic>) {
      // Handle FastAPI error format
      if (data.containsKey('detail')) {
        final detail = data['detail'];
        if (detail is String) {
          return detail;
        } else if (detail is List) {
          // Validation errors
          return detail.map((e) => e['msg'] ?? e.toString()).join(', ');
        }
      }
    }

    return 'Server error';
  }
}
