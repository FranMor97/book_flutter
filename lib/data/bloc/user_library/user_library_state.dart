part of 'user_library_bloc.dart';

@immutable
abstract class UserLibraryState extends Equatable {
  const UserLibraryState();

  @override
  List<Object?> get props => [];
}

class UserLibraryInitial extends UserLibraryState {}

class UserLibraryLoading extends UserLibraryState {}

class UserLibraryLoaded extends UserLibraryState {
  final List<BookUserDto> books;
  final String? currentStatus;
  final String userId;

  const UserLibraryLoaded({
    required this.books,
    this.currentStatus,
    required this.userId,
  });

  @override
  List<Object?> get props => [books, currentStatus, userId];

  UserLibraryLoaded copyWith({
    List<BookUserDto>? books,
    String? currentStatus,
    String? userId,
  }) {
    return UserLibraryLoaded(
      books: books ?? this.books,
      currentStatus: currentStatus ?? this.currentStatus,
      userId: userId ?? this.userId,
    );
  }
}

class UserLibraryError extends UserLibraryState {
  final String message;

  const UserLibraryError({required this.message});

  @override
  List<Object?> get props => [message];
}
