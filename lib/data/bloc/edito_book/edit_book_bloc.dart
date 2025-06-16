// lib/data/bloc/edit_book/edit_book_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_dto.dart';
import '../../repositories/book_repository.dart';

part 'edit_book_event.dart';
part 'edit_book_state.dart';

@injectable
class EditBookBloc extends Bloc<EditBookEvent, EditBookState> {
  final IBookRepository bookRepository;

  EditBookBloc({
    required this.bookRepository,
  }) : super(EditBookInitial()) {
    on<EditBookLoad>(_onEditBookLoad);
    on<EditBookUpdate>(_onEditBookUpdate);
  }

  Future<void> _onEditBookLoad(
    EditBookLoad event,
    Emitter<EditBookState> emit,
  ) async {
    emit(EditBookLoading());

    try {
      final book = await bookRepository.getBookById(event.bookId);

      if (book == null) {
        emit(const EditBookError(message: 'Libro no encontrado'));
        return;
      }

      emit(EditBookLoaded(book: book));
    } catch (e) {
      emit(EditBookError(message: e.toString()));
    }
  }

  Future<void> _onEditBookUpdate(
    EditBookUpdate event,
    Emitter<EditBookState> emit,
  ) async {
    final currentState = state;
    if (currentState is! EditBookLoaded) return;

    emit(EditBookUpdating(book: currentState.book));

    try {
      final updatedBook = await bookRepository.updateBook(
        event.book.id!,
        event.book,
      );

      emit(EditBookUpdateSuccess(book: updatedBook));

      // Volver al estado cargado con el libro actualizado
      emit(EditBookLoaded(book: updatedBook));
    } catch (e) {
      emit(EditBookError(message: e.toString()));

      // Volver al estado anterior en caso de error
      emit(EditBookLoaded(book: currentState.book));
    }
  }
}
