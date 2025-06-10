import 'dart:convert';

import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../models/comments_group.dart';

@LazySingleton(
    as: IReadingGroupRepository, env: [Environment.dev, Environment.prod])
class DioReadingGroupRepository implements IReadingGroupRepository {
  final Dio _dio;
  final String _baseUrl;
  static const String _groupsEndpoint = '/reading-groups';

  DioReadingGroupRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
  })  : _dio = dio,
        _baseUrl = baseUrl;

  @override
  Future<List<ReadingGroup>> getUserGroups() async {
    try {
      final response = await _dio.get('$_baseUrl$_groupsEndpoint');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> groupsData = responseData['data'];
          return groupsData.map((json) => ReadingGroup.fromJson(json)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener grupos de usuario: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> getGroupById(String groupId) async {
    try {
      final response = await _dio.get('$_baseUrl$_groupsEndpoint/$groupId');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);
        return ReadingGroup.fromJson(responseData);
      }

      throw Exception('Error al cargar el grupo');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener grupo: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> createGroup({
    required String name,
    String? description,
    required String bookId,
    bool isPrivate = false,
    ReadingGoal? readingGoal,
  }) async {
    try {
      final data = {
        'name': name,
        'description': description,
        'bookId': bookId,
        'isPrivate': isPrivate,
        'readingGoal': readingGoal?.toJson(),
      };

      final response = await _dio.post(
        '$_baseUrl$_groupsEndpoint',
        data: data,
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return ReadingGroup.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al crear grupo');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al crear grupo: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> updateGroup({
    required String groupId,
    String? name,
    String? description,
    bool? isPrivate,
    ReadingGoal? readingGoal,
  }) async {
    try {
      final Map<String, dynamic> updateData = {};
      if (name != null) updateData['name'] = name;
      if (description != null) updateData['description'] = description;
      if (isPrivate != null) updateData['isPrivate'] = isPrivate;
      if (readingGoal != null) updateData['readingGoal'] = readingGoal.toJson();

      final response = await _dio.patch(
        '$_baseUrl$_groupsEndpoint/$groupId',
        data: updateData,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return ReadingGroup.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al actualizar grupo');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al actualizar grupo: ${e.toString()}');
    }
  }

  @override
  Future<List<ReadingGroup>> searchPublicGroups({
    String? query,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'page': page,
        'limit': limit,
      };

      if (query != null && query.isNotEmpty) {
        queryParams['q'] = query;
      }

      final response = await _dio.get(
        '$_baseUrl$_groupsEndpoint/public',
        queryParameters: queryParams,
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> groupsData = responseData['data'];
          return groupsData.map((json) => ReadingGroup.fromJson(json)).toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al buscar grupos: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> joinGroup(String groupId) async {
    try {
      final response =
          await _dio.post('$_baseUrl$_groupsEndpoint/$groupId/join');

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return ReadingGroup.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al unirse al grupo');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al unirse al grupo: ${e.toString()}');
    }
  }

  @override
  Future<void> leaveGroup(String groupId) async {
    try {
      await _dio.delete('$_baseUrl$_groupsEndpoint/$groupId/leave');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al abandonar grupo: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> manageMember({
    required String groupId,
    required String memberId,
    required String action,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl$_groupsEndpoint/$groupId/members/$memberId',
        data: {'action': action},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return ReadingGroup.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al gestionar miembro');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al gestionar miembro: ${e.toString()}');
    }
  }

  @override
  Future<ReadingGroup> updateReadingProgress({
    required String groupId,
    required int currentPage,
  }) async {
    try {
      final response = await _dio.patch(
        '$_baseUrl$_groupsEndpoint/$groupId/progress',
        data: {'currentPage': currentPage},
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return ReadingGroup.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al actualizar progreso');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al actualizar progreso: ${e.toString()}');
    }
  }

  @override
  Future<List<GroupMessage>> getGroupMessages({
    required String groupId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final response = await _dio.get(
        '$_baseUrl$_groupsEndpoint/$groupId/messages',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data') && responseData['data'] is List) {
          final List<dynamic> messagesData = responseData['data'];
          return messagesData
              .map((json) => GroupMessage.fromJson(json))
              .toList();
        }
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al obtener mensajes: ${e.toString()}');
    }
  }

  @override
  Future<GroupMessage> sendGroupMessage({
    required String groupId,
    required String text,
  }) async {
    try {
      final response = await _dio.post(
        '$_baseUrl$_groupsEndpoint/$groupId/messages',
        data: {'text': text},
      );

      if (response.statusCode == 201 && response.data != null) {
        final responseData = _ensureMapResponse(response.data);

        if (responseData.containsKey('data')) {
          return GroupMessage.fromJson(responseData['data']);
        }
      }

      throw Exception('Error al enviar mensaje');
    } on DioException catch (e) {
      throw _handleDioException(e);
    } catch (e) {
      throw Exception('Error al enviar mensaje: ${e.toString()}');
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
