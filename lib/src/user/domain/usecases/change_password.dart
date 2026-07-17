import '../../../../core/errors/result.dart';
import '../repos/user_repo.dart';

class ChangePassword {
  final UserRepository _repo;
  ChangePassword(this._repo);

  Future<Result<void>> call(int idUsuario, String newPassword) {
    return _repo.changePassword(idUsuario, newPassword);
  }
}
