import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

import '../data/Implementations/api_user_repository.dart';
import '../data/Implementations/dio_auth_repository.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';

/// Módulo para registrar dependencias externas
@module
abstract class AppModule {
  /// Proporciona una instancia de SharedPreferences
  @preResolve // Importante para inicialización asíncrona
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// Proporciona una instancia básica de Dio
  @lazySingleton
  Dio get dio => Dio(BaseOptions(
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ));

  @LazySingleton(as: UserRepository, env: [Environment.dev, Environment.prod])
  UserRepository userRepository(
    Dio dio,
    @Named("apiBaseUrl") String baseUrl,
    SharedPreferences sharedPreferences,
  ) {
    final cacheStore = SharedPrefsCacheStore(sharedPreferences);
    final cacheManager = CacheManager(cacheStore);

    return ApiUserRepository(
      dio: dio,
      baseUrl: baseUrl,
      cacheManager: cacheManager,
    );
  }

  @LazySingleton(as: AuthRepository)
  AuthRepository authRepository(SharedPreferences sharedPreferences) {
    return DioAuthRepository(sharedPreferences);
  }

  /// Proporciona la URL base para la API
  @Named("apiBaseUrl")
  @prod
  String get apiBaseUrl => 'https://localhost:3000/api';

  /// URL base para desarrollo
  @Named("apiBaseUrl")
  @dev
  String get devApiBaseUrl => 'http://localhost:3000/api';

  /// URL base para pruebas
  @Named("apiBaseUrl")
  @test
  String get testApiBaseUrl => 'http://localhost:3000/api';
}
