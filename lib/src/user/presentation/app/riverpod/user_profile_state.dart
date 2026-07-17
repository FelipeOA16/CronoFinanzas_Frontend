import '../../../../auth/domain/entities/user.dart';

abstract class UserProfileState {
  const UserProfileState();
}

class UserProfileIdle extends UserProfileState {
  const UserProfileIdle();
}

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
}

class UserProfileSuccess extends UserProfileState {
  final User user;
  final String? message;
  const UserProfileSuccess(this.user, {this.message});
}

class UserProfileError extends UserProfileState {
  final String message;
  const UserProfileError(this.message);
}

class PasswordChanged extends UserProfileState {
  const PasswordChanged();
}
