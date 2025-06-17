abstract class CacheStore {
  Future<void> put(String key, String value);

  Future<String?> get(String key);

  Future<void> delete(String key);
}
