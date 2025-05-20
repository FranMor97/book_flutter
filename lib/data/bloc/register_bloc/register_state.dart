part of 'register_bloc.dart';

@immutable
abstract class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object?> get props => [];
}

class RegisterInitial extends RegisterState {}

class RegisterLoading extends RegisterState {}

class RegisterSuccess extends RegisterState {
  final UserDto user;

  const RegisterSuccess(this.user);

  @override
  List<Object?> get props => [user];
}

class RegisterFailure extends RegisterState {
  final String error;

  const RegisterFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class RegisterFormState extends RegisterState {
  final bool isValid;
  final String appName;
  final String firstName;
  final String email;
  final String password;
  final String confirmPassword;
  final String lastName1;
  final String? lastName2;
  final String idNumber;
  final String mobilePhone;
  final DateTime birthDate;
  final bool acceptTerms;

  const RegisterFormState({
    required this.isValid,
    required this.appName,
    required this.firstName,
    required this.email,
    required this.password,
    required this.confirmPassword,
    required this.lastName1,
    this.lastName2,
    required this.idNumber,
    required this.mobilePhone,
    required this.birthDate,
    required this.acceptTerms,
  });

  @override
  List<Object?> get props => [
        isValid,
        appName,
        firstName,
        email,
        password,
        confirmPassword,
        lastName1,
        lastName2,
        idNumber,
        mobilePhone,
        birthDate,
        acceptTerms,
      ];

  RegisterFormState copyWith({
    bool? isValid,
    String? appName,
    String? firstName,
    String? email,
    String? password,
    String? confirmPassword,
    String? lastName1,
    String? lastName2,
    String? idNumber,
    String? mobilePhone,
    DateTime? birthDate,
    bool? acceptTerms,
  }) {
    return RegisterFormState(
      isValid: isValid ?? this.isValid,
      appName: appName ?? this.appName,
      firstName: firstName ?? this.firstName,
      email: email ?? this.email,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      lastName1: lastName1 ?? this.lastName1,
      lastName2: lastName2 ?? this.lastName2,
      idNumber: idNumber ?? this.idNumber,
      mobilePhone: mobilePhone ?? this.mobilePhone,
      birthDate: birthDate ?? this.birthDate,
      acceptTerms: acceptTerms ?? this.acceptTerms,
    );
  }
}
