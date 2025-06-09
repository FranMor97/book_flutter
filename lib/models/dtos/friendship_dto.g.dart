// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'friendship_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

FriendshipDto _$FriendshipDtoFromJson(Map<String, dynamic> json) =>
    FriendshipDto(
      id: json['_id'] as String?,
      requesterId: FriendshipDto._extractIdFromField(json['requesterId']),
      recipientId: FriendshipDto._extractIdFromField(json['recipientId']),
      status: json['status'] as String,
      createdAt: FriendshipDto._dateTimeFromJson(json['createdAt'] as String),
      updatedAt: FriendshipDto._dateTimeFromJson(json['updatedAt'] as String),
      requester: json['requester'] == null
          ? null
          : UserDto.fromJson(json['requester'] as Map<String, dynamic>),
      recipient: json['recipient'] == null
          ? null
          : UserDto.fromJson(json['recipient'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$FriendshipDtoToJson(FriendshipDto instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'requesterId': instance.requesterId,
      'recipientId': instance.recipientId,
      'status': instance.status,
      'createdAt': FriendshipDto._dateTimeToJson(instance.createdAt),
      'updatedAt': FriendshipDto._dateTimeToJson(instance.updatedAt),
      if (instance.requester case final value?) 'requester': value,
      if (instance.recipient case final value?) 'recipient': value,
    };
