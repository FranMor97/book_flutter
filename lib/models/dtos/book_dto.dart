import 'package:json_annotation/json_annotation.dart';

import '../book.dart';

part 'book_dto.g.dart';

@JsonSerializable()
class BookDto {
  @JsonKey(name: '_id') // MongoDB uses _id by default
  final String? id;

  // Información básica del libro
  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'authors')
  final List<String> authors;

  @JsonKey(name: 'synopsis')
  final String? synopsis;

  // Información de la edición/versión específica
  @JsonKey(name: 'isbn')
  final String? isbn;

  @JsonKey(name: 'publisher')
  final String? publisher;

  @JsonKey(
      name: 'publicationDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? publicationDate;

  @JsonKey(name: 'edition')
  final String? edition;

  @JsonKey(name: 'language')
  final String language;

  @JsonKey(name: 'pageCount')
  final int? pageCount;

  // Información de categorización
  @JsonKey(name: 'genres')
  final List<String> genres;

  @JsonKey(name: 'tags')
  final List<String> tags;

  // Información multimedia
  @JsonKey(name: 'coverImage')
  final String? coverImage;

  // Metadatos y estadísticas
  @JsonKey(name: 'averageRating')
  final double averageRating;

  @JsonKey(name: 'totalRatings')
  final int totalRatings;

  @JsonKey(name: 'totalReviews')
  final int totalReviews;

  // Campos para tracking y administración
  @JsonKey(
      name: 'createdAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  @JsonKey(
      name: 'updatedAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime updatedAt;

  BookDto({
    this.id,
    required this.title,
    required this.authors,
    this.synopsis,
    this.isbn,
    this.publisher,
    this.publicationDate,
    this.edition,
    this.language = 'Español',
    this.pageCount,
    List<String>? genres,
    List<String>? tags,
    this.coverImage,
    this.averageRating = 0.0,
    this.totalRatings = 0,
    this.totalReviews = 0,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : this.genres = genres ?? [],
        this.tags = tags ?? [],
        this.createdAt = createdAt ?? DateTime.now(),
        this.updatedAt = updatedAt ?? DateTime.now();

  // From JSON
  factory BookDto.fromJson(Map<String, dynamic> json) =>
      _$BookDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$BookDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();

  // Convert DTO to domain Book
  Book toBook() {
    return Book(
      id: id,
      title: title,
      authors: authors,
      synopsis: synopsis,
      isbn: isbn,
      publisher: publisher,
      publicationDate: publicationDate,
      edition: edition,
      language: language,
      pageCount: pageCount,
      genres: genres,
      tags: tags,
      coverImage: coverImage,
      averageRating: averageRating,
      totalRatings: totalRatings,
      totalReviews: totalReviews,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Factory para crear un nuevo libro
  factory BookDto.forCreation({
    required String title,
    required List<String> authors,
    String? synopsis,
    String? isbn,
    String? publisher,
    DateTime? publicationDate,
    String? edition,
    String language = 'Español',
    int? pageCount,
    List<String>? genres,
    List<String>? tags,
    String? coverImage,
  }) {
    return BookDto(
      title: title,
      authors: authors,
      synopsis: synopsis,
      isbn: isbn,
      publisher: publisher,
      publicationDate: publicationDate,
      edition: edition,
      language: language,
      pageCount: pageCount,
      genres: genres,
      tags: tags,
      coverImage: coverImage,
    );
  }

  // Método para convertir a JSON para crear un nuevo libro
  Map<String, dynamic> toJsonForCreation() {
    final json = toJson();
    json.remove('_id'); // Elimina el ID ya que MongoDB lo generará
    json.remove('createdAt'); // Se generará en el servidor
    json.remove('updatedAt'); // Se generará en el servidor
    json.remove('averageRating'); // Se inicializará con valores por defecto
    json.remove('totalRatings'); // Se inicializará con valores por defecto
    json.remove('totalReviews'); // Se inicializará con valores por defecto
    return json;
  }
}
