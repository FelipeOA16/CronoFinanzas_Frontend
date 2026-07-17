import '../../../../core/errors/result.dart';
import '../entities/user.dart';
import '../repos/auth_repo.dart';

class GetMe {
  final AuthRepository _repository;

  GetMe(this._repository);

  Future<Result<User>> call() {
    return _repository.getMe();
  }
}
