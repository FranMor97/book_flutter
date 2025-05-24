// lib/screens/home/views/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/bloc/home/home_bloc.dart';
import '../../../models/dtos/book_user_dto.dart';
import '../../../models/dtos/book_dto.dart';
import '../../data/repositories/book_user_repository.dart';

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
                              '¡Hola, Francisco!',
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
                          // Navegar a búsqueda
                        },
                      ),
                      Stack(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.notifications_outlined,
                                color: Colors.white),
                            onPressed: () {
                              // Mostrar notificaciones
                            },
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
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

                        // Libros en progreso
                        _buildCurrentlyReadingSection(state.currentlyReading),
                        const SizedBox(height: 24),

                        // Objetivos de lectura
                        _buildReadingGoalsSection(),
                        const SizedBox(height: 24),

                        // Acciones rápidas
                        _buildQuickActionsSection(),
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

  Widget _buildCurrentlyReadingSection(List<BookUserDto> currentlyReading) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Leyendo Ahora',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                // Agregar nuevo libro
              },
              icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
              label: const Text(
                'Agregar',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: currentlyReading.length,
            itemBuilder: (context, index) {
              final book = currentlyReading[index];
              final gradients = [
                [const Color(0xFF8B5CF6), const Color(0xFFEC4899)],
                [const Color(0xFF10B981), const Color(0xFF06B6D4)],
                [const Color(0xFFF59E0B), const Color(0xFFEF4444)],
              ];

              return Container(
                width: 300,
                margin: EdgeInsets.only(
                    right: index < currentlyReading.length - 1 ? 16 : 0),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      colors: gradients[index % gradients.length]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y emoji (usaremos el bookId como referencia)
                    const Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Libro en Progreso', // Aquí iría book.title si tuvieras populate
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                'Autor Desconocido', // book.author
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text('📚', style: TextStyle(fontSize: 32)),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Progreso
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Progreso',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                        Text(
                          '${((book.currentPage / 400) * 100).toInt()}%', // Asumiendo 400 páginas
                          style: const TextStyle(
                              color: Colors.white, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: book.currentPage / 400,
                      backgroundColor: Colors.white24,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Página ${book.currentPage} de 400',
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const Spacer(),

                    // Botón de actualizar
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          _showProgressDialog(context, book);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white24,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Actualizar Progreso'),
                      ),
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

  Widget _buildReadingGoalsSection() {
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
                'Objetivos de Lectura',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () {
                  // Configurar objetivos
                },
                child: const Text(
                  'Configurar',
                  style: TextStyle(color: Color(0xFF8B5CF6)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Páginas diarias
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Páginas Diarias', style: TextStyle(color: Colors.grey)),
                  Text('32/50',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 32 / 50,
                backgroundColor: Colors.grey.withOpacity(0.3),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF10B981)),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Meta mensual
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Meta Mensual', style: TextStyle(color: Colors.grey)),
                  Text('2/4 libros',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              LinearProgressIndicator(
                value: 2 / 4,
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

  Widget _buildQuickActionsSection() {
    final actions = [
      {
        'icon': Icons.explore,
        'label': 'Explorar',
        'gradient': [const Color(0xFF6366F1), const Color(0xFF8B5CF6)]
      },
      {
        'icon': Icons.group,
        'label': 'Clubes',
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF43F5E)]
      },
      {
        'icon': Icons.calendar_today,
        'label': 'Calendario',
        'gradient': [const Color(0xFF14B8A6), const Color(0xFF06B6D4)]
      },
      {
        'icon': Icons.emoji_events,
        'label': 'Logros',
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFEF4444)]
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Acciones Rápidas',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 1.5,
          ),
          itemCount: actions.length,
          itemBuilder: (context, index) {
            final action = actions[index];
            return InkWell(
              onTap: () {
                // Navegar según la acción
              },
              child: Container(
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: action['gradient'] as List<Color>),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      action['icon'] as IconData,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      action['label'] as String,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
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
                // Ver todas las recomendaciones
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

              return Container(
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
                          const Icon(Icons.star, color: Colors.white, size: 14),
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
              Icon(Icons.group, color: Color(0xFF10B981)),
              SizedBox(width: 8),
              Text(
                'Actividad Reciente',
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
            ...recentlyFinished
                .take(3)
                .map((book) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [Color(0xFF10B981), Color(0xFF059669)],
                              ),
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                'F',
                                style: TextStyle(
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
                                const Text(
                                  'Has terminado de leer un libro',
                                  style: TextStyle(color: Colors.white),
                                ),
                                Text(
                                  'hace ${_getTimeAgo(book.finishDate)}',
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ))
                .toList()
          else
            const Text(
              'No hay actividad reciente',
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
      return '${difference.inDays} día${difference.inDays > 1 ? 's' : ''}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hora${difference.inHours > 1 ? 's' : ''}';
    } else {
      return '${difference.inMinutes} minuto${difference.inMinutes > 1 ? 's' : ''}';
    }
  }

  void _showProgressDialog(BuildContext context, BookUserDto book) {
    final pageController =
        TextEditingController(text: book.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text(
          'Actualizar Progreso',
          style: TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: pageController,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'Página actual',
            labelStyle: TextStyle(color: Colors.grey),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF8B5CF6)),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final newPage =
                  int.tryParse(pageController.text) ?? book.currentPage;
              context.read<HomeBloc>().add(
                    HomeUpdateQuickProgress(
                      bookUserId: book.id!,
                      newPage: newPage,
                    ),
                  );
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }
}
