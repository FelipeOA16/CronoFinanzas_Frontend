import 'package:dio/dio.dart';

import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/aporte_meta_model.dart';
import '../models/meta_financiera_model.dart';
import '../models/meta_financiera_resumen_model.dart';

class MetaFinancieraRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  MetaFinancieraRemoteDataSource(this._apiClient, this._dio);

  Future<List<MetaFinancieraModel>> getMetas({
    String? estado,
    String? prioridad,
    String? search,
  }) async {
    final query = <String, dynamic>{
      if (estado != null) 'estado': estado,
      if (prioridad != null) 'prioridad': prioridad,
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final data = await _apiClient.handleRequest(
      () => _dio.get(
        Endpoints.metas,
        queryParameters: query.isEmpty ? null : query,
      ),
    );
    return (data as List<dynamic>)
        .map((e) => MetaFinancieraModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<MetaFinancieraModel> getMeta(int id) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.meta(id)),
    );
    return MetaFinancieraModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MetaFinancieraModel> createMeta(Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.metas, data: body),
    );
    return MetaFinancieraModel.fromJson(data as Map<String, dynamic>);
  }

  Future<MetaFinancieraModel> updateMeta(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.meta(id), data: body),
    );
    return MetaFinancieraModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteMeta(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.meta(id)),
    );
  }

  Future<MetaFinancieraResumenModel> getResumen() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.metasResumen),
    );
    return MetaFinancieraResumenModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<AporteMetaModel>> getAportes(int id) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.metaAportes(id)),
    );
    return (data as List<dynamic>)
        .map((e) => AporteMetaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<AporteMetaModel> registrarAporte(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.metaAportes(id), data: body),
    );
    return AporteMetaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> eliminarAporte(int id, int aporteId) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.metaAporte(id, aporteId)),
    );
  }
}
