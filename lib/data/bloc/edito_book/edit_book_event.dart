part of 'edit_book_bloc.dart';

@immutable
abstract class EditBookEvent extends Equatable {
  const EditBookEvent();

  @override
  List<Object> get props => [];
}

class EditBookLoad extends EditBookEvent {
  final String bookId;

  const EditBookLoad({required this.bookId});

  @override
  List<Object> get props => [bookId];
}

class EditBookUpdate extends EditBookEvent {
  final BookDto book;

  const EditBookUpdate({required this.book});

  @override
  List<Object> get props => [book];
}
