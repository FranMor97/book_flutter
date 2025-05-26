// lib/data/bloc/user_library/user_library_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_user_dto.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/book_user_repository.dart';

part 'user_library_event.dart';
part 'user_library_state.dart';

class UserLibraryBloc extends Bloc<UserLibraryEvent, UserLibraryState> {
  final IBookUserRepository bookUserRepository;
  final IAuthRepository authRepository;

  UserLibraryBloc({
    required this.bookUserRepository,
    required this.authRepository,
  }) : super(UserLibraryInitial()) {
    on<UserLibraryLoadBooks>(_onLoadBooks);
    on<UserLibraryFilterByStatus>(_onFilterByStatus);
    on<UserLibraryRefresh>(_onRefresh);
    on<UserLibraryRemoveBook>(_onRemoveBook);
    on<UserLibraryAddReview>(_onAddReview);
    on<UserLibraryAddNote>(_onAddNote);
    on<UserLibraryUpdateProgress>(_onUpdateProgress);
    on<UserLibraryUpdateStatus>(_onUpdateStatus);
  }

  Future<void> _onUpdateProgress(
    UserLibraryUpdateProgress event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    try {
      final updatedBook = await bookUserRepository.updateProgress(
        id: event.bookUserId,
        currentPage: event.currentPage,
        markAsCompleted: event.markAsCompleted,
      );

      final updatedBooks = currentState.books.map((book) {
        if (book.id == event.bookUserId) {
          return updatedBook;
        }
        return book;
      }).toList();

      emit(UserLibraryLoaded(
        books: updatedBooks,
        currentStatus: currentState.currentStatus,
        userId: currentState.userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onUpdateStatus(
    UserLibraryUpdateStatus event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    try {
      final updatedBook = await bookUserRepository.updateStatus(
        id: event.bookUserId,
        status: event.status,
      );

      final updatedBooks = currentState.books.map((book) {
        if (book.id == event.bookUserId) {
          return updatedBook;
        }
        return book;
      }).toList();

      emit(UserLibraryLoaded(
        books: updatedBooks,
        currentStatus: currentState.currentStatus,
        userId: currentState.userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onLoadBooks(
    UserLibraryLoadBooks event,
    Emitter<UserLibraryState> emit,
  ) async {
    emit(UserLibraryLoading());

    try {
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) {
        emit(const UserLibraryError(message: 'Usuario no autenticado'));
        return;
      }

      final response = await bookUserRepository.getUserBooks(
        userId: userId,
        page: 1,
        limit: 50, // Cargar suficientes libros inicialmente
      );

      emit(UserLibraryLoaded(
        books: response.bookUsers,
        currentStatus: null, // Sin filtro inicial
        userId: userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onFilterByStatus(
    UserLibraryFilterByStatus event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    emit(UserLibraryLoading());

    try {
      final userId = currentState.userId;
      final response = await bookUserRepository.getUserBooks(
        userId: userId,
        status: event.status,
        page: 1,
        limit: 50,
      );

      emit(UserLibraryLoaded(
        books: response.bookUsers,
        currentStatus: event.status,
        userId: userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onRefresh(
    UserLibraryRefresh event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    emit(UserLibraryLoading());

    try {
      final userId = currentState.userId;
      final status = currentState.currentStatus;

      final response = await bookUserRepository.getUserBooks(
        userId: userId,
        status: status,
        page: 1,
        limit: 50,
      );

      emit(UserLibraryLoaded(
        books: response.bookUsers,
        currentStatus: status,
        userId: userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onRemoveBook(
    UserLibraryRemoveBook event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    try {
      await bookUserRepository.removeBookFromUser(event.bookUserId);

      // Actualizar la lista sin el libro eliminado
      final updatedBooks = currentState.books
          .where((book) => book.id != event.bookUserId)
          .toList();

      emit(UserLibraryLoaded(
        books: updatedBooks,
        currentStatus: currentState.currentStatus,
        userId: currentState.userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onAddReview(
    UserLibraryAddReview event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    try {
      final updatedBookUser = await bookUserRepository.addReview(
        id: event.bookUserId,
        review: event.review,
      );

      // Actualizar el libro en la lista
      final updatedBooks = currentState.books.map((book) {
        if (book.id == event.bookUserId) {
          return updatedBookUser;
        }
        return book;
      }).toList();

      emit(UserLibraryLoaded(
        books: updatedBooks,
        currentStatus: currentState.currentStatus,
        userId: currentState.userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }

  Future<void> _onAddNote(
    UserLibraryAddNote event,
    Emitter<UserLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! UserLibraryLoaded) {
      return;
    }

    try {
      final updatedBook = await bookUserRepository.addNote(
        id: event.bookUserId,
        note: event.note,
      );

      // Actualizar el libro en la lista
      final updatedBooks = currentState.books.map((book) {
        if (book.id == event.bookUserId) {
          return updatedBook;
        }
        return book;
      }).toList();

      emit(UserLibraryLoaded(
        books: updatedBooks,
        currentStatus: currentState.currentStatus,
        userId: currentState.userId,
      ));
    } catch (e) {
      emit(UserLibraryError(message: e.toString()));
    }
  }
}
