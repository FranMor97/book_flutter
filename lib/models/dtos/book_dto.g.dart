// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'book_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BookDto _$BookDtoFromJson(Map<String, dynamic> json) => BookDto(
      id: json['_id'] as String?,
      title: json['title'] as String,
      authors:
          (json['authors'] as List<dynamic>).map((e) => e as String).toList(),
      synopsis: json['synopsis'] as String?,
      isbn: json['isbn'] as String?,
      publisher: json['publisher'] as String?,
      publicationDate:
          BookDto._dateTimeFromNullableJson(json['publicationDate'] as String?),
      edition: json['edition'] as String?,
      language: json['language'] as String? ?? 'Español',
      pageCount: (json['pageCount'] as num?)?.toInt(),
      genres:
          (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      coverImage: json['coverImage'] as String?,
      averageRating: (json['averageRating'] as num?)?.toDouble() ?? 0.0,
      totalRatings: (json['totalRatings'] as num?)?.toInt() ?? 0,
      totalReviews: (json['totalReviews'] as num?)?.toInt() ?? 0,
      createdAt: BookDto._dateTimeFromJson(json['createdAt'] as String),
      updatedAt: BookDto._dateTimeFromJson(json['updatedAt'] as String),
    );

Map<String, dynamic> _$BookDtoToJson(BookDto instance) => <String, dynamic>{
      '_id': instance.id,
      'title': instance.title,
      'authors': instance.authors,
      'synopsis': instance.synopsis,
      'isbn': instance.isbn,
      'publisher': instance.publisher,
      'publicationDate':
          BookDto._dateTimeToNullableJson(instance.publicationDate),
      'edition': instance.edition,
      'language': instance.language,
      'pageCount': instance.pageCount,
      'genres': instance.genres,
      'tags': instance.tags,
      'coverImage': instance.coverImage,
      'averageRating': instance.averageRating,
      'totalRatings': instance.totalRatings,
      'totalReviews': instance.totalReviews,
      'createdAt': BookDto._dateTimeToJson(instance.createdAt),
      'updatedAt': BookDto._dateTimeToJson(instance.updatedAt),
    };
