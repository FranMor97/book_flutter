part of 'user_library_bloc.dart';

@immutable
abstract class UserLibraryEvent extends Equatable {
  const UserLibraryEvent();

  @override
  List<Object?> get props => [];
}

class UserLibraryLoadBooks extends UserLibraryEvent {}

class UserLibraryFilterByStatus extends UserLibraryEvent {
  final String status;

  const UserLibraryFilterByStatus({required this.status});

  @override
  List<Object?> get props => [status];
}

class UserLibraryRefresh extends UserLibraryEvent {}

class UserLibraryRemoveBook extends UserLibraryEvent {
  final String bookUserId;

  const UserLibraryRemoveBook({required this.bookUserId});

  @override
  List<Object?> get props => [bookUserId];
}

class UserLibraryAddReview extends UserLibraryEvent {
  final String bookUserId;
  final ReviewDto review;

  const UserLibraryAddReview({
    required this.bookUserId,
    required this.review,
  });

  @override
  List<Object?> get props => [bookUserId, review];
}

class UserLibraryAddNote extends UserLibraryEvent {
  final String bookUserId;
  final NoteDto note;

  const UserLibraryAddNote({
    required this.bookUserId,
    required this.note,
  });

  @override
  List<Object?> get props => [bookUserId, note];
}

class UserLibraryUpdateProgress extends UserLibraryEvent {
  final String bookUserId;
  final int currentPage;
  final bool markAsCompleted;

  const UserLibraryUpdateProgress({
    required this.bookUserId,
    required this.currentPage,
    this.markAsCompleted = false,
  });

  @override
  List<Object?> get props => [bookUserId, currentPage, markAsCompleted];
}

class UserLibraryUpdateStatus extends UserLibraryEvent {
  final String bookUserId;
  final String status;

  const UserLibraryUpdateStatus({
    required this.bookUserId,
    required this.status,
  });

  @override
  List<Object?> get props => [bookUserId, status];
}
