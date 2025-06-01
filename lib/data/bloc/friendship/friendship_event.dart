// lib/data/bloc/friendship/friendship_event.dart
part of 'friendship_bloc.dart';

@immutable
abstract class FriendshipEvent extends Equatable {
  const FriendshipEvent();

  @override
  List<Object?> get props => [];
}

class FriendshipLoadFriends extends FriendshipEvent {}

class FriendshipLoadRequests extends FriendshipEvent {}

class FriendshipSearchUsers extends FriendshipEvent {
  final String query;

  const FriendshipSearchUsers({required this.query});

  @override
  List<Object?> get props => [query];
}

class FriendshipSendRequest extends FriendshipEvent {
  final String recipientId;
  final String? searchQuery; // Para actualizar resultados de búsqueda

  const FriendshipSendRequest({
    required this.recipientId,
    this.searchQuery,
  });

  @override
  List<Object?> get props => [recipientId, searchQuery];
}

class FriendshipRespondToRequest extends FriendshipEvent {
  final String friendshipId;
  final String status; // 'accepted' o 'rejected'

  const FriendshipRespondToRequest({
    required this.friendshipId,
    required this.status,
  });

  @override
  List<Object?> get props => [friendshipId, status];
}

class FriendshipRemoveFriend extends FriendshipEvent {
  final String friendshipId;

  const FriendshipRemoveFriend({required this.friendshipId});

  @override
  List<Object?> get props => [friendshipId];
}
