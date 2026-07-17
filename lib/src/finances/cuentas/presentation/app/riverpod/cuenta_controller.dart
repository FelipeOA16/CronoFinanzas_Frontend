import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../app/di/providers.dart';
import '../../../domain/entities/cuenta.dart';
import '../../../domain/usecases/create_cuenta.dart';
import '../../../domain/usecases/delete_cuenta.dart';
import '../../../domain/usecases/get_cuentas.dart';
import '../../../domain/usecases/update_cuenta.dart';
import '../../../data/datasources/cuenta_remote_data_src.dart';
import '../../../data/repos/cuenta_repo_impl.dart';
import 'cuenta_state.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final cuentaRemoteDataSourceProvider = Provider<CuentaRemoteDataSource>((ref) {
  return CuentaRemoteDataSource(
    ref.watch(apiClientProvider),
    ref.watch(dioProvider),
  );
});

final cuentaRepositoryProvider = Provider((ref) {
  return CuentaRepositoryImpl(ref.watch(cuentaRemoteDataSourceProvider));
});

final getCuentasUseCaseProvider = Provider((ref) {
  return GetCuentas(ref.watch(cuentaRepositoryProvider));
});

final createCuentaUseCaseProvider = Provider((ref) {
  return CreateCuenta(ref.watch(cuentaRepositoryProvider));
});

final updateCuentaUseCaseProvider = Provider((ref) {
  return UpdateCuenta(ref.watch(cuentaRepositoryProvider));
});

final deleteCuentaUseCaseProvider = Provider((ref) {
  return DeleteCuenta(ref.watch(cuentaRepositoryProvider));
});

final cuentaControllerProvider =
    StateNotifierProvider<CuentaController, CuentaState>((ref) {
      return CuentaController(
        getCuentas: ref.watch(getCuentasUseCaseProvider),
        createCuenta: ref.watch(createCuentaUseCaseProvider),
        updateCuenta: ref.watch(updateCuentaUseCaseProvider),
        deleteCuenta: ref.watch(deleteCuentaUseCaseProvider),
      );
    });

// ─── Controller ──────────────────────────────────────────────────────────────

class CuentaController extends StateNotifier<CuentaState> {
  final GetCuentas _getCuentas;
  final CreateCuenta _createCuenta;
  final UpdateCuenta _updateCuenta;
  final DeleteCuenta _deleteCuenta;

  CuentaController({
    required GetCuentas getCuentas,
    required CreateCuenta createCuenta,
    required UpdateCuenta updateCuenta,
    required DeleteCuenta deleteCuenta,
  }) : _getCuentas = getCuentas,
       _createCuenta = createCuenta,
       _updateCuenta = updateCuenta,
       _deleteCuenta = deleteCuenta,
       super(const CuentaInitial());

  List<Cuenta> get _current =>
      state is CuentaLoaded ? (state as CuentaLoaded).cuentas : [];

  Future<void> loadCuentas() async {
    state = const CuentaLoading();
    final result = await _getCuentas();
    if (result.isFail) {
      state = CuentaError(result.failure.message);
      return;
    }
    state = CuentaLoaded(result.data);
  }

  Future<bool> createCuenta({
    required String nombre,
    required String tipo,
    required String moneda,
    required double saldoInicial,
    String? color,
    String? institucion,
    bool incluirEnTotal = true,
    String? notas,
  }) async {
    final result = await _createCuenta(
      nombre: nombre,
      tipo: tipo,
      moneda: moneda,
      saldoInicial: saldoInicial,
      color: color,
      institucion: institucion,
      incluirEnTotal: incluirEnTotal,
      notas: notas,
    );
    if (result.isFail) {
      state = CuentaError(result.failure.message, previousCuentas: _current);
      return false;
    }
    final updated = [..._current, result.data];
    state = CuentaOperationSuccess(updated, 'Cuenta creada');
    return true;
  }

  Future<bool> updateCuenta({
    required int id,
    String? nombre,
    String? tipo,
    String? moneda,
    String? color,
    String? institucion,
    bool? esActiva,
    bool? incluirEnTotal,
    String? notas,
  }) async {
    final result = await _updateCuenta(
      id: id,
      nombre: nombre,
      tipo: tipo,
      moneda: moneda,
      color: color,
      institucion: institucion,
      esActiva: esActiva,
      incluirEnTotal: incluirEnTotal,
      notas: notas,
    );
    if (result.isFail) {
      state = CuentaError(result.failure.message, previousCuentas: _current);
      return false;
    }
    final updated = _current.map((c) => c.id == id ? result.data : c).toList();
    state = CuentaOperationSuccess(updated, 'Cuenta actualizada');
    return true;
  }

  Future<bool> deleteCuenta(int id) async {
    final result = await _deleteCuenta(id);
    if (result.isFail) {
      state = CuentaError(result.failure.message, previousCuentas: _current);
      return false;
    }
    final updated = _current.where((c) => c.id != id).toList();
    state = CuentaOperationSuccess(updated, 'Cuenta eliminada');
    return true;
  }
}
