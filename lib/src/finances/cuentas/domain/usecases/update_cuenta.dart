import '../../../../../core/errors/result.dart';
import '../entities/cuenta.dart';
import '../repos/cuenta_repo.dart';

class UpdateCuenta {
  final CuentaRepository _repository;
  UpdateCuenta(this._repository);

  Future<Result<Cuenta>> call({
    required int id,
    String? nombre,
    String? tipo,
    String? moneda,
    String? color,
    String? icono,
    String? institucion,
    bool? esActiva,
    bool? incluirEnTotal,
    String? notas,
  }) => _repository.updateCuenta(
    id: id,
    nombre: nombre,
    tipo: tipo,
    moneda: moneda,
    color: color,
    icono: icono,
    institucion: institucion,
    esActiva: esActiva,
    incluirEnTotal: incluirEnTotal,
    notas: notas,
  );
}
