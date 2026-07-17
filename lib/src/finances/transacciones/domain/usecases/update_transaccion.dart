import '../../../../../core/errors/result.dart';
import '../entities/transaccion.dart';
import '../repos/transaccion_repo.dart';

class UpdateTransaccion {
  final TransaccionRepository _repository;
  UpdateTransaccion(this._repository);

  Future<Result<Transaccion>> call({
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
  }) {
    return _repository.updateTransaccion(
      id: id,
      tipo: tipo,
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      categoriaId: categoriaId,
      descripcion: descripcion,
      pagadoA: pagadoA,
      notas: notas,
      esRecurrente: esRecurrente,
    );
  }
}
