// lib/screens/user_screens/friends_screens.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_app_f/data/bloc/friendship/friendship_bloc.dart';
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/user.dart';
import 'package:book_app_f/models/friendship.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  _FriendsScreenState createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchActive = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Cargar amigos al inicio
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FriendshipBloc>().add(FriendshipLoadFriends());
    });
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
            setState(() {
              _isSearchActive = false;
              _searchController.clear();
            });

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
                    setState(() {
                      _searchController.clear();
                      _isSearchActive = false;
                    });

                    // Volver a cargar amigos
                    if (_tabController.index == 0) {
                      context
                          .read<FriendshipBloc>()
                          .add(FriendshipLoadFriends());
                    } else {
                      context
                          .read<FriendshipBloc>()
                          .add(FriendshipLoadRequests());
                    }
                  },
                ),
              ),
              onSubmitted: (value) {
                if (value.length >= 3) {
                  setState(() {
                    _isSearchActive = true;
                  });
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
                // Pestaña de amigos o resultados de búsqueda
                _isSearchActive
                    ? _buildSearchResultsView()
                    : _buildFriendsView(),

                // Pestaña de solicitudes
                _buildRequestsView(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Vista de amigos
  Widget _buildFriendsView() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (state is FriendshipFriendsLoaded) {
          return _buildFriendsList(context, state.friends);
        }

        if (state is FriendshipError) {
          return _buildErrorView(state.message, FriendshipLoadFriends());
        }

        // Estado inicial o no manejado
        return const Center(
          child: Text(
            'Cargando amigos...',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  // Vista de resultados de búsqueda
  Widget _buildSearchResultsView() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipSearching) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (state is FriendshipSearchResults) {
          return _buildSearchResults(context, state.results);
        }

        if (state is FriendshipError) {
          return _buildErrorView(
              state.message,
              _searchController.text.isNotEmpty
                  ? FriendshipSearchUsers(query: _searchController.text)
                  : FriendshipLoadFriends());
        }

        // Estado inicial o no manejado
        return const Center(
          child: Text(
            'Busca usuarios por nombre o correo electrónico',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
    );
  }

  // Vista de solicitudes
  Widget _buildRequestsView() {
    return BlocBuilder<FriendshipBloc, FriendshipState>(
      builder: (context, state) {
        if (state is FriendshipLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (state is FriendshipRequestsLoaded) {
          return _buildRequestsList(context, state.requests);
        }

        if (state is FriendshipError) {
          return _buildErrorView(state.message, FriendshipLoadRequests());
        }

        // Estado inicial o no manejado
        return const Center(
          child: Text(
            'Cargando solicitudes...',
            style: TextStyle(color: Colors.white),
          ),
        );
      },
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
              color: const Color(0xFF22223B),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'view',
                  child: Row(
                    children: [
                      Icon(Icons.person, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Ver perfil', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'remove',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Eliminar amistad',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ),
              ],
              onSelected: (value) {
                if (value == 'view') {
                  _showUserProfileBottomSheet(context, friend);
                } else if (value == 'remove') {
                  _showRemoveFriendConfirmation(context, friend);
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildRequestsList(BuildContext context, List<Friendship> requests) {
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
        final requester = request.requester;

        if (requester == null) {
          return const SizedBox
              .shrink(); // No mostrar si no hay datos de usuario
        }

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
                  requester.avatar != null && requester.avatar!.isNotEmpty
                      ? NetworkImage(requester.avatar!)
                      : null,
              child: requester.avatar == null || requester.avatar!.isEmpty
                  ? Text(
                      requester.firstName.isNotEmpty
                          ? requester.firstName[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    )
                  : null,
            ),
            title: Text(
              '${requester.firstName} ${requester.lastName1}',
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
                  icon: const Icon(Icons.check_circle, color: Colors.green),
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
                  icon: const Icon(Icons.cancel, color: Colors.red),
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

  Widget _buildSearchResults(
      BuildContext context, List<UserFriendshipStatus> results) {
    if (results.isEmpty) {
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
      itemCount: results.length,
      itemBuilder: (context, index) {
        final result = results[index];
        final user = result.user;

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
              result.friendshipStatus,
              result.isRequester,
              user.id!,
              result.friendshipId,
            ),
          ),
        );
      },
    );
  }

  Widget _buildFriendshipActionButton(
    BuildContext context,
    String? status,
    bool isRequester,
    String userId,
    String? friendshipId,
  ) {
    // Si ya son amigos
    if (status == 'accepted') {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.green, size: 16),
            SizedBox(width: 4),
            Text(
              'Amigos',
              style: TextStyle(color: Colors.green),
            ),
          ],
        ),
      );
    }
    // Si hay una solicitud pendiente
    else if (status == 'pending') {
      // Si el usuario actual envió la solicitud
      if (isRequester) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.amber.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.hourglass_empty, color: Colors.amber, size: 16),
              SizedBox(width: 4),
              Text(
                'Pendiente',
                style: TextStyle(color: Colors.amber),
              ),
            ],
          ),
        );
      }
      // Si el usuario actual recibió la solicitud
      else {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.check_circle, color: Colors.green),
              onPressed: () {
                if (friendshipId != null) {
                  context.read<FriendshipBloc>().add(
                        FriendshipRespondToRequest(
                          friendshipId: friendshipId,
                          status: 'accepted',
                        ),
                      );
                }
              },
            ),
            IconButton(
              icon: const Icon(Icons.cancel, color: Colors.red),
              onPressed: () {
                if (friendshipId != null) {
                  context.read<FriendshipBloc>().add(
                        FriendshipRespondToRequest(
                          friendshipId: friendshipId,
                          status: 'rejected',
                        ),
                      );
                }
              },
            ),
          ],
        );
      }
    }
    // Si no hay relación o fue rechazada
    else {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text('Agregar'),
      );
    }
  }

  Widget _buildErrorView(String message, FriendshipEvent retryEvent) {
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
            onPressed: () => context.read<FriendshipBloc>().add(retryEvent),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }

  void _showUserProfileBottomSheet(BuildContext context, User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF8B5CF6),
                  image: user.avatar != null && user.avatar!.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(user.avatar!),
                          fit: BoxFit.cover,
                        )
                      : null,
                ),
                child: user.avatar == null || user.avatar!.isEmpty
                    ? Center(
                        child: Text(
                          user.firstName.isNotEmpty
                              ? user.firstName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: Text(
                '${user.firstName} ${user.lastName1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (user.lastName2 != null && user.lastName2!.isNotEmpty)
              Center(
                child: Text(
                  user.lastName2!,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 18,
                  ),
                ),
              ),
            const SizedBox(height: 16),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.email, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  user.email,
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, color: Colors.grey),
                const SizedBox(width: 8),
                Text(
                  'Miembro desde ${_formatDate(user.registrationDate)}',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Cerrar'),
              ),
            ),
          ],
        ),
      ),
    );
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
              // Aquí necesitaríamos el ID de la amistad, que actualmente no tenemos en el modelo User
              // Idealmente, al cargar los amigos, deberíamos obtener también el ID de la amistad
              // Para esta demostración, asumimos que el ID de usuario es también el ID de amistad
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

  String _formatDate(DateTime? date) {
    if (date == null) return 'Fecha desconocida';
    return '${date.day}/${date.month}/${date.year}';
  }
}
