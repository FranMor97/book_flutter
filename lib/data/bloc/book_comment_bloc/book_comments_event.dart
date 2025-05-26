part of 'book_comments_bloc.dart';

@immutable
abstract class BookCommentsEvent extends Equatable {
  const BookCommentsEvent();

  @override
  List<Object?> get props => [];
}

class BookCommentsAddComment extends BookCommentsEvent {
  final String bookId;
  final String? bookUserId; // Hacerlo opcional
  final ReviewDto review;

  const BookCommentsAddComment({
    required this.bookId,
    this.bookUserId, // Ya no es required
    required this.review,
  });

  @override
  List<Object?> get props => [bookId, bookUserId, review];
}

class BookCommentsLoad extends BookCommentsEvent {
  final String bookId;

  const BookCommentsLoad({required this.bookId});

  @override
  List<Object> get props => [bookId];
}
