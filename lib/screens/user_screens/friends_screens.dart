// lib/screens/friends/friends_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_app_f/data/bloc/friendship/friendship_bloc.dart';
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/user.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Amigos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8B5CF6),
          tabs: const [
            Tab(text: 'Mis Amigos'),
            Tab(text: 'Solicitudes'),
          ],
          onTap: (index) {
            if (index == 0) {
              context.read<FriendshipBloc>().add(FriendshipLoadFriends());
            } else {
              context.read<FriendshipBloc>().add(FriendshipLoadRequests());
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Barra de búsqueda
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Buscar usuarios...',
                hintStyle: TextStyle(color: Colors.grey[400]),
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                filled: true,
                fillColor: const Color(0xFF1A1A2E),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: () {
                    _searchController.clear();
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.length >= 3) {
                  context
                      .read<FriendshipBloc>()
                      .add(FriendshipSearchUsers(query: value));
                }
              },
            ),
          ),

          // Contenido principal
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Pestaña de amigos
                BlocBuilder<FriendshipBloc, FriendshipState>(
                  builder: (context, state) {
                    if (state is FriendshipLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      );
                    }

                    if (state is FriendshipSearching ||
                        state is FriendshipSearchResults) {
                      return _buildSearchResults(context, state);
                    }

                    if (state is FriendshipFriendsLoaded) {
                      return _buildFriendsList(context, state.friends);
                    }

                    if (state is FriendshipError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<FriendshipBloc>()
                                  .add(FriendshipLoadFriends()),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        'Cargando amigos...',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),

                // Pestaña de solicitudes
                BlocBuilder<FriendshipBloc, FriendshipState>(
                  builder: (context, state) {
                    if (state is FriendshipLoading) {
                      return const Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF8B5CF6),
                        ),
                      );
                    }

                    if (state is FriendshipRequestsLoaded) {
                      return _buildRequestsList(context, state.requests);
                    }

                    if (state is FriendshipError) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline,
                                size: 60, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              'Error: ${state.message}',
                              style: const TextStyle(color: Colors.white),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context
                                  .read<FriendshipBloc>()
                                  .add(FriendshipLoadRequests()),
                              child: const Text('Reintentar'),
                            ),
                          ],
                        ),
                      );
                    }

                    return const Center(
                      child: Text(
                        'Cargando solicitudes...',
                        style: TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFriendsList(BuildContext context, List<User> friends) {
    if (friends.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 60,
              color: Color(0xFF8B5CF6),
            ),
            SizedBox(height: 16),
            Text(
              'No tienes amigos todavía',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Busca usuarios y envía solicitudes de amistad',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: friends.length,
      itemBuilder: (context, index) {
        final friend = friends[index];
        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              backgroundImage:
                  friend.avatar != null && friend.avatar!.isNotEmpty
                      ? NetworkImage(friend.avatar!)
                      : null,
              child: friend.avatar == null || friend.avatar!.isEmpty
                  ? Text(
                      friend.firstName.isNotEmpty
                          ? friend.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              '${friend.firstName} ${friend.lastName1}',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              friend.email,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Text('Ver perfil'),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Text('Eliminar amistad'),
                ),
              ],
              onSelected: (value) {
                if (value == 'remove') {
                  _showRemoveFriendConfirmation(context, friend);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, List<dynamic> requests) {
    if (requests.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.mail_outline,
              size: 60,
              color: Color(0xFF8B5CF6),
            ),
            SizedBox(height: 16),
            Text(
              'No tienes solicitudes pendientes',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: requests.length,
      itemBuilder: (context, index) {
        final request = requests[index];
        final user =
            request.requester; // Asumiendo que el usuario actual es el receptor

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF8B5CF6),
              backgroundImage: user?.avatar != null && user!.avatar!.isNotEmpty
                  ? NetworkImage(user.avatar!)
                  : null,
              child: user?.avatar == null || user!.avatar!.isEmpty
                  ? Text(
                      user?.firstName != null && user!.firstName.isNotEmpty
                          ? user.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              user != null
                  ? '${user.firstName} ${user.lastName1}'
                  : 'Usuario desconocido',
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: const Text(
              'Quiere ser tu amigo',
              style: TextStyle(color: Colors.grey),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.check, color: Colors.green),
                  onPressed: () {
                    context.read<FriendshipBloc>().add(
                          FriendshipRespondToRequest(
                            friendshipId: request.id,
                            status: 'accepted',
                          ),
                        );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  onPressed: () {
                    context.read<FriendshipBloc>().add(
                          FriendshipRespondToRequest(
                            friendshipId: request.id,
                            status: 'rejected',
                          ),
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSearchResults(BuildContext context, FriendshipState state) {
    if (state is FriendshipSearching) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
      );
    }

    if (state is FriendshipSearchResults) {
      if (state.results.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.search_off,
                size: 60,
                color: Color(0xFF8B5CF6),
              ),
              const SizedBox(height: 16),
              Text(
                'No se encontraron resultados para "${_searchController.text}"',
                style: const TextStyle(color: Colors.white),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: state.results.length,
        itemBuilder: (context, index) {
          final result = state.results[index];
          final user = User.fromJson(result);
          final friendshipStatus = result['friendshipStatus'];
          final isRequester = result['isRequester'] ?? false;

          return Card(
            color: const Color(0xFF1A1A2E),
            margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF8B5CF6),
                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                    ? NetworkImage(user.avatar!)
                    : null,
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Text(
                        user.firstName.isNotEmpty
                            ? user.firstName[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : null,
              ),
              title: Text(
                '${user.firstName} ${user.lastName1}',
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                user.email,
                style: const TextStyle(color: Colors.grey),
              ),
              trailing: _buildFriendshipActionButton(
                context,
                friendshipStatus,
                isRequester,
                user.id!,
              ),
            ),
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildFriendshipActionButton(
    BuildContext context,
    String? status,
    bool isRequester,
    String userId,
  ) {
    if (status == 'accepted') {
      return const Chip(
        label: Text('Amigos'),
        backgroundColor: Color(0xFF10B981),
        labelStyle: TextStyle(color: Colors.white),
      );
    } else if (status == 'pending') {
      if (isRequester) {
        return const Chip(
          label: Text('Pendiente'),
          backgroundColor: Color(0xFFF59E0B),
          labelStyle: TextStyle(color: Colors.white),
        );
      } else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check, color: Colors.green),
              onPressed: () {
                // Aceptar solicitud
              },
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: () {
                // Rechazar solicitud
              },
            ),
          ],
        );
      }
    } else if (status == 'rejected') {
      return ElevatedButton(
        onPressed: () {
          context.read<FriendshipBloc>().add(
                FriendshipSendRequest(
                  recipientId: userId,
                  searchQuery: _searchController.text,
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
        ),
        child: const Text('Agregar'),
      );
    } else {
      return ElevatedButton(
        onPressed: () {
          context.read<FriendshipBloc>().add(
                FriendshipSendRequest(
                  recipientId: userId,
                  searchQuery: _searchController.text,
                ),
              );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
        ),
        child: const Text('Agregar'),
      );
    }
  }

  void _showRemoveFriendConfirmation(BuildContext context, User friend) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Eliminar amistad',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          '¿Estás seguro de que quieres eliminar a ${friend.firstName} ${friend.lastName1} de tus amigos?',
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
              context.read<FriendshipBloc>().add(
                    FriendshipRemoveFriend(friendshipId: friend.id!),
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
}
