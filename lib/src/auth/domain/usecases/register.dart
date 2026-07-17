import '../../../../core/errors/result.dart';
import '../entities/user.dart';
import '../repos/auth_repo.dart';

class Register {
  final AuthRepository _repository;

  Register(this._repository);

  Future<Result<User>> call({
    required String email,
    required String password,
    String? nombre,
    String? apellido,
    String? nombreMostrar,
  }) {
    return _repository.register(
      email: email,
      password: password,
      nombre: nombre,
      apellido: apellido,
      nombreMostrar: nombreMostrar,
    );
  }
}
