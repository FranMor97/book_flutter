part of 'login_bloc.dart';

@immutable
abstract class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial - Aún no se ha intentado iniciar sesión
class LoginInitial extends LoginState {}

/// Estado de carga - Se está procesando el inicio de sesión
class LoginLoading extends LoginState {}

/// Estado de éxito - Inicio de sesión exitoso
class LoginSuccess extends LoginState {
  final UserDto user;

  const LoginSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

/// Estado de error - Inicio de sesión fallido
class LoginFailure extends LoginState {
  final String error;

  const LoginFailure({required this.error});

  @override
  List<Object?> get props => [error];
}
