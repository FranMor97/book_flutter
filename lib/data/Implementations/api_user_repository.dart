import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/dtos/user_dto.dart';
import '../repositories/user_repository.dart';

/// Implementación del repositorio de usuarios con API + caché local
@LazySingleton(as: UserRepository)
@prod
@dev
class ApiUserRepository implements UserRepository {
  final Dio _dio;
  final String _baseUrl;
  final CacheManager _cacheManager;

  ApiUserRepository({
    required Dio dio,
    @Named("apiBaseUrl") required String baseUrl,
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
        data: userDto.toJson(),
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
}

/// Clase para gestionar la caché
@lazySingleton
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
@LazySingleton(as: CacheStore)
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
