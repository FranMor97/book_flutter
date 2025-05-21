// models/book.dart

import 'dtos/book_dto.dart';

class Book {
  final String? id;

  // Información básica del libro
  final String title;
  final List<String> authors;
  final String? synopsis;

  // Información de la edición/versión específica
  final String? isbn;
  final String? publisher;
  final DateTime? publicationDate;
  final String? edition;
  final String language;
  final int? pageCount;

  // Información de categorización
  final List<String> genres;
  final List<String> tags;

  // Información multimedia
  final String? coverImage;

  // Metadatos y estadísticas
  final double averageRating;
  final int totalRatings;
  final int totalReviews;

  // Campos para tracking y administración
  final DateTime createdAt;
  final DateTime updatedAt;

  Book({
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
  })  : genres = genres ?? [],
        tags = tags ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  // Factory para crear desde BookDto
  factory Book.fromDto(BookDto dto) {
    return Book(
      id: dto.id,
      title: dto.title,
      authors: dto.authors,
      synopsis: dto.synopsis,
      isbn: dto.isbn,
      publisher: dto.publisher,
      publicationDate: dto.publicationDate,
      edition: dto.edition,
      language: dto.language,
      pageCount: dto.pageCount,
      genres: dto.genres,
      tags: dto.tags,
      coverImage: dto.coverImage,
      averageRating: dto.averageRating,
      totalRatings: dto.totalRatings,
      totalReviews: dto.totalReviews,
      createdAt: dto.createdAt,
      updatedAt: dto.updatedAt,
    );
  }
}
