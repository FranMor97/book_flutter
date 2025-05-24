// lib/data/implementations/simple_auth_repository.dart (NUEVO)
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../repositories/auth_repository.dart';

class DioAuthRepository implements AuthRepository {
  final SharedPreferences _prefs;
  static const String _tokenKey = 'auth_token';

  DioAuthRepository(this._prefs);

  @override
  Future<String?> getCurrentUserId() async {
    try {
      final token = _prefs.getString(_tokenKey);
      if (token == null || JwtDecoder.isExpired(token)) {
        return null;
      }

      final decodedToken = JwtDecoder.decode(token);
      return decodedToken['id'] as String?;
    } catch (e) {
      return null;
    }
  }
}
