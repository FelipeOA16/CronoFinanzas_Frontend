import 'package:dio/dio.dart';
import '../../../../core/config/endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../../auth/data/models/user_model.dart';

class UserRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  UserRemoteDataSource(this._apiClient, this._dio);

  Future<UserModel> updatePerfil(
    int idUsuario, {
    String? nombre,
    String? apellido,
    String? nombreMostrar,
    String? telefono,
    String? pais,
    String? zonaHoraria,
    String? idioma,
    String? fotoUrl,
  }) async {
    final body = <String, dynamic>{
      if (nombre != null) 'nombre': nombre,
      if (apellido != null) 'apellido': apellido,
      if (nombreMostrar != null) 'nombre_mostrar': nombreMostrar,
      if (telefono != null) 'telefono': telefono,
      if (pais != null) 'pais': pais,
      if (zonaHoraria != null) 'zona_horaria': zonaHoraria,
      if (idioma != null) 'idioma': idioma,
      if (fotoUrl != null) 'foto_url': fotoUrl,
    };
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.userPerfil(idUsuario), data: body),
    );
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> changePassword(int idUsuario, String newPassword) async {
    await _apiClient.handleRequest(
      () => _dio.patch(
        Endpoints.userPassword(idUsuario),
        data: {'new_password': newPassword},
      ),
    );
  }

  Future<void> deleteAccount(int idUsuario) async {
    await _apiClient.handleRequest(
      () => _dio.delete(Endpoints.userDelete(idUsuario)),
    );
  }
}
