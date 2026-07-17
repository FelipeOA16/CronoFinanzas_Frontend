import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../app/di/providers.dart';
import '../../../data/datasources/presupuesto_remote_data_src.dart';
import '../../../data/repos/presupuesto_repo_impl.dart';
import '../../../domain/entities/presupuesto.dart';
import '../../../domain/repos/presupuesto_repo.dart';
import 'presupuesto_state.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final presupuestoRemoteDataSourceProvider =
    Provider<PresupuestoRemoteDataSource>((ref) {
      return PresupuestoRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final presupuestoRepositoryProvider = Provider<PresupuestoRepository>((ref) {
  return PresupuestoRepositoryImpl(
    ref.watch(presupuestoRemoteDataSourceProvider),
  );
});

final presupuestoControllerProvider =
    StateNotifierProvider<PresupuestoController, PresupuestoState>((ref) {
      return PresupuestoController(ref.watch(presupuestoRepositoryProvider));
    });

// ─── Controller ──────────────────────────────────────────────────────────────

class PresupuestoController extends StateNotifier<PresupuestoState> {
  final PresupuestoRepository _repo;

  PresupuestoController(this._repo) : super(const PresupuestoInitial());

  List<Presupuesto> get _current => state is PresupuestoLoaded
      ? (state as PresupuestoLoaded).presupuestos
      : [];

  Future<void> loadPresupuestos({int? mes, int? anio}) async {
    state = const PresupuestoLoading();
    final result = await _repo.getPresupuestos(mes: mes, anio: anio);
    if (result.isFail) {
      state = PresupuestoError(result.failure.message);
      return;
    }
    final sorted = [...result.data]
      ..sort((a, b) {
        // Global first, then by category name
        if (a.esGlobal && !b.esGlobal) return -1;
        if (!a.esGlobal && b.esGlobal) return 1;
        return (a.categoriaNombre ?? '').compareTo(b.categoriaNombre ?? '');
      });
    state = PresupuestoLoaded(sorted);
  }

  Future<bool> createPresupuesto({
    int? categoriaId,
    required int mes,
    required int anio,
    required double montoLimite,
    required String moneda,
  }) async {
    final result = await _repo.createPresupuesto(
      categoriaId: categoriaId,
      mes: mes,
      anio: anio,
      montoLimite: montoLimite,
      moneda: moneda,
    );
    if (result.isFail) {
      state = PresupuestoError(result.failure.message, previous: _current);
      return false;
    }
    state = PresupuestoLoaded([
      ...result.data == null ? _current : [result.data, ..._current],
    ]);
    await loadPresupuestos(mes: mes, anio: anio);
    return true;
  }

  Future<bool> updatePresupuesto({
    required int id,
    double? montoLimite,
    String? moneda,
    int? mes,
    int? anio,
  }) async {
    final result = await _repo.updatePresupuesto(
      id: id,
      montoLimite: montoLimite,
      moneda: moneda,
    );
    if (result.isFail) {
      state = PresupuestoError(result.failure.message, previous: _current);
      return false;
    }
    await loadPresupuestos(mes: mes, anio: anio);
    return true;
  }

  Future<bool> deletePresupuesto(int id, {int? mes, int? anio}) async {
    final result = await _repo.deletePresupuesto(id);
    if (result.isFail) {
      state = PresupuestoError(result.failure.message, previous: _current);
      return false;
    }
    final updated = _current.where((p) => p.id != id).toList();
    state = PresupuestoLoaded(updated);
    return true;
  }
}
