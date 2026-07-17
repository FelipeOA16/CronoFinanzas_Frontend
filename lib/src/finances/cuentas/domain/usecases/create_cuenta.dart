import '../../../../../core/errors/result.dart';
import '../entities/cuenta.dart';
import '../repos/cuenta_repo.dart';

class CreateCuenta {
  final CuentaRepository _repository;
  CreateCuenta(this._repository);

  Future<Result<Cuenta>> call({
    required String nombre,
    required String tipo,
    required String moneda,
    required double saldoInicial,
    String? color,
    String? icono,
    String? institucion,
    bool esActiva = true,
    bool incluirEnTotal = true,
    String? notas,
  }) => _repository.createCuenta(
    nombre: nombre,
    tipo: tipo,
    moneda: moneda,
    saldoInicial: saldoInicial,
    color: color,
    icono: icono,
    institucion: institucion,
    esActiva: esActiva,
    incluirEnTotal: incluirEnTotal,
    notas: notas,
  );
}
