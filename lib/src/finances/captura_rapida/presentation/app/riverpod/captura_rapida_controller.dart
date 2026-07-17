import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../app/di/providers.dart';
import '../../../../cuentas/presentation/app/riverpod/cuenta_controller.dart';
import '../../../../deudas_prestamos/presentation/app/riverpod/deuda_prestamo_controller.dart';
import '../../../../reportes/presentation/app/riverpod/reporte_controller.dart';
import '../../../../transacciones/presentation/app/riverpod/transaccion_controller.dart';
import '../../../data/datasources/captura_rapida_remote_data_src.dart';
import '../../../data/repos/captura_rapida_repo_impl.dart';
import '../../../domain/entities/captura_rapida.dart';
import '../../../domain/entities/captura_rapida_resumen.dart';
import '../../../domain/repos/captura_rapida_repo.dart';
import 'captura_rapida_state.dart';

final capturaRapidaRemoteDataSourceProvider =
    Provider<CapturaRapidaRemoteDataSource>((ref) {
      return CapturaRapidaRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final capturaRapidaRepositoryProvider = Provider<CapturaRapidaRepository>((
  ref,
) {
  return CapturaRapidaRepositoryImpl(
    ref.watch(capturaRapidaRemoteDataSourceProvider),
  );
});

final capturaRapidaResumenProvider =
    FutureProvider.autoDispose<CapturaRapidaResumen>((ref) async {
      final result = await ref
          .watch(capturaRapidaRepositoryProvider)
          .getResumen();
      if (result.isOk) return result.data;
      throw Exception(result.failure.message);
    });

final capturaRapidaControllerProvider =
    StateNotifierProvider<CapturaRapidaController, CapturaRapidaState>((ref) {
      return CapturaRapidaController(
        ref,
        ref.watch(capturaRapidaRepositoryProvider),
      );
    });

class CapturaRapidaController extends StateNotifier<CapturaRapidaState> {
  final Ref _ref;
  final CapturaRapidaRepository _repo;
  int _temporaryId = -1;

  CapturaRapidaController(this._ref, this._repo)
    : super(const CapturaRapidaState());

  Future<void> load({
    String estado = 'pendiente',
    String? tipo,
    bool force = false,
  }) async {
    if (!force && state.isLoaded(estado)) return;
    if (state.isLoading(estado)) return;

    state = estado == 'completada'
        ? state.copyWith(loadingCompletadas: true, clearError: true)
        : state.copyWith(loadingPendientes: true, clearError: true);
    final result = await _repo.getCapturas(estado: estado, tipo: tipo);
    if (result.isFail) {
      state = estado == 'completada'
          ? state.copyWith(
              loadingCompletadas: false,
              errorMessage: result.failure.message,
            )
          : state.copyWith(
              loadingPendientes: false,
              errorMessage: result.failure.message,
            );
      return;
    }
    state = estado == 'completada'
        ? state.copyWith(
            completadas: result.data,
            completadasLoaded: true,
            loadingCompletadas: false,
            clearError: true,
          )
        : state.copyWith(
            pendientes: result.data,
            pendientesLoaded: true,
            loadingPendientes: false,
            clearError: true,
          );
  }

  Future<bool> createOptimistic(Map<String, dynamic> body) async {
    final temporaryId = _temporaryId--;
    final temporary = CapturaRapida(
      id: temporaryId,
      usuarioId: 0,
      tipo: body['tipo'] as String,
      monto: (body['monto'] as num).toDouble(),
      moneda: body['moneda'] as String? ?? 'PEN',
      cuentaId: body['cuenta_id'] as int?,
      cuentaDestinoId: body['cuenta_destino_id'] as int?,
      notaRapida: body['nota_rapida'] as String?,
      estado: 'pendiente',
      createdAt: DateTime.now(),
    );
    state = state.copyWith(
      pendientes: [temporary, ...state.pendientes],
      itemStatus: {...state.itemStatus, temporaryId: CapturaItemStatus.saving},
      clearError: true,
    );

    final result = await _repo.create(body);
    if (result.isFail) {
      final statuses = {...state.itemStatus}..remove(temporaryId);
      state = state.copyWith(
        pendientes: state.pendientes
            .where((item) => item.id != temporaryId)
            .toList(),
        itemStatus: statuses,
        errorMessage: result.failure.message,
      );
      return false;
    }

    final statuses = {...state.itemStatus}..remove(temporaryId);
    state = state.copyWith(
      pendientes: state.pendientes
          .map((item) => item.id == temporaryId ? result.data : item)
          .toList(),
      itemStatus: statuses,
      clearError: true,
    );
    _ref.invalidate(capturaRapidaResumenProvider);
    return true;
  }

  Future<bool> completar(int id, Map<String, dynamic> body) async {
    if (_isBusy(id)) return false;
    _setItemStatus(id, CapturaItemStatus.completing);
    final result = await _repo.completar(id, body);
    if (result.isFail) {
      _setItemError(id, result.failure.message);
      return false;
    }

    final statuses = {...state.itemStatus}..remove(id);
    state = state.copyWith(
      pendientes: state.pendientes.where((item) => item.id != id).toList(),
      completadas: [result.data, ...state.completadas],
      itemStatus: statuses,
      clearError: true,
    );
    _ref.invalidate(capturaRapidaResumenProvider);
    unawaited(_refreshFinancialState());
    return true;
  }

  Future<bool> descartar(int id) async {
    if (_isBusy(id)) return false;
    _setItemStatus(id, CapturaItemStatus.deleting);
    final result = await _repo.descartar(id);
    if (result.isFail) {
      _setItemError(id, result.failure.message);
      return false;
    }
    final statuses = {...state.itemStatus}..remove(id);
    state = state.copyWith(
      pendientes: state.pendientes.where((item) => item.id != id).toList(),
      itemStatus: statuses,
      clearError: true,
    );
    _ref.invalidate(capturaRapidaResumenProvider);
    return true;
  }

  bool _isBusy(int id) {
    final status = state.statusFor(id);
    return status == CapturaItemStatus.saving ||
        status == CapturaItemStatus.completing ||
        status == CapturaItemStatus.deleting;
  }

  void _setItemStatus(int id, CapturaItemStatus status) {
    state = state.copyWith(
      itemStatus: {...state.itemStatus, id: status},
      clearError: true,
    );
  }

  void _setItemError(int id, String message) {
    state = state.copyWith(
      itemStatus: {...state.itemStatus, id: CapturaItemStatus.error},
      errorMessage: message,
    );
  }

  Future<void> _refreshFinancialState() async {
    _ref.invalidate(patrimonioProvider);
    _ref.invalidate(patrimonioNetoEstimadoProvider);
    final now = DateTime.now();
    try {
      await Future.wait([
        _ref.read(cuentaControllerProvider.notifier).loadCuentas(),
        _ref.read(transaccionControllerProvider.notifier).load(limit: 200),
        _ref
            .read(reporteControllerProvider.notifier)
            .loadReporte(mes: now.month, anio: now.year),
      ]);
    } catch (_) {
      // La transaccion ya fue creada; cada pantalla conserva su manejo de error.
    }
  }
}
