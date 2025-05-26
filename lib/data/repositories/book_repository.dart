// lib/data/repositories/book_repository.dart
import 'package:book_app_f/models/book_comments.dart';

import '../../models/dtos/book_dto.dart';

/// Repositorio abstracto para gestionar libros
abstract class IBookRepository {
  /// Obtiene todos los libros con paginación y filtros opcionales
  ///
  /// [page] - Número de página (por defecto 1)
  /// [limit] - Límite de libros por página (por defecto 10)
  /// [title] - Filtro por título (opcional)
  /// [author] - Filtro por autor (opcional)
  /// [genre] - Filtro por género (opcional)
  Future<BookListResponse> getAllBooks({
    int page = 1,
    int limit = 10,
    String? title,
    String? author,
    String? genre,
  });

  /// Obtiene un libro específico por su ID
  ///
  /// Retorna null si no se encuentra el libro
  Future<BookDto?> getBookById(String bookId);

  /// Busca libros por texto libre
  ///
  /// Busca en título, autores y descripción
  Future<BookListResponse> searchBooks({
    required String query,
    int page = 1,
    int limit = 10,
  });

  /// Obtiene libros por género específico
  Future<BookListResponse> getBooksByGenre({
    required String genre,
    int page = 1,
    int limit = 10,
  });

  /// Obtiene los libros más leídos/populares
  Future<BookListResponse> getPopularBooks({
    int page = 1,
    int limit = 10,
  });

  /// Obtiene libros mejor valorados
  Future<BookListResponse> getTopRatedBooks({
    int page = 1,
    int limit = 10,
  });

  /// Crea un nuevo libro (solo para administradores)
  Future<BookDto> createBook(BookDto bookDto);

  /// Actualiza un libro existente (solo para administradores)
  Future<BookDto> updateBook(String bookId, BookDto bookDto);

  /// Elimina un libro (solo para administradores)
  Future<void> deleteBook(String bookId);

  /// Obtiene géneros disponibles
  Future<List<String>> getAvailableGenres();

  /// Obtiene autores disponibles
  Future<List<String>> getAvailableAuthors();

  // En la interfaz IBookRepository
  Future<List<BookComment>> getBookComments(String bookId, String userId);

  Future<BookComment> addBookComment({
    required String bookId,
    required String text,
    required int rating,
    String? title,
    bool isPublic = true,
  });
}

/// Respuesta que contiene una lista de libros con metadatos de paginación
class BookListResponse {
  final List<BookDto> books;
  final BookListMeta meta;

  BookListResponse({
    required this.books,
    required this.meta,
  });

  factory BookListResponse.fromJson(Map<String, dynamic> json) {
    return BookListResponse(
      books:
          (json['data'] as List).map((book) => BookDto.fromJson(book)).toList(),
      meta: BookListMeta.fromJson(json['meta']),
    );
  }
}

class BookListMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  BookListMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory BookListMeta.fromJson(Map<String, dynamic> json) {
    return BookListMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 0,
    );
  }
}
