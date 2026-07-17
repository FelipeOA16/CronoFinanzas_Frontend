import 'package:dio/dio.dart';
import '../../../../../core/config/endpoints.dart';
import '../../../../../core/network/api_client.dart';
import '../models/deuda_prestamo_model.dart';
import '../models/deuda_prestamo_resumen_model.dart';
import '../models/pago_deuda_prestamo_model.dart';

class DeudaPrestamoRemoteDataSource {
  final ApiClient _apiClient;
  final Dio _dio;

  DeudaPrestamoRemoteDataSource(this._apiClient, this._dio);

  Future<List<DeudaPrestamoModel>> getDeudasPrestamos({
    String? tipo,
    String? estado,
    String? prioridad,
    DateTime? vencenHasta,
    String? search,
  }) async {
    final query = <String, dynamic>{
      if (tipo != null) 'tipo': tipo,
      if (estado != null) 'estado': estado,
      if (prioridad != null) 'prioridad': prioridad,
      if (vencenHasta != null)
        'vencen_hasta': vencenHasta.toIso8601String().substring(0, 10),
      if (search != null && search.trim().isNotEmpty) 'search': search.trim(),
    };
    final data = await _apiClient.handleRequest(
      () => _dio.get(
        Endpoints.deudasPrestamos,
        queryParameters: query.isEmpty ? null : query,
      ),
    );
    return (data as List<dynamic>)
        .map((e) => DeudaPrestamoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeudaPrestamoModel> getDeudaPrestamo(int id) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.deudaPrestamo(id)),
    );
    return DeudaPrestamoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<DeudaPrestamoModel> createDeudaPrestamo(
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.deudasPrestamos, data: body),
    );
    return DeudaPrestamoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<DeudaPrestamoModel> updateDeudaPrestamo(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.patch(Endpoints.deudaPrestamo(id), data: body),
    );
    return DeudaPrestamoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> deleteDeudaPrestamo(int id) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.deudaPrestamo(id)),
    );
  }

  Future<DeudaPrestamoResumenModel> getResumen() async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.deudasPrestamosResumen),
    );
    return DeudaPrestamoResumenModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<PagoDeudaPrestamoModel>> getPagos(int id) async {
    final data = await _apiClient.handleRequest(
      () => _dio.get(Endpoints.deudaPrestamoPagos(id)),
    );
    return (data as List<dynamic>)
        .map((e) => PagoDeudaPrestamoModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<PagoDeudaPrestamoModel> registrarPago(
    int id,
    Map<String, dynamic> body,
  ) async {
    final data = await _apiClient.handleRequest(
      () => _dio.post(Endpoints.deudaPrestamoPagos(id), data: body),
    );
    return PagoDeudaPrestamoModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> eliminarPago(int id, int pagoId) async {
    await _apiClient.handleRequest<dynamic>(
      () => _dio.delete(Endpoints.deudaPrestamoPago(id, pagoId)),
    );
  }
}
