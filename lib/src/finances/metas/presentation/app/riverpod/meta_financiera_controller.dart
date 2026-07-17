import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/di/providers.dart';
import '../../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../data/datasources/meta_financiera_remote_data_src.dart';
import '../../../data/repos/meta_financiera_repo_impl.dart';
import '../../../domain/entities/meta_financiera.dart';
import '../../../domain/entities/meta_financiera_resumen.dart';
import '../../../domain/repos/meta_financiera_repo.dart';
import 'meta_financiera_state.dart';

final metaFinancieraRemoteDataSourceProvider =
    Provider<MetaFinancieraRemoteDataSource>((ref) {
      return MetaFinancieraRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final metaFinancieraRepositoryProvider = Provider<MetaFinancieraRepository>((
  ref,
) {
  return MetaFinancieraRepositoryImpl(
    ref.watch(metaFinancieraRemoteDataSourceProvider),
  );
});

final metaFinancieraResumenProvider =
    FutureProvider.autoDispose<MetaFinancieraResumen>((ref) async {
      final repo = ref.watch(metaFinancieraRepositoryProvider);
      final result = await repo.getResumen();
      if (result.isOk) return result.data;
      throw Exception(result.failure.message);
    });

final metaFinancieraControllerProvider =
    StateNotifierProvider<MetaFinancieraController, MetaFinancieraState>((ref) {
      return MetaFinancieraController(
        ref,
        ref.watch(metaFinancieraRepositoryProvider),
      );
    });

class MetaFinancieraController extends StateNotifier<MetaFinancieraState> {
  final Ref _ref;
  final MetaFinancieraRepository _repo;

  MetaFinancieraController(this._ref, this._repo)
    : super(const MetaFinancieraInitial());

  List<MetaFinanciera> get _items {
    final s = state;
    if (s is MetaFinancieraLoaded) return s.items;
    if (s is MetaFinancieraError) return s.previousItems;
    return const [];
  }

  MetaFinancieraResumen? get _resumen {
    final s = state;
    if (s is MetaFinancieraLoaded) return s.resumen;
    if (s is MetaFinancieraError) return s.previousResumen;
    return null;
  }

  Future<void> load({
    String? estado = 'activa',
    String? prioridad,
    String? search,
  }) async {
    state = const MetaFinancieraLoading();
    final listResult = await _repo.getMetas(
      estado: estado,
      prioridad: prioridad,
      search: search,
    );
    final resumenResult = await _repo.getResumen();
    if (listResult.isFail) {
      state = MetaFinancieraError(
        listResult.failure.message,
        previousItems: _items,
        previousResumen: _resumen,
      );
      return;
    }
    state = MetaFinancieraLoaded(
      items: listResult.data,
      resumen: resumenResult.isOk ? resumenResult.data : null,
    );
  }

  Future<void> loadDetail(int id) async {
    final currentItems = _items;
    final currentResumen = _resumen;
    state = const MetaFinancieraLoading();
    final detailResult = await _repo.getMeta(id);
    final aportesResult = await _repo.getAportes(id);
    if (detailResult.isFail) {
      state = MetaFinancieraError(
        detailResult.failure.message,
        previousItems: currentItems,
        previousResumen: currentResumen,
      );
      return;
    }
    state = MetaFinancieraLoaded(
      items: currentItems,
      resumen: currentResumen,
      selected: detailResult.data,
      aportes: aportesResult.isOk ? aportesResult.data : const [],
    );
  }

  Future<bool> create(Map<String, dynamic> body) async {
    final result = await _repo.createMeta(body);
    if (result.isFail) return _error(result.failure.message);
    _ref.invalidate(metaFinancieraResumenProvider);
    await load();
    return true;
  }

  Future<bool> update(int id, Map<String, dynamic> body) async {
    final result = await _repo.updateMeta(id, body);
    if (result.isFail) return _error(result.failure.message);
    _ref.invalidate(metaFinancieraResumenProvider);
    await load();
    return true;
  }

  Future<bool> delete(int id) async {
    final result = await _repo.deleteMeta(id);
    if (result.isFail) return _error(result.failure.message);
    _ref.invalidate(metaFinancieraResumenProvider);
    await load();
    return true;
  }

  Future<bool> registrarAporte(int id, Map<String, dynamic> body) async {
    final result = await _repo.registrarAporte(id, body);
    if (result.isFail) return _error(result.failure.message);
    await _refreshFinancialState();
    await loadDetail(id);
    return true;
  }

  Future<bool> eliminarAporte(int id, int aporteId) async {
    final result = await _repo.eliminarAporte(id, aporteId);
    if (result.isFail) return _error(result.failure.message);
    await _refreshFinancialState();
    await loadDetail(id);
    return true;
  }

  bool _error(String message) {
    state = MetaFinancieraError(
      message,
      previousItems: _items,
      previousResumen: _resumen,
    );
    return false;
  }

  Future<void> _refreshFinancialState() async {
    await _ref.read(cuentaControllerProvider.notifier).loadCuentas();
    _ref.invalidate(patrimonioProvider);
    _ref.invalidate(metaFinancieraResumenProvider);
    try {
      await Future.wait([
        _ref.read(patrimonioProvider.future),
        _ref.read(metaFinancieraResumenProvider.future),
      ]);
    } catch (_) {
      // Las pantallas con watch mostraran el error normal si el refresh falla.
    }
  }
}
