import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/config/endpoints.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../app/di/providers.dart';
import '../../../../../finances/transacciones/data/models/categoria_model.dart';
import '../../../../../finances/transacciones/domain/entities/categoria.dart';
import 'categoria_state.dart';

// ─── DI ──────────────────────────────────────────────────────────────────────

final categoriaControllerProvider =
    StateNotifierProvider<CategoriaController, CategoriaState>((ref) {
      return CategoriaController(
        apiClient: ref.watch(apiClientProvider),
        dio: ref.watch(dioProvider),
      );
    });

// ─── Controller ──────────────────────────────────────────────────────────────

class CategoriaController extends StateNotifier<CategoriaState> {
  final ApiClient _apiClient;
  final Dio _dio;

  CategoriaController({required ApiClient apiClient, required Dio dio})
    : _apiClient = apiClient,
      _dio = dio,
      super(const CategoriaInitial());

  Future<void> loadCategorias() async {
    state = const CategoriaLoading();
    try {
      final data = await _apiClient.handleRequest(
        () => _dio.get(Endpoints.categorias),
      );
      final list = (data as List<dynamic>)
          .map((e) => CategoriaModel.fromJson(e as Map<String, dynamic>))
          .toList();
      state = CategoriaLoaded(list);
    } catch (e) {
      state = CategoriaError(e.toString());
    }
  }

  Future<bool> createCategoria({
    required String nombre,
    required String tipo,
    String? color,
    String? icono,
    int? padreId,
  }) async {
    try {
      await _apiClient.handleRequest(
        () => _dio.post(
          Endpoints.categorias,
          data: {
            'nombre': nombre,
            'tipo': tipo,
            if (color != null) 'color': color,
            if (icono != null) 'icono': icono,
            if (padreId != null) 'padre_id': padreId,
          },
        ),
      );
      await loadCategorias();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> updateCategoria(
    int id, {
    String? nombre,
    String? tipo,
    String? color,
    String? icono,
  }) async {
    try {
      await _apiClient.handleRequest(
        () => _dio.patch(
          Endpoints.categoria(id),
          data: {
            if (nombre != null) 'nombre': nombre,
            if (tipo != null) 'tipo': tipo,
            if (color != null) 'color': color,
            if (icono != null) 'icono': icono,
          },
        ),
      );
      await loadCategorias();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> deleteCategoria(int id) async {
    try {
      await _apiClient.handleRequest(
        () => _dio.delete(Endpoints.categoria(id)),
      );
      await loadCategorias();
      return true;
    } catch (_) {
      return false;
    }
  }
}
