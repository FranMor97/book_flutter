import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/screens/login/views/login_screen.dart';
import 'package:book_app_f/screens/login/views/register_screen.dart';
import 'package:book_app_f/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../data/bloc/login/login_bloc.dart';
import '../data/bloc/register_bloc/register_bloc.dart';
import '../data/bloc/home/home_bloc.dart'; // NUEVA IMPORTACIÓN
import '../data/repositories/user_repository.dart';
import '../data/repositories/book_repository.dart'; // NUEVA IMPORTACIÓN
import '../data/repositories/book_user_repository.dart'; // NUEVA IMPORTACIÓN
import '../injection.dart';
import '../screens/home_screen/home_screen.dart';

/// Clase que configura y gestiona todas las rutas de la aplicación
class AppRouter {
  // Singleton pattern
  static final AppRouter _instance = AppRouter._internal();

  factory AppRouter() => _instance;

  AppRouter._internal();

  // Getter para obtener la configuración del router
  GoRouter get router => _router;

  // Definición de nombres de rutas para referencia más fácil
  static const String splash = 'splash';
  static const String login = 'login';
  static const String register = 'register';
  static const String home = 'home';

  // Definición de las rutas
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
  static const String registerPath = '/register';
  static const String homePath = '/';

  final _router = GoRouter(
    initialLocation: splashPath,
    debugLogDiagnostics: true, // Útil durante el desarrollo

    routes: [
      GoRoute(
        name: splash,
        path: splashPath,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        name: login,
        path: loginPath,
        builder: (context, state) => BlocProvider(
          create: (context) => LoginBloc(
            userRepository: getIt<IUserRepository>(),
          ),
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        name: register,
        path: registerPath,
        builder: (context, state) => BlocProvider(
          create: (context) => RegisterBloc(
            userRepository: getIt<IUserRepository>(),
          ),
          child: const RegisterScreen(),
        ),
      ),
      // NUEVA RUTA HOME CON HOMEBLOC
      GoRoute(
        name: home,
        path: homePath,
        builder: (context, state) => BlocProvider(
          create: (context) => HomeBloc(
            bookUserRepository: getIt<IBookUserRepository>(),
            bookRepository: getIt<IBookRepository>(),
            iAuthRepository: getIt<IAuthRepository>(),
          ),
          child: const HomeScreen(),
        ),
      ),
    ],

    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'La ruta ${state.uri.path} no existe',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(homePath),
              child: const Text('Ir al inicio'),
            ),
          ],
        ),
      ),
    ),

    // Implementación de redirect para manejar autenticación
    redirect: (BuildContext context, GoRouterState state) {
      // TODO: Implementar lógica de redirección basada en autenticación
      // Por ejemplo, verificar si el usuario está autenticado
      // y redirigir a login si está accediendo a rutas protegidas
      return null; // Devuelve null para mantener la ruta actual
    },
  );
}
