import '../../../../../core/errors/result.dart';
import '../entities/categoria.dart';
import '../repos/transaccion_repo.dart';

class GetCategorias {
  final TransaccionRepository _repository;
  GetCategorias(this._repository);

  Future<Result<List<Categoria>>> call() => _repository.getCategorias();
}
