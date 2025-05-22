// lib/data/implementations/dio_book_user_repository.dart
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../models/dtos/book_user_dto.dart';
import '../repositories/book_user_repository.dart';

@LazySingleton(
    as: IBookUserRepository, env: [Environment.dev, Environment.prod])
class DioBookUserRepository implements IBookUserRepository {
  final Dio _dio;
  final String _baseUrl;
  static const String _bookUsersEndpoint = '/book-users';

  DioBookUserRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  @override
  Future<BookUserListResponse> getUserBooks({
    required String userId,
    String? status,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'userId': userId,
        'page': page,
        'limit': limit,
      };

      if (status != null && status.isNotEmpty) {
        queryParams['status'] = status;
      }

      final response = await _dio.get(
        '$_baseUrl$_bookUsersEndpoint',
        queryParameters: queryParams,
      );

      return BookUserListResponse.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener libros del usuario: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto?> getUserBook({
    required String userId,
    required String bookId,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_bookUsersEndpoint/user/$userId/book/$bookId',
      );

      if (response.statusCode == 200 && response.data != null) {
        return BookUserDto.fromJson(response.data);
      }
      return null;
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        return null;
      }
      throw _handleDioException(e);
    } catch (e) {
      throw Exception(
          'Error al obtener relación usuario-libro: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto> addBookToUser({
    required String userId,
    required String bookId,
    String status = 'to-read',
  }) async {
    try {
      final bookUserDto = BookUserDto.forNewReading(
        userId: userId,
        bookId: bookId,
        status: status,
      );

      final response = await _dio.post(
        '$_baseUrl$_bookUsersEndpoint',
        data: bookUserDto.toJsonForCreation(),
      );

      return BookUserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al agregar libro al usuario: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto> updateReadingProgress({
    required String id,
    int? currentPage,
    String? status,
    DateTime? finishDate,
  }) async {
    try {
      final updateData = <String, dynamic>{};

      if (currentPage != null) {
        updateData['currentPage'] = currentPage;
      }
      if (status != null) {
        updateData['status'] = status;

        // Si el estado es "reading" y no hay fecha de inicio, establecerla
        if (status == 'reading') {
          updateData['startDate'] = DateTime.now().toIso8601String();
        }

        // Si el estado es "completed", establecer fecha de finalización
        if (status == 'completed') {
          updateData['finishDate'] =
              (finishDate ?? DateTime.now()).toIso8601String();
        }
      }
      if (finishDate != null) {
        updateData['finishDate'] = finishDate.toIso8601String();
      }

      final response = await _dio.patch(
        '$_baseUrl$_bookUsersEndpoint/$id',
        data: updateData,
      );

      return BookUserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al actualizar progreso: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto> addReview({
    required String id,
    required ReviewDto review,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_bookUsersEndpoint/$id/reviews',
        data: review.toJson(),
      );

      return BookUserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al agregar reseña: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto> addNote({
    required String id,
    required NoteDto note,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_bookUsersEndpoint/$id/notes',
        data: note.toJson(),
      );

      return BookUserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al agregar nota: ${e.toString()}');
    }
  }

  @override
  Future<BookUserDto> setReadingGoal({
    required String id,
    required ReadingGoalDto goal,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl$_bookUsersEndpoint/$id/goal',
        data: {'readingGoal': goal.toJson()},
      );

      return BookUserDto.fromJson(response.data['data']);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al establecer objetivo: ${e.toString()}');
    }
  }

  @override
  Future<void> removeBookFromUser(String id) async {
    try {
      await _dio.delete('$_baseUrl$_bookUsersEndpoint/$id');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al eliminar libro del usuario: ${e.toString()}');
    }
  }

  @override
  Future<UserReadingStats> getUserReadingStats(String userId) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_bookUsersEndpoint/user/$userId/stats',
      );

      return UserReadingStats.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener estadísticas: ${e.toString()}');
    }
  }

  /// Maneja las excepciones de Dio
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
      case 409:
        return Exception('Conflicto: $errorMessage');
      case 500:
        return Exception('Error del servidor: $errorMessage');
      default:
        return Exception('Error de conexión: ${e.message}');
    }
  }
}
