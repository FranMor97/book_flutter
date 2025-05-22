// import 'package:bloc/bloc.dart';
// import 'package:equatable/equatable.dart';
// import 'package:meta/meta.dart';
// import '../../models/dtos/user_dto.dart';
// import '../repositories/user_repository.dart';
//
// part 'login_event.dart';
// part 'login_state.dart';
//
// class LoginBloc extends Bloc<LoginEvent, LoginState> {
//   final UserRepository userRepository;
//
//   LoginBloc({required this.userRepository}) : super(LoginInitial()) {
//     on<LoginSubmitted>(_onLoginSubmitted);
//     on<LoginWithToken>(_onLoginWithToken);
//     on<LogoutRequested>(_onLogoutRequested);
//   }
//
//   Future<void> _onLoginSubmitted(
//     LoginSubmitted event,
//     Emitter<LoginState> emit,
//   ) async {
//     emit(LoginLoading());
//
//     try {
//       final loginDto = UserDto.forLogin(
//         email: event.email,
//         password: event.password,
//       );
//
//       // Llamar al repositorio para iniciar sesión
//       final user = await userRepository.login(loginDto);
//
//       emit(LoginSuccess(user: user));
//     } catch (e) {
//       emit(LoginFailure(error: e.toString()));
//     }
//   }
//
//   Future<void> _onLoginWithToken(
//     LoginWithToken event,
//     Emitter<LoginState> emit,
//   ) async {
//     emit(LoginLoading());
//
//     try {
//       // Intentar obtener usuario desde token almacenado
//       final user = await userRepository.getUserWithStoredToken();
//
//       if (user != null) {
//         emit(LoginSuccess(user: user));
//       } else {
//         emit(LoginInitial());
//       }
//     } catch (e) {
//       emit(LoginFailure(error: e.toString()));
//     }
//   }
//
//   Future<void> _onLogoutRequested(
//     LogoutRequested event,
//     Emitter<LoginState> emit,
//   ) async {
//     emit(LoginLoading());
//
//     try {
//       await userRepository.logout();
//       emit(LoginInitial());
//     } catch (e) {
//       emit(LoginFailure(error: e.toString()));
//     }
//   }
// }
