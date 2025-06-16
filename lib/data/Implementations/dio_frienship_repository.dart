// lib/data/implementations/dio_friendship_repository.dart
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/models/dtos/friendship_dto.dart';
import 'package:book_app_f/models/friendship.dart';
import 'package:book_app_f/models/user.dart';
import 'package:book_app_f/models/user_with_friendship.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/dtos/user_dto.dart';

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
  Future<List<UserWithFriendshipId>> getFriendRequests() async {
    try {
      final response =
          await _dio.get('$_baseUrl$_friendshipsEndpoint/requests');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> requestsData = responseData['data'];

          return requestsData.map((item) {
            final itemMap = _ensureMapResponse(item);
            return UserWithFriendshipId.fromJson(itemMap);
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
  // @override
  // Future<List<Friendship>> getFriendRequests() async {
  //   try {
  //     final response =
  //         await _dio.get('$_baseUrl$_friendshipsEndpoint/requests');
  //
  //     if (response.statusCode == 200 && response.data != null) {
  //       final responseData = _ensureMapResponse(response.data);
  //
  //       if (responseData.containsKey('data') && responseData['data'] is List) {
  //         final List<dynamic> requestsData = responseData['data'];
  //
  //         // Convertir a FriendshipDto y luego a Friendship
  //         final requests = requestsData.map((item) {
  //           final itemMap = _ensureMapResponse(item);
  //
  //           // Manejo especial para campos anidados
  //           try {
  //             return FriendshipDto.fromJson(itemMap).toDomain();
  //           } catch (e) {
  //             print('Error al convertir friendshipDto: $e');
  //             print('Item problemático: $itemMap');
  //
  //             // Intenta una conversión manual con manejo de errores
  //             return _convertToFriendship(itemMap);
  //           }
  //         }).toList();
  //
  //         return requests.where((f) => f != null).cast<Friendship>().toList();
  //       }
  //     }
  //
  //     return [];
  //   } on DioException catch (e) {
  //     throw _handleDioException(e);
  //   } catch (e) {
  //     throw Exception(
  //         'Error al obtener solicitudes de amistad: ${e.toString()}');
  //   }
  // }

  // Método auxiliar para convertir manualmente un map a Friendship
  Friendship? _convertToFriendship(Map<String, dynamic> data) {
    try {
      // Extraer IDs de manera segura
      String requesterId = '';
      if (data['requesterId'] is String) {
        requesterId = data['requesterId'];
      } else if (data['requesterId'] is Map) {
        final requesterMap =
            Map<String, dynamic>.from(data['requesterId'] as Map);
        requesterId = requesterMap['_id']?.toString() ??
            requesterMap['id']?.toString() ??
            '';
      }

      String recipientId = '';
      if (data['recipientId'] is String) {
        recipientId = data['recipientId'];
      } else if (data['recipientId'] is Map) {
        final recipientMap =
            Map<String, dynamic>.from(data['recipientId'] as Map);
        recipientId = recipientMap['_id']?.toString() ??
            recipientMap['id']?.toString() ??
            '';
      }

      // Extraer requester/recipient como User si están disponibles
      User? requester;
      if (data['requester'] is Map) {
        try {
          requester = User.fromJson(_normalizeUserData(data['requester']));
        } catch (e) {
          print('Error al convertir requester: $e');
        }
      }

      User? recipient;
      if (data['recipient'] is Map) {
        try {
          recipient = User.fromJson(_normalizeUserData(data['recipient']));
        } catch (e) {
          print('Error al convertir recipient: $e');
        }
      }

      // Crear Friendship con los datos disponibles
      return Friendship(
        id: data['_id']?.toString() ?? data['id']?.toString() ?? '',
        requesterId: requesterId,
        recipientId: recipientId,
        status:
            _stringToFriendshipStatus(data['status']?.toString() ?? 'pending'),
        createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
        updatedAt: _parseDateTime(data['updatedAt']) ?? DateTime.now(),
        requester: requester,
        recipient: recipient,
      );
    } catch (e) {
      print('Error en conversión manual de Friendship: $e');
      return null;
    }
  }

  // Convierte string a FriendshipStatus
  FriendshipStatus _stringToFriendshipStatus(String status) {
    switch (status) {
      case 'pending':
        return FriendshipStatus.pending;
      case 'accepted':
        return FriendshipStatus.accepted;
      case 'rejected':
        return FriendshipStatus.rejected;
      case 'blocked':
        return FriendshipStatus.blocked;
      default:
        return FriendshipStatus.pending;
    }
  }

  // Parsea DateTime de manera segura
  DateTime? _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return null;

    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        return null;
      }
    }

    return null;
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
    try {
      if (data is Map<String, dynamic>) {
        return data;
      } else if (data is Map) {
        return Map<String, dynamic>.from(data);
      } else {
        print(
            'Error: Formato de respuesta inesperado. Tipo: ${data.runtimeType}');
        print('Contenido: $data');
        throw Exception('Formato de respuesta inesperado: $data');
      }
    } catch (e) {
      print('Error al convertir respuesta a Map: $e');
      return {}; // Devolver un mapa vacío en caso de error
    }
  }

  // Método para normalizar los datos de usuario
  Map<String, dynamic> _normalizeUserData(dynamic userData) {
    try {
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
    } catch (e) {
      print('Error al normalizar usuario: $e');
      // Devolver un usuario mínimo válido en caso de error
      return {
        'id': '',
        'firstName': 'Usuario',
        'lastName1': 'Desconocido',
        'lastName2': '',
        'email': '',
        'avatar': '',
      };
    }
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

    print(
        'Error en petición HTTP (${e.requestOptions.method} ${e.requestOptions.path}): [$statusCode] $errorMessage');

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
