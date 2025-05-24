import 'package:book_app_f/data/Implementations/api_user_repository.dart';
import 'package:book_app_f/data/Implementations/dio_auth_repository.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

/// Módulo para registrar dependencias externas
@module
abstract class AppModule {
  /// Proporciona una instancia de SharedPreferences
  @preResolve
  Future<SharedPreferences> get sharedPreferences =>
      SharedPreferences.getInstance();

  /// Proporciona una instancia de Dio con interceptor de autenticación
  @lazySingleton
  Dio dio(SharedPreferences prefs) {
    final dio = Dio(BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));

    // Agregar interceptor para incluir el token en las peticiones
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = prefs.getString('auth_token');
          if (token != null) {
            options.headers['auth-token'] = token;
          }
          return handler.next(options);
        },
        onError: (error, handler) {
          // Manejar errores de autenticación
          if (error.response?.statusCode == 401) {
            // Token expirado o inválido
            prefs.remove('auth_token');
          }
          return handler.next(error);
        },
      ),
    );

    return dio;
  }

  /// Proporciona la URL base para la API en producción
  @Named("apiBaseUrl")
  @prod
  String get apiBaseUrl => 'http://192.168.1.14:3000/api';

  /// URL base para desarrollo
  @Named("apiBaseUrl")
  @dev
  String get devApiBaseUrl => 'http://localhost:3000/api';

  /// URL base para pruebas
  @Named("apiBaseUrl")
  @test
  String get testApiBaseUrl => 'http://localhost:3000/api';

  // @LazySingleton(as: IAuthRepository)
  // IAuthRepository authRepository(SharedPreferences sharedPreferences) {
  //   return DioAuthRepository(sharedPreferences);
  // }

  @lazySingleton
  CacheStore cacheStore(SharedPreferences prefs) =>
      SharedPrefsCacheStore(prefs);

  @lazySingleton
  CacheManager cacheManager(CacheStore store) => CacheManager(store);
}
