// lib/models/dtos/friendship_dto.dart
import 'package:json_annotation/json_annotation.dart';
import '../friendship.dart';
import '../user.dart';
import 'user_dto.dart';

part 'friendship_dto.g.dart';

@JsonSerializable()
class FriendshipDto {
  @JsonKey(name: '_id')
  final String? id;

  // Utilizamos un JsonKey personalizado para manejar tanto string como Map
  @JsonKey(name: 'requesterId', fromJson: _extractIdFromField)
  final String requesterId;

  // Utilizamos un JsonKey personalizado para manejar tanto string como Map
  @JsonKey(name: 'recipientId', fromJson: _extractIdFromField)
  final String recipientId;

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(
    name: 'createdAt',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime createdAt;

  @JsonKey(
    name: 'updatedAt',
    fromJson: _dateTimeFromJson,
    toJson: _dateTimeToJson,
  )
  final DateTime updatedAt;

  // Relaciones
  @JsonKey(name: 'requester', includeIfNull: false)
  final UserDto? requester;

  @JsonKey(name: 'recipient', includeIfNull: false)
  final UserDto? recipient;

  // Campo adicional para la UI
  @JsonKey(ignore: true)
  final bool isRequester;

  FriendshipDto({
    this.id,
    required this.requesterId,
    required this.recipientId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    this.requester,
    this.recipient,
    this.isRequester = false,
  });

  // From JSON
  factory FriendshipDto.fromJson(Map<String, dynamic> json) =>
      _$FriendshipDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$FriendshipDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Helper method to extract ID from either a string or a Map
  static String _extractIdFromField(dynamic field) {
    if (field == null) return '';

    if (field is String) {
      return field;
    } else if (field is Map) {
      // Intenta obtener '_id' o 'id'
      return (field['_id'] ?? field['id'] ?? '').toString();
    }

    // En caso de cualquier otro tipo, convierte a string
    return field.toString();
  }

  // Convert DTO to domain Friendship
  Friendship toDomain() {
    return Friendship(
      id: id ?? '',
      requesterId: requesterId,
      recipientId: recipientId,
      status: _statusFromString(status),
      createdAt: createdAt,
      updatedAt: updatedAt,
      requester: requester?.toUser(),
      recipient: recipient?.toUser(),
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

  // Factory para crear un DTO a partir del modelo de dominio
  factory FriendshipDto.fromDomain(Friendship friendship) {
    return FriendshipDto(
      id: friendship.id,
      requesterId: friendship.requesterId,
      recipientId: friendship.recipientId,
      status: _statusToString(friendship.status),
      createdAt: friendship.createdAt,
      updatedAt: friendship.updatedAt,
      // Nota: no convertimos los campos de relación aquí para evitar ciclos
    );
  }
}
