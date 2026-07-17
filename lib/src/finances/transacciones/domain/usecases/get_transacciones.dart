import '../../../../../core/errors/result.dart';
import '../repos/transaccion_repo.dart';

class GetTransacciones {
  final TransaccionRepository _repository;
  GetTransacciones(this._repository);

  Future<Result<Map<String, dynamic>>> call({
    int? cuentaId,
    String? tipo,
    int? categoriaId,
    DateTime? fechaDesde,
    DateTime? fechaHasta,
    int limit = 50,
    int offset = 0,
  }) {
    return _repository.getTransacciones(
      cuentaId: cuentaId,
      tipo: tipo,
      categoriaId: categoriaId,
      fechaDesde: fechaDesde,
      fechaHasta: fechaHasta,
      limit: limit,
      offset: offset,
    );
  }
}
