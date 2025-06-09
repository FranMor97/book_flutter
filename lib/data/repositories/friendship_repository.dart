// lib/data/repositories/friendship_repository.dart
import 'package:book_app_f/models/dtos/friendship_dto.dart';
import 'package:book_app_f/models/friendship.dart';
import 'package:book_app_f/models/user.dart';
import 'package:book_app_f/models/user_with_friendship.dart';

abstract class IFriendshipRepository {
  /// Obtiene la lista de amigos del usuario actual
  Future<List<User>> getFriends();

  /// Obtiene las solicitudes de amistad pendientes recibidas
  Future<List<UserWithFriendshipId>> getFriendRequests();

  /// Busca usuarios por nombre o email
  /// Retorna usuarios con su estado de amistad
  Future<List<UserFriendshipStatus>> searchUsers(String query);

  /// Envía una solicitud de amistad
  Future<Friendship> sendFriendRequest(String recipientId);

  /// Responde a una solicitud de amistad
  /// status puede ser 'accepted' o 'rejected'
  Future<Friendship> respondToFriendRequest(String friendshipId, String status);

  /// Elimina una amistad
  Future<void> removeFriend(String friendshipId);
}

/// Clase para contener un usuario con su estado de amistad
class UserFriendshipStatus {
  final User user;
  final String? friendshipStatus;
  final String? friendshipId;
  final bool isRequester;

  UserFriendshipStatus({
    required this.user,
    this.friendshipStatus,
    this.friendshipId,
    this.isRequester = false,
  });

  factory UserFriendshipStatus.fromJson(Map<String, dynamic> json) {
    return UserFriendshipStatus(
      user: User.fromJson(json),
      friendshipStatus: json['friendshipStatus'] as String?,
      friendshipId: json['friendshipId'] as String?,
      isRequester: json['isRequester'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      ...user.toJson(),
      'friendshipStatus': friendshipStatus,
      'friendshipId': friendshipId,
      'isRequester': isRequester,
    };
  }
}
