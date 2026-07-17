import '../../../../../core/errors/exceptions.dart';
import '../../../../../core/errors/failures.dart';
import '../../../../../core/errors/result.dart';
import '../../domain/entities/reporte.dart';
import '../../domain/repos/reporte_repo.dart';
import '../datasources/reporte_remote_data_src.dart';

class ReporteRepositoryImpl implements ReporteRepository {
  final ReporteRemoteDataSource _remote;

  ReporteRepositoryImpl(this._remote);

  @override
  Future<Result<ReporteData>> getReporte({
    int? mes,
    int? anio,
    int mesesFlujo = 6,
  }) async {
    try {
      final model = await _remote.getReporte(
        mes: mes,
        anio: anio,
        mesesFlujo: mesesFlujo,
      );
      return Result.ok(model);
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
