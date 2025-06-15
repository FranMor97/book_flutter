// lib/data/bloc/admin_users/admin_users_event.dart
part of 'admin_users_bloc.dart';

@immutable
abstract class AdminUsersEvent extends Equatable {
  const AdminUsersEvent();

  @override
  List<Object?> get props => [];
}

class AdminUsersLoadAll extends AdminUsersEvent {
  final int page;
  final int limit;

  const AdminUsersLoadAll({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

class AdminUsersDeleteUser extends AdminUsersEvent {
  final String userId;

  const AdminUsersDeleteUser({required this.userId});

  @override
  List<Object?> get props => [userId];
}

class AdminUsersNavigateToCreate extends AdminUsersEvent {}

class AdminUsersNavigateToEdit extends AdminUsersEvent {
  final UserDto user;

  const AdminUsersNavigateToEdit({required this.user});

  @override
  List<Object?> get props => [user];
}
