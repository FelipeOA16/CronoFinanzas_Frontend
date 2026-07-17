import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../../core/network/api_client.dart';
import '../../../../../app/di/providers.dart';
import '../../../domain/entities/categoria.dart';
import '../../../domain/entities/transaccion.dart';
import '../../../domain/usecases/create_transaccion.dart';
import '../../../domain/usecases/delete_transaccion.dart';
import '../../../domain/usecases/get_categorias.dart';
import '../../../domain/usecases/get_transacciones.dart';
import '../../../domain/usecases/update_transaccion.dart';
import '../../../data/datasources/transaccion_remote_data_src.dart';
import '../../../data/repos/transaccion_repo_impl.dart';
import 'transaccion_state.dart';

// ─── DI providers ────────────────────────────────────────────────────────────

final transaccionRemoteDataSourceProvider =
    Provider<TransaccionRemoteDataSource>((ref) {
      return TransaccionRemoteDataSource(
        ref.watch(apiClientProvider),
        ref.watch(dioProvider),
      );
    });

final transaccionRepositoryProvider = Provider((ref) {
  return TransaccionRepositoryImpl(
    ref.watch(transaccionRemoteDataSourceProvider),
  );
});

final getCategoriasUseCaseProvider = Provider((ref) {
  return GetCategorias(ref.watch(transaccionRepositoryProvider));
});

final getTransaccionesUseCaseProvider = Provider((ref) {
  return GetTransacciones(ref.watch(transaccionRepositoryProvider));
});

final createTransaccionUseCaseProvider = Provider((ref) {
  return CreateTransaccion(ref.watch(transaccionRepositoryProvider));
});

final updateTransaccionUseCaseProvider = Provider((ref) {
  return UpdateTransaccion(ref.watch(transaccionRepositoryProvider));
});

final deleteTransaccionUseCaseProvider = Provider((ref) {
  return DeleteTransaccion(ref.watch(transaccionRepositoryProvider));
});

final transaccionControllerProvider =
    StateNotifierProvider<TransaccionController, TransaccionState>((ref) {
      return TransaccionController(
        getCategorias: ref.watch(getCategoriasUseCaseProvider),
        getTransacciones: ref.watch(getTransaccionesUseCaseProvider),
        createTransaccion: ref.watch(createTransaccionUseCaseProvider),
        updateTransaccion: ref.watch(updateTransaccionUseCaseProvider),
        deleteTransaccion: ref.watch(deleteTransaccionUseCaseProvider),
      );
    });

// ─── Controller ──────────────────────────────────────────────────────────────

class TransaccionController extends StateNotifier<TransaccionState> {
  final GetCategorias _getCategorias;
  final GetTransacciones _getTransacciones;
  final CreateTransaccion _createTransaccion;
  final UpdateTransaccion _updateTransaccion;
  final DeleteTransaccion _deleteTransaccion;

  TransaccionController({
    required GetCategorias getCategorias,
    required GetTransacciones getTransacciones,
    required CreateTransaccion createTransaccion,
    required UpdateTransaccion updateTransaccion,
    required DeleteTransaccion deleteTransaccion,
  }) : _getCategorias = getCategorias,
       _getTransacciones = getTransacciones,
       _createTransaccion = createTransaccion,
       _updateTransaccion = updateTransaccion,
       _deleteTransaccion = deleteTransaccion,
       super(const TransaccionInitial());

  List<Transaccion> get _currentItems {
    final s = state;
    if (s is TransaccionLoaded) return s.items;
    if (s is TransaccionOperationSuccess) return s.items;
    if (s is TransaccionError) return s.previousItems;
    return [];
  }

  List<Categoria> get _currentCategorias {
    final s = state;
    if (s is TransaccionLoaded) return s.categorias;
    if (s is TransaccionOperationSuccess) return s.categorias;
    if (s is TransaccionError) return s.previousCategorias;
    return [];
  }

  Future<void> load({
    int? cuentaId,
    String? tipo,
    int? categoriaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limit = 50,
    int offset = 0,
  }) async {
    state = const TransaccionLoading();

    // Load categorias and transacciones in sequence
    final catsResult = await _getCategorias();
    final cats = catsResult.isFail
        ? <Categoria>[]
        : catsResult.data as List<Categoria>;

    final txResult = await _getTransacciones(
      cuentaId: cuentaId,
      tipo: tipo,
      categoriaId: categoriaId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      limit: limit,
      offset: offset,
    );

    if (txResult.isFail) {
      state = TransaccionError(
        txResult.failure.message,
        previousCategorias: cats,
      );
    } else {
      final raw = txResult.data as Map<String, dynamic>;
      state = TransaccionLoaded(
        items: List<Transaccion>.from(raw['items'] as List),
        total: raw['total'] as int,
        categorias: cats,
      );
    }
  }

  Future<bool> createTransaccion({
    required int cuentaId,
    required String tipo,
    required double monto,
    required String moneda,
    required DateTime fecha,
    int? categoriaId,
    int? cuentaDestinoId,
    String? descripcion,
    String? pagadoA,
    String? notas,
    bool esRecurrente = false,
  }) async {
    state = const TransaccionLoading();
    final result = await _createTransaccion(
      cuentaId: cuentaId,
      tipo: tipo,
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      categoriaId: categoriaId,
      cuentaDestinoId: cuentaDestinoId,
      descripcion: descripcion,
      pagadoA: pagadoA,
      notas: notas,
      esRecurrente: esRecurrente,
    );
    if (result.isFail) {
      state = TransaccionError(
        result.failure.message,
        previousItems: _currentItems,
        previousCategorias: _currentCategorias,
      );
      return false;
    }
    final updated = [result.data as Transaccion, ..._currentItems];
    state = TransaccionOperationSuccess(
      items: updated,
      total: updated.length,
      categorias: _currentCategorias,
      message: 'Transacción creada',
    );
    return true;
  }

  Future<bool> updateTransaccion({
    required int id,
    String? tipo,
    double? monto,
    String? moneda,
    DateTime? fecha,
    int? categoriaId,
    String? descripcion,
    String? pagadoA,
    String? notas,
    bool? esRecurrente,
  }) async {
    state = const TransaccionLoading();
    final result = await _updateTransaccion(
      id: id,
      tipo: tipo,
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      categoriaId: categoriaId,
      descripcion: descripcion,
      pagadoA: pagadoA,
      notas: notas,
      esRecurrente: esRecurrente,
    );
    if (result.isFail) {
      state = TransaccionError(
        result.failure.message,
        previousItems: _currentItems,
        previousCategorias: _currentCategorias,
      );
      return false;
    }
    final updated = _currentItems
        .map((t) => t.id == id ? result.data as Transaccion : t)
        .toList();
    state = TransaccionOperationSuccess(
      items: updated,
      total: updated.length,
      categorias: _currentCategorias,
      message: 'Transacción actualizada',
    );
    return true;
  }

  Future<bool> deleteTransaccion(int id) async {
    state = const TransaccionLoading();
    final result = await _deleteTransaccion(id);
    if (result.isFail) {
      state = TransaccionError(
        result.failure.message,
        previousItems: _currentItems,
        previousCategorias: _currentCategorias,
      );
      return false;
    }
    final updated = _currentItems.where((t) => t.id != id).toList();
    state = TransaccionOperationSuccess(
      items: updated,
      total: updated.length,
      categorias: _currentCategorias,
      message: 'Transacción eliminada',
    );
    return true;
  }
}
