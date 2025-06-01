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

  factory Friendship.fromJson(Map<String, dynamic> json) {
    return Friendship(
      id: json['_id'] ?? json['id'],
      requesterId: json['requesterId'],
      recipientId: json['recipientId'],
      status: _statusFromString(json['status']),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      requester:
          json['requester'] != null ? User.fromJson(json['requester']) : null,
      recipient:
          json['recipient'] != null ? User.fromJson(json['recipient']) : null,
    );
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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'requesterId': requesterId,
      'recipientId': recipientId,
      'status': _statusToString(status),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
