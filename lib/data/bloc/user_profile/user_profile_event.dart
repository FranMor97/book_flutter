// lib/data/bloc/user_profile/user_profile_event.dart
part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileEvent extends Equatable {
  const UserProfileEvent();

  @override
  List<Object> get props => [];
}

class UserProfileLoad extends UserProfileEvent {}

class UserProfileLoadWithId extends UserProfileEvent {
  final String userId;

  const UserProfileLoadWithId({required this.userId});

  @override
  List<Object> get props => [userId];
}

class UserProfileUpdate extends UserProfileEvent {
  final UserDto userDto;

  const UserProfileUpdate({required this.userDto});

  @override
  List<Object> get props => [userDto];
}
