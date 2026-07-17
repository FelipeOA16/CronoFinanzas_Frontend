import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/notificacion_model.dart';

class NotificacionRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  NotificacionRemoteDataSource(this._apiClient, this._dio);

  Future<List<NotificacionModel>> getAlertas() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.notificaciones),
    );
    final list = data as List<dynamic>;
    return list
        .map((e) => NotificacionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
