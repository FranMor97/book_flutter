// lib/data/bloc/book_library/book_library_state.dart
part of 'book_library_bloc.dart';

@immutable
abstract class BookLibraryState extends Equatable {
  const BookLibraryState();

  @override
  List<Object?> get props => [];
}

class BookLibraryInitial extends BookLibraryState {}

class BookLibraryLoading extends BookLibraryState {}

class BookLibraryLoaded extends BookLibraryState {
  final List<BookDto> books;
  final BookListMeta meta;
  final String? currentQuery;
  final String? currentGenre;
  final BookLibraryFilter currentFilter;
  final List<String> availableGenres;
  final bool isLoadingMore;

  const BookLibraryLoaded({
    required this.books,
    required this.meta,
    this.currentQuery,
    this.currentGenre,
    this.currentFilter = BookLibraryFilter.all,
    this.availableGenres = const [],
    this.isLoadingMore = false,
  });

  @override
  List<Object?> get props => [
        books,
        meta,
        currentQuery,
        currentGenre,
        currentFilter,
        availableGenres,
        isLoadingMore,
      ];

  BookLibraryLoaded copyWith({
    List<BookDto>? books,
    BookListMeta? meta,
    String? currentQuery,
    String? currentGenre,
    BookLibraryFilter? currentFilter,
    List<String>? availableGenres,
    bool? isLoadingMore,
  }) {
    return BookLibraryLoaded(
      books: books ?? this.books,
      meta: meta ?? this.meta,
      currentQuery: currentQuery ?? this.currentQuery,
      currentGenre: currentGenre ?? this.currentGenre,
      currentFilter: currentFilter ?? this.currentFilter,
      availableGenres: availableGenres ?? this.availableGenres,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }

  bool get hasMorePages => meta.page < meta.pages;
}

class BookLibraryError extends BookLibraryState {
  final String message;

  const BookLibraryError({required this.message});

  @override
  List<Object?> get props => [message];
}

enum BookLibraryFilter { all, popular, topRated }
