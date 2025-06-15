// lib/data/bloc/admin_users/admin_users_state.dart
part of 'admin_users_bloc.dart';

@immutable
abstract class AdminUsersState extends Equatable {
  const AdminUsersState();

  @override
  List<Object?> get props => [];
}

class AdminUsersInitial extends AdminUsersState {}

class AdminUsersLoading extends AdminUsersState {}

class AdminUsersLoaded extends AdminUsersState {
  final List<UserDto> users;

  const AdminUsersLoaded({required this.users});

  @override
  List<Object?> get props => [users];
}

class AdminUsersError extends AdminUsersState {
  final String message;

  const AdminUsersError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Estados para acciones específicas
class AdminUsersActionInProgress extends AdminUsersState {
  final String message;

  const AdminUsersActionInProgress({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminUsersActionSuccess extends AdminUsersState {
  final String message;

  const AdminUsersActionSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class AdminUsersActionFailure extends AdminUsersState {
  final String message;

  const AdminUsersActionFailure({required this.message});

  @override
  List<Object?> get props => [message];
}

// Estados de navegación
class AdminUsersNavigatingToCreate extends AdminUsersState {}

class AdminUsersNavigatingToEdit extends AdminUsersState {
  final UserDto user;

  const AdminUsersNavigatingToEdit({required this.user});

  @override
  List<Object?> get props => [user];
}
