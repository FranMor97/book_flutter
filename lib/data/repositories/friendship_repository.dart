// lib/data/repositories/friendship_repository.dart
import 'package:book_app_f/models/friendship.dart';
import 'package:book_app_f/models/user.dart';

abstract class IFriendshipRepository {
  /// Obtiene la lista de amigos del usuario actual
  Future<List<User>> getFriends();

  /// Obtiene las solicitudes de amistad pendientes recibidas
  Future<List<Friendship>> getFriendRequests();

  /// Busca usuarios por nombre o email
  /// Retorna usuarios junto con su estado de amistad
  Future<List<Map<String, dynamic>>> searchUsers(String query);

  /// Envía una solicitud de amistad
  Future<Friendship> sendFriendRequest(String recipientId);

  /// Responde a una solicitud de amistad
  /// status puede ser 'accepted' o 'rejected'
  Future<Friendship> respondToFriendRequest(String friendshipId, String status);

  /// Elimina una amistad
  Future<void> removeFriend(String friendshipId);
}
