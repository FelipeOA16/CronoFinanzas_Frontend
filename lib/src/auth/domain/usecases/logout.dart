import '../../../../core/errors/result.dart';
import '../repos/auth_repo.dart';

class Logout {
  final AuthRepository _repository;

  Logout(this._repository);

  Future<Result<void>> call(String refreshToken) {
    return _repository.logout(refreshToken);
  }
}
