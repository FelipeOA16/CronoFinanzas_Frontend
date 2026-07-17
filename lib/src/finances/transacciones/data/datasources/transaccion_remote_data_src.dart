import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/categoria_model.dart';
import '../models/transaccion_model.dart';

class TransaccionRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  TransaccionRemoteDataSource(this._apiClient, this._dio);

  Future<List<CategoriaModel>> getCategorias() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.categorias, queryParameters: {'flat': true}),
    );
    final list = data as List<dynamic>;
    return list
        .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<Map<String, dynamic>> getTransacciones({
    int? cuentaId,
    String? tipo,
    int? categoriaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limit = 50,
    int offset = 0,
  }) async {
    final queryParams = <String, dynamic>{
      'limit': limit,
      'offset': offset,
      if (cuentaId != null) 'cuenta_id': cuentaId,
      if (tipo != null) 'tipo': tipo,
      if (categoriaId != null) 'categoria_id': categoriaId,
      if (fechaDesde != null)
        'fecha_desde': fechaDesde.toIso8601String().substring(0, 10),
      if (fechaHasta != null)
        'fecha_hasta': fechaHasta.toIso8601String().substring(0, 10),
    };

    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.transacciones, queryParameters: queryParams),
    );
    return data as Map<String, dynamic>;
  }

  Future<TransaccionModel> createTransaccion(Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.transacciones, data: body),
    );
    return TransaccionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<TransaccionModel> updateTransaccion(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.transaccion(id), data: body),
    );
    return TransaccionModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteTransaccion(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.transaccion(id)),
    );
  }
}
