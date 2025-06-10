// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reading_group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GroupMember _$GroupMemberFromJson(Map<String, dynamic> json) => GroupMember(
      userId: json['userId'] as String,
      role: json['role'] as String,
      currentPage: (json['currentPage'] as num).toInt(),
      joinedAt: GroupMember._dateTimeFromJson(json['joinedAt'] as String),
    );

Map<String, dynamic> _$GroupMemberToJson(GroupMember instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'role': instance.role,
      'currentPage': instance.currentPage,
      'joinedAt': GroupMember._dateTimeToJson(instance.joinedAt),
    };

ReadingGoal _$ReadingGoalFromJson(Map<String, dynamic> json) => ReadingGoal(
      pagesPerDay: (json['pagesPerDay'] as num?)?.toInt(),
      targetFinishDate: ReadingGoal._dateTimeFromNullableJson(
          json['targetFinishDate'] as String?),
    );

Map<String, dynamic> _$ReadingGoalToJson(ReadingGoal instance) =>
    <String, dynamic>{
      'pagesPerDay': instance.pagesPerDay,
      'targetFinishDate':
          ReadingGoal._dateTimeToNullableJson(instance.targetFinishDate),
    };

ReadingGroup _$ReadingGroupFromJson(Map<String, dynamic> json) => ReadingGroup(
      id: json['_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      bookId: json['bookId'] as String,
      creatorId: json['creatorId'] as String,
      members: (json['members'] as List<dynamic>)
          .map((e) => GroupMember.fromJson(e as Map<String, dynamic>))
          .toList(),
      isPrivate: json['isPrivate'] as bool,
      readingGoal: json['readingGoal'] == null
          ? null
          : ReadingGoal.fromJson(json['readingGoal'] as Map<String, dynamic>?),
      createdAt: ReadingGroup._dateTimeFromJson(json['createdAt'] as String),
      updatedAt: ReadingGroup._dateTimeFromJson(json['updatedAt'] as String),
    );

Map<String, dynamic> _$ReadingGroupToJson(ReadingGroup instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'bookId': instance.bookId,
      'creatorId': instance.creatorId,
      'members': instance.members,
      'isPrivate': instance.isPrivate,
      'readingGoal': instance.readingGoal,
      'createdAt': ReadingGroup._dateTimeToJson(instance.createdAt),
      'updatedAt': ReadingGroup._dateTimeToJson(instance.updatedAt),
    };
