part of 'admin_home_bloc.dart';

@immutable
abstract class AdminHomeEvent extends Equatable {
  const AdminHomeEvent();

  @override
  List<Object> get props => [];
}

class NavigateToUsersManagement extends AdminHomeEvent {}

class NavigateToBooksManagement extends AdminHomeEvent {}

class NavigateToAdminHome extends AdminHomeEvent {}

class AdminLogout extends AdminHomeEvent {}
