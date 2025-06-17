import 'dart:convert';
import 'dart:io';
import 'package:book_app_f/data/repositories/user_repository.dart';
import 'package:book_app_f/models/dtos/user_dto.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../models/cache_manager.dart';

/// Implementación del repositorio de usuarios con API + caché local
@LazySingleton(as: IUserRepository, env: [Environment.dev, Environment.prod])
class ApiUserRepository implements IUserRepository {
  final Dio _dio;
  final String _baseUrl;
  final SharedPreferences prefs;
  final CacheManager _cacheManager;
  static const String _tokenKey = 'auth_token';

  ApiUserRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
    required CacheManager cacheManager,
    required this.prefs,
  })  : _dio = dio,
        _baseUrl = baseUrl,
        _cacheManager = cacheManager;

  @override
  Future<UserDto> register(UserDto userDto) async {
    try {
      // Realizar petición HTTP usando Dio
      final response = await _dio.post(
        '$_baseUrl/auth/register',
        data: userDto.toJsonForRegistration(),
      );

      // Obtener datos del usuario desde la respuesta
      final responseData = response.data;
      final UserDto userData = responseData['data'] != null
          ? UserDto.fromJson(responseData['data'])
          : UserDto.fromJson(responseData);

      // Guardar en caché
      await _cacheManager.saveUser(userData);

      return userData;
    } on DioException catch (e) {
      // Manejo personalizado de errores de la API
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';

        // Manejar casos específicos
        if (errorMessage.contains('Email already registered')) {
          throw Exception('El correo electrónico ya está registrado');
        } else if (errorMessage.contains('ID number already registered')) {
          throw Exception('El número de identificación ya está registrado');
        }

        throw Exception(errorMessage);
      }

      // Errores de red u otros
      throw Exception('No se pudo conectar al servidor: ${e.message}');
    } catch (e) {
      // Otros errores inesperados
      throw Exception('Error al registrar usuario: ${e.toString()}');
    }
  }

  @override
  Future<UserDto> login(UserDto loginDto) async {
    try {
      await prefs.remove('auth_token');
      await _cacheManager.clearUser();

      // Realizar petición HTTP usando Dio
      final baseUrl = '$_baseUrl/auth/login';

      final response = await _dio.post(
        baseUrl,
        data: {
          'email': loginDto.email,
          'password': loginDto.password,
        },
      );

      // Extraer datos de la respuesta
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw Exception(responseData['error']);
      }

      final token = responseData['data']['token'];
      final userData = responseData['data']['user'];

      if (token == null) {
        throw Exception('No se recibió un token válido');
      }

      if (userData == null) {
        throw Exception('No se recibieron datos del usuario');
      }

      // Guardar token
      await _saveToken(token);
      await prefs.setString('auth_token', token);
      await _cacheManager.saveUser(UserDto.fromJson(userData));

      // Convertir los datos del usuario a UserDto
      final user = UserDto.fromJson(userData);

      return user;
    } on DioException catch (e) {
      // Manejo personalizado de errores de la API
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';

        // Manejar casos específicos
        if (errorMessage.contains('User not found')) {
          throw Exception('Usuario no encontrado');
        } else if (errorMessage.contains('Invalid password')) {
          throw Exception('Contraseña incorrecta');
        }

        throw Exception(errorMessage);
      }

      // Errores de red u otros
      throw Exception('No se pudo conectar al servidor: ${e.message}');
    } catch (e) {
      // Otros errores inesperados
      throw Exception('Error al iniciar sesión: ${e.toString()}');
    }
  }

  @override
  Future<void> logout() async {
    try {
      final token = await _getToken();

      if (token != null) {}
    } catch (e) {
      // Ignoramos errores del backend durante logout
    } finally {
      await _clearToken();
      await _cacheManager.clearUser();
    }
  }

  @override
  Future<UserDto?> getUserWithStoredToken() async {
    try {
      final cachedUser = await _cacheManager.getUser();

      if (cachedUser != null) {
        return cachedUser;
      }

      // Si no hay usuario en caché, intentar obtenerlo del servidor
      final token = await _getToken();

      if (token == null) {
        return null;
      }

      // Hacer petición para obtener perfil de usuario
      final response = await _dio.get(
        '$_baseUrl/auth/profile',
        options: Options(
          headers: {'Authorization': 'Bearer $token'},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = UserDto.fromJson(response.data);

        // Guardar en caché
        await _cacheManager.saveUser(userData);

        return userData;
      }

      return null;
    } catch (e) {
      // Si hay error, limpiamos el token y retornamos null
      await _clearToken();
      return null;
    }
  }

  @override
  Future<UserDto> getUserById(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No se encontró un token de autenticación');
      }

      final response = await _dio.get(
        '$_baseUrl/auth/user/$userId', // Cambiado el endpoint
      );

      if (response.statusCode == 200 && response.data != null) {
        final userData = response.data['data'] != null
            ? UserDto.fromJson(response.data['data'])
            : UserDto.fromJson(response.data);
        return userData;
      } else {
        throw Exception('No se pudo obtener el usuario');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';
        if (e.response?.statusCode == 404) {
          throw Exception('Usuario no encontrado');
        } else if (e.response?.statusCode == 401) {
          throw Exception('No autorizado para acceder a este usuario');
        }
        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener usuario por ID: ${e.toString()}');
    }
  }

  @override
  Future<UserDto> updateProfile(UserDto userDto) async {
    try {
      // Realizar petición HTTP usando Dio
      final response = await _dio.patch(
        '$_baseUrl/auth/profile',
        data: userDto.toJsonForUpdate(),
      );

      // Obtener datos del usuario desde la respuesta
      final responseData = response.data;
      final UserDto userData = responseData['data'] != null
          ? UserDto.fromJson(responseData['data'])
          : UserDto.fromJson(responseData);
      if (Platform.isAndroid && userData.role == 'client') {
        await _cacheManager.saveUser(userData);
      }
      return userData;
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      }

      // Errores de red u otros
      throw Exception('No se pudo conectar al servidor: ${e.message}');
    } catch (e) {
      // Otros errores inesperados
      throw Exception('Error al actualizar perfil: ${e.toString()}');
    }
  }

  @override
  Future<List<UserDto>> getAllUsers({int page = 1, int limit = 20}) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No se encontró un token de autenticación');
      }

      final response = await _dio.get(
        '$_baseUrl/auth/getAll',
        queryParameters: {
          'page': page,
          'limit': limit,
        },
        options: Options(
          headers: {'auth-token': token},
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final List<dynamic> usersData = response.data;
        return usersData.map((userData) => UserDto.fromJson(userData)).toList();
      } else {
        throw Exception('No se pudieron obtener los usuarios');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error al obtener usuarios: ${e.toString()}');
    }
  }

  @override
  Future<void> deleteUser(String userId) async {
    try {
      final token = await _getToken();
      if (token == null) {
        throw Exception('No se encontró un token de autenticación');
      }

      final response = await _dio.delete(
        '$_baseUrl/auth/user/$userId',
        options: Options(
          headers: {'auth-token': token},
        ),
      );

      if (response.statusCode != 200) {
        throw Exception('No se pudo eliminar el usuario');
      }
    } on DioException catch (e) {
      if (e.response != null) {
        final errorMessage = e.response?.data['error'] ?? 'Error desconocido';
        throw Exception(errorMessage);
      }
      throw Exception('Error de conexión: ${e.message}');
    } catch (e) {
      throw Exception('Error al eliminar usuario: ${e.toString()}');
    }
  }

  /// Guarda el token de autenticación
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  /// Obtiene el token guardado
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  /// Elimina el token guardado
  Future<void> _clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }
}

/// Implementación de caché usando SharedPreferences
