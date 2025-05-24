import 'package:book_app_f/data/repositories/book_repository.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../models/dtos/book_dto.dart';

@LazySingleton(as: IBookRepository, env: [Environment.dev, Environment.prod])
class DioBookRepository implements IBookRepository {
  final Dio _dio;
  final String _baseUrl;
  static const String _booksEndpoint = '/books';

  DioBookRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  @override
  Future<BookListResponse> getAllBooks({
    int page = 1,
    int limit = 10,
    String? title,
    String? author,
    String? genre,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (title != null && title.isNotEmpty) {
        queryParams['title'] = title;
      }
      if (author != null && author.isNotEmpty) {
        queryParams['author'] = author;
      }
      if (genre != null && genre.isNotEmpty) {
        queryParams['genre'] = genre;
      }

      final response = await _dio.get(
        '$_baseUrl$_booksEndpoint',
        queryParameters: queryParams,
      );

      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener libros: ${e.toString()}');
    }
  }

  @override
  Future<BookDto?> getBookById(String bookId) async {
    try {
      final response = await _dio.get('$_baseUrl$_booksEndpoint/$bookId');

      if (response.statusCode == 200 && response.data != null) {
        return BookDto.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener libro: ${e.toString()}');
    }
  }

  @override
  Future<BookListResponse> searchBooks({
    required String query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_booksEndpoint/search',
        queryParameters: {
          'q': query,
          'page': page,
          'limit': limit,
        },
      );

      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al buscar libros: ${e.toString()}');
    }
  }

  @override
  Future<BookListResponse> getBooksByGenre({
    required String genre,
    int page = 1,
    int limit = 10,
  }) async {
    return getAllBooks(
      genre: genre,
      page: page,
      limit: limit,
    );
  }

  @override
  Future<BookListResponse> getPopularBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_booksEndpoint/popular',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener libros populares: ${e.toString()}');
    }
  }

  @override
  Future<BookListResponse> getTopRatedBooks({
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_booksEndpoint/top-rated',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      return BookListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception(
          'Error al obtener libros mejor valorados: ${e.toString()}');
    }
  }

  @override
  Future<BookDto> createBook(BookDto bookDto) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_booksEndpoint',
        data: bookDto.toJsonForCreation(),
      );

      return BookDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al crear libro: ${e.toString()}');
    }
  }

  @override
  Future<BookDto> updateBook(String bookId, BookDto bookDto) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl$_booksEndpoint/$bookId',
        data: bookDto.toJson(),
      );

      return BookDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al actualizar libro: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteBook(String bookId) async {
    try {
      await _dio.delete('$_baseUrl$_booksEndpoint/$bookId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al eliminar libro: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAvailableGenres() async {
    try {
      final response = await _dio.get('$_baseUrl$_booksEndpoint/genres');
      return List<String>.from(response.data['genres'] ?? []);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener géneros: ${e.toString()}');
    }
  }

  @override
  Future<List<String>> getAvailableAuthors() async {
    try {
      final response = await _dio.get('$_baseUrl$_booksEndpoint/authors');
      return List<String>.from(response.data['authors'] ?? []);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener autores: ${e.toString()}');
    }
  }

  /// Maneja las excepciones de Dio y las convierte en excepciones específicas
  Exception _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data['error'] ?? 'Error desconocido';

    switch (statusCode) {
      case 400:
        return Exception('Solicitud inválida: $errorMessage');
      case 401:
        return Exception('No autorizado: $errorMessage');
      case 403:
        return Exception('Acceso prohibido: $errorMessage');
      case 404:
        return Exception('No encontrado: $errorMessage');
      case 500:
        return Exception('Error del servidor: $errorMessage');
      default:
        return Exception('Error de conexión: ${e.message}');
    }
  }
}
