import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/presupuesto_model.dart';

class PresupuestoRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  PresupuestoRemoteDataSource(this._apiClient, this._dio);

  Future<List<PresupuestoModel>> getPresupuestos({int? mes, int? anio}) async {
    final queryParams = <String, dynamic>{};
    if (mes != null) queryParams['mes'] = mes;
    if (anio != null) queryParams['anio'] = anio;

    final data = await _apiClient.handleRequest(
      () => _dio.get(
        Endpoints.presupuestos,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      ),
    );
    final list = data as List<dynamic>;
    return list
        .map((e) => PresupuestoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PresupuestoModel> createPresupuesto(Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.presupuestos, data: body),
    );
    return PresupuestoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<PresupuestoModel> updatePresupuesto(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.put(Endpoints.presupuesto(id), data: body),
    );
    return PresupuestoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deletePresupuesto(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.presupuesto(id)),
    );
  }
}
