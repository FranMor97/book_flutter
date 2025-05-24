// lib/data/bloc/book_detail/book_detail_state.dart
part of 'book_detail_bloc.dart';

@immutable
abstract class BookDetailState extends Equatable {
  const BookDetailState();

  @override
  List<Object?> get props => [];
}

class BookDetailInitial extends BookDetailState {}

class BookDetailLoading extends BookDetailState {}

class BookDetailLoaded extends BookDetailState {
  final BookDto book;
  final UserBookStatus? userBook;

  const BookDetailLoaded({
    required this.book,
    this.userBook,
  });

  @override
  List<Object?> get props => [book, userBook];
}

class BookDetailError extends BookDetailState {
  final String message;

  const BookDetailError({required this.message});

  @override
  List<Object> get props => [message];
}
