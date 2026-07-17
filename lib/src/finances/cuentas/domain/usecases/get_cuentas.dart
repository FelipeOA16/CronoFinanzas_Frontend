import '../../../../../core/errors/result.dart';
import '../entities/cuenta.dart';
import '../repos/cuenta_repo.dart';

class GetCuentas {
  final CuentaRepository _repository;
  GetCuentas(this._repository);

  Future<Result<List<Cuenta>>> call() => _repository.getCuentas();
}
