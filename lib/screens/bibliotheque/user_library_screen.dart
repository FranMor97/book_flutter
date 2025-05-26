import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/bloc/user_library/user_library_bloc.dart';
import '../../models/dtos/book_dto.dart';
import '../../models/dtos/book_user_dto.dart';

class UserLibraryScreen extends StatefulWidget {
  const UserLibraryScreen({super.key});

  @override
  State<UserLibraryScreen> createState() => _UserLibraryScreenState();
}

class _UserLibraryScreenState extends State<UserLibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Cargar todos los libros inicialmente
    context.read<UserLibraryBloc>().add(UserLibraryLoadBooks());

    // Listener para cambiar el filtro cuando cambia la pestaña
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) {
      String? status;
      switch (_tabController.index) {
        case 0: // Todos
          status = null;
          break;
        case 1: // Por leer
          status = 'to-read';
          break;
        case 2: // Leyendo
          status = 'reading';
          break;
        case 3: // Completados
          status = 'completed';
          break;
      }

      if (status != null) {
        context
            .read<UserLibraryBloc>()
            .add(UserLibraryFilterByStatus(status: status));
      } else {
        context.read<UserLibraryBloc>().add(UserLibraryLoadBooks());
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title:
            const Text('Mi Biblioteca', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF8B5CF6),
          tabs: const [
            Tab(text: 'Todos'),
            Tab(text: 'Por leer'),
            Tab(text: 'Leyendo'),
            Tab(text: 'Completados'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {
              context.pushNamed('explore');
            },
          ),
        ],
      ),
      body: BlocBuilder<UserLibraryBloc, UserLibraryState>(
        builder: (context, state) {
          if (state is UserLibraryLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }

          if (state is UserLibraryError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<UserLibraryBloc>()
                        .add(UserLibraryLoadBooks()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is UserLibraryLoaded) {
            if (state.books.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.library_books_outlined,
                      size: 80,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      state.currentStatus == null
                          ? 'Tu biblioteca está vacía'
                          : state.currentStatus == 'to-read'
                              ? 'No tienes libros por leer'
                              : state.currentStatus == 'reading'
                                  ? 'No estás leyendo ningún libro'
                                  : 'No has completado ningún libro',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Explora y añade libros a tu biblioteca',
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: () {
                        context.pushNamed('explore');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                      icon: const Icon(Icons.search),
                      label: const Text('Buscar libros'),
                    ),
                  ],
                ),
              );
            }
            final bloc = context.read<UserLibraryBloc>();
            return RefreshIndicator(
              onRefresh: () async {
                bloc.add(UserLibraryRefresh());
              },
              color: const Color(0xFF8B5CF6),
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 0.7,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: state.books.length,
                itemBuilder: (context, index) {
                  final bookUser = state.books[index];
                  final bookData = bookUser.bookId;

                  return _buildBookCard(context, bookUser, bookData, bloc);
                },
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF8B5CF6),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () {
          context.pushNamed('explore');
        },
      ),
    );
  }

  Widget _buildBookCard(
      BuildContext context, BookUserDto bookUser, BookDto? bookData, bloc) {
    // Determinar color basado en el estado
    Color statusColor;
    String statusText;
    IconData statusIcon;

    switch (bookUser.status) {
      case 'to-read':
        statusColor = Colors.blue;
        statusText = 'Por leer';
        statusIcon = Icons.bookmark_border;
        break;
      case 'reading':
        statusColor = Colors.green;
        statusText = 'Leyendo';
        statusIcon = Icons.menu_book;
        break;
      case 'completed':
        statusColor = Colors.amber;
        statusText = 'Completado';
        statusIcon = Icons.check_circle;
        break;
      default:
        statusColor = Colors.grey;
        statusText = 'Desconocido';
        statusIcon = Icons.help_outline;
    }

    return GestureDetector(
      onTap: () {
        if (bookData != null && bookData.id != null) {
          context.pushNamed(
            'book-detail',
            pathParameters: {'id': bookData.id!},
          );
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Portada del libro (parte superior del card)
            Stack(
              children: [
                // Portada o placeholder
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(12)),
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        statusColor.withOpacity(0.8),
                        statusColor.withOpacity(0.4),
                      ],
                    ),
                  ),
                  child: bookData?.coverImage != null
                      ? ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(12)),
                          child: Image.network(
                            bookData!.coverImage!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Text('📚',
                                        style: TextStyle(fontSize: 60))),
                          ),
                        )
                      : const Center(
                          child: Text('📚', style: TextStyle(fontSize: 60))),
                ),

                // Botón de opciones
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.more_vert, color: Colors.white),
                      iconSize: 20,
                      onPressed: () {
                        _showOptionsBottomSheet(
                            context, bookUser, bookData, bloc);
                      },
                    ),
                  ),
                ),

                // Indicador de estado
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Icon(statusIcon, color: statusColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Información del libro (parte inferior del card)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Título
                  Text(
                    bookData?.title ?? 'Libro sin título',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Autor
                  Text(
                    bookData?.authors.isNotEmpty == true
                        ? bookData!.authors.first
                        : 'Autor desconocido',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  // Progreso (si está leyendo)
                  if (bookUser.status == 'reading' &&
                      bookData?.pageCount != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Progreso:',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 10),
                        ),
                        Text(
                          '${(bookUser.currentPage / bookData!.pageCount! * 100).toInt()}%',
                          style: const TextStyle(
                              color: Colors.white, fontSize: 10),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    LinearProgressIndicator(
                      value: bookData.pageCount! > 0
                          ? bookUser.currentPage / bookData.pageCount!
                          : 0,
                      backgroundColor: Colors.grey.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                    ),
                  ],

                  // Rating personal (si existe)
                  if (bookUser.personalRating > 0) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          index < bookUser.personalRating
                              ? Icons.star
                              : Icons.star_border,
                          color: Colors.amber,
                          size: 12,
                        );
                      }),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context, BookUserDto bookUser,
      BookDto? bookData, UserLibraryBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Título del libro
              Text(
                bookData?.title ?? 'Opciones del libro',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Opciones
              _buildOptionItem(
                context,
                icon: Icons.menu_book,
                title: 'Ver detalles',
                onTap: () {
                  Navigator.pop(context);
                  if (bookData != null && bookData.id != null) {
                    context.pushNamed(
                      'book-detail',
                      pathParameters: {'id': bookData.id!},
                    );
                  }
                },
              ),

              if (bookUser.status == 'reading')
                _buildOptionItem(
                  context,
                  icon: Icons.update,
                  title: 'Actualizar progreso',
                  onTap: () {
                    Navigator.pop(context);
                    _showUpdateProgressDialog(context, bookUser, bookData);
                  },
                ),

              _buildOptionItem(
                context,
                icon: Icons.rate_review,
                title: 'Añadir reseña',
                onTap: () {
                  Navigator.pop(context);
                  _showAddReviewDialog(context, bookUser, bloc);
                },
              ),

              _buildOptionItem(
                context,
                icon: Icons.note_add,
                title: 'Añadir nota',
                onTap: () {
                  Navigator.pop(context);
                  _showAddNoteDialog(context, bookUser, bloc);
                },
              ),

              _buildOptionItem(
                context,
                icon: Icons.swap_horiz,
                title: 'Cambiar estado',
                onTap: () {
                  Navigator.pop(context);
                  _showStatusChangeDialog(context, bookUser, bloc);
                },
              ),

              _buildOptionItem(
                context,
                icon: Icons.delete_outline,
                title: 'Eliminar de la biblioteca',
                color: Colors.red,
                onTap: () {
                  Navigator.pop(context);
                  _confirmRemoveBook(context, bookUser.id!, bloc);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOptionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.white),
      title: Text(title, style: TextStyle(color: color ?? Colors.white)),
      onTap: onTap,
      dense: true,
    );
  }

  void _confirmRemoveBook(
      BuildContext context, String bookUserId, UserLibraryBloc bloc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title:
            const Text('Eliminar libro', style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres eliminar este libro de tu biblioteca?',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              bloc.add(
                UserLibraryRemoveBook(bookUserId: bookUserId),
              );
            },
            child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showStatusChangeDialog(
      BuildContext context, BookUserDto bookUser, UserLibraryBloc bloc) {
    String currentStatus = bookUser.status;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Cambiar estado',
              style: TextStyle(color: Colors.white)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildStatusOption(
                context,
                'Por leer',
                'to-read',
                currentStatus,
                (value) => setState(() => currentStatus = value),
              ),
              _buildStatusOption(
                context,
                'Leyendo',
                'reading',
                currentStatus,
                (value) => setState(() => currentStatus = value),
              ),
              _buildStatusOption(
                context,
                'Completado',
                'completed',
                currentStatus,
                (value) => setState(() => currentStatus = value),
              ),
              _buildStatusOption(
                context,
                'Abandonado',
                'abandoned',
                currentStatus,
                (value) => setState(() => currentStatus = value),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                // Solo realizar la acción si el estado ha cambiado
                if (currentStatus != bookUser.status) {
                  // Aquí iría la lógica para cambiar el estado
                  // Implementar en futuros pasos
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    String value,
    String groupValue,
    Function(String) onChanged,
  ) {
    return RadioListTile<String>(
      title: Text(label, style: const TextStyle(color: Colors.white)),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged(newValue);
        }
      },
      activeColor: const Color(0xFF8B5CF6),
      contentPadding: EdgeInsets.zero,
    );
  }

  void _showAddNoteDialog(
      BuildContext context, BookUserDto bookUser, UserLibraryBloc bloc) {
    final textController = TextEditingController();
    final pageController =
        TextEditingController(text: bookUser.currentPage.toString());

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Añadir nota', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Página',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: textController,
              style: const TextStyle(color: Colors.white),
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Nota',
                labelStyle: TextStyle(color: Colors.grey),
                alignLabelWithHint: true,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                final page =
                    int.tryParse(pageController.text) ?? bookUser.currentPage;
                final note = NoteDto(
                  page: page,
                  text: textController.text,
                );

                Navigator.pop(context);
                bloc.add(
                  UserLibraryAddNote(
                    bookUserId: bookUser.id!,
                    note: note,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  void _showAddReviewDialog(
      BuildContext context, BookUserDto bookUser, UserLibraryBloc bloc) {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    int rating = 0;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Añadir reseña',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Título (opcional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Reseña',
                    labelStyle: TextStyle(color: Colors.grey),
                    alignLabelWithHint: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Valoración: ',
                        style: TextStyle(color: Colors.white)),
                    ...List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                        ),
                        onPressed: () {
                          setState(() {
                            rating = index + 1;
                          });
                        },
                      );
                    }),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty) {
                  final review = ReviewDto(
                    text: textController.text,
                    rating: rating,
                    title: titleController.text.isNotEmpty
                        ? titleController.text
                        : null,
                    isPublic: true,
                  );

                  Navigator.pop(context);
                  bloc.add(
                    UserLibraryAddReview(
                      bookUserId: bookUser.id!,
                      review: review,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(
      BuildContext context, BookUserDto bookUser, BookDto? bookData) {
    final pageController =
        TextEditingController(text: bookUser.currentPage.toString());
    int maxPages = bookData?.pageCount ?? 0;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Actualizar progreso',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Página actual',
                labelStyle: const TextStyle(color: Colors.grey),
                helperText: maxPages > 0 ? 'Máximo: $maxPages páginas' : null,
                helperStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(pageController.text);
              if (page != null) {
                Navigator.pop(context);

                // Si el usuario ha llegado a la última página, preguntar si quiere marcarlo como completado
                if (maxPages > 0 && page >= maxPages) {
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: const Color(0xFF1A1A2E),
                      title: const Text('¡Felicidades!',
                          style: TextStyle(color: Colors.white)),
                      content: const Text(
                        '¡Has llegado al final del libro! ¿Quieres marcarlo como completado?',
                        style: TextStyle(color: Colors.white),
                      ),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: const Text('No, solo actualizar',
                              style: TextStyle(color: Colors.grey)),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);

                            // Marcar como completado
                            // Implementar en futuros pasos
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Sí, completado'),
                        ),
                      ],
                    ),
                  );
                }
              }
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

  void _showNotesAndReviews(BuildContext context, BookUserDto bookUser,
      BookDto? bookData, UserLibraryBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.6,
          minChildSize: 0.4,
          maxChildSize: 0.9,
          expand: false,
          builder: (context, scrollController) {
            return SingleChildScrollView(
              controller: scrollController,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título y botón de cerrar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            bookData?.title ?? 'Notas y reseñas',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const Divider(color: Colors.grey),

                    // Pestañas para notas y reseñas
                    DefaultTabController(
                      length: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const TabBar(
                            tabs: [
                              Tab(text: 'Notas'),
                              Tab(text: 'Reseñas'),
                            ],
                            labelColor: Colors.white,
                            unselectedLabelColor: Colors.grey,
                            indicatorColor: Color(0xFF8B5CF6),
                          ),
                          SizedBox(
                            height: 400,
                            child: TabBarView(
                              children: [
                                // Pestaña de notas
                                _buildNotesTab(bookUser, bloc),

                                // Pestaña de reseñas
                                _buildReviewsTab(bookUser, bloc),
                              ],
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
        );
      },
    );
  }

  Widget _buildNotesTab(BookUserDto bookUser, UserLibraryBloc bloc) {
    if (bookUser.notes.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.note_alt_outlined, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes notas para este libro',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddNoteDialog(context, bookUser, bloc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Añadir nota'),
            ),
          ],
        ),
      );
    }

    // Ordenar notas por página
    final sortedNotes = List<NoteDto>.from(bookUser.notes)
      ..sort((a, b) => a.page.compareTo(b.page));

    return ListView.builder(
      itemCount: sortedNotes.length,
      itemBuilder: (context, index) {
        final note = sortedNotes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF22223B),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la nota
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Página
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Página ${note.page}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // Fecha
                    Text(
                      _formatDate(note.createdAt),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // Contenido de la nota
                Text(
                  note.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildReviewsTab(BookUserDto bookUser, UserLibraryBloc bloc) {
    if (bookUser.reviews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.rate_review_outlined,
                size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No tienes reseñas para este libro',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _showAddReviewDialog(context, bookUser, bloc);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Añadir reseña'),
            ),
          ],
        ),
      );
    }

    // Ordenar reseñas por fecha (más recientes primero)
    final sortedReviews = List<ReviewDto>.from(bookUser.reviews)
      ..sort((a, b) => b.date.compareTo(a.date));

    return ListView.builder(
      itemCount: sortedReviews.length,
      itemBuilder: (context, index) {
        final review = sortedReviews[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          color: const Color(0xFF22223B),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado de la reseña
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Título o fecha
                    Text(
                      review.title ?? 'Reseña',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    // Fecha
                    Text(
                      _formatDate(review.date),
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),

                // Valoración
                if (review.rating > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(5, (index) {
                      return Icon(
                        index < review.rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16,
                      );
                    }),
                  ),
                ],

                // Contenido de la reseña
                const SizedBox(height: 8),
                Text(
                  review.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Hace ${difference.inMinutes} min';
      }
      return 'Hace ${difference.inHours} h';
    } else if (difference.inDays < 7) {
      return 'Hace ${difference.inDays} días';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}
