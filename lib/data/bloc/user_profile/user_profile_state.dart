// lib/data/bloc/user_profile/user_profile_state.dart
part of 'user_profile_bloc.dart';

@immutable
abstract class UserProfileState extends Equatable {
  const UserProfileState();

  @override
  List<Object?> get props => [];
}

class UserProfileInitial extends UserProfileState {}

class UserProfileLoading extends UserProfileState {}

class UserProfileLoaded extends UserProfileState {
  final UserDto user;

  const UserProfileLoaded({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserProfileUpdating extends UserProfileState {}

class UserProfileUpdateSuccess extends UserProfileState {
  final UserDto user;

  const UserProfileUpdateSuccess({required this.user});

  @override
  List<Object?> get props => [user];
}

class UserProfileError extends UserProfileState {
  final String message;

  const UserProfileError({required this.message});

  @override
  List<Object?> get props => [message];
}
