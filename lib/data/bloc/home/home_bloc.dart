// lib/data/bloc/home/home_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/data/repositories/user_repository.dart';
import 'package:book_app_f/models/dtos/user_dto.dart';
import 'package:book_app_f/models/genre_stats.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_dto.dart';
import '../../../models/dtos/book_user_dto.dart';
import '../../repositories/book_repository.dart';
import '../../repositories/book_user_repository.dart';

part 'home_event.dart';
part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final IBookUserRepository bookUserRepository;
  final IBookRepository bookRepository;
  final IAuthRepository iAuthRepository;
  final IUserRepository userRepository;

  HomeBloc({
    required this.bookUserRepository,
    required this.bookRepository,
    required this.iAuthRepository,
    required this.userRepository,
  }) : super(HomeInitial()) {
    on<HomeLoadDashboard>(_onLoadDashboard);
    on<HomeRefreshDashboard>(_onRefreshDashboard);
    on<HomeUpdateQuickProgress>(_onUpdateQuickProgress);
  }

  Future<void> _onLoadDashboard(
    HomeLoadDashboard event,
    Emitter<HomeState> emit,
  ) async {
    emit(HomeLoading());

    try {
      final user = await iAuthRepository.getCurrentUserId();
      final userDTO = await userRepository.getUserWithStoredToken();
      // Cargar datos en paralelo para mejor performance
      final results = await Future.wait([
        _getCurrentlyReading(user!),
        _getReadingStats(user),
        _getRecentlyFinished(user),
        _getRecommendations(),
        _getPagesReadThisWeek(user),
        _getFavoriteGenres(user),
      ]);

      final currentlyReading = results[0] as List<BookUserDto>;
      final stats = results[1] as UserReadingStats;
      final recentlyFinished = results[2] as List<BookUserDto>;
      final recommendations = results[3] as List<BookDto>;
      final pagesReadThisWeek = results[4] as int;
      final favoriteGenres = results[5] as List<GenreStat>;

      emit(HomeLoaded(
          currentlyReading: currentlyReading,
          stats: stats,
          recentlyFinished: recentlyFinished,
          recommendations: recommendations,
          userId: user,
          pagesReadThisWeek: pagesReadThisWeek,
          user: userDTO));
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  Future<int> _getPagesReadThisWeek(String userId) async {
    try {
      final stats = await bookUserRepository.getPagesReadByPeriod(userId);
      return stats.pagesRead;
    } catch (e) {
      print('Error al obtener páginas por semana: $e');
      return 0;
    }
  }

  Future<List<GenreStat>> _getFavoriteGenres(String userId) async {
    try {
      return await bookUserRepository.getFavoriteGenres(userId, limit: 3);
    } catch (e) {
      print('Error al obtener géneros favoritos: $e');
      return []; // En caso de error, devolver lista vacía
    }
  }

  Future<void> _onRefreshDashboard(
    HomeRefreshDashboard event,
    Emitter<HomeState> emit,
  ) async {
    // Mantener estado actual mientras cargamos
    final currentState = state;

    try {
      final results = await Future.wait([
        _getCurrentlyReading(event.userId),
        _getReadingStats(event.userId),
        _getRecentlyFinished(event.userId),
        _getRecommendations(),
      ]);

      final user = await userRepository.getUserWithStoredToken();
      final currentlyReading = results[0] as List<BookUserDto>;
      final stats = results[1] as UserReadingStats;
      final recentlyFinished = results[2] as List<BookUserDto>;
      final recommendations = results[3] as List<BookDto>;

      emit(HomeLoaded(
          currentlyReading: currentlyReading,
          stats: stats,
          recentlyFinished: recentlyFinished,
          recommendations: recommendations,
          user: user));
    } catch (e) {
      // Si hay error, mantener estado anterior o mostrar error
      if (currentState is HomeLoaded) {
        // Mantener datos anteriores pero podrías mostrar un mensaje de error
        emit(currentState);
      } else {
        emit(HomeError(message: e.toString()));
      }
    }
  }

  Future<void> _onUpdateQuickProgress(
    HomeUpdateQuickProgress event,
    Emitter<HomeState> emit,
  ) async {
    final currentState = state;
    if (currentState is! HomeLoaded) return;

    emit(HomeProgressUpdating(previousState: currentState));

    try {
      // Actualizar progreso
      final updatedBook = await bookUserRepository.updateReadingProgress(
        id: event.bookUserId,
        currentPage: event.newPage,
      );

      // Actualizar la lista de libros en progreso
      final updatedCurrentlyReading = currentState.currentlyReading
          .map((book) => book.id == event.bookUserId ? updatedBook : book)
          .toList();

      // Recargar estadísticas si es necesario
      final updatedStats = await bookUserRepository.getUserReadingStats(
        updatedBook.userId,
      );

      final updatedDashboard = currentState.copyWith(
        currentlyReading: updatedCurrentlyReading,
        stats: updatedStats,
      );

      emit(HomeProgressUpdated(
        updatedBook: updatedBook,
        updatedDashboard: updatedDashboard,
      ));

      // Volver al estado normal después de un breve delay
      await Future.delayed(const Duration(milliseconds: 500));
      emit(updatedDashboard);
    } catch (e) {
      emit(HomeError(message: e.toString()));
    }
  }

  /// Métodos auxiliares para obtener datos específicos
  Future<List<BookUserDto>> _getCurrentlyReading(String userId) async {
    final response = await bookUserRepository.getUserBooks(
      userId: userId,
      status: 'reading',
      limit: 5, // Limitar a los 5 más recientes
    );
    return response.bookUsers;
  }

  Future<UserReadingStats> _getReadingStats(String userId) async {
    return await bookUserRepository.getUserReadingStats(userId);
  }

  Future<List<BookUserDto>> _getRecentlyFinished(String userId) async {
    final response = await bookUserRepository.getUserBooks(
      userId: userId,
      status: 'completed',
      limit: 3, // Los 3 últimos terminados
    );
    return response.bookUsers;
  }

  Future<List<BookDto>> _getRecommendations() async {
    // Por ahora obtener libros populares como recomendaciones
    final response = await bookRepository.getPopularBooks(limit: 5);
    return response.books;
  }
}
