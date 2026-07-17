import 'package:dio/dio.dart';
import '../config/endpoints.dart';
import '../storage/token_storage.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage;
  final Dio _dio;
  final void Function()? onUnauthenticated;
  final void Function(String accessToken)? onTokenRefreshed;
  bool _isRefreshing = false;

  AuthInterceptor(
    this._tokenStorage,
    this._dio, {
    this.onUnauthenticated,
    this.onTokenRefreshed,
  });

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    // Skip auth for login and refresh endpoints
    if (options.path == Endpoints.login || options.path == Endpoints.refresh) {
      return handler.next(options);
    }

    // Add access token to protected endpoints
    final accessToken = await _tokenStorage.getAccessToken();
    if (accessToken != null) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    return handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    // Handle 401 errors with token refresh
    if (err.response?.statusCode == 401 && !_isRefreshing) {
      // Skip refresh for login endpoint
      if (err.requestOptions.path == Endpoints.login) {
        return handler.next(err);
      }

      _isRefreshing = true;

      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null) {
          await _tokenStorage.clear();
          _isRefreshing = false;
          return handler.next(err);
        }

        // Attempt token refresh
        final response = await _dio.post(
          Endpoints.refresh,
          data: {'refresh_token': refreshToken},
          options: Options(headers: {'Content-Type': 'application/json'}),
        );

        if (response.statusCode == 200) {
          final newAccessToken = response.data['access_token'] as String;
          final newRefreshToken = response.data['refresh_token'] as String;

          await _tokenStorage.saveTokens(
            accessToken: newAccessToken,
            refreshToken: newRefreshToken,
          );
          onTokenRefreshed?.call(newAccessToken);

          // Retry original request with new token
          err.requestOptions.headers['Authorization'] =
              'Bearer $newAccessToken';
          final retryResponse = await _dio.fetch(err.requestOptions);
          _isRefreshing = false;
          return handler.resolve(retryResponse);
        }
      } catch (e) {
        // Refresh failed — clear tokens and signal the app to go to login
        await _tokenStorage.clear();
        onUnauthenticated?.call();
        _isRefreshing = false;
        return handler.next(err);
      }

      _isRefreshing = false;
    }

    return handler.next(err);
  }
}
