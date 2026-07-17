import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/presupuesto.dart';
import '../../domain/repos/presupuesto_repo.dart';
import '../datasources/presupuesto_remote_data_src.dart';

class PresupuestoRepositoryImpl implements PresupuestoRepository {
  final PresupuestoRemoteDataSource _remote;

  PresupuestoRepositoryImpl(this._remote);

  @override
  Future<Result<List<Presupuesto>>> getPresupuestos({
    int? mes,
    int? anio,
  }) async {
    try {
      final list = await _remote.getPresupuestos(mes: mes, anio: anio);
      return Result.ok(list);
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
  Future<Result<Presupuesto>> createPresupuesto({
    int? categoriaId,
    required int mes,
    required int anio,
    required double montoLimite,
    required String moneda,
  }) async {
    try {
      final body = <String, dynamic>{
        if (categoriaId != null) 'categoria_id': categoriaId,
        'mes': mes,
        'anio': anio,
        'monto_limite': montoLimite,
        'moneda': moneda,
      };
      final result = await _remote.createPresupuesto(body);
      return Result.ok(result);
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
  Future<Result<Presupuesto>> updatePresupuesto({
    required int id,
    double? montoLimite,
    String? moneda,
  }) async {
    try {
      final body = <String, dynamic>{
        if (montoLimite != null) 'monto_limite': montoLimite,
        if (moneda != null) 'moneda': moneda,
      };
      final result = await _remote.updatePresupuesto(id, body);
      return Result.ok(result);
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
  Future<Result<void>> deletePresupuesto(int id) async {
    try {
      await _remote.deletePresupuesto(id);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }
}
