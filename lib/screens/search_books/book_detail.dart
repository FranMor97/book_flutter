// lib/screens/explore/book_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/bloc/book_detail/book_detail_bloc.dart';
import '../../injection.dart';
import '../../models/dtos/book_dto.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) =>
          getIt<BookDetailBloc>()..add(BookDetailLoad(bookId: bookId)),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        body: BlocBuilder<BookDetailBloc, BookDetailState>(
          builder: (context, state) {
            if (state is BookDetailLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              );
            }

            if (state is BookDetailError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.red, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<BookDetailBloc>()
                          .add(BookDetailLoad(bookId: bookId)),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            if (state is BookDetailLoaded) {
              return _buildBookDetail(context, state.book, state.userBook);
            }

            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }

  Widget _buildBookDetail(
      BuildContext context, BookDto book, UserBookStatus? userBook) {
    return CustomScrollView(
      slivers: [
        // App Bar con imagen de fondo
        SliverAppBar(
          expandedHeight: 300.0,
          floating: false,
          pinned: true,
          backgroundColor: Colors.transparent,
          flexibleSpace: FlexibleSpaceBar(
            background: book.coverImage != null && book.coverImage!.isNotEmpty
                ? Image.network(
                    book.coverImage!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                        ),
                      ),
                      child: const Center(
                          child: Text('📚', style: TextStyle(fontSize: 80))),
                    ),
                  )
                : Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                      ),
                    ),
                    child: const Center(
                        child: Text('📚', style: TextStyle(fontSize: 80))),
                  ),
          ),
          leading: Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          actions: [
            Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.share, color: Colors.white),
                onPressed: () {
                  // Compartir libro
                },
              ),
            ),
          ],
        ),

        // Contenido del libro
        SliverToBoxAdapter(
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título y autor
                Text(
                  book.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  book.authors.join(', '),
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
                  ),
                ),

                // Rating y estadísticas
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 20),
                    Text(
                      ' ${book.averageRating.toStringAsFixed(1)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' (${book.totalRatings} valoraciones)',
                      style: const TextStyle(color: Colors.grey),
                    ),
                    const Spacer(),
                    if (book.pageCount != null)
                      Text(
                        '${book.pageCount} páginas',
                        style: const TextStyle(color: Colors.grey),
                      ),
                  ],
                ),

                // Botones de acción
                const SizedBox(height: 24),
                _buildActionButtons(context, book, userBook),

                // Géneros
                if (book.genres.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Géneros',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: book.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        backgroundColor: const Color(0xFF1A1A2E),
                        labelStyle: const TextStyle(color: Colors.white),
                      );
                    }).toList(),
                  ),
                ],

                // Sinopsis
                if (book.synopsis != null && book.synopsis!.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Sinopsis',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.synopsis!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],

                // Detalles del libro
                const SizedBox(height: 24),
                const Text(
                  'Detalles',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildDetailItem('Editorial', book.publisher ?? 'Desconocida'),
                _buildDetailItem('ISBN', book.isbn ?? 'No disponible'),
                _buildDetailItem('Idioma', book.language),
                if (book.publicationDate != null)
                  _buildDetailItem(
                    'Fecha de publicación',
                    '${book.publicationDate!.day}/${book.publicationDate!.month}/${book.publicationDate!.year}',
                  ),
                if (book.edition != null && book.edition!.isNotEmpty)
                  _buildDetailItem('Edición', book.edition!),

                // Espacio final
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(
      BuildContext context, BookDto book, UserBookStatus? userBook) {
    // Si el libro ya está en la biblioteca del usuario
    if (userBook != null) {
      return Column(
        children: [
          // Botón principal según el estado
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () {
                // Actualizar estado o ir a la pantalla de lectura
                if (userBook.status == 'to-read') {
                  context.read<BookDetailBloc>().add(
                        BookDetailUpdateStatus(
                          bookId: book.id!,
                          status: 'reading',
                        ),
                      );
                } else if (userBook.status == 'reading') {
                  // Navegar a la pantalla de lectura
                  // context.go('/reading/${userBook.id}');
                }
              },
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                userBook.status == 'to-read'
                    ? 'Comenzar a leer'
                    : userBook.status == 'reading'
                        ? 'Continuar leyendo'
                        : 'Leer de nuevo',
              ),
            ),
          ),

          // Menú de cambio de estado
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () {
                _showStatusChangeMenu(
                    context, book, userBook, context.read<BookDetailBloc>());
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Cambiar estado',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ),
        ],
      );
    }

    // Si el libro no está en la biblioteca
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () {
          context.read<BookDetailBloc>().add(
                BookDetailAddToLibrary(
                  bookId: book.id!,
                  status: 'to-read',
                ),
              );
        },
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text('Añadir a mi biblioteca'),
      ),
    );
  }

  void _showStatusChangeMenu(BuildContext context, BookDto book,
      UserBookStatus userBook, BookDetailBloc bloc) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return BlocProvider.value(
          value: bloc,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Cambiar estado',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                _buildStatusOption(
                  context,
                  'Por leer',
                  'to-read',
                  userBook.status,
                  book.id!,
                  bloc,
                ),
                _buildStatusOption(
                  context,
                  'Leyendo',
                  'reading',
                  userBook.status,
                  book.id!,
                  bloc,
                ),
                _buildStatusOption(
                  context,
                  'Completado',
                  'completed',
                  userBook.status,
                  book.id!,
                  bloc,
                ),
                _buildStatusOption(
                  context,
                  'Abandonado',
                  'abandoned',
                  userBook.status,
                  book.id!,
                  bloc,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatusOption(
    BuildContext context,
    String label,
    String status,
    String currentStatus,
    String bookId,
    BookDetailBloc bloc,
  ) {
    final isSelected = status == currentStatus;

    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? const Color(0xFF8B5CF6) : Colors.white,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      leading: Radio<String>(
        value: status,
        groupValue: currentStatus,
        onChanged: (value) {
          Navigator.pop(context);
          bloc.add(
            BookDetailUpdateStatus(
              bookId: bookId,
              status: value!,
            ),
          );
        },
        activeColor: const Color(0xFF8B5CF6),
      ),
      onTap: () {
        if (status != currentStatus) {
          Navigator.pop(context);
          bloc.add(
            BookDetailUpdateStatus(
              bookId: bookId,
              status: status,
            ),
          );
        }
      },
    );
  }
}

class UserBookStatus {
  final String id;
  final String status;
  final int currentPage;

  UserBookStatus({
    required this.id,
    required this.status,
    this.currentPage = 0,
  });
}
