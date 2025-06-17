import 'package:shared_preferences/shared_preferences.dart';

import 'cache_store.dart';

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
