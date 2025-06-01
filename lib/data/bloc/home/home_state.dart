// lib/data/bloc/home/home_state.dart
part of 'home_bloc.dart';

@immutable
abstract class HomeState extends Equatable {
  const HomeState();

  @override
  List<Object?> get props => [];
}

/// Estado inicial
class HomeInitial extends HomeState {}

/// Estado de carga
class HomeLoading extends HomeState {}

/// Estado de éxito con datos del dashboard
class HomeLoaded extends HomeState {
  final List<BookUserDto> currentlyReading;
  final UserReadingStats stats;
  final List<BookUserDto> recentlyFinished;
  final List<BookDto> recommendations;
  final String? userId;
  final int pagesReadThisWeek;
  final List<GenreStat> favoriteGenres;

  const HomeLoaded({
    required this.currentlyReading,
    required this.stats,
    required this.recentlyFinished,
    required this.recommendations,
    this.pagesReadThisWeek = 0,
    this.userId,
    this.favoriteGenres = const [],
  });

  @override
  List<Object?> get props => [
        currentlyReading,
        stats,
        recentlyFinished,
        recommendations,
        userId,
        pagesReadThisWeek,
        favoriteGenres,
      ];

  HomeLoaded copyWith({
    List<BookUserDto>? currentlyReading,
    UserReadingStats? stats,
    List<BookUserDto>? recentlyFinished,
    List<BookDto>? recommendations,
    String? userId,
    int? pagesReadThisWeek,
    List<GenreStat>? favoriteGenres,
  }) {
    return HomeLoaded(
      currentlyReading: currentlyReading ?? this.currentlyReading,
      stats: stats ?? this.stats,
      recentlyFinished: recentlyFinished ?? this.recentlyFinished,
      recommendations: recommendations ?? this.recommendations,
      userId: userId ?? this.userId,
      pagesReadThisWeek: pagesReadThisWeek ?? this.pagesReadThisWeek,
      favoriteGenres: favoriteGenres ?? this.favoriteGenres,
    );
  }
}

/// Estado de error
class HomeError extends HomeState {
  final String message;

  const HomeError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Estado de actualización de progreso
class HomeProgressUpdating extends HomeState {
  final HomeLoaded previousState;

  const HomeProgressUpdating({required this.previousState});

  @override
  List<Object?> get props => [previousState];
}

/// Estado después de actualizar progreso exitosamente
class HomeProgressUpdated extends HomeState {
  final BookUserDto updatedBook;
  final HomeLoaded updatedDashboard;

  const HomeProgressUpdated({
    required this.updatedBook,
    required this.updatedDashboard,
  });

  @override
  List<Object?> get props => [updatedBook, updatedDashboard];
}
