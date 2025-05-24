import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/user_dto.dart';
import '../../repositories/user_repository.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  final IUserRepository userRepository;

  RegisterBloc({required this.userRepository}) : super(RegisterInitial()) {
    on<RegisterSubmitted>(_onRegisterSubmitted);
    on<RegisterFormChanged>(_onRegisterFormChanged);
  }

  Future<void> _onRegisterSubmitted(
    RegisterSubmitted event,
    Emitter<RegisterState> emit,
  ) async {
    emit(RegisterLoading());

    try {
      // Llamar al repositorio para registrar al usuario
      final user = await userRepository.register(event.userDto);

      emit(RegisterSuccess(user));
    } catch (e) {
      emit(RegisterFailure(e.toString()));
    }
  }

  void _onRegisterFormChanged(
    RegisterFormChanged event,
    Emitter<RegisterState> emit,
  ) {
    // Validar si el formulario es válido
    final isValid = _validateForm(
      appName: event.appName,
      firstName: event.firstName,
      lastName1: event.lastName1,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
      idNumber: event.idNumber,
      mobilePhone: event.mobilePhone,
      acceptTerms: event.acceptTerms,
    );

    emit(RegisterFormState(
      isValid: isValid,
      appName: event.appName,
      firstName: event.firstName,
      lastName1: event.lastName1,
      lastName2: event.lastName2,
      email: event.email,
      password: event.password,
      confirmPassword: event.confirmPassword,
      idNumber: event.idNumber,
      mobilePhone: event.mobilePhone,
      birthDate: event.birthDate,
      acceptTerms: event.acceptTerms,
    ));
  }

  bool _validateForm({
    required String appName,
    required String firstName,
    required String lastName1,
    required String email,
    required String password,
    required String confirmPassword,
    required String idNumber,
    required String mobilePhone,
    required bool acceptTerms,
  }) {
    // Validar que todos los campos requeridos estén completos
    if (appName.isEmpty ||
        firstName.isEmpty ||
        lastName1.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty ||
        idNumber.isEmpty ||
        mobilePhone.isEmpty) {
      return false;
    }

    // Validar formato de email
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(email)) {
      return false;
    }

    // Validar que las contraseñas coincidan
    if (password != confirmPassword) {
      return false;
    }

    // Validar longitud mínima de contraseña
    if (password.length < 6) {
      return false;
    }

    // Validar aceptación de términos
    if (!acceptTerms) {
      return false;
    }

    return true;
  }
}
