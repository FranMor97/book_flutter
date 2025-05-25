// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_user_creation_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookUserCreationDto _$BookUserCreationDtoFromJson(Map<String, dynamic> json) =>
    BookUserCreationDto(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      bookId: json['bookId'] as String,
      status: json['status'] as String? ?? 'to-read',
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      startDate: BookUserCreationDto._dateTimeFromNullableJson(
          json['startDate'] as String?),
      finishDate: BookUserCreationDto._dateTimeFromNullableJson(
          json['finishDate'] as String?),
      personalRating: (json['personalRating'] as num?)?.toInt() ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? false,
      shareProgress: json['shareProgress'] as bool? ?? true,
      lastUpdated:
          BookUserCreationDto._dateTimeFromJson(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$BookUserCreationDtoToJson(
        BookUserCreationDto instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'status': instance.status,
      'currentPage': instance.currentPage,
      'startDate':
          BookUserCreationDto._dateTimeToNullableJson(instance.startDate),
      'finishDate':
          BookUserCreationDto._dateTimeToNullableJson(instance.finishDate),
      'personalRating': instance.personalRating,
      'isPrivate': instance.isPrivate,
      'shareProgress': instance.shareProgress,
      'lastUpdated': BookUserCreationDto._dateTimeToJson(instance.lastUpdated),
    };
