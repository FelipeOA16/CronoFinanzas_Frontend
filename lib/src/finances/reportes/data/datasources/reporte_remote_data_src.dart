import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/reporte_model.dart';

class ReporteRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  ReporteRemoteDataSource(this._apiClient, this._dio);

  Future<ReporteDataModel> getReporte({
    int? mes,
    int? anio,
    int mesesFlujo = 6,
  }) async {
    final queryParams = <String, dynamic>{'meses_flujo': mesesFlujo};
    if (mes != null) queryParams['mes'] = mes;
    if (anio != null) queryParams['anio'] = anio;

    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.reportesResumen, queryParameters: queryParams),
    );
    return ReporteDataModel.fromJson(data as Map<String, dynamic>);
  }
}
