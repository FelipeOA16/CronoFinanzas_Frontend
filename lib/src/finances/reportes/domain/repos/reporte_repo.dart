import '../../../../../core/errors/result.dart';
import '../entities/reporte.dart';

abstract class ReporteRepository {
  Future<Result<ReporteData>> getReporte({int? mes, int? anio, int mesesFlujo});
}
