part of 'edit_book_bloc.dart';

@immutable
abstract class EditBookState extends Equatable {
  const EditBookState();

  @override
  List<Object?> get props => [];
}

class EditBookInitial extends EditBookState {}

class EditBookLoading extends EditBookState {}

class EditBookLoaded extends EditBookState {
  final BookDto book;

  const EditBookLoaded({required this.book});

  @override
  List<Object> get props => [book];
}

class EditBookUpdating extends EditBookState {
  final BookDto book;

  const EditBookUpdating({required this.book});

  @override
  List<Object> get props => [book];
}

class EditBookUpdateSuccess extends EditBookState {
  final BookDto book;

  const EditBookUpdateSuccess({required this.book});

  @override
  List<Object> get props => [book];
}

class EditBookError extends EditBookState {
  final String message;

  const EditBookError({required this.message});

  @override
  List<Object> get props => [message];
}
