// lib/screens/group_chat_screens/select_book_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/bloc/book_library/book_library_bloc.dart';
import '../../models/dtos/book_dto.dart';

class SelectBookScreen extends StatefulWidget {
  const SelectBookScreen({super.key});

  @override
  State<SelectBookScreen> createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends State<SelectBookScreen> {
  final _searchController = TextEditingController();
  String? _selectedGenre;

  @override
  void initState() {
    super.initState();
    context.read<BookLibraryBloc>().add(BookLibraryLoadBooks());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Seleccionar libro',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(null), // Regresar sin selección
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildSearchBar(),
            _buildCategoriesFilter(),
            Expanded(
              child: BlocBuilder<BookLibraryBloc, BookLibraryState>(
                builder: (context, state) {
                  if (state is BookLibraryLoading) {
                    return const Center(
                        child: CircularProgressIndicator(
                            color: Color(0xFF8B5CF6)));
                  }

                  if (state is BookLibraryError) {
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
                                .read<BookLibraryBloc>()
                                .add(BookLibraryLoadBooks()),
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is BookLibraryLoaded) {
                    if (state.currentGenre != null && _selectedGenre == null) {
                      _selectedGenre = state.currentGenre;
                    } else if (state.currentGenre == null) {
                      _selectedGenre = null;
                    }

                    return _buildBookGrid(state.books);
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Buscar libros para tu grupo...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            setState(() {
              _selectedGenre = null;
            });
            context
                .read<BookLibraryBloc>()
                .add(BookLibrarySearchBooks(query: query));
          } else {
            setState(() {
              _selectedGenre = null;
            });
            context.read<BookLibraryBloc>().add(BookLibraryClearFilters());
          }
        },
      ),
    );
  }

  Widget _buildCategoriesFilter() {
    final categories = [
      'Todos',
      'Novela',
      'Ciencia Ficción',
      'Fantasía',
      'Misterio',
      'Romance',
      'Historia',
      'Biografía'
    ];

    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected =
              index == 0 ? _selectedGenre == null : category == _selectedGenre;

          return Container(
            margin: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(category),
              onSelected: (selected) {
                if (index == 0) {
                  setState(() {
                    _selectedGenre = null;
                  });
                  context
                      .read<BookLibraryBloc>()
                      .add(BookLibraryClearFilters());
                } else {
                  setState(() {
                    _selectedGenre = category;
                  });
                  context
                      .read<BookLibraryBloc>()
                      .add(BookLibraryFilterByGenre(genre: category));
                }
              },
              backgroundColor: const Color(0xFF1A1A2E),
              selectedColor: const Color(0xFF8B5CF6),
              checkmarkColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildBookGrid(List<BookDto> books) {
    if (books.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.menu_book_outlined,
              size: 60,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedGenre != null
                  ? 'No se encontraron libros de ${_selectedGenre}'
                  : 'No se encontraron libros con estos criterios',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  _selectedGenre = null;
                  _searchController.clear();
                });
                context.read<BookLibraryBloc>().add(BookLibraryLoadBooks());
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('Ver todos los libros'),
            ),
          ],
        ),
      );
    } else {
      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.7,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: books.length,
        itemBuilder: (context, index) {
          final book = books[index];
          return _buildSelectableBookCard(book);
        },
      );
    }
  }

  Widget _buildSelectableBookCard(BookDto book) {
    return GestureDetector(
      onTap: () {
        // Mostrar diálogo de confirmación
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Confirmar selección',
                style: TextStyle(color: Colors.white),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 100,
                    height: 150,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      image:
                          book.coverImage != null && book.coverImage!.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(book.coverImage!),
                                  fit: BoxFit.cover,
                                )
                              : null,
                      gradient: book.coverImage == null ||
                              book.coverImage!.isEmpty
                          ? const LinearGradient(
                              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                            )
                          : null,
                    ),
                    child: book.coverImage == null || book.coverImage!.isEmpty
                        ? const Center(
                            child: Text('📚', style: TextStyle(fontSize: 40)),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    book.authors.isNotEmpty
                        ? book.authors.first
                        : 'Desconocido',
                    style: const TextStyle(color: Colors.grey, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    '¿Seleccionar este libro para tu grupo?',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text(
                    'Cancelar',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Cerrar diálogo
                    context.pop(book); // Retornar el libro seleccionado
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8B5CF6),
                  ),
                  child: const Text('Seleccionar'),
                ),
              ],
            );
          },
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Portada del libro
                Expanded(
                  child: Container(
                    width: double.infinity,
                    decoration: const BoxDecoration(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(12)),
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFF8B5CF6),
                          Color(0xFFEC4899),
                        ],
                      ),
                    ),
                    child:
                        book.coverImage != null && book.coverImage!.isNotEmpty
                            ? ClipRRect(
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)),
                                child: Image.network(
                                  book.coverImage!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Center(
                                      child: Text(
                                        '📚',
                                        style: TextStyle(fontSize: 40),
                                      ),
                                    );
                                  },
                                ),
                              )
                            : const Center(
                                child: Text(
                                  '📚',
                                  style: TextStyle(fontSize: 40),
                                ),
                              ),
                  ),
                ),

                // Información del libro
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        book.authors.isNotEmpty
                            ? book.authors.first
                            : 'Desconocido',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.star, color: Colors.amber, size: 14),
                          Text(
                            ' ${book.averageRating.toStringAsFixed(1)}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            // Overlay de hover effect
            Positioned.fill(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: null,
                  splashColor: const Color(0xFF8B5CF6).withOpacity(0.3),
                  highlightColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
