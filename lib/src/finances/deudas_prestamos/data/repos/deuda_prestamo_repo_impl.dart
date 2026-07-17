import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/deuda_prestamo.dart';
import '../../domain/entities/deuda_prestamo_resumen.dart';
import '../../domain/entities/pago_deuda_prestamo.dart';
import '../../domain/repos/deuda_prestamo_repo.dart';
import '../datasources/deuda_prestamo_remote_data_src.dart';

class DeudaPrestamoRepositoryImpl implements DeudaPrestamoRepository {
  final DeudaPrestamoRemoteDataSource _remote;

  DeudaPrestamoRepositoryImpl(this._remote);

  @override
  Future<Result<List<DeudaPrestamo>>> getDeudasPrestamos({
    String? tipo,
    String? estado,
    String? prioridad,
    DateTime? vencenHasta,
    String? search,
  }) async {
    try {
      final data = await _remote.getDeudasPrestamos(
        tipo: tipo,
        estado: estado,
        prioridad: prioridad,
        vencenHasta: vencenHasta,
        search: search,
      );
      return Result.ok(data);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<DeudaPrestamo>> getDeudaPrestamo(int id) async {
    try {
      return Result.ok(await _remote.getDeudaPrestamo(id));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<DeudaPrestamo>> createDeudaPrestamo(
    Map<String, dynamic> body,
  ) async {
    try {
      return Result.ok(await _remote.createDeudaPrestamo(body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<DeudaPrestamo>> updateDeudaPrestamo(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      return Result.ok(await _remote.updateDeudaPrestamo(id, body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<void>> deleteDeudaPrestamo(int id) async {
    try {
      await _remote.deleteDeudaPrestamo(id);
      return Result.ok(null);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<DeudaPrestamoResumen>> getResumen() async {
    try {
      return Result.ok(await _remote.getResumen());
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<List<PagoDeudaPrestamo>>> getPagos(int id) async {
    try {
      return Result.ok(await _remote.getPagos(id));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<PagoDeudaPrestamo>> registrarPago(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      return Result.ok(await _remote.registrarPago(id, body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<void>> eliminarPago(int id, int pagoId) async {
    try {
      await _remote.eliminarPago(id, pagoId);
      return Result.ok(null);
    } catch (e) {
      return _fail(e);
    }
  }

  Result<T> _fail<T>(Object e) {
    if (e is NetworkException) return Result.fail(NetworkFailure(e.message));
    if (e is UnauthorizedException)
      return Result.fail(UnauthorizedFailure(e.message));
    if (e is ValidationException)
      return Result.fail(ValidationFailure(e.message));
    if (e is ServerException)
      return Result.fail(ServerFailure(e.message, e.statusCode));
    return Result.fail(UnknownFailure(e.toString()));
  }
}
