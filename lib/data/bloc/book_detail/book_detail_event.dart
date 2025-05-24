// lib/data/bloc/book_detail/book_detail_event.dart
part of 'book_detail_bloc.dart';

@immutable
abstract class BookDetailEvent extends Equatable {
  const BookDetailEvent();

  @override
  List<Object> get props => [];
}

class BookDetailLoad extends BookDetailEvent {
  final String bookId;

  const BookDetailLoad({required this.bookId});

  @override
  List<Object> get props => [bookId];
}

class BookDetailAddToLibrary extends BookDetailEvent {
  final String bookId;
  final String status;

  const BookDetailAddToLibrary({
    required this.bookId,
    required this.status,
  });

  @override
  List<Object> get props => [bookId, status];
}

class BookDetailUpdateStatus extends BookDetailEvent {
  final String bookId;
  final String status;

  const BookDetailUpdateStatus({
    required this.bookId,
    required this.status,
  });

  @override
  List<Object> get props => [bookId, status];
}
