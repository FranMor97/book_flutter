import 'package:book_app_f/screens/login/views/login_screen.dart';
import 'package:book_app_f/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

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
  static const String home = 'home';

  // Definición de las rutas
  static const String splashPath = '/splash';
  static const String loginPath = '/login';
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
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        name: home,
        path: homePath,
        builder: (context, state) => const Placeholder(),
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

    redirect: (BuildContext context, GoRouterState state) {},
  );
}
