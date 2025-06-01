// lib/data/bloc/user_profile/user_profile_event.dart
part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileLoad extends UserProfileEvent {}

class UserProfileUpdate extends UserProfileEvent {
  final UserDto userDto;

  const UserProfileUpdate({required this.userDto});

  @override
  List<Object> get props => [userDto];
}
