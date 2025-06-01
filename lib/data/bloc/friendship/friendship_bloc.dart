// lib/data/bloc/friendship/friendship_bloc.dart
import 'package:bloc/bloc.dart';
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/models/friendship.dart';
import 'package:book_app_f/models/user.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'friendship_event.dart';
part 'friendship_state.dart';

class FriendshipBloc extends Bloc<FriendshipEvent, FriendshipState> {
  final IFriendshipRepository friendshipRepository;

  FriendshipBloc({required this.friendshipRepository})
      : super(FriendshipInitial()) {
    on<FriendshipLoadFriends>(_onLoadFriends);
    on<FriendshipLoadRequests>(_onLoadRequests);
    on<FriendshipSearchUsers>(_onSearchUsers);
    on<FriendshipSendRequest>(_onSendRequest);
    on<FriendshipRespondToRequest>(_onRespondToRequest);
    on<FriendshipRemoveFriend>(_onRemoveFriend);
  }

  Future<void> _onLoadFriends(
    FriendshipLoadFriends event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipLoading());

    try {
      final friends = await friendshipRepository.getFriends();
      emit(FriendshipFriendsLoaded(friends: friends));
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }

  Future<void> _onLoadRequests(
    FriendshipLoadRequests event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipLoading());

    try {
      final requests = await friendshipRepository.getFriendRequests();
      emit(FriendshipRequestsLoaded(requests: requests));
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }

  Future<void> _onSearchUsers(
    FriendshipSearchUsers event,
    Emitter<FriendshipState> emit,
  ) async {
    emit(FriendshipSearching());

    try {
      final results = await friendshipRepository.searchUsers(event.query);
      emit(FriendshipSearchResults(results: results));
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }

  Future<void> _onSendRequest(
    FriendshipSendRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    final currentState = state;
    emit(FriendshipActionInProgress());

    try {
      final friendship = await friendshipRepository.sendFriendRequest(
        event.recipientId,
      );

      emit(FriendshipRequestSent(friendship: friendship));

      // Volver al estado anterior pero actualizado
      if (currentState is FriendshipSearchResults) {
        add(FriendshipSearchUsers(query: event.searchQuery ?? ''));
      } else {
        add(FriendshipLoadFriends());
      }
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }

  Future<void> _onRespondToRequest(
    FriendshipRespondToRequest event,
    Emitter<FriendshipState> emit,
  ) async {
    final currentState = state;
    emit(FriendshipActionInProgress());

    try {
      final friendship = await friendshipRepository.respondToFriendRequest(
        event.friendshipId,
        event.status,
      );

      emit(FriendshipRequestResponded(
        friendship: friendship,
        status: event.status,
      ));

      // Recargar solicitudes pendientes
      add(FriendshipLoadRequests());
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }

  Future<void> _onRemoveFriend(
    FriendshipRemoveFriend event,
    Emitter<FriendshipState> emit,
  ) async {
    final currentState = state;
    emit(FriendshipActionInProgress());

    try {
      await friendshipRepository.removeFriend(event.friendshipId);

      emit(const FriendshipRemoved());

      // Recargar lista de amigos
      add(FriendshipLoadFriends());
    } catch (e) {
      emit(FriendshipError(message: e.toString()));
    }
  }
}
