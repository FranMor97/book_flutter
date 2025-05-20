part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object?> get props => [];
}

class RegisterSubmitted extends RegisterEvent {
  final UserDto userDto;

  const RegisterSubmitted({required this.userDto});

  @override
  List<Object?> get props => [userDto];
}

class RegisterFormChanged extends RegisterEvent {
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

  const RegisterFormChanged({
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
}
