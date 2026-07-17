import '../../../../core/errors/result.dart';
import '../entities/auth_tokens.dart';
import '../repos/auth_repo.dart';

class RefreshToken {
  final AuthRepository _repository;

  RefreshToken(this._repository);

  Future<Result<AuthTokens>> call(String refreshToken) {
    return _repository.refreshToken(refreshToken);
  }
}
