// lib/screens/reading_group/create_group_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/bloc/book_library/book_library_bloc.dart';
import '../../data/bloc/reading_group/reading_group_bloc.dart';
import '../../data/repositories/book_repository.dart';
import '../../data/repositories/reading_group_repository.dart';
import '../../injection.dart';
import '../../models/reading_group.dart';
import '../../models/dtos/book_dto.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();

  BookDto? _selectedBook;
  bool _isPrivate = false;
  DateTime? _targetDate;
  int? _pagesPerDay;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    // Cargar libros populares para la selección
    context.read<BookLibraryBloc>().add(BookLibraryLoadPopular());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _targetDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      helpText: 'Fecha objetivo de finalización',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: Theme.of(context).colorScheme,
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _targetDate = picked;
      });
    }
  }

  void _submitForm() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_selectedBook == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, selecciona un libro'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      // Crear objeto ReadingGoal si hay fecha objetivo o páginas por día
      ReadingGoal? readingGoal;
      if (_targetDate != null || _pagesPerDay != null) {
        readingGoal = ReadingGoal(
          targetFinishDate: _targetDate,
          pagesPerDay: _pagesPerDay,
        );
      }

      // Enviar evento de creación
      context.read<ReadingGroupBloc>().add(
            ReadingGroupCreate(
              name: _nameController.text,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
              bookId: _selectedBook!.id!,
              isPrivate: _isPrivate,
              readingGoal: readingGoal,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingGroupBloc(
        readingGroupRepository: getIt<IReadingGroupRepository>(),
      ),
      child: BlocListener<ReadingGroupBloc, ReadingGroupState>(
        listener: (context, state) {
          if (state is ReadingGroupCreated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Grupo creado con éxito'),
                backgroundColor: Colors.green,
              ),
            );

            // Navegar de vuelta a la lista de grupos
            Navigator.pop(context);
          } else if (state is ReadingGroupError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          appBar: AppBar(
            title: const Text('Crear Grupo de Lectura',
                style: TextStyle(color: Colors.white)),
            backgroundColor: const Color(0xFF1A1A2E),
            iconTheme: const IconThemeData(color: Colors.white),
            actions: [
              BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
                builder: (context, state) {
                  if (state is ReadingGroupActionInProgress) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }
                  return IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _submitForm,
                  );
                },
              ),
            ],
          ),
          body: Form(
            key: _formKey,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre del grupo
                  TextFormField(
                    controller: _nameController,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Nombre del grupo',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ej. Club de lectura fantástica',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.group, color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF1A1A2E),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa un nombre para el grupo';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Descripción
                  TextFormField(
                    controller: _descriptionController,
                    style: const TextStyle(color: Colors.white),
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Descripción (opcional)',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Describe el propósito del grupo',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.description, color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF1A1A2E),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Selección de libro
                  Text(
                    'Libro del grupo',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  _buildBookSelector(context),
                  const SizedBox(height: 24),

                  // Tipo de grupo
                  Row(
                    children: [
                      Text(
                        'Configuración del grupo',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    title: const Text('Grupo privado',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                      'Solo pueden unirse miembros invitados',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                    value: _isPrivate,
                    onChanged: (value) {
                      setState(() {
                        _isPrivate = value;
                      });
                    },
                    activeColor: const Color(0xFF8B5CF6),
                    tileColor: const Color(0xFF1A1A2E),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: const BorderSide(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Objetivos de lectura
                  Text(
                    'Objetivos de lectura (opcional)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),

                  // Fecha objetivo
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Fecha objetivo',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.calendar_today, color: Colors.grey),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                      ),
                      child: _targetDate == null
                          ? const Text(
                              'Seleccionar fecha objetivo',
                              style: TextStyle(color: Colors.grey),
                            )
                          : Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _dateFormat.format(_targetDate!),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.clear,
                                      color: Colors.grey, size: 18),
                                  onPressed: () {
                                    setState(() {
                                      _targetDate = null;
                                    });
                                  },
                                ),
                              ],
                            ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Páginas por día
                  TextFormField(
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      labelText: 'Páginas por día',
                      labelStyle: TextStyle(color: Colors.grey),
                      hintText: 'Ej. 20',
                      hintStyle: TextStyle(color: Colors.grey),
                      prefixIcon: Icon(Icons.menu_book, color: Colors.grey),
                      filled: true,
                      fillColor: Color(0xFF1A1A2E),
                      border: OutlineInputBorder(),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                    ),
                    onChanged: (value) {
                      setState(() {
                        _pagesPerDay = int.tryParse(value);
                      });
                    },
                  ),

                  const SizedBox(height: 32),

                  // Botón de creación
                  BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state is ReadingGroupActionInProgress
                              ? null
                              : _submitForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8B5CF6),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            disabledBackgroundColor: Colors.grey,
                          ),
                          child: state is ReadingGroupActionInProgress
                              ? const SizedBox(
                                  width: 24,
                                  height: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('CREAR GRUPO'),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookSelector(BuildContext context) {
    return BlocBuilder<BookLibraryBloc, BookLibraryState>(
      builder: (context, state) {
        if (state is BookLibraryLoading) {
          return const Center(
            child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
          );
        }

        if (state is BookLibraryError) {
          return Center(
            child: Column(
              children: [
                const Text(
                  'Error al cargar libros',
                  style: TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () {
                    context
                        .read<BookLibraryBloc>()
                        .add(BookLibraryLoadPopular());
                  },
                  child: const Text('Reintentar'),
                ),
              ],
            ),
          );
        }

        if (state is BookLibraryLoaded) {
          // Si ya hay un libro seleccionado, mostrarlo
          if (_selectedBook != null) {
            return Card(
              color: const Color(0xFF1A1A2E),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    // Portada del libro
                    Container(
                      width: 60,
                      height: 90,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        image: _selectedBook!.coverImage != null
                            ? DecorationImage(
                                image: NetworkImage(_selectedBook!.coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                        color: const Color(0xFF8B5CF6),
                      ),
                      child: _selectedBook!.coverImage == null
                          ? const Center(
                              child: Text('📚', style: TextStyle(fontSize: 24)),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),

                    // Detalles del libro
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedBook!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _selectedBook!.authors.isNotEmpty
                                ? _selectedBook!.authors.first
                                : 'Autor desconocido',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 4),
                          if (_selectedBook!.pageCount != null)
                            Text(
                              '${_selectedBook!.pageCount} páginas',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 14,
                              ),
                            ),
                        ],
                      ),
                    ),

                    // Botón para cambiar libro
                    IconButton(
                      icon:
                          const Icon(Icons.change_circle, color: Colors.white),
                      onPressed: () {
                        _showBookSelectionDialog(context, state.books);
                      },
                    ),
                  ],
                ),
              ),
            );
          }

          // Si no hay libro seleccionado, mostrar botón para seleccionar
          return OutlinedButton.icon(
            onPressed: () {
              _showBookSelectionDialog(context, state.books);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.grey),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            icon: const Icon(Icons.book),
            label: const Text('Seleccionar libro'),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  void _showBookSelectionDialog(BuildContext context, List<BookDto> books) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Seleccionar libro',
            style: TextStyle(color: Colors.white)),
        content: SizedBox(
          width: double.maxFinite,
          height: 400,
          child: ListView.builder(
            itemCount: books.length,
            itemBuilder: (context, index) {
              final book = books[index];
              return ListTile(
                leading: Container(
                  width: 40,
                  height: 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    image: book.coverImage != null
                        ? DecorationImage(
                            image: NetworkImage(book.coverImage!),
                            fit: BoxFit.cover,
                          )
                        : null,
                    color: const Color(0xFF8B5CF6),
                  ),
                  child: book.coverImage == null
                      ? const Center(
                          child: Text('📚', style: TextStyle(fontSize: 16)),
                        )
                      : null,
                ),
                title: Text(
                  book.title,
                  style: const TextStyle(color: Colors.white),
                ),
                subtitle: Text(
                  book.authors.isNotEmpty ? book.authors.first : 'Desconocido',
                  style: const TextStyle(color: Colors.grey),
                ),
                onTap: () {
                  setState(() {
                    _selectedBook = book;
                  });
                  Navigator.pop(context);
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () {
              // Navegar a la pantalla de búsqueda avanzada
              Navigator.pop(context);
              context.pushNamed('explore').then((selectedBook) {
                if (selectedBook != null && selectedBook is BookDto) {
                  setState(() {
                    _selectedBook = selectedBook;
                  });
                }
              });
            },
            child: const Text('Buscar más libros',
                style: TextStyle(color: Color(0xFF8B5CF6))),
          ),
        ],
      ),
    );
  }
}
