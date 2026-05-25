import '../../domain/entities/user_entity.dart';

enum LoginStatus { initial, loading, success, error }

class LoginState {
  final LoginStatus status;
  final String? errorMessage;
  final UserEntity? user;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.user,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    UserEntity? user,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage ?? this.errorMessage,
      user: user ?? this.user,
    );
  }
}
