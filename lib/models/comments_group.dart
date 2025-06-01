// lib/models/group_message.dart
import 'package:book_app_f/models/user.dart';

enum MessageType { text, system, progress }

class GroupMessage {
  final String id;
  final String groupId;
  final String userId;
  final String text;
  final MessageType type;
  final DateTime createdAt;

  // Campos adicionales que pueden ser útiles
  final User? user; // Usuario que envió el mensaje (opcional)

  GroupMessage({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.text,
    required this.type,
    required this.createdAt,
    this.user,
  });

  factory GroupMessage.fromJson(Map<String, dynamic> json) {
    return GroupMessage(
      id: json['_id'] ?? json['id'],
      groupId: json['groupId'],
      userId: json['userId'] is Map
          ? json['userId']['_id'] ?? json['userId']['id']
          : json['userId'],
      text: json['text'],
      type: _typeFromString(json['type'] ?? 'text'),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      user: json['userId'] is Map ? User.fromJson(json['userId']) : null,
    );
  }

  static MessageType _typeFromString(String type) {
    switch (type) {
      case 'text':
        return MessageType.text;
      case 'system':
        return MessageType.system;
      case 'progress':
        return MessageType.progress;
      default:
        return MessageType.text;
    }
  }

  static String _typeToString(MessageType type) {
    switch (type) {
      case MessageType.text:
        return 'text';
      case MessageType.system:
        return 'system';
      case MessageType.progress:
        return 'progress';
      default:
        return 'text';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'text': text,
      'type': _typeToString(type),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
