// lib/data/implementations/dio_friendship_repository.dart
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/models/friendship.dart';
import 'package:book_app_f/models/user.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(
    as: IFriendshipRepository, env: [Environment.dev, Environment.prod])
class DioFriendshipRepository implements IFriendshipRepository {
  final Dio _dio;
  final String _baseUrl;
  static const String _friendshipsEndpoint = '/friendships';

  DioFriendshipRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  @override
  Future<List<User>> getFriends() async {
    try {
      final response = await _dio.get('$_baseUrl$_friendshipsEndpoint/friends');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> friendsData = responseData['data'];
          return friendsData.map((item) => User.fromJson(item)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener amigos: ${e.toString()}');
    }
  }

  @override
  Future<List<Friendship>> getFriendRequests() async {
    try {
      final response =
          await _dio.get('$_baseUrl$_friendshipsEndpoint/requests');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> requestsData = responseData['data'];
          return requestsData.map((item) => Friendship.fromJson(item)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception(
          'Error al obtener solicitudes de amistad: ${e.toString()}');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_friendshipsEndpoint/search-users',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> usersData = responseData['data'];
          return usersData.map((item) => item as Map<String, dynamic>).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al buscar usuarios: ${e.toString()}');
    }
  }

  @override
  Future<Friendship> sendFriendRequest(String recipientId) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_friendshipsEndpoint/request',
        data: {'recipientId': recipientId},
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data')) {
          return Friendship.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al enviar solicitud de amistad');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al enviar solicitud de amistad: ${e.toString()}');
    }
  }

  @override
  Future<Friendship> respondToFriendRequest(
      String friendshipId, String status) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl$_friendshipsEndpoint/respond/$friendshipId',
        data: {'status': status},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = response.data is Map<String, dynamic>
            ? response.data
            : Map<String, dynamic>.from(response.data);

        if (responseData.containsKey('data')) {
          return Friendship.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al responder a solicitud de amistad');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al responder a solicitud: ${e.toString()}');
    }
  }

  @override
  Future<void> removeFriend(String friendshipId) async {
    try {
      await _dio.delete('$_baseUrl$_friendshipsEndpoint/$friendshipId');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al eliminar amistad: ${e.toString()}');
    }
  }

  Exception _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    final errorMessage = e.response?.data is Map
        ? e.response?.data['error'] ?? 'Error desconocido'
        : 'Error desconocido';

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
