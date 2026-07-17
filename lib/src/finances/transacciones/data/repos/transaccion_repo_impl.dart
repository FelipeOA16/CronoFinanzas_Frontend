import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/categoria.dart';
import '../../domain/entities/transaccion.dart';
import '../../domain/repos/transaccion_repo.dart';
import '../datasources/transaccion_remote_data_src.dart';
import '../models/transaccion_model.dart';

class TransaccionRepositoryImpl implements TransaccionRepository {
  final TransaccionRemoteDataSource _remote;

  TransaccionRepositoryImpl(this._remote);

  @override
  Future<Result<List<Categoria>>> getCategorias() async {
    try {
      final cats = await _remote.getCategorias();
      return Result.ok(cats);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Map<String, dynamic>>> getTransacciones({
    int? cuentaId,
    String? tipo,
    int? categoriaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final raw = await _remote.getTransacciones(
        cuentaId: cuentaId,
        tipo: tipo,
        categoriaId: categoriaId,
        fechaDesde: fechaDesde,
        fechaHasta: fechaHasta,
        limit: limit,
        offset: offset,
      );
      // Parse items list into Transaccion entities
      final itemsRaw = raw['items'] as List<dynamic>;
      final items = itemsRaw
          .map((e) => TransaccionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      return Result.ok({
        'items': items as List<Transaccion>,
        'total': raw['total'] as int,
        'limit': raw['limit'] as int,
        'offset': raw['offset'] as int,
      });
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaccion>> createTransaccion({
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
    try {
      final body = TransaccionModel(
        id: 0,
        usuarioId: 0,
        cuentaId: cuentaId,
        cuentaDestinoId: cuentaDestinoId,
        tipo: tipo,
        monto: monto,
        moneda: moneda,
        fecha: fecha,
        categoriaId: categoriaId,
        descripcion: descripcion,
        pagadoA: pagadoA,
        notas: notas,
        esRecurrente: esRecurrente,
      ).toJson();
      final tx = await _remote.createTransaccion(body);
      return Result.ok(tx);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Result.fail(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<Transaccion>> updateTransaccion({
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
    try {
      final body = <String, dynamic>{
        if (tipo != null) 'tipo': tipo,
        if (monto != null) 'monto': monto,
        if (moneda != null) 'moneda': moneda,
        if (fecha != null) 'fecha': fecha.toIso8601String().substring(0, 10),
        if (categoriaId != null) 'categoria_id': categoriaId,
        if (descripcion != null) 'descripcion': descripcion,
        if (pagadoA != null) 'pagado_a': pagadoA,
        if (notas != null) 'notas': notas,
        if (esRecurrente != null) 'es_recurrente': esRecurrente,
      };
      final tx = await _remote.updateTransaccion(id, body);
      return Result.ok(tx);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ValidationException catch (e) {
      return Result.fail(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteTransaccion(int id) async {
    try {
      await _remote.deleteTransaccion(id);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }
}
