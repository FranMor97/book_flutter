// lib/screens/home/views/home_screen.dart
import 'package:book_app_f/data/repositories/book_user_repository.dart';
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
                          // Navegar a perfil
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
                        _buildStatsSection(state.stats),
                        const SizedBox(height: 24),

                        // Mi biblioteca (antes "Libros en progreso")
                        _buildMyLibrarySection(context, state.currentlyReading),
                        const SizedBox(height: 24),

                        // Objetivos de lectura
                        _buildReadingGoalsSection(state.stats),
                        const SizedBox(height: 24),

                        // Recomendaciones
                        _buildRecommendationsSection(state.recommendations),
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

  Widget _buildStatsSection(UserReadingStats stats) {
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
                icon: Icons.star,
                label: 'Rating',
                value: stats.averageRating.toStringAsFixed(1),
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
            height: 160,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: books.length,
              itemBuilder: (context, index) {
                final bookUser = books[index];

                // Extraer datos del libro si están disponibles
                final bookData = bookUser.bookId is Map
                    ? BookDto.fromJson(bookUser.bookId as Map<String, dynamic>)
                    : null;

                // Determinar color basado en el estado
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

                return Container(
                  width: 120,
                  margin:
                      EdgeInsets.only(right: index < books.length - 1 ? 16 : 0),
                  child: GestureDetector(
                    onTap: () {
                      if (bookData != null && bookData.id != null) {
                        context.pushNamed(
                          'book-detail',
                          pathParameters: {'id': bookData.id!},
                        );
                      } else {
                        // Redirigir a la biblioteca si no hay ID de libro
                        context.pushNamed('user-library');
                      }
                    },
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Portada del libro
                        Container(
                          height: 120,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            ),
                          ),
                          child: bookData?.coverImage != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    bookData!.coverImage!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error,
                                            stackTrace) =>
                                        const Center(
                                            child: Text('📚',
                                                style:
                                                    TextStyle(fontSize: 32))),
                                  ),
                                )
                              : const Center(
                                  child: Text('📚',
                                      style: TextStyle(fontSize: 32))),
                        ),

                        // Título del libro
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Row(
                            children: [
                              Icon(statusIcon, color: statusColor, size: 12),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  bookData?.title ?? 'Libro sin título',
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

  Widget _buildReadingGoalsSection(UserReadingStats stats) {
    // Calcular el progreso para la meta mensual (asumimos 4 libros al mes como meta)
    final monthlyGoalProgress = stats.booksRead / 4;

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
              const Icon(Icons.track_changes, color: Color(0xFF8B5CF6)),
              const SizedBox(width: 8),
              const Text(
                'Estadísticas de Lectura',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Configurar objetivos (por implementar)
                },
                child: const Text(
                  'Configurar',
                  style: TextStyle(color: Color(0xFF8B5CF6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Totales
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Libros',
                      style: TextStyle(color: Colors.grey)),
                  Text('${stats.totalBooks}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Total Reseñas',
                      style: TextStyle(color: Colors.grey)),
                  Text('${stats.totalReviews}',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meta mensual
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Meta Mensual',
                      style: TextStyle(color: Colors.grey)),
                  Text('${stats.booksRead}/4 libros',
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: monthlyGoalProgress > 1 ? 1 : monthlyGoalProgress,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF3B82F6)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsSection(List<BookDto> recommendations) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Recomendaciones',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {
                context.pushNamed('explore');
              },
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Ver todas', style: TextStyle(color: Color(0xFF8B5CF6))),
                  Icon(Icons.chevron_right, color: Color(0xFF8B5CF6)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: recommendations.length,
            itemBuilder: (context, index) {
              final book = recommendations[index];
              final gradients = [
                [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
                [const Color(0xFF3B82F6), const Color(0xFF6366F1)],
                [const Color(0xFF10B981), const Color(0xFF14B8A6)],
              ];

              return GestureDetector(
                onTap: () {
                  if (book.id != null) {
                    context.pushNamed(
                      'book-detail',
                      pathParameters: {'id': book.id!},
                    );
                  }
                },
                child: Container(
                  width: 140,
                  margin: EdgeInsets.only(
                      right: index < recommendations.length - 1 ? 16 : 0),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        colors: gradients[index % gradients.length]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('📖', style: TextStyle(fontSize: 32)),
                        const SizedBox(height: 8),
                        Text(
                          book.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          book.authors.isNotEmpty
                              ? book.authors.first
                              : 'Autor desconocido',
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.star,
                                color: Colors.white, size: 14),
                            Text(
                              ' ${book.averageRating.toStringAsFixed(1)}',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 12),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
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
