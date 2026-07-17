import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/di/providers.dart';
import '../../../data/datasources/deuda_prestamo_remote_data_src.dart';
import '../../../data/repos/deuda_prestamo_repo_impl.dart';
import '../../../domain/entities/deuda_prestamo.dart';
import '../../../domain/entities/deuda_prestamo_resumen.dart';
import '../../../domain/entities/pago_deuda_prestamo.dart';
import '../../../domain/repos/deuda_prestamo_repo.dart';
import 'deuda_prestamo_state.dart';

final deudaPrestamoRemoteDataSourceProvider =
    Provider<DeudaPrestamoRemoteDataSource>((ref) {
      return DeudaPrestamoRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final deudaPrestamoRepositoryProvider = Provider<DeudaPrestamoRepository>((
  ref,
) {
  return DeudaPrestamoRepositoryImpl(
    ref.watch(deudaPrestamoRemoteDataSourceProvider),
  );
});

final deudaPrestamoResumenProvider =
    FutureProvider.autoDispose<DeudaPrestamoResumen>((ref) async {
      final repo = ref.watch(deudaPrestamoRepositoryProvider);
      final result = await repo.getResumen();
      if (result.isOk) return result.data;
      throw Exception(result.failure.message);
    });

final patrimonioNetoEstimadoProvider = FutureProvider.autoDispose<double>((
  ref,
) async {
  final patrimonio = await ref.watch(patrimonioProvider.future);
  final resumen = await ref.watch(deudaPrestamoResumenProvider.future);
  return patrimonio - resumen.totalDebo + resumen.totalMeDeben;
});

final deudaPrestamoControllerProvider =
    StateNotifierProvider<DeudaPrestamoController, DeudaPrestamoState>((ref) {
      return DeudaPrestamoController(
        ref.watch(deudaPrestamoRepositoryProvider),
      );
    });

class DeudaPrestamoController extends StateNotifier<DeudaPrestamoState> {
  final DeudaPrestamoRepository _repo;

  DeudaPrestamoController(this._repo) : super(const DeudaPrestamoInitial());

  List<DeudaPrestamo> get _items {
    final s = state;
    if (s is DeudaPrestamoLoaded) return s.items;
    if (s is DeudaPrestamoError) return s.previousItems;
    return const [];
  }

  DeudaPrestamoResumen? get _resumen {
    final s = state;
    if (s is DeudaPrestamoLoaded) return s.resumen;
    if (s is DeudaPrestamoError) return s.previousResumen;
    return null;
  }

  Future<void> load({
    String? tipo,
    String? estado = 'activa',
    String? prioridad,
    DateTime? vencenHasta,
    String? search,
  }) async {
    state = const DeudaPrestamoLoading();
    final listResult = await _repo.getDeudasPrestamos(
      tipo: tipo,
      estado: estado,
      prioridad: prioridad,
      vencenHasta: vencenHasta,
      search: search,
    );
    final resumenResult = await _repo.getResumen();
    if (listResult.isFail) {
      state = DeudaPrestamoError(
        listResult.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return;
    }
    state = DeudaPrestamoLoaded(
      items: listResult.data,
      resumen: resumenResult.isOk ? resumenResult.data : null,
    );
  }

  Future<void> loadDetail(int id) async {
    final currentItems = _items;
    final currentResumen = _resumen;
    state = const DeudaPrestamoLoading();
    final detailResult = await _repo.getDeudaPrestamo(id);
    final pagosResult = await _repo.getPagos(id);
    if (detailResult.isFail) {
      state = DeudaPrestamoError(
        detailResult.failure.message,
        previousItems: currentItems,
        previousResumen: currentResumen,
      );
      return;
    }
    state = DeudaPrestamoLoaded(
      items: currentItems,
      resumen: currentResumen,
      selected: detailResult.data,
      pagos: pagosResult.isOk ? pagosResult.data : const [],
    );
  }

  Future<bool> create(Map<String, dynamic> body) async {
    final result = await _repo.createDeudaPrestamo(body);
    if (result.isFail) {
      state = DeudaPrestamoError(
        result.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return false;
    }
    await load();
    return true;
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    final result = await _repo.updateDeudaPrestamo(id, body);
    if (result.isFail) {
      state = DeudaPrestamoError(
        result.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return false;
    }
    await load();
    return true;
  }

  Future<bool> delete(int id) async {
    final result = await _repo.deleteDeudaPrestamo(id);
    if (result.isFail) {
      state = DeudaPrestamoError(
        result.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return false;
    }
    await load();
    return true;
  }

  Future<bool> registrarPago(int id, Map<String, dynamic> body) async {
    final result = await _repo.registrarPago(id, body);
    if (result.isFail) {
      state = DeudaPrestamoError(
        result.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return false;
    }
    await loadDetail(id);
    return true;
  }

  Future<bool> eliminarPago(int id, int pagoId) async {
    final result = await _repo.eliminarPago(id, pagoId);
    if (result.isFail) {
      state = DeudaPrestamoError(
        result.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return false;
    }
    await loadDetail(id);
    return true;
  }
}
