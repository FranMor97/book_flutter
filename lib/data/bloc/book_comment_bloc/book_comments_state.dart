part of 'book_comments_bloc.dart';

@immutable
abstract class BookCommentsState extends Equatable {
  const BookCommentsState();

  @override
  List<Object?> get props => [];
}

class BookCommentsInitial extends BookCommentsState {}

class BookCommentsLoading extends BookCommentsState {}

class BookCommentsLoaded extends BookCommentsState {
  final List<BookComment> comments;
  final String?
      userBookId; // ID de la relación libro-usuario del usuario actual
  final bool
      canAddComment; // Si el usuario puede añadir comentarios (ha completado el libro)

  const BookCommentsLoaded({
    required this.comments,
    this.userBookId,
    this.canAddComment = false,
  });

  @override
  List<Object?> get props => [comments, userBookId, canAddComment];
}

class BookCommentsSubmitting extends BookCommentsState {}

class BookCommentsError extends BookCommentsState {
  final String message;

  const BookCommentsError({required this.message});

  @override
  List<Object> get props => [message];
}
