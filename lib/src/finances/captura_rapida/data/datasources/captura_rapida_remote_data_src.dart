import 'package:dio/dio.dart';

import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/captura_rapida_model.dart';
import '../models/captura_rapida_resumen_model.dart';

class CapturaRapidaRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  CapturaRapidaRemoteDataSource(this._apiClient, this._dio);

  Future<List<CapturaRapidaModel>> getCapturas({
    String? estado,
    String? tipo,
  }) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(
        Endpoints.capturasRapidas,
        queryParameters: {
          if (estado != null) 'estado': estado,
          if (tipo != null) 'tipo': tipo,
        },
      ),
    );
    return (data as List<dynamic>)
        .map((e) => CapturaRapidaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CapturaRapidaModel> getCaptura(int id) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.capturaRapida(id)),
    );
    return CapturaRapidaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CapturaRapidaModel> create(Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.capturasRapidas, data: body),
    );
    return CapturaRapidaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CapturaRapidaModel> update(int id, Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.capturaRapida(id), data: body),
    );
    return CapturaRapidaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CapturaRapidaModel> completar(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.capturaRapidaCompletar(id), data: body),
    );
    return CapturaRapidaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> descartar(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.capturaRapida(id)),
    );
  }

  Future<CapturaRapidaResumenModel> getResumen() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.capturasRapidasResumen),
    );
    return CapturaRapidaResumenModel.fromJson(data as Map<String, dynamic>);
  }
}
