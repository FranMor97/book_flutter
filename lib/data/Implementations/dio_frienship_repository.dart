// lib/data/implementations/dio_friendship_repository.dart
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/models/dtos/friendship_dto.dart';
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
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> friendsData = responseData['data'];
          return friendsData
              .map((item) => User.fromJson(_normalizeUserData(item)))
              .toList();
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
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> requestsData = responseData['data'];

          // Convertir a FriendshipDto y luego a Friendship
          return requestsData.map((item) {
            final itemMap = _ensureMapResponse(item);

            // Si hay campo requesterId y es un objeto, normalizarlo
            if (itemMap.containsKey('requesterId') &&
                itemMap['requesterId'] is Map) {
              final requesterMap = _ensureMapResponse(itemMap['requesterId']);
              itemMap['requester'] = requesterMap;
            }

            return FriendshipDto.fromJson(itemMap).toDomain();
          }).toList();
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
  Future<List<UserFriendshipStatus>> searchUsers(String query) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_friendshipsEndpoint/search-users',
        queryParameters: {'q': query},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> usersData = responseData['data'];

          return usersData.map((item) {
            final itemMap = _ensureMapResponse(item);
            return UserFriendshipStatus.fromJson(itemMap);
          }).toList();
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
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          final friendshipData = _ensureMapResponse(responseData['data']);
          return FriendshipDto.fromJson(friendshipData).toDomain();
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
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          final friendshipData = _ensureMapResponse(responseData['data']);
          return FriendshipDto.fromJson(friendshipData).toDomain();
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

  // Método para asegurar que las respuestas sean Map<String, dynamic>
  Map<String, dynamic> _ensureMapResponse(dynamic data) {
    if (data is Map<String, dynamic>) {
      return data;
    } else if (data is Map) {
      return Map<String, dynamic>.from(data);
    } else {
      throw Exception('Formato de respuesta inesperado: $data');
    }
  }

  // Método para normalizar los datos de usuario
  Map<String, dynamic> _normalizeUserData(dynamic userData) {
    final Map<String, dynamic> normalizedUser = _ensureMapResponse(userData);

    // Convertir _id a id si existe
    if (normalizedUser.containsKey('_id') &&
        !normalizedUser.containsKey('id')) {
      normalizedUser['id'] = normalizedUser['_id'];
    }

    // Asegurar campos requeridos con valores por defecto
    normalizedUser['firstName'] = normalizedUser['firstName'] ?? '';
    normalizedUser['lastName1'] = normalizedUser['lastName1'] ?? '';
    normalizedUser['lastName2'] = normalizedUser['lastName2'] ?? '';
    normalizedUser['email'] = normalizedUser['email'] ?? '';
    normalizedUser['avatar'] = normalizedUser['avatar'] ?? '';

    return normalizedUser;
  }

  Exception _handleDioException(DioException e) {
    final statusCode = e.response?.statusCode;
    String errorMessage = 'Error desconocido';

    try {
      // Intentar extraer el mensaje de error de la respuesta
      if (e.response?.data is Map) {
        errorMessage = e.response?.data['error'] ?? 'Error desconocido';
      } else if (e.response?.data is String) {
        errorMessage = e.response?.data;
      } else {
        errorMessage = e.message ?? 'Error desconocido';
      }
    } catch (_) {
      errorMessage = e.message ?? 'Error desconocido';
    }

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
        return Exception('Error de conexión: $errorMessage');
    }
  }
}
