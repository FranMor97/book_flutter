// lib/screens/admin/admin_users_screen.dart
import 'package:book_app_f/data/bloc/admin_user_bloc/admin_users_bloc.dart';
import 'package:book_app_f/models/dtos/user_dto.dart';
import 'package:book_app_f/routes/book_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

class _AdminUsersScreenState extends State<AdminUsersScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late AdminUsersBloc _bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _bloc = context.read<AdminUsersBloc>();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<UserDto> _getFilteredUsers(List<UserDto> users) {
    if (_searchQuery.isEmpty) return users;

    return users.where((user) {
      final searchLower = _searchQuery.toLowerCase();
      return user.firstName.toLowerCase().contains(searchLower) ||
          user.lastName1.toLowerCase().contains(searchLower) ||
          (user.lastName2?.toLowerCase().contains(searchLower) ?? false) ||
          user.email.toLowerCase().contains(searchLower) ||
          user.idNumber.toLowerCase().contains(searchLower) ||
          user.mobilePhone.toLowerCase().contains(searchLower);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<AdminUsersBloc>();
    return BlocListener<AdminUsersBloc, AdminUsersState>(
      listener: (context, state) {
        if (state is AdminUsersNavigatingToCreate) {
          context.goNamed(AppRouter.adminRegister);
        } else if (state is AdminUsersNavigatingToEdit) {
          context.pushNamed(AppRouter.adminUserProfile,
              pathParameters: {'id': state.user.id!});
        } else if (state is AdminUsersActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is AdminUsersActionFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: const Text(
            'Administrar Usuarios',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.goNamed(AppRouter.adminHome),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                _bloc.add(AdminUsersNavigateToCreate());
              },
            ),
          ],
        ),
        body: Column(
          children: [
            _buildSearchBar(),
            Expanded(
              child: BlocBuilder<AdminUsersBloc, AdminUsersState>(
                builder: (context, state) {
                  if (state is AdminUsersLoading ||
                      state is AdminUsersActionInProgress) {
                    return const Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                    );
                  }

                  if (state is AdminUsersLoaded) {
                    final filteredUsers = _getFilteredUsers(state.users);
                    return _buildUsersList(context, filteredUsers);
                  }

                  if (state is AdminUsersError) {
                    return _buildErrorView(context, state.message);
                  }

                  // Estado inicial o no manejado
                  return const Center(
                    child: Text(
                      'Cargando usuarios...',
                      style: TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // NUEVO: Widget del buscador
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        decoration: InputDecoration(
          hintText: 'Buscar usuarios...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          border: InputBorder.none,
          icon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildUsersList(BuildContext context, List<UserDto> users) {
    if (users.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isEmpty ? Icons.people_outline : Icons.search_off,
              size: 60,
              color: const Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'No hay usuarios registrados'
                  : 'No se encontraron usuarios',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              child: Text(
                user.firstName.isNotEmpty
                    ? user.firstName.substring(0, 1).toUpperCase()
                    : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            title: Text(
              '${user.firstName} ${user.lastName1}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              user.email,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.amber),
                  onPressed: () {
                    _bloc.add(
                      AdminUsersNavigateToEdit(user: user),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, user);
                  },
                ),
              ],
            ),
            onTap: () {
              _showUserDetails(context, user);
            },
          ),
        );
      },
    );
  }

  Widget _buildErrorView(BuildContext context, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Error: $message',
            style: const TextStyle(color: Colors.white),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              _bloc.add(const AdminUsersLoadAll());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, UserDto user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Eliminar Usuario',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${user.firstName} ${user.lastName1}? Esta acción no se puede deshacer.',
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _bloc.add(
                AdminUsersDeleteUser(userId: user.id!),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showUserDetails(BuildContext context, UserDto user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true, // ¡CLAVE! Permite control total del tamaño
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7, // Tamaño inicial (70% de la pantalla)
        minChildSize: 0.5, // Tamaño mínimo (50%)
        maxChildSize: 0.95, // Tamaño máximo (95%)
        expand: false,
        builder: (context, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Color(0xFF1A1A2E),
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // Handle para indicar que se puede arrastrar
              Container(
                margin: const EdgeInsets.only(top: 8),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[600],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Contenido scrolleable
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Avatar y nombre
                      Center(
                        child: CircleAvatar(
                          radius: 40,
                          backgroundColor: const Color(0xFF8B5CF6),
                          child: Text(
                            user.firstName.isNotEmpty
                                ? user.firstName.substring(0, 1).toUpperCase()
                                : '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 30,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Center(
                        child: Text(
                          '${user.firstName} ${user.lastName1} ${user.lastName2 ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Divider(color: Colors.grey),

                      // Información del usuario
                      _userInfoRow(Icons.email, 'Email', user.email),
                      _userInfoRow(
                          Icons.phone_android, 'Teléfono', user.mobilePhone),
                      _userInfoRow(Icons.badge, 'ID', user.idNumber),
                      _userInfoRow(Icons.calendar_today, 'Fecha de nacimiento',
                          _formatDate(user.birthDate)),
                      _userInfoRow(Icons.person_pin, 'Rol',
                          user.role == 'admin' ? 'Administrador' : 'Cliente'),
                      _userInfoRow(Icons.app_registration, 'App', user.appName),
                      _userInfoRow(Icons.access_time, 'Registro',
                          _formatDate(user.registrationDate)),

                      const SizedBox(height: 30),

                      // Botones de acción
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _bloc.add(
                                  AdminUsersNavigateToEdit(user: user),
                                );
                              },
                              icon: const Icon(Icons.edit),
                              label: const Text('Editar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pop(context);
                                _showDeleteConfirmation(context, user);
                              },
                              icon: const Icon(Icons.delete),
                              label: const Text('Eliminar'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Espacio extra para que el scroll funcione bien
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _userInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
              Text(
                value,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'No disponible';
    return '${date.day}/${date.month}/${date.year}';
  }
}
