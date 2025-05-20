import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dio/dio.dart';

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
