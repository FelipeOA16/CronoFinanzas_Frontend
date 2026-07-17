import '../../../../../core/errors/result.dart';
import '../repos/cuenta_repo.dart';

class DeleteCuenta {
  final CuentaRepository _repository;
  DeleteCuenta(this._repository);

  Future<Result<void>> call(int id) => _repository.deleteCuenta(id);
}
