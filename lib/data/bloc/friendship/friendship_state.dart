// lib/data/bloc/friendship/friendship_state.dart
part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipState extends Equatable {
  const FriendshipState();

  @override
  List<Object?> get props => [];
}

class FriendshipInitial extends FriendshipState {}

class FriendshipLoading extends FriendshipState {}

class FriendshipSearching extends FriendshipState {}

class FriendshipActionInProgress extends FriendshipState {}

class FriendshipFriendsLoaded extends FriendshipState {
  final List<User> friends;

  const FriendshipFriendsLoaded({required this.friends});

  @override
  List<Object?> get props => [friends];
}

class FriendshipRequestsLoaded extends FriendshipState {
  final List<UserWithFriendshipId> requests;

  const FriendshipRequestsLoaded({required this.requests});

  @override
  List<Object?> get props => [requests];
}

class FriendshipSearchResults extends FriendshipState {
  final List<UserFriendshipStatus> results;

  const FriendshipSearchResults({required this.results});

  @override
  List<Object?> get props => [results];
}

class FriendshipRequestSent extends FriendshipState {
  final Friendship friendship;

  const FriendshipRequestSent({required this.friendship});

  @override
  List<Object?> get props => [friendship];
}

class FriendshipRequestResponded extends FriendshipState {
  final Friendship friendship;
  final String status;

  const FriendshipRequestResponded({
    required this.friendship,
    required this.status,
  });

  @override
  List<Object?> get props => [friendship, status];
}

class FriendshipRemoved extends FriendshipState {
  const FriendshipRemoved();
}

class FriendshipError extends FriendshipState {
  final String message;

  const FriendshipError({required this.message});

  @override
  List<Object?> get props => [message];
}
