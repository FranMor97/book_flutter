part of 'register_bloc.dart';

@immutable
abstract class RegisterEvent {}

class RegisterSubmitted extends RegisterEvent {
  final UserDto userDto;

  RegisterSubmitted({required this.userDto});
}
