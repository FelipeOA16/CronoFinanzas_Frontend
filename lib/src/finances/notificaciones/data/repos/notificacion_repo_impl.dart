import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/notificacion.dart';
import '../../domain/repos/notificacion_repo.dart';
import '../datasources/notificacion_remote_data_src.dart';

class NotificacionRepositoryImpl implements NotificacionRepository {
  final NotificacionRemoteDataSource _remote;

  NotificacionRepositoryImpl(this._remote);

  @override
  Future<Result<List<Notificacion>>> getAlertas() async {
    try {
      final models = await _remote.getAlertas();
      return Result.ok(models);
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
