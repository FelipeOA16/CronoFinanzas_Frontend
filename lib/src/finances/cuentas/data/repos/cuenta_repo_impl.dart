import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/cuenta.dart';
import '../../domain/repos/cuenta_repo.dart';
import '../datasources/cuenta_remote_data_src.dart';

class CuentaRepositoryImpl implements CuentaRepository {
  final CuentaRemoteDataSource _remote;

  CuentaRepositoryImpl(this._remote);

  @override
  Future<Result<List<Cuenta>>> getCuentas() async {
    try {
      final cuentas = await _remote.getCuentas();
      return Result.ok(cuentas);
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
  Future<Result<Cuenta>> createCuenta({
    required String nombre,
    required String tipo,
    required String moneda,
    required double saldoInicial,
    String? color,
    String? icono,
    String? institucion,
    bool esActiva = true,
    bool incluirEnTotal = true,
    String? notas,
  }) async {
    try {
      final body = <String, dynamic>{
        'nombre': nombre,
        'tipo': tipo,
        'moneda': moneda,
        'saldo_inicial': saldoInicial,
        if (color != null) 'color': color,
        if (icono != null) 'icono': icono,
        if (institucion != null) 'institucion': institucion,
        'es_activa': esActiva,
        'incluir_en_total': incluirEnTotal,
        if (notas != null) 'notas': notas,
      };
      final cuenta = await _remote.createCuenta(body);
      return Result.ok(cuenta);
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
  Future<Result<Cuenta>> updateCuenta({
    required int id,
    String? nombre,
    String? tipo,
    String? moneda,
    String? color,
    String? icono,
    String? institucion,
    bool? esActiva,
    bool? incluirEnTotal,
    String? notas,
  }) async {
    try {
      final body = <String, dynamic>{
        if (nombre != null) 'nombre': nombre,
        if (tipo != null) 'tipo': tipo,
        if (moneda != null) 'moneda': moneda,
        if (color != null) 'color': color,
        if (icono != null) 'icono': icono,
        if (institucion != null) 'institucion': institucion,
        if (esActiva != null) 'es_activa': esActiva,
        if (incluirEnTotal != null) 'incluir_en_total': incluirEnTotal,
        if (notas != null) 'notas': notas,
      };
      final cuenta = await _remote.updateCuenta(id, body);
      return Result.ok(cuenta);
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
  Future<Result<void>> deleteCuenta(int id) async {
    try {
      await _remote.deleteCuenta(id);
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
