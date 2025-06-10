// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'comments_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMessage _$GroupMessageFromJson(Map<String, dynamic> json) => GroupMessage(
      id: json['_id'] as String,
      groupId: json['groupId'] as String,
      userId: json['userId'] as String,
      text: json['text'] as String,
      type: GroupMessage._typeFromString(json['type'] as String),
      createdAt: GroupMessage._dateTimeFromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$GroupMessageToJson(GroupMessage instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'text': instance.text,
      'type': GroupMessage._typeToString(instance.type),
      'createdAt': GroupMessage._dateTimeToJson(instance.createdAt),
    };
