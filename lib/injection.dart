import 'package:book_app_f/data/bloc/user_library/user_library_bloc.dart';
import 'package:book_app_f/data/repositories/auth_repository.dart'
    show IAuthRepository;
import 'package:book_app_f/data/repositories/book_user_repository.dart';
import 'package:book_app_f/data/services/socket_service.dart';
import 'package:book_app_f/injection.config.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: 'init',
  preferRelativeImports: true,
  asExtension: true,
)
Future<void> configureDependencies({String? env}) async =>
    await getIt.init(environment: env);

void registerServices() {
  print("Registrando servicios...");

  // Registrar socketUrl usando la misma base que apiBaseUrl pero con ws:// en lugar de http://
  if (!getIt.isRegistered<String>(instanceName: 'socketUrl')) {
    try {
      final apiBaseUrl = getIt<String>(instanceName: 'apiBaseUrl');

      // Convertir http:// a ws:// o https:// a wss:// y ajustar la ruta
      final socketUrl = apiBaseUrl
          .replaceFirst('http://', 'ws://')
          .replaceFirst('https://', 'wss://')
          .replaceFirst('/api', ''); // Eliminar /api si existe

      print("socketUrl generada: $socketUrl");

      getIt.registerLazySingleton<String>(() => socketUrl,
          instanceName: 'socketUrl');
    } catch (e) {
      print("Error al obtener apiBaseUrl: $e");
      // Fallback a una URL directa en caso de error
      getIt.registerLazySingleton<String>(() => 'ws://192.168.1.14:3000',
          instanceName: 'socketUrl');
    }
  }

  // Registrar el servicio de socket solo si no está registrado
  if (!getIt.isRegistered<SocketService>()) {
    getIt.registerLazySingleton(() => SocketService());
  }
}

UserLibraryBloc createUserLibraryBloc() {
  return UserLibraryBloc(
    bookUserRepository: getIt<IBookUserRepository>(),
    authRepository: getIt<IAuthRepository>(),
  );
}
