import 'package:bloc/bloc.dart';
import 'package:book_app_f/models/book_comments.dart';
import 'package:book_app_f/models/dtos/book_user_dto.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../repositories/book_repository.dart';
import '../../repositories/book_user_repository.dart';
import '../../repositories/auth_repository.dart';

part 'book_comments_event.dart';
part 'book_comments_state.dart';

class BookCommentsBloc extends Bloc<BookCommentsEvent, BookCommentsState> {
  final IBookRepository bookRepository;
  final IBookUserRepository bookUserRepository;
  final IAuthRepository authRepository;

  BookCommentsBloc({
    required this.bookRepository,
    required this.bookUserRepository,
    required this.authRepository,
  }) : super(BookCommentsInitial()) {
    on<BookCommentsLoad>(_onBookCommentsLoad);
    on<BookCommentsAddComment>(_onBookCommentsAddComment);
    on<BookCommentsDeleteComment>(_onBookCommentsDeleteComment);
  }

  Future<void> _onBookCommentsDeleteComment(
    BookCommentsDeleteComment event,
    Emitter<BookCommentsState> emit,
  ) async {
    final currentState = state;

    if (currentState is! BookCommentsLoaded) return;
    emit(BookCommentsSubmitting());

    try {
      await bookRepository.deleteBookComment(event.commentId);

      // Recargar comentarios
      add(BookCommentsLoad(bookId: event.commentId));
    } catch (e) {
      emit(BookCommentsError(message: e.toString()));
    }
  }

  Future<void> _onBookCommentsLoad(
    BookCommentsLoad event,
    Emitter<BookCommentsState> emit,
  ) async {
    emit(BookCommentsLoading());

    try {
      // Obtener el usuario actual para saber qué comentarios son suyos
      final userId = await authRepository.getCurrentUserId();

      // Obtener comentarios del libro (esta función habría que implementarla)
      final comments = await bookRepository.getBookComments(
        event.bookId,
        userId!,
      );

      // Obtener el bookUser del usuario actual si existe
      final bookUser = userId != null
          ? await bookUserRepository.getUserBook(
              userId: userId,
              bookId: event.bookId,
            )
          : null;

      emit(BookCommentsLoaded(
        comments: comments,
        userBookId: bookUser?.id,
        canAddComment: bookUser != null && bookUser.status == 'completed',
      ));
    } catch (e) {
      emit(BookCommentsError(message: e.toString()));
    }
  }

  // book_comments_bloc.dart
  Future<void> _onBookCommentsAddComment(
    BookCommentsAddComment event,
    Emitter<BookCommentsState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookCommentsLoaded) return;

    emit(BookCommentsSubmitting());

    try {
      // Siempre usar bookRepository.addBookComment
      final newComment = await bookRepository.addBookComment(
        bookId: event.bookId,
        text: event.review.text,
        rating: event.review.rating,
        title: event.review.title,
        isPublic: event.review.isPublic,
      );

      // Recargar comentarios
      add(BookCommentsLoad(bookId: event.bookId));
    } catch (e) {
      emit(BookCommentsError(message: e.toString()));
    }
  }
}
