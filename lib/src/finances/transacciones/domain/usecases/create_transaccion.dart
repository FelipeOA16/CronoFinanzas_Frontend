import '../../../../../core/errors/result.dart';
import '../entities/transaccion.dart';
import '../repos/transaccion_repo.dart';

class CreateTransaccion {
  final TransaccionRepository _repository;
  CreateTransaccion(this._repository);

  Future<Result<Transaccion>> call({
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
    bool esRecurrente = false,
  }) {
    return _repository.createTransaccion(
      cuentaId: cuentaId,
      tipo: tipo,
      monto: monto,
      moneda: moneda,
      fecha: fecha,
      categoriaId: categoriaId,
      cuentaDestinoId: cuentaDestinoId,
      descripcion: descripcion,
      pagadoA: pagadoA,
      notas: notas,
      esRecurrente: esRecurrente,
    );
  }
}
