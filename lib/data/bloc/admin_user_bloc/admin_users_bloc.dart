// lib/data/bloc/admin_users/admin_users_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/user_dto.dart';
import '../../repositories/user_repository.dart';

part 'admin_users_event.dart';
part 'admin_users_state.dart';

class AdminUsersBloc extends Bloc<AdminUsersEvent, AdminUsersState> {
  final IUserRepository userRepository;

  AdminUsersBloc({required this.userRepository}) : super(AdminUsersInitial()) {
    on<AdminUsersLoadAll>(_onLoadAll);
    on<AdminUsersDeleteUser>(_onDeleteUser);
    on<AdminUsersNavigateToCreate>(_onNavigateToCreate);
    on<AdminUsersNavigateToEdit>(_onNavigateToEdit);
  }

  Future<void> _onLoadAll(
    AdminUsersLoadAll event,
    Emitter<AdminUsersState> emit,
  ) async {
    emit(AdminUsersLoading());
    try {
      final users = await userRepository.getAllUsers(
        page: event.page,
        limit: event.limit,
      );
      emit(AdminUsersLoaded(users: users));
    } catch (e) {
      emit(AdminUsersError(message: e.toString()));
    }
  }

  Future<void> _onDeleteUser(
    AdminUsersDeleteUser event,
    Emitter<AdminUsersState> emit,
  ) async {
    try {
      // Mostrar estado de carga
      emit(AdminUsersActionInProgress(message: 'Eliminando usuario...'));

      // Ejecutar la eliminación
      await userRepository.deleteUser(event.userId);

      // Recargar la lista de usuarios
      final users = await userRepository.getAllUsers();

      // Mostrar mensaje de éxito
      emit(AdminUsersActionSuccess(message: 'Usuario eliminado con éxito'));

      // Restaurar la lista actualizada
      emit(AdminUsersLoaded(users: users));
    } catch (e) {
      emit(AdminUsersActionFailure(
          message: 'Error al eliminar: ${e.toString()}'));

      // Recargar datos para asegurar consistencia
      add(AdminUsersLoadAll());
    }
  }

  void _onNavigateToCreate(
    AdminUsersNavigateToCreate event,
    Emitter<AdminUsersState> emit,
  ) {
    emit(AdminUsersNavigatingToCreate());
  }

  void _onNavigateToEdit(
    AdminUsersNavigateToEdit event,
    Emitter<AdminUsersState> emit,
  ) {
    emit(AdminUsersNavigatingToEdit(user: event.user));
  }
}
