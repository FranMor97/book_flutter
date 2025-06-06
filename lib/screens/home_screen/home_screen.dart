// lib/screens/home/views/home_screen.dart
import 'package:book_app_f/data/bloc/friendship/friendship_bloc.dart';
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/book_user_repository.dart';
import 'package:book_app_f/data/repositories/friendship_repository.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/screens/user_screens/friends_screens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../data/bloc/home/home_bloc.dart';
import '../../../models/dtos/book_user_dto.dart';
import '../../../models/dtos/book_dto.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(HomeLoadDashboard());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.purple,
                ),
              );
            }

            if (state is HomeError) {
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
                      onPressed: () =>
                          context.read<HomeBloc>().add(HomeLoadDashboard()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is HomeLoaded) {
              return CustomScrollView(
                slivers: [
                  // App Bar personalizado
                  SliverAppBar(
                    floating: true,
                    backgroundColor: const Color(0xFF1A1A2E),
                    elevation: 0,
                    title: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ),
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                          ),
                          child: const Center(
                            child: Text(
                              'R',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'THE READER',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '¡Hola, Lector!',
                              style: TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    actions: [
                      IconButton(
                        icon: const Icon(Icons.search, color: Colors.white),
                        onPressed: () {
                          context.pushNamed('explore');
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.person_outline,
                            color: Colors.white),
                        onPressed: () {
                          context.pushNamed('user-profile');
                        },
                      ),
                    ],
                  ),

                  // Contenido principal
                  SliverPadding(
                    padding: const EdgeInsets.all(16),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        // Estadísticas
                        _buildStatsSection(
                            state.stats, state.pagesReadThisWeek),
                        const SizedBox(height: 24),

                        // Mi biblioteca (antes "Libros en progreso")
                        _buildMyLibrarySection(context, state.currentlyReading),
                        const SizedBox(height: 24),

                        // Objetivos de lectura
                        _buildReadingGroupsSection(context),
                        const SizedBox(height: 24),

                        // Recomendaciones
                        _buildFriendsSection(context),
                        const SizedBox(height: 24),

                        // Actividad reciente
                        _buildRecentActivitySection(state.recentlyFinished),
                      ]),
                    ),
                  ),
                ],
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildStatsSection(UserReadingStats stats, int pagesReadThisWeek) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mi Progreso',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.menu_book,
                label: 'Leídos',
                value: stats.booksRead.toString(),
                gradient: const [Color(0xFF3B82F6), Color(0xFF06B6D4)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.auto_stories,
                label: 'Leyendo',
                value: stats.booksReading.toString(),
                gradient: const [Color(0xFF10B981), Color(0xFF059669)],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                icon: Icons.trending_up,
                label: 'Páginas',
                value: stats.totalPagesRead.toString(),
                gradient: const [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                icon: Icons.calendar_view_week,
                label: 'Esta semana',
                value: '$pagesReadThisWeek págs',
                gradient: const [Color(0xFFF59E0B), Color(0xFFEF4444)],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required List<Color> gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: gradient),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.white, size: 24),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMyLibrarySection(BuildContext context, List<BookUserDto> books) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Mi Biblioteca',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                context.pushNamed('user-library');
              },
              icon: const Icon(Icons.library_books, color: Color(0xFF8B5CF6)),
              label: const Text(
                'Ver todos',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.library_books_outlined,
                  size: 60,
                  color: Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No tienes libros en tu biblioteca',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Explora y añade libros para comenzar',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.pushNamed('explore');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                  child: const Text('Explorar libros'),
                ),
              ],
            ),
          )
        else
          SizedBox(
            height: 200,
            child: PageView.builder(
              controller: PageController(viewportFraction: 0.7),
              itemCount: books.length,
              itemBuilder: (context, index) {
                final bookUser = books[index];
                final bookData = bookUser.bookId;

                // Determinar color e ícono por estado
                Color statusColor;
                IconData statusIcon;
                switch (bookUser.status) {
                  case 'to-read':
                    statusColor = Colors.blue;
                    statusIcon = Icons.bookmark_border;
                    break;
                  case 'reading':
                    statusColor = Colors.green;
                    statusIcon = Icons.menu_book;
                    break;
                  case 'completed':
                    statusColor = Colors.amber;
                    statusIcon = Icons.check_circle;
                    break;
                  default:
                    statusColor = Colors.grey;
                    statusIcon = Icons.help_outline;
                }

                return GestureDetector(
                  onTap: () {
                    if (bookData.id != null) {
                      context.pushNamed(
                        'book-detail',
                        pathParameters: {'id': bookData.id!},
                      );
                    } else {
                      context.pushNamed('user-library');
                    }
                  },
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: const Color(0xFF1A1A2E),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(16)),
                            child: bookData.coverImage != null
                                ? Image.network(
                                    bookData.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, __, ___) => Image.asset(
                                      'assets/images/default_cover.png',
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : Image.asset(
                                    'assets/images/default_cover.png',
                                    fit: BoxFit.cover,
                                  ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 14),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bookData.title ?? 'Libro sin título',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Widget _buildReadingGroupsSection(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingGroupBloc(
        readingGroupRepository: getIt<IReadingGroupRepository>(),
      )..add(ReadingGroupLoadUserGroups()),
      child: BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
        builder: (context, state) {
          if (state is ReadingGroupLoading) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              ),
            );
          }

          if (state is ReadingGroupError) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 40),
                  const SizedBox(height: 8),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      context
                          .read<ReadingGroupBloc>()
                          .add(ReadingGroupLoadUserGroups());
                    },
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is ReadingGroupUserGroupsLoaded) {
            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF1A1A2E),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.group, color: Color(0xFF8B5CF6)),
                      const SizedBox(width: 8),
                      const Text(
                        'Mis Grupos de Lectura',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          context.pushNamed('reading-groups');
                        },
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Si no hay grupos, mostrar mensaje y botón para crear/buscar
                  if (state.groups.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          const Text(
                            'No participas en ningún grupo de lectura',
                            style: TextStyle(color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () {
                              context.pushNamed('search-groups');
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                            ),
                            child: const Text('Explorar grupos'),
                          ),
                        ],
                      ),
                    )
                  else
                    // Mostrar los grupos del usuario (limitado a 2 para la vista home)
                    Column(
                      children: state.groups.take(2).map((group) {
                        final book = group.book;
                        return InkWell(
                          onTap: () {
                            context.pushNamed(
                              'group-chat',
                              pathParameters: {'id': group.id},
                            );
                          },
                          child: Container(
                            margin: const EdgeInsets.only(bottom: 12),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFF22223B),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Row(
                              children: [
                                // Portada del libro o icono
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF8B5CF6),
                                    borderRadius: BorderRadius.circular(8),
                                    image: book?.coverImage != null
                                        ? DecorationImage(
                                            image:
                                                NetworkImage(book!.coverImage!),
                                            fit: BoxFit.cover,
                                          )
                                        : null,
                                  ),
                                  child: book?.coverImage == null
                                      ? const Icon(Icons.book,
                                          color: Colors.white)
                                      : null,
                                ),
                                const SizedBox(width: 12),

                                // Información del grupo
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        group.name,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (book != null)
                                        Text(
                                          book.title,
                                          style: const TextStyle(
                                            color: Colors.grey,
                                            fontSize: 12,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      Text(
                                        '${group.members.length} miembros',
                                        style: const TextStyle(
                                          color: Colors.grey,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Indicador de mensajes o botón
                                const Icon(
                                  Icons.chat_bubble_outline,
                                  color: Color(0xFF8B5CF6),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                  if (state.groups.isNotEmpty)
                    Center(
                      child: TextButton.icon(
                        icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
                        label: const Text(
                          'Unirse a más grupos',
                          style: TextStyle(color: Color(0xFF8B5CF6)),
                        ),
                        onPressed: () {
                          context.pushNamed('search-groups');
                        },
                      ),
                    ),
                ],
              ),
            );
          }

          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A2E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.grey.withOpacity(0.1)),
            ),
            child: const Center(
              child: Text(
                'Cargando grupos de lectura...',
                style: TextStyle(color: Colors.white70),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendsSection(BuildContext context) {
    return BlocProvider(
      create: (context) => FriendshipBloc(
        friendshipRepository: getIt<IFriendshipRepository>(),
      )..add(FriendshipLoadFriends()),
      child: BlocBuilder<FriendshipBloc, FriendshipState>(
        builder: (context, state) {
          if (state is FriendshipLoading) {
            return const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Amigos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 16),
                SizedBox(
                  height: 130,
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  ),
                ),
              ],
            );
          }

          if (state is FriendshipFriendsLoaded) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Amigos',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () {
                        // Navegar a la pantalla de amigos
                        context.pushNamed('friend-screen');
                      },
                      icon: const Icon(Icons.people, color: Color(0xFF8B5CF6)),
                      label: const Text(
                        'Ver todos',
                        style: TextStyle(color: Color(0xFF8B5CF6)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                if (state.friends.isEmpty)
                  Container(
                    height: 130,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A2E),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.people_outline,
                            size: 40,
                            color: Color(0xFF8B5CF6),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'No tienes amigos todavía',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          TextButton(
                            onPressed: () {
                              // Navegar a la pantalla de búsqueda de amigos
                              context.pushNamed('friend-screen');
                            },
                            child: const Text(
                              'Buscar amigos',
                              style: TextStyle(color: Color(0xFF8B5CF6)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  SizedBox(
                    height: 130,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: state.friends.length,
                      itemBuilder: (context, index) {
                        final friend = state.friends[index];
                        return Container(
                          width: 100,
                          margin: EdgeInsets.only(
                            right: index < state.friends.length - 1 ? 12 : 0,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1A1A2E),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: const Color(0xFF8B5CF6),
                                backgroundImage: friend.avatar != null
                                    ? NetworkImage(friend.avatar!)
                                    : null,
                                child: friend.avatar == null
                                    ? Text(
                                        friend.firstName.isNotEmpty
                                            ? friend.firstName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 24,
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                friend.firstName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                friend.lastName1,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            );
          }

          if (state is FriendshipError) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Amigos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 130,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A1A2E),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 40,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Error: ${state.message}',
                          style: const TextStyle(color: Colors.white),
                          textAlign: TextAlign.center,
                        ),
                        TextButton(
                          onPressed: () {
                            context
                                .read<FriendshipBloc>()
                                .add(FriendshipLoadFriends());
                          },
                          child: const Text('Reintentar'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildRecentActivitySection(List<BookUserDto> recentlyFinished) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.history, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Últimos Libros Completados',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Libros recientemente terminados
          if (recentlyFinished.isNotEmpty)
            ...recentlyFinished.take(3).map((bookUser) {
              // Extraer datos del libro si están disponibles
              final bookData = bookUser.bookId is Map
                  ? BookDto.fromJson(bookUser.bookId as Map<String, dynamic>)
                  : null;

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: GestureDetector(
                  onTap: () {
                    if (bookData != null && bookData.id != null) {
                      context.pushNamed(
                        'book-detail',
                        pathParameters: {'id': bookData.id!},
                      );
                    }
                  },
                  child: Row(
                    children: [
                      // Miniatura del libro
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            bookData?.title.substring(0, 1) ?? 'L',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bookData?.title ?? 'Libro sin título',
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Completado ${_getTimeAgo(bookUser.finishDate)}',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                      // Valoración si existe
                      if (bookUser.personalRating > 0)
                        Row(
                          children: [
                            Icon(
                              Icons.star,
                              color: Colors.amber,
                              size: 16,
                            ),
                            Text(
                              ' ${bookUser.personalRating}',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                    ],
                  ),
                ),
              );
            }).toList()
          else
            const Text(
              'No has completado ningún libro recientemente',
              style: TextStyle(color: Colors.grey),
            ),
        ],
      ),
    );
  }

  String _getTimeAgo(DateTime? date) {
    if (date == null) return 'hace tiempo';
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 0) {
      return 'hace ${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return 'hace ${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return 'hace ${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
  }
}
