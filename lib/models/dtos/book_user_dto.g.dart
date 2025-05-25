// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_user_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

NoteDto _$NoteDtoFromJson(Map<String, dynamic> json) => NoteDto(
      page: (json['page'] as num).toInt(),
      text: json['text'] as String,
      createdAt: NoteDto._dateTimeFromJson(json['createdAt'] as String),
    );

Map<String, dynamic> _$NoteDtoToJson(NoteDto instance) => <String, dynamic>{
      'page': instance.page,
      'text': instance.text,
      'createdAt': NoteDto._dateTimeToJson(instance.createdAt),
    };

ReadingSessionDto _$ReadingSessionDtoFromJson(Map<String, dynamic> json) =>
    ReadingSessionDto(
      startDate: ReadingSessionDto._dateTimeFromNullableJson(
          json['startDate'] as String?),
      endDate: ReadingSessionDto._dateTimeFromNullableJson(
          json['endDate'] as String?),
    );

Map<String, dynamic> _$ReadingSessionDtoToJson(ReadingSessionDto instance) =>
    <String, dynamic>{
      'startDate':
          ReadingSessionDto._dateTimeToNullableJson(instance.startDate),
      'endDate': ReadingSessionDto._dateTimeToNullableJson(instance.endDate),
    };

ReviewDto _$ReviewDtoFromJson(Map<String, dynamic> json) => ReviewDto(
      reviewId: json['reviewId'] as String?,
      text: json['text'] as String,
      rating: (json['rating'] as num?)?.toInt() ?? 0,
      date: ReviewDto._dateTimeFromJson(json['date'] as String),
      title: json['title'] as String?,
      isPublic: json['isPublic'] as bool? ?? true,
      readingSession: json['readingSession'] == null
          ? null
          : ReadingSessionDto.fromJson(
              json['readingSession'] as Map<String, dynamic>),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );

Map<String, dynamic> _$ReviewDtoToJson(ReviewDto instance) => <String, dynamic>{
      'reviewId': instance.reviewId,
      'text': instance.text,
      'rating': instance.rating,
      'date': ReviewDto._dateTimeToJson(instance.date),
      'title': instance.title,
      'isPublic': instance.isPublic,
      'readingSession': instance.readingSession,
      'tags': instance.tags,
    };

ReadingGoalDto _$ReadingGoalDtoFromJson(Map<String, dynamic> json) =>
    ReadingGoalDto(
      pagesPerDay: (json['pagesPerDay'] as num?)?.toInt(),
      targetFinishDate: ReadingGoalDto._dateTimeFromNullableJson(
          json['targetFinishDate'] as String?),
    );

Map<String, dynamic> _$ReadingGoalDtoToJson(ReadingGoalDto instance) =>
    <String, dynamic>{
      'pagesPerDay': instance.pagesPerDay,
      'targetFinishDate':
          ReadingGoalDto._dateTimeToNullableJson(instance.targetFinishDate),
    };

BookUserDto _$BookUserDtoFromJson(Map<String, dynamic> json) => BookUserDto(
      id: json['_id'] as String?,
      userId: json['userId'] as String,
      bookId: BookDto.fromJson(json['bookId'] as Map<String, dynamic>),
      status: json['status'] as String? ?? 'to-read',
      currentPage: (json['currentPage'] as num?)?.toInt() ?? 0,
      startDate:
          BookUserDto._dateTimeFromNullableJson(json['startDate'] as String?),
      finishDate:
          BookUserDto._dateTimeFromNullableJson(json['finishDate'] as String?),
      personalRating: (json['personalRating'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as List<dynamic>?)
          ?.map((e) => ReviewDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      notes: (json['notes'] as List<dynamic>?)
          ?.map((e) => NoteDto.fromJson(e as Map<String, dynamic>))
          .toList(),
      readingGoal: json['readingGoal'] == null
          ? null
          : ReadingGoalDto.fromJson(
              json['readingGoal'] as Map<String, dynamic>),
      isPrivate: json['isPrivate'] as bool? ?? false,
      shareProgress: json['shareProgress'] as bool? ?? true,
      lastUpdated: BookUserDto._dateTimeFromJson(json['lastUpdated'] as String),
    );

Map<String, dynamic> _$BookUserDtoToJson(BookUserDto instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'userId': instance.userId,
      'bookId': instance.bookId,
      'status': instance.status,
      'currentPage': instance.currentPage,
      'startDate': BookUserDto._dateTimeToNullableJson(instance.startDate),
      'finishDate': BookUserDto._dateTimeToNullableJson(instance.finishDate),
      'personalRating': instance.personalRating,
      'reviews': instance.reviews,
      'notes': instance.notes,
      'readingGoal': instance.readingGoal,
      'isPrivate': instance.isPrivate,
      'shareProgress': instance.shareProgress,
      'lastUpdated': BookUserDto._dateTimeToJson(instance.lastUpdated),
    };
