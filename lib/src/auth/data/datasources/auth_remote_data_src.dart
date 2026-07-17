import 'package:dio/dio.dart';
import '../../../../core/config/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/auth_tokens_model.dart';
import '../models/sesion_activa_model.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  AuthRemoteDataSource(this._apiClient, this._dio);

  Future<UserModel> register({
    required String email,
    required String password,
    String? nombre,
    String? apellido,
    String? nombreMostrar,
  }) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(
        Endpoints.register,
        data: {
          'email': email,
          'password': password,
          if (nombre != null) 'nombre': nombre,
          if (apellido != null) 'apellido': apellido,
          if (nombreMostrar != null) 'nombre_mostrar': nombreMostrar,
        },
      ),
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthTokensModel> login({
    required String email,
    required String password,
  }) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(
        Endpoints.login,
        data: {'email': email, 'password': password},
      ),
    );
    return AuthTokensModel.fromJson(data as Map<String, dynamic>);
  }

  Future<UserModel> getMe() async {
    final data = await _apiClient.handleRequest(() => _dio.get(Endpoints.me));
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.refresh, data: {'refresh_token': refreshToken}),
    );
    return AuthTokensModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> logout(String refreshToken) async {
    try {
      await _dio.post(
        Endpoints.logout,
        data: {'refresh_token': refreshToken},
        options: Options(validateStatus: (s) => s != null && s < 500),
      );
    } catch (_) {
      // Best-effort: ignore errors during logout
    }
  }

  Future<void> forgotPassword(String email) async {
    await _apiClient.handleRequest(
      () => _dio.post(Endpoints.forgotPassword, data: {'email': email}),
    );
  }

  Future<void> resetPassword(String token, String newPassword) async {
    await _apiClient.handleRequest(
      () => _dio.post(
        Endpoints.resetPassword,
        data: {'token': token, 'new_password': newPassword},
      ),
    );
  }

  Future<void> verifyEmail(String token) async {
    await _apiClient.handleRequest(
      () => _dio.post(Endpoints.verifyEmail, data: {'token': token}),
    );
  }

  Future<void> resendVerification() async {
    await _apiClient.handleRequest(
      () => _dio.post(Endpoints.resendVerification),
    );
  }

  Future<List<SesionActivaModel>> listSessions(int idUsuario) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.userSessions(idUsuario)),
    );
    return (data as List<dynamic>)
        .map((e) => SesionActivaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> revokeSession(int idUsuario, String sessionUuid) async {
    await _apiClient.handleRequest(
      () => _dio.delete(Endpoints.userSession(idUsuario, sessionUuid)),
    );
  }

  Future<void> revokeAllSessions(int idUsuario) async {
    await _apiClient.handleRequest(
      () => _dio.delete(Endpoints.userSessions(idUsuario)),
    );
  }
}
