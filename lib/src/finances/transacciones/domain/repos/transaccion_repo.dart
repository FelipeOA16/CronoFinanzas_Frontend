import '../../../../../core/errors/result.dart';
import '../entities/categoria.dart';
import '../entities/transaccion.dart';

abstract class TransaccionRepository {
  Future<Result<List<Categoria>>> getCategorias();

  Future<Result<Map<String, dynamic>>> getTransacciones({
    int? cuentaId,
    String? tipo,
    int? categoriaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limit,
    int offset,
  });

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
    bool esRecurrente,
  });

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
  });

  Future<Result<void>> deleteTransaccion(int id);
}
