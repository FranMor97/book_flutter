// lib/data/bloc/create_book/create_book_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../models/dtos/book_dto.dart';
import '../../repositories/book_repository.dart';

part 'create_book_event.dart';
part 'create_book_state.dart';

@injectable
class CreateBookBloc extends Bloc<CreateBookEvent, CreateBookState> {
  final IBookRepository bookRepository;

  CreateBookBloc({
    required this.bookRepository,
  }) : super(CreateBookInitial()) {
    on<CreateBookSubmit>(_onCreateBookSubmit);
    on<CreateBookReset>(_onCreateBookReset);
  }

  Future<void> _onCreateBookSubmit(
    CreateBookSubmit event,
    Emitter<CreateBookState> emit,
  ) async {
    emit(CreateBookLoading());

    try {
      final newBook = await bookRepository.createBook(event.book);
      emit(CreateBookSuccess(book: newBook));
    } catch (e) {
      emit(CreateBookError(message: e.toString()));
    }
  }

  void _onCreateBookReset(
    CreateBookReset event,
    Emitter<CreateBookState> emit,
  ) {
    emit(CreateBookInitial());
  }
}
