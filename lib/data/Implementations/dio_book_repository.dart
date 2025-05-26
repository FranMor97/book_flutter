import 'package:book_app_f/data/repositories/book_repository.dart';
import 'package:book_app_f/models/book_comments.dart';
import 'package:book_app_f/models/comment_user.dart';
import 'package:book_app_f/models/user.dart';
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
      print('📤 SOLICITANDO LIBRO POR ID: $bookId');
      final response = await _dio.get('$_baseUrl$_booksEndpoint/$bookId');

      print('📥 RESPUESTA RECIBIDA [STATUS: ${response.statusCode}]');
      print('📥 TIPO DE RESPONSE.DATA: ${response.data.runtimeType}');

      if (response.statusCode == 200 && response.data != null) {
        // Verificar el tipo de respuesta y procesar adecuadamente
        try {
          if (response.data is Map) {
            print('📥 PROCESANDO RESPONSE.DATA COMO MAP');

            // Asegurarse de que estamos tratando con un Map<String, dynamic>
            final Map<String, dynamic> bookData = {};

            // Convertir manualmente los campos que necesitamos
            (response.data as Map).forEach((key, value) {
              if (value is Map) {
                // Para campos anidados, convertirlos a Map<String, dynamic>
                bookData[key.toString()] = Map<String, dynamic>.from(value);
              } else if (value is List) {
                // Para listas, asegurarse de que son List<dynamic>
                bookData[key.toString()] = List<dynamic>.from(value);
              } else {
                // Para tipos simples, usarlos directamente
                bookData[key.toString()] = value;
              }
            });

            print('📥 MAPA PROCESADO: ${bookData.keys}');
            return BookDto.fromJson(bookData);
          } else {
            print('📥 ERROR: RESPONSE.DATA NO ES UN MAP');
            throw Exception('El formato de respuesta no es un Map');
          }
        } catch (e) {
          print('📥 ERROR AL PROCESAR RESPONSE.DATA: $e');
          throw Exception('Error al procesar datos del libro: $e');
        }
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      print('📥 ERROR DIO: ${e.message}');
      print('📥 RESPONSE: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      print('📥 ERROR GENERAL: $e');
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

// lib/data/Implementations/dio_book_repository.dart
// lib/data/Implementations/dio_book_repository.dart
  @override
  Future<List<BookComment>> getBookComments(
      String bookId, String userId) async {
    try {
      final response =
          await _dio.get('$_baseUrl$_booksEndpoint/$bookId/comments');

      if (response.statusCode == 200 && response.data != null) {
        final Map<String, dynamic> responseData =
            response.data is Map<String, dynamic>
                ? response.data
                : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> commentsData = responseData['data'];

          return commentsData.map((item) {
            // Convertir item a Map<String, dynamic> si no lo es
            final Map<String, dynamic> commentMap = item is Map<String, dynamic>
                ? item
                : Map<String, dynamic>.from(item);

            // Manejar el objeto usuario
            Map<String, dynamic> userMap;
            if (commentMap['user'] != null && commentMap['user'] is Map) {
              userMap = Map<String, dynamic>.from(commentMap['user']);
            } else {
              userMap = {
                'id': 'unknown',
                'firstName': 'Usuario',
                'lastName1': 'Anónimo',
                'avatar': null
              };
            }

            return BookComment(
              id: commentMap['id']?.toString() ?? 'unknown',
              text: commentMap['text']?.toString() ?? '',
              rating: commentMap['rating'] is num
                  ? commentMap['rating'].toInt()
                  : 0,
              date: commentMap['date'] != null
                  ? DateTime.parse(commentMap['date'].toString())
                  : DateTime.now(),
              title: commentMap['title']?.toString(),
              user: CommentUser.fromJson(userMap),
              isOwnComment: userId != null && userMap['id'] == userId,
            );
          }).toList();
        }
      }
      print('📥 NO SE ENCONTRARON COMENTARIOS O FORMATO INCORRECTO');
      return [];
    } on DioException catch (e) {
      print('Error DIO al obtener comentarios: ${e.message}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      print('Error general al obtener comentarios: $e');
      throw Exception('Error al obtener comentarios: ${e.toString()}');
    }
  }

  // lib/data/Implementations/dio_book_repository.dart
  @override
  Future<BookComment> addBookComment({
    required String bookId,
    required String text,
    required int rating,
    String? title,
    bool isPublic = true,
  }) async {
    try {
      print('📤 ENVIANDO VALORACIÓN PARA LIBRO: $bookId');

      final data = {
        'text': text,
        'rating': rating,
        'title': title,
        'isPublic': isPublic,
      };
      final url = '$_baseUrl$_booksEndpoint/$bookId/comments';
      final response = await _dio.post(
        '$_baseUrl$_booksEndpoint/$bookId/comments',
        data: data,
      );

      print('📥 RESPUESTA RECIBIDA [STATUS: ${response.statusCode}]');

      if (response.statusCode == 201 && response.data != null) {
        final commentData = response.data['data'];

        // Crear el objeto BookComment a partir de la respuesta
        final comment = BookComment(
          id: commentData['id'] ?? 'unknown',
          text: commentData['text'] ?? '',
          rating: commentData['rating'] ?? 0,
          date: commentData['date'] != null
              ? DateTime.parse(commentData['date'])
              : DateTime.now(),
          title: commentData['title'],
          user: CommentUser.fromJson(commentData['user']),
          isOwnComment: true, // Es del usuario actual
        );

        return comment;
      }

      throw Exception('Error al añadir valoración: respuesta inválida');
    } on DioException catch (e) {
      print('Error DIO al añadir valoración: ${e.message}');
      print('Status: ${e.response?.statusCode}');
      print('Response: ${e.response?.data}');
      throw _handleDioException(e);
    } catch (e) {
      print('Error general al añadir valoración: $e');
      throw Exception('Error al añadir valoración: ${e.toString()}');
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
