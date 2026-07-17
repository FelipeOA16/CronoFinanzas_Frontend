import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../../auth/domain/entities/user.dart';
import '../../domain/repos/user_repo.dart';
import '../datasources/user_remote_data_src.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource _remote;

  UserRepositoryImpl(this._remote);

  @override
  Future<Result<User>> getUser(int idUsuario) async {
    // getUser se delega a getMe vía auth; si se necesita, se extiende aquí
    return Result.fail(const ServerFailure('No implementado directamente'));
  }

  @override
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
  }) async {
    try {
      final user = await _remote.updatePerfil(
        idUsuario,
        nombre: nombre,
        apellido: apellido,
        nombreMostrar: nombreMostrar,
        telefono: telefono,
        pais: pais,
        zonaHoraria: zonaHoraria,
        idioma: idioma,
        fotoUrl: fotoUrl,
      );
      return Result.ok(user);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> changePassword(int idUsuario, String newPassword) async {
    try {
      await _remote.changePassword(idUsuario, newPassword);
      return Result.ok(null);
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> deleteAccount(int idUsuario) async {
    try {
      await _remote.deleteAccount(idUsuario);
      return Result.ok(null);
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }
}
