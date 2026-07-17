import '../../../../../core/errors/result.dart';
import '../repos/transaccion_repo.dart';

class DeleteTransaccion {
  final TransaccionRepository _repository;
  DeleteTransaccion(this._repository);

  Future<Result<void>> call(int id) => _repository.deleteTransaccion(id);
}
