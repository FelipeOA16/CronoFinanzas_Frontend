import '../../../../../core/errors/result.dart';
import '../entities/presupuesto.dart';

abstract class PresupuestoRepository {
  Future<Result<List<Presupuesto>>> getPresupuestos({int? mes, int? anio});
  Future<Result<Presupuesto>> createPresupuesto({
    int? categoriaId,
    required int mes,
    required int anio,
    required double montoLimite,
    required String moneda,
  });
  Future<Result<Presupuesto>> updatePresupuesto({
    required int id,
    double? montoLimite,
    String? moneda,
  });
  Future<Result<void>> deletePresupuesto(int id);
}
