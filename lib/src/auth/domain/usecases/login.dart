import '../../../../core/errors/result.dart';
import '../entities/auth_tokens.dart';
import '../repos/auth_repo.dart';

class Login {
  final AuthRepository _repository;

  Login(this._repository);

  Future<Result<AuthTokens>> call({
    required String email,
    required String password,
  }) {
    return _repository.login(email: email, password: password);
  }
}
