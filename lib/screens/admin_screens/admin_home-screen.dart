// lib/screens/admin/admin_home_screen.dart
import 'package:book_app_f/data/bloc/admin_home_bloc/admin_home_bloc.dart';
import 'package:book_app_f/routes/book_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AdminHomeBloc, AdminHomeState>(
      listener: (context, state) {
        if (state is NavigatingToUsersManagement) {
          context.goNamed(AppRouter.adminUsers);
        } else if (state is NavigatingToBooksManagement) {
          context.goNamed(AppRouter.explore);
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: const Text('Panel de Administración',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A2E),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () {
                context.goNamed('login');
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Panel de Administración',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Selecciona una opción para administrar',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 64),
                // Botón para administrar usuarios
                _buildAdminButton(
                  context,
                  title: 'Administrar Usuarios',
                  icon: Icons.people,
                  onTap: () {
                    context
                        .read<AdminHomeBloc>()
                        .add(NavigateToUsersManagement());
                  },
                ),
                const SizedBox(height: 24),
                // Botón para administrar libros
                _buildAdminButton(
                  context,
                  title: 'Administrar Libros',
                  icon: Icons.book,
                  onTap: () {
                    context
                        .read<AdminHomeBloc>()
                        .add(NavigateToBooksManagement());
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAdminButton(
    BuildContext context, {
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 120,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1A1A2E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 5,
          shadowColor: Colors.black.withOpacity(0.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(width: 16),
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
