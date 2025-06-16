// lib/screens/search_books/explore_screen.dart
import 'dart:io';

import 'package:book_app_f/routes/book_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../data/bloc/book_library/book_library_bloc.dart';
import '../../models/dtos/book_dto.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
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
        backgroundColor: const Color(0xFF0A0A0F),
        elevation: 0,
        title: const Text(
          'Explorar Libros',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.home,
              color: Color(0xFF8B5CF6),
              size: 28,
            ),
            onPressed: () {
              Platform.isWindows
                  ? context.goNamed(AppRouter.adminHome)
                  : context.goNamed(AppRouter.home);
            },
            tooltip: 'Ir al inicio',
          ),
          const SizedBox(width: 8),
        ],
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
                    // Actualizar el género seleccionado basado en el estado
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
          hintText: 'Buscar libros, autores, géneros...',
          hintStyle: TextStyle(color: Colors.grey[400]),
          prefixIcon: const Icon(Icons.search, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFF1A1A2E),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          suffixIcon: IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.grey),
            onPressed: () {
              // Mostrar filtros avanzados
            },
          ),
        ),
        onSubmitted: (query) {
          if (query.isNotEmpty) {
            setState(() {
              _selectedGenre = null; // Limpiar género seleccionado al buscar
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
      child: BlocBuilder<BookLibraryBloc, BookLibraryState>(
        builder: (context, state) {
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) {
              final category = categories[index];
              // Establecer selección para 'Todos' cuando no hay género seleccionado
              final isSelected = index == 0
                  ? _selectedGenre == null
                  : category == _selectedGenre;

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
          return _buildBookCard(book);
        },
      );
    }
  }

  Widget _buildBookCard(BookDto book) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          'book-detail',
          pathParameters: {'id': book.id!},
        );
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
            // Portada del libro
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF8B5CF6),
                      Color(0xFFEC4899),
                    ],
                  ),
                ),
                child: book.coverImage != null && book.coverImage!.isNotEmpty
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
                      const SizedBox(width: 8),
                      if (book.pageCount != null)
                        Text(
                          '${book.pageCount} págs',
                          style:
                              TextStyle(color: Colors.grey[400], fontSize: 12),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
