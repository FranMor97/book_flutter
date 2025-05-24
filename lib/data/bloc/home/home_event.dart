// lib/data/bloc/home/home_event.dart
part of 'home_bloc.dart';

@immutable
abstract class HomeEvent extends Equatable {
  const HomeEvent();

  @override
  List<Object> get props => [];
}

class HomeLoadDashboard extends HomeEvent {}
// class HomeLoadDashboard extends HomeEvent {
//   // final String userId;
//
//   const HomeLoadDashboard({required this.userId});
//
//   @override
//   List<Object> get props => [userId];
// }

/// Evento para refrescar datos del dashboard
class HomeRefreshDashboard extends HomeEvent {
  final String userId;

  const HomeRefreshDashboard({required this.userId});

  @override
  List<Object> get props => [userId];
}

/// Evento para actualizar progreso rápido desde el dashboard
class HomeUpdateQuickProgress extends HomeEvent {
  final String bookUserId;
  final int newPage;

  const HomeUpdateQuickProgress({
    required this.bookUserId,
    required this.newPage,
  });

  @override
  List<Object> get props => [bookUserId, newPage];
}
