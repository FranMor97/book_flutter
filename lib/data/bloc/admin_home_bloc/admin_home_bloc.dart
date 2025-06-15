import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'admin_home_event.dart';
part 'admin_home_state.dart';

class AdminHomeBloc extends Bloc<AdminHomeEvent, AdminHomeState> {
  AdminHomeBloc() : super(AdminHomeInitial()) {
    on<NavigateToUsersManagement>(_onNavigateToUsersManagement);
    on<NavigateToBooksManagement>(_onNavigateToBooksManagement);
    on<NavigateToAdminHome>(_onNavigateToAdminHome);
    on<AdminLogout>(_onAdminLogout);
  }

  void _onNavigateToUsersManagement(
    NavigateToUsersManagement event,
    Emitter<AdminHomeState> emit,
  ) {
    emit(NavigatingToUsersManagement());
  }

  void _onNavigateToBooksManagement(
    NavigateToBooksManagement event,
    Emitter<AdminHomeState> emit,
  ) {
    emit(NavigatingToBooksManagement());
  }

  void _onNavigateToAdminHome(
    NavigateToAdminHome event,
    Emitter<AdminHomeState> emit,
  ) {
    emit(NavigatingToAdminHome());
  }

  void _onAdminLogout(
    AdminLogout event,
    Emitter<AdminHomeState> emit,
  ) {
    emit(AdminLoggingOut());
  }
}
