import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/injection.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import '../../../models/dtos/user_dto.dart';
import '../../repositories/user_repository.dart';

part 'login_event.dart';
part 'login_state.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  final IUserRepository userRepository;

  LoginBloc({required this.userRepository}) : super(LoginInitial()) {
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoginWithToken>(_onLoginWithToken);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      final loginDto = UserDto.forLogin(
        email: event.email,
        password: event.password,
      );

      final user = await userRepository.login(loginDto);

      try {
        final socketService = getIt<SocketService>();
        print('Login: Reinicializando socket después del login...');

        // Esperar un poco para que el token se guarde correctamente
        await Future.delayed(const Duration(milliseconds: 300));

        final socketUrl = getIt<String>(instanceName: 'socketUrl');
        await socketService.initSocket(socketUrl);

        print('Login: Socket reinicializado exitosamente');
      } catch (e) {
        print('Login: Error al reinicializar socket: $e');
        // No fallar el login por problemas de socket
      }
      if (Platform.isWindows && user.role == 'client') {
        emit(const LoginFailure(
            error: 'Los clientes no pueden iniciar sesión desde Windows.'));
        return;
      }

      if (Platform.isAndroid && user.role == 'admin') {
        emit(const LoginFailure(
            error:
                'Los administradores no pueden iniciar sesión desde Android.'));
        return;
      }

      emit(LoginSuccess(user: user));
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }

  Future<void> _onLoginWithToken(
    LoginWithToken event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      // Intentar obtener usuario desde token almacenado
      final user = await userRepository.getUserWithStoredToken();

      if (user != null) {
        emit(LoginSuccess(user: user));
      } else {
        emit(LoginInitial());
      }
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<LoginState> emit,
  ) async {
    emit(LoginLoading());

    try {
      await userRepository.logout();
      emit(LoginInitial());
    } catch (e) {
      emit(LoginFailure(error: e.toString()));
    }
  }
}
