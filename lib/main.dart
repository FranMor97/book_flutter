import 'dart:io';

import 'package:book_app_f/routes/book_routes.dart';
import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';
import 'injection.dart'; // Solo importa el archivo de inyección

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  late String env;
  if (Platform.isAndroid) {
    env = Environment.prod;
  } else {
    env = Environment.dev;
  }
  await configureDependencies(env: env);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const Color seedColor = Color(0xFF424242);

    return MaterialApp.router(
      title: 'Book App',
      debugShowCheckedModeBanner: false,
      routerConfig: AppRouter().router,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            elevation: 2,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: seedColor,
          brightness: Brightness.dark,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark,
    );
  }
}
