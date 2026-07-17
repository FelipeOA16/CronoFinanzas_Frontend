import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/user.dart';

abstract class UserRepository {
  Future<Result<User>> getUser(int idUsuario);

  Future<Result<User>> updatePerfil(
    int idUsuario, {
    String? nombre,
    String? apellido,
    String? nombreMostrar,
    String? telefono,
    String? pais,
    String? zonaHoraria,
    String? idioma,
    String? fotoUrl,
  });

  Future<Result<void>> changePassword(int idUsuario, String newPassword);

  Future<Result<void>> deleteAccount(int idUsuario);
}
