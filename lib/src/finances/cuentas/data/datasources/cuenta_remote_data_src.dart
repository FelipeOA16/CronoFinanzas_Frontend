import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/cuenta_model.dart';

class CuentaRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  CuentaRemoteDataSource(this._apiClient, this._dio);

  Future<List<CuentaModel>> getCuentas() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.cuentas),
    );
    final list = data as List<dynamic>;
    return list
        .map((e) => CuentaModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<CuentaModel> createCuenta(Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.cuentas, data: body),
    );
    return CuentaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<CuentaModel> updateCuenta(int id, Map<String, dynamic> body) async {
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.cuenta(id), data: body),
    );
    return CuentaModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteCuenta(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.cuenta(id)),
    );
  }
}
