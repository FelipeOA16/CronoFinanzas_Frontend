import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/aporte_meta.dart';
import '../../domain/entities/meta_financiera.dart';
import '../../domain/entities/meta_financiera_resumen.dart';
import '../../domain/repos/meta_financiera_repo.dart';
import '../datasources/meta_financiera_remote_data_src.dart';

class MetaFinancieraRepositoryImpl implements MetaFinancieraRepository {
  final MetaFinancieraRemoteDataSource _remote;

  MetaFinancieraRepositoryImpl(this._remote);

  @override
  Future<Result<List<MetaFinanciera>>> getMetas({
    String? estado,
    String? prioridad,
    String? search,
  }) async {
    try {
      return Result.ok(
        await _remote.getMetas(
          estado: estado,
          prioridad: prioridad,
          search: search,
        ),
      );
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<MetaFinanciera>> getMeta(int id) async {
    try {
      return Result.ok(await _remote.getMeta(id));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<MetaFinanciera>> createMeta(Map<String, dynamic> body) async {
    try {
      return Result.ok(await _remote.createMeta(body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<MetaFinanciera>> updateMeta(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      return Result.ok(await _remote.updateMeta(id, body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<void>> deleteMeta(int id) async {
    try {
      await _remote.deleteMeta(id);
      return Result.ok(null);
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<MetaFinancieraResumen>> getResumen() async {
    try {
      return Result.ok(await _remote.getResumen());
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<List<AporteMeta>>> getAportes(int id) async {
    try {
      return Result.ok(await _remote.getAportes(id));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<AporteMeta>> registrarAporte(
    int id,
    Map<String, dynamic> body,
  ) async {
    try {
      return Result.ok(await _remote.registrarAporte(id, body));
    } catch (e) {
      return _fail(e);
    }
  }

  @override
  Future<Result<void>> eliminarAporte(int id, int aporteId) async {
    try {
      await _remote.eliminarAporte(id, aporteId);
      return Result.ok(null);
    } catch (e) {
      return _fail(e);
    }
  }

  Result<T> _fail<T>(Object e) {
    if (e is NetworkException) {
      return Result.fail(NetworkFailure(e.message));
    }
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
