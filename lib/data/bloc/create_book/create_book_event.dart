part of 'create_book_bloc.dart';

@immutable
abstract class CreateBookEvent extends Equatable {
  const CreateBookEvent();

  @override
  List<Object> get props => [];
}

class CreateBookSubmit extends CreateBookEvent {
  final BookDto book;

  const CreateBookSubmit({required this.book});

  @override
  List<Object> get props => [book];
}

class CreateBookReset extends CreateBookEvent {}
