part of 'admin_home_bloc.dart';

@immutable
abstract class AdminHomeState extends Equatable {
  const AdminHomeState();

  @override
  List<Object> get props => [];
}

class AdminHomeInitial extends AdminHomeState {}

// Estados de navegación
class NavigatingToUsersManagement extends AdminHomeState {}

class NavigatingToBooksManagement extends AdminHomeState {}

class NavigatingToAdminHome extends AdminHomeState {}

class AdminLoggingOut extends AdminHomeState {}
