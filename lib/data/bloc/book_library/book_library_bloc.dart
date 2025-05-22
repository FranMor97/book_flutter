// lib/data/bloc/book_library/book_library_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_dto.dart';
import '../../repositories/book_repository.dart';

part 'book_library_event.dart';
part 'book_library_state.dart';

class BookLibraryBloc extends Bloc<BookLibraryEvent, BookLibraryState> {
  final IBookRepository bookRepository;

  BookLibraryBloc({required this.bookRepository})
      : super(BookLibraryInitial()) {
    on<BookLibraryLoadBooks>(_onLoadBooks);
    on<BookLibrarySearchBooks>(_onSearchBooks);
    on<BookLibraryFilterByGenre>(_onFilterByGenre);
    on<BookLibraryLoadPopular>(_onLoadPopular);
    on<BookLibraryLoadTopRated>(_onLoadTopRated);
    on<BookLibraryLoadMore>(_onLoadMore);
    on<BookLibraryClearFilters>(_onClearFilters);
    on<BookLibraryRefresh>(_onRefresh);
  }

  Future<void> _onLoadBooks(
    BookLibraryLoadBooks event,
    Emitter<BookLibraryState> emit,
  ) async {
    emit(BookLibraryLoading());

    try {
      final booksResponse =
          await bookRepository.getAllBooks(page: 1, limit: 20);
      final genres = await bookRepository.getAvailableGenres();

      emit(BookLibraryLoaded(
        books: booksResponse.books,
        meta: booksResponse.meta,
        availableGenres: genres,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onSearchBooks(
    BookLibrarySearchBooks event,
    Emitter<BookLibraryState> emit,
  ) async {
    emit(BookLibraryLoading());

    try {
      final response = await bookRepository.searchBooks(
        query: event.query,
        page: 1,
        limit: 20,
      );

      final currentState = state;
      final genres = currentState is BookLibraryLoaded
          ? currentState.availableGenres
          : await bookRepository.getAvailableGenres();

      emit(BookLibraryLoaded(
        books: response.books,
        meta: response.meta,
        currentQuery: event.query,
        availableGenres: genres,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onFilterByGenre(
    BookLibraryFilterByGenre event,
    Emitter<BookLibraryState> emit,
  ) async {
    emit(BookLibraryLoading());

    try {
      final response = await bookRepository.getBooksByGenre(
        genre: event.genre,
        page: 1,
        limit: 20,
      );

      final currentState = state;
      final genres = currentState is BookLibraryLoaded
          ? currentState.availableGenres
          : await bookRepository.getAvailableGenres();

      emit(BookLibraryLoaded(
        books: response.books,
        meta: response.meta,
        currentGenre: event.genre,
        availableGenres: genres,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onLoadPopular(
    BookLibraryLoadPopular event,
    Emitter<BookLibraryState> emit,
  ) async {
    emit(BookLibraryLoading());

    try {
      final response = await bookRepository.getPopularBooks(page: 1, limit: 20);

      final currentState = state;
      final genres = currentState is BookLibraryLoaded
          ? currentState.availableGenres
          : await bookRepository.getAvailableGenres();

      emit(BookLibraryLoaded(
        books: response.books,
        meta: response.meta,
        currentFilter: BookLibraryFilter.popular,
        availableGenres: genres,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onLoadTopRated(
    BookLibraryLoadTopRated event,
    Emitter<BookLibraryState> emit,
  ) async {
    emit(BookLibraryLoading());

    try {
      final response =
          await bookRepository.getTopRatedBooks(page: 1, limit: 20);

      final currentState = state;
      final genres = currentState is BookLibraryLoaded
          ? currentState.availableGenres
          : await bookRepository.getAvailableGenres();

      emit(BookLibraryLoaded(
        books: response.books,
        meta: response.meta,
        currentFilter: BookLibraryFilter.topRated,
        availableGenres: genres,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onLoadMore(
    BookLibraryLoadMore event,
    Emitter<BookLibraryState> emit,
  ) async {
    final currentState = state;
    if (currentState is! BookLibraryLoaded || !currentState.hasMorePages) {
      return;
    }

    emit(currentState.copyWith(isLoadingMore: true));

    try {
      final nextPage = currentState.meta.page + 1;
      BookListResponse response;

      if (currentState.currentQuery != null) {
        response = await bookRepository.searchBooks(
          query: currentState.currentQuery!,
          page: nextPage,
          limit: 20,
        );
      } else if (currentState.currentGenre != null) {
        response = await bookRepository.getBooksByGenre(
          genre: currentState.currentGenre!,
          page: nextPage,
          limit: 20,
        );
      } else {
        switch (currentState.currentFilter) {
          case BookLibraryFilter.popular:
            response = await bookRepository.getPopularBooks(
              page: nextPage,
              limit: 20,
            );
            break;
          case BookLibraryFilter.topRated:
            response = await bookRepository.getTopRatedBooks(
              page: nextPage,
              limit: 20,
            );
            break;
          case BookLibraryFilter.all:
          default:
            response = await bookRepository.getAllBooks(
              page: nextPage,
              limit: 20,
            );
            break;
        }
      }

      final updatedBooks = [...currentState.books, ...response.books];

      emit(currentState.copyWith(
        books: updatedBooks,
        meta: response.meta,
        isLoadingMore: false,
      ));
    } catch (e) {
      emit(BookLibraryError(message: e.toString()));
    }
  }

  Future<void> _onClearFilters(
    BookLibraryClearFilters event,
    Emitter<BookLibraryState> emit,
  ) async {
    add(BookLibraryLoadBooks());
  }

  Future<void> _onRefresh(
    BookLibraryRefresh event,
    Emitter<BookLibraryState> emit,
  ) async {
    final currentState = state;

    if (currentState is BookLibraryLoaded) {
      if (currentState.currentQuery != null) {
        add(BookLibrarySearchBooks(query: currentState.currentQuery!));
      } else if (currentState.currentGenre != null) {
        add(BookLibraryFilterByGenre(genre: currentState.currentGenre!));
      } else {
        switch (currentState.currentFilter) {
          case BookLibraryFilter.popular:
            add(BookLibraryLoadPopular());
            break;
          case BookLibraryFilter.topRated:
            add(BookLibraryLoadTopRated());
            break;
          case BookLibraryFilter.all:
          default:
            add(BookLibraryLoadBooks());
            break;
        }
      }
    } else {
      add(BookLibraryLoadBooks());
    }
  }
}
