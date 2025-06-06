// lib/models/friendship.dart
import 'package:book_app_f/models/user.dart';

enum FriendshipStatus { pending, accepted, rejected, blocked }

class Friendship {
  final String id;
  final String requesterId;
  final String recipientId;
  final FriendshipStatus status;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? requester;
  final User? recipient;

  Friendship({
    required this.id,
    required this.requesterId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.requester,
    this.recipient,
  });

  // Para propósitos de la UI
  bool get isPending => status == FriendshipStatus.pending;
  bool get isAccepted => status == FriendshipStatus.accepted;
  bool get isRejected => status == FriendshipStatus.rejected;
  bool get isBlocked => status == FriendshipStatus.blocked;

  // Método auxiliar para obtener el otro usuario desde la perspectiva de un usuario
  User? getOtherUser(String userId) {
    if (requesterId == userId) {
      return recipient;
    } else if (recipientId == userId) {
      return requester;
    }
    return null;
  }

  // Método para determinar si el usuario actual es el solicitante
  bool isUserRequester(String userId) {
    return requesterId == userId;
  }

  // Método para determinar si el usuario actual puede responder a la solicitud
  bool canRespond(String userId) {
    return recipientId == userId && status == FriendshipStatus.pending;
  }

  // Método toJson para serialización manual si es necesario
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'recipientId': recipientId,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'requester': requester?.toJson(),
      'recipient': recipient?.toJson(),
    };
  }

  // Métodos estáticos para conversión de estados
  static String _statusToString(FriendshipStatus status) {
    switch (status) {
      case FriendshipStatus.pending:
        return 'pending';
      case FriendshipStatus.accepted:
        return 'accepted';
      case FriendshipStatus.rejected:
        return 'rejected';
      case FriendshipStatus.blocked:
        return 'blocked';
      default:
        return 'pending';
    }
  }

  static FriendshipStatus _statusFromString(String status) {
    switch (status) {
      case 'pending':
        return FriendshipStatus.pending;
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'rejected':
        return FriendshipStatus.rejected;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.pending;
    }
  }
}
