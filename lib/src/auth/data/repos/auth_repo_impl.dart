import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/result.dart';
import '../../domain/entities/auth_tokens.dart';
import '../../domain/entities/sesion_activa.dart';
import '../../domain/entities/user.dart';
import '../../domain/repos/auth_repo.dart';
import '../datasources/auth_remote_data_src.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remoteDataSource;

  AuthRepositoryImpl(this._remoteDataSource);

  @override
  Future<Result<User>> register({
    required String email,
    required String password,
    String? nombre,
    String? apellido,
    String? nombreMostrar,
  }) async {
    try {
      final user = await _remoteDataSource.register(
        email: email,
        password: password,
        nombre: nombre,
        apellido: apellido,
        nombreMostrar: nombreMostrar,
      );
      return Result.ok(user);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Result.fail(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthTokens>> login({
    required String email,
    required String password,
  }) async {
    try {
      final tokens = await _remoteDataSource.login(
        email: email,
        password: password,
      );
      return Result.ok(tokens);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ValidationException catch (e) {
      return Result.fail(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<User>> getMe() async {
    try {
      final user = await _remoteDataSource.getMe();
      return Result.ok(user);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<AuthTokens>> refreshToken(String refreshToken) async {
    try {
      final tokens = await _remoteDataSource.refreshToken(refreshToken);
      return Result.ok(tokens);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on UnauthorizedException catch (e) {
      return Result.fail(UnauthorizedFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> logout(String refreshToken) async {
    try {
      await _remoteDataSource.logout(refreshToken);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> forgotPassword(String email) async {
    try {
      await _remoteDataSource.forgotPassword(email);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resetPassword(String token, String newPassword) async {
    try {
      await _remoteDataSource.resetPassword(token, newPassword);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } on ValidationException catch (e) {
      return Result.fail(ValidationFailure(e.message));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> verifyEmail(String token) async {
    try {
      await _remoteDataSource.verifyEmail(token);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> resendVerification() async {
    try {
      await _remoteDataSource.resendVerification();
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<List<SesionActiva>>> listSessions(int idUsuario) async {
    try {
      final sessions = await _remoteDataSource.listSessions(idUsuario);
      return Result.ok(sessions);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> revokeSession(int idUsuario, String sessionUuid) async {
    try {
      await _remoteDataSource.revokeSession(idUsuario, sessionUuid);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Result<void>> revokeAllSessions(int idUsuario) async {
    try {
      await _remoteDataSource.revokeAllSessions(idUsuario);
      return Result.ok(null);
    } on NetworkException catch (e) {
      return Result.fail(NetworkFailure(e.message));
    } on ServerException catch (e) {
      return Result.fail(ServerFailure(e.message, e.statusCode));
    } catch (e) {
      return Result.fail(UnknownFailure(e.toString()));
    }
  }
}
