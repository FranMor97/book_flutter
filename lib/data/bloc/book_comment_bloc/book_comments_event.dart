part of 'book_comments_bloc.dart';

@immutable
abstract class BookCommentsEvent extends Equatable {
  const BookCommentsEvent();

  @override
  List<Object> get props => [];
}

class BookCommentsLoad extends BookCommentsEvent {
  final String bookId;

  const BookCommentsLoad({required this.bookId});

  @override
  List<Object> get props => [bookId];
}

class BookCommentsAddComment extends BookCommentsEvent {
  final String bookId;
  final String bookUserId;
  final ReviewDto review;

  const BookCommentsAddComment({
    required this.bookId,
    required this.bookUserId,
    required this.review,
  });

  @override
  List<Object> get props => [bookId, bookUserId, review];
}
