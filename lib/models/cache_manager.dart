import 'dart:convert';

import 'cache_store.dart';
import 'dtos/user_dto.dart';

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
