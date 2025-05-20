part of 'login_bloc.dart';

@immutable
abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object> get props => [];
}

/// Evento que se emite cuando el usuario intenta iniciar sesión
class LoginSubmitted extends LoginEvent {
  final String email;
  final String password;

  const LoginSubmitted({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

/// Evento que se emite para intentar iniciar sesión con un token guardado
class LoginWithToken extends LoginEvent {}

/// Evento que se emite cuando el usuario cierra sesión
class LogoutRequested extends LoginEvent {}
