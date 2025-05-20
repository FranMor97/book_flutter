import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dtos/user_dto.dart';
import '../repositories/user_repository.dart';

/// Implementación del repositorio de usuarios con API + caché local
class ApiUserRepository implements UserRepository {
  final Dio _dio;
  final String _baseUrl;
  final CacheManager _cacheManager;
  static const String _tokenKey = 'auth_token';

  ApiUserRepository({
    required Dio dio,
    required String baseUrl,
    required CacheManager cacheManager,
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
      // Realizar petición HTTP usando Dio
      final response = await _dio.post(
        '$_baseUrl/auth/login',
        data: {
          'email': loginDto.email,
          'password': loginDto.password,
        },
      );

      // Extraer token de la respuesta
      final responseData = response.data;

      if (responseData['error'] != null) {
        throw Exception(responseData['error']);
      }

      final token = responseData['data']['token'];

      if (token == null) {
        throw Exception('No se recibió un token válido');
      }

      // Guardar token
      await _saveToken(token);

      // Obtener datos del usuario
      final user = await getUserWithStoredToken();

      if (user == null) {
        throw Exception('No se pudo obtener la información del usuario');
      }

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

      if (token != null) {
        // Opcional: Notificar al backend sobre cierre de sesión
        // await _dio.post('$_baseUrl/auth/logout',
        //   options: Options(headers: {'Authorization': 'Bearer $token'}),
        // );
      }
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

/// Clase para gestionar la caché
class CacheManager {
  static const String _userCacheKey = 'user_data';

  final CacheStore _cacheStore;

  CacheManager(this._cacheStore);

  /// Guarda los datos del usuario en caché
  Future<void> saveUser(UserDto user) async {
    await _cacheStore.put(_userCacheKey, json.encode(user.toJson()));
  }

  /// Recupera el usuario desde la caché
  Future<UserDto?> getUser() async {
    final cachedData = await _cacheStore.get(_userCacheKey);
    if (cachedData != null) {
      return UserDto.fromJson(json.decode(cachedData));
    }
    return null;
  }

  /// Elimina el usuario de la caché
  Future<void> clearUser() async {
    await _cacheStore.delete(_userCacheKey);
  }
}

/// Interfaz para el almacenamiento de caché
abstract class CacheStore {
  Future<void> put(String key, String value);
  Future<String?> get(String key);
  Future<void> delete(String key);
}

/// Implementación de caché usando SharedPreferences
class SharedPrefsCacheStore implements CacheStore {
  final SharedPreferences _prefs;

  SharedPrefsCacheStore(this._prefs);

  @override
  Future<void> put(String key, String value) async {
    await _prefs.setString(key, value);
  }

  @override
  Future<String?> get(String key) async {
    return _prefs.getString(key);
  }

  @override
  Future<void> delete(String key) async {
    await _prefs.remove(key);
  }
}
