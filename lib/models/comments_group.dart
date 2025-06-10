import 'package:book_app_f/models/user.dart';
import 'package:json_annotation/json_annotation.dart';

part 'comments_group.g.dart';

enum MessageType { text, system, progress }

@JsonSerializable()
class GroupMessage {
  @JsonKey(name: '_id')
  final String id;

  @JsonKey(name: 'groupId')
  final String groupId;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'type', fromJson: _typeFromString, toJson: _typeToString)
  final MessageType type;

  @JsonKey(
      name: 'createdAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  // Campos adicionales que pueden ser útiles
  @JsonKey(ignore: true)
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

  // From JSON
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

  // To JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'groupId': groupId,
      'userId': userId,
      'text': text,
      'type': _typeToString(type),
      'createdAt': _dateTimeToJson(createdAt),
    };
  }

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Helper methods for MessageType conversion
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
}
