// lib/data/repositories/book_user_repository.dart
import '../../models/dtos/book_user_dto.dart';

/// Repositorio abstracto para gestionar la relación usuario-libro
abstract class IBookUserRepository {
  /// Obtiene todos los libros de un usuario con filtros opcionales
  Future<BookUserListResponse> getUserBooks({
    required String userId,
    String? status, // 'to-read', 'reading', 'completed', 'abandoned'
    int page = 1,
    int limit = 10,
  });

  /// Obtiene una relación específica usuario-libro
  Future<BookUserDto?> getUserBook({
    required String userId,
    required String bookId,
  });

  /// Agrega un libro a la lista del usuario
  Future<BookUserDto> addBookToUser({
    required String userId,
    required String bookId,
    String status = 'to-read',
  });

  /// Actualiza el progreso de lectura de un libro
  Future<BookUserDto> updateReadingProgress({
    required String id,
    int? currentPage,
    String? status,
    DateTime? finishDate,
  });

  /// Agrega una reseña a un libro
  Future<BookUserDto> addReview({
    required String id,
    required ReviewDto review,
  });

  /// Agrega una nota a un libro
  Future<BookUserDto> addNote({
    required String id,
    required NoteDto note,
  });

  /// Establece un objetivo de lectura
  Future<BookUserDto> setReadingGoal({
    required String id,
    required ReadingGoalDto goal,
  });

  /// Elimina la relación usuario-libro
  Future<void> removeBookFromUser(String id);

  /// Obtiene estadísticas de lectura del usuario
  Future<UserReadingStats> getUserReadingStats(String userId);
}

/// Respuesta con lista de relaciones usuario-libro
class BookUserListResponse {
  final List<BookUserDto> bookUsers;
  final BookUserListMeta meta;

  BookUserListResponse({
    required this.bookUsers,
    required this.meta,
  });

  factory BookUserListResponse.fromJson(Map<String, dynamic> json) {
    return BookUserListResponse(
      bookUsers: (json['data'] as List)
          .map((item) => BookUserDto.fromJson(item))
          .toList(),
      meta: BookUserListMeta.fromJson(json['meta']),
    );
  }
}

/// Metadatos de paginación
class BookUserListMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  BookUserListMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory BookUserListMeta.fromJson(Map<String, dynamic> json) {
    return BookUserListMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 0,
    );
  }
}

/// Estadísticas de lectura del usuario
class UserReadingStats {
  final int totalBooks;
  final int booksRead;
  final int booksReading;
  final int booksToRead;
  final int totalPagesRead;
  final double averageRating;
  final int totalReviews;

  UserReadingStats({
    required this.totalBooks,
    required this.booksRead,
    required this.booksReading,
    required this.booksToRead,
    required this.totalPagesRead,
    required this.averageRating,
    required this.totalReviews,
  });

  factory UserReadingStats.fromJson(Map<String, dynamic> json) {
    return UserReadingStats(
      totalBooks: json['totalBooks'] ?? 0,
      booksRead: json['booksRead'] ?? 0,
      booksReading: json['booksReading'] ?? 0,
      booksToRead: json['booksToRead'] ?? 0,
      totalPagesRead: json['totalPagesRead'] ?? 0,
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
    );
  }
}
