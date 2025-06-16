part of 'create_book_bloc.dart';

@immutable
abstract class CreateBookState extends Equatable {
  const CreateBookState();

  @override
  List<Object?> get props => [];
}

class CreateBookInitial extends CreateBookState {}

class CreateBookLoading extends CreateBookState {}

class CreateBookSuccess extends CreateBookState {
  final BookDto book;

  const CreateBookSuccess({required this.book});

  @override
  List<Object> get props => [book];
}

class CreateBookError extends CreateBookState {
  final String message;

  const CreateBookError({required this.message});

  @override
  List<Object> get props => [message];
}
