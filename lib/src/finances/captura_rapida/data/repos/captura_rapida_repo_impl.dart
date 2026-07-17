import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/captura_rapida.dart';
import '../../domain/entities/captura_rapida_resumen.dart';
import '../../domain/repos/captura_rapida_repo.dart';
import '../datasources/captura_rapida_remote_data_src.dart';

class CapturaRapidaRepositoryImpl implements CapturaRapidaRepository {
  final CapturaRapidaRemoteDataSource _remote;

  CapturaRapidaRepositoryImpl(this._remote);

  @override
  Future<Result<List<CapturaRapida>>> getCapturas({
    String? estado,
    String? tipo,
  }) async => _guard(() => _remote.getCapturas(estado: estado, tipo: tipo));

  @override
  Future<Result<CapturaRapida>> getCaptura(int id) =>
      _guard(() => _remote.getCaptura(id));

  @override
  Future<Result<CapturaRapida>> create(Map<String, dynamic> body) =>
      _guard(() => _remote.create(body));

  @override
  Future<Result<CapturaRapida>> update(int id, Map<String, dynamic> body) =>
      _guard(() => _remote.update(id, body));

  @override
  Future<Result<CapturaRapida>> completar(int id, Map<String, dynamic> body) =>
      _guard(() => _remote.completar(id, body));

  @override
  Future<Result<void>> descartar(int id) async {
    try {
      await _remote.descartar(id);
      return Result.ok(null);
    } catch (e) {
      return _failure(e);
    }
  }

  @override
  Future<Result<CapturaRapidaResumen>> getResumen() =>
      _guard(_remote.getResumen);

  Future<Result<T>> _guard<T>(Future<T> Function() action) async {
    try {
      return Result.ok(await action());
    } catch (e) {
      return _failure(e);
    }
  }

  Result<T> _failure<T>(Object e) {
    if (e is NetworkException) return Result.fail(NetworkFailure(e.message));
    if (e is UnauthorizedException) {
      return Result.fail(UnauthorizedFailure(e.message));
    }
    if (e is ValidationException) {
      return Result.fail(ValidationFailure(e.message));
    }
    if (e is ServerException) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    }
    return Result.fail(UnknownFailure(e.toString()));
  }
}
