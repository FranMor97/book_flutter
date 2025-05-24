// lib/data/bloc/book_detail/book_detail_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:book_app_f/screens/search_books/book_detail.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_dto.dart';
import '../../../models/dtos/book_user_dto.dart';
import '../../repositories/auth_repository.dart';
import '../../repositories/book_repository.dart';
import '../../repositories/book_user_repository.dart';

part 'book_detail_event.dart';
part 'book_detail_state.dart';

@injectable
class BookDetailBloc extends Bloc<BookDetailEvent, BookDetailState> {
  final IBookRepository bookRepository;
  final IBookUserRepository bookUserRepository;
  final IAuthRepository authRepository;

  BookDetailBloc({
    required this.bookRepository,
    required this.bookUserRepository,
    required this.authRepository,
  }) : super(BookDetailInitial()) {
    on<BookDetailLoad>(_onBookDetailLoad);
    on<BookDetailAddToLibrary>(_onBookDetailAddToLibrary);
    on<BookDetailUpdateStatus>(_onBookDetailUpdateStatus);
  }

  Future<void> _onBookDetailLoad(
    BookDetailLoad event,
    Emitter<BookDetailState> emit,
  ) async {
    emit(BookDetailLoading());

    try {
      // Obtener ID del usuario actual
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) {
        emit(BookDetailError(message: 'Usuario no autenticado'));
        return;
      }

      // Obtener detalles del libro
      final book = await bookRepository.getBookById(event.bookId);
      if (book == null) {
        emit(BookDetailError(message: 'Libro no encontrado'));
        return;
      }

      // Verificar si el libro está en la biblioteca del usuario
      final userBook = await bookUserRepository.getUserBook(
        userId: userId,
        bookId: event.bookId,
      );

      // Crear estado simplificado del libro en la biblioteca
      final userBookStatus = userBook != null
          ? UserBookStatus(
              id: userBook.id!,
              status: userBook.status,
              currentPage: userBook.currentPage,
            )
          : null;

      emit(BookDetailLoaded(
        book: book,
        userBook: userBookStatus,
      ));
    } catch (e) {
      emit(BookDetailError(message: e.toString()));
    }
  }

  Future<void> _onBookDetailAddToLibrary(
    BookDetailAddToLibrary event,
    Emitter<BookDetailState> emit,
  ) async {
    // Mantener estado actual mientras se procesa
    final currentState = state;
    if (currentState is! BookDetailLoaded) return;

    try {
      // Obtener ID del usuario actual
      final userId = await authRepository.getCurrentUserId();
      if (userId == null) {
        emit(BookDetailError(message: 'Usuario no autenticado'));
        return;
      }

      // Añadir libro a la biblioteca
      final userBook = await bookUserRepository.addBookToUser(
        userId: userId,
        bookId: event.bookId,
        status: event.status,
      );

      // Crear estado simplificado
      final userBookStatus = UserBookStatus(
        id: userBook.id!,
        status: userBook.status,
        currentPage: userBook.currentPage,
      );

      // Emitir nuevo estado
      emit(BookDetailLoaded(
        book: currentState.book,
        userBook: userBookStatus,
      ));
    } catch (e) {
      emit(BookDetailError(message: e.toString()));
    }
  }

  Future<void> _onBookDetailUpdateStatus(
    BookDetailUpdateStatus event,
    Emitter<BookDetailState> emit,
  ) async {
    // Mantener estado actual mientras se procesa
    final currentState = state;
    if (currentState is! BookDetailLoaded || currentState.userBook == null)
      return;

    try {
      // Actualizar estado del libro
      final updatedUserBook = await bookUserRepository.updateReadingProgress(
        id: currentState.userBook!.id,
        status: event.status,
      );

      // Crear estado simplificado actualizado
      final updatedUserBookStatus = UserBookStatus(
        id: updatedUserBook.id!,
        status: updatedUserBook.status,
        currentPage: updatedUserBook.currentPage,
      );

      // Emitir nuevo estado
      emit(BookDetailLoaded(
        book: currentState.book,
        userBook: updatedUserBookStatus,
      ));
    } catch (e) {
      emit(BookDetailError(message: e.toString()));
    }
  }
}
