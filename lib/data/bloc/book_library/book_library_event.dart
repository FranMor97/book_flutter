// lib/data/bloc/book_library/book_library_event.dart
part of 'book_library_bloc.dart';

@immutable
abstract class BookLibraryEvent extends Equatable {
  const BookLibraryEvent();

  @override
  List<Object> get props => [];
}

class BookLibraryLoadBooks extends BookLibraryEvent {}

class BookLibrarySearchBooks extends BookLibraryEvent {
  final String query;

  const BookLibrarySearchBooks({required this.query});

  @override
  List<Object> get props => [query];
}

class BookLibraryFilterByGenre extends BookLibraryEvent {
  final String genre;

  const BookLibraryFilterByGenre({required this.genre});

  @override
  List<Object> get props => [genre];
}

class BookLibraryLoadPopular extends BookLibraryEvent {}

class BookLibraryLoadTopRated extends BookLibraryEvent {}

class BookLibraryLoadMore extends BookLibraryEvent {}

class BookLibraryClearFilters extends BookLibraryEvent {}

class BookLibraryRefresh extends BookLibraryEvent {}
