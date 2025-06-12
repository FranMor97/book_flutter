// lib/screens/reading_group/create_group_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/bloc/reading_group/reading_group_bloc.dart';
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

      ReadingGoal? readingGoal;
      if (_targetDate != null || _pagesPerDay != null) {
        readingGoal = ReadingGoal(
          targetFinishDate: _targetDate,
          pagesPerDay: _pagesPerDay,
        );
      }

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

  Future<void> _navigateToBookSearch() async {
    final result = await context.pushNamed<BookDto?>('select-book-screen');
    if (result != null) {
      setState(() {
        _selectedBook = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReadingGroupBloc, ReadingGroupState>(
      listener: (context, state) {
        if (state is ReadingGroupCreated) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Grupo creado con éxito'),
              backgroundColor: Colors.green,
            ),
          );
          context.pop();
        } else if (state is ReadingGroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al crear el grupo: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: const Text(
            'Crear Grupo de Lectura',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: const Color(0xFF1A1A2E),
          iconTheme: const IconThemeData(color: Colors.white),
          actions: [
            // Botón de home
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Color(0xFF8B5CF6),
                size: 28,
              ),
              onPressed: () {
                context.goNamed('home');
              },
              tooltip: 'Ir al inicio',
            ),
            const SizedBox(width: 8),
            // Botón de guardar/loading
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
                  tooltip: 'Crear grupo',
                );
              },
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Nombre del grupo',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.group, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A2E),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingresa un nombre para el grupo';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Descripción (opcional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.description, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A2E),
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
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
                Text(
                  'Configuración del grupo',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                SwitchListTile(
                  title: const Text('Grupo privado',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Solo pueden unirse miembros invitados',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: _isPrivate,
                  onChanged: (value) => setState(() => _isPrivate = value),
                  activeColor: const Color(0xFF8B5CF6),
                  tileColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                const SizedBox(height: 24),
                Text(
                  'Objetivos de lectura (opcional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
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
                    ),
                    child: _targetDate == null
                        ? const Text('Seleccionar fecha',
                            style: TextStyle(color: Colors.grey))
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_dateFormat.format(_targetDate!),
                                  style: const TextStyle(color: Colors.white)),
                              IconButton(
                                icon: const Icon(Icons.clear,
                                    color: Colors.grey, size: 18),
                                onPressed: () =>
                                    setState(() => _targetDate = null),
                              ),
                            ],
                          ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Páginas por día',
                    labelStyle: TextStyle(color: Colors.grey),
                    prefixIcon: Icon(Icons.menu_book, color: Colors.grey),
                    filled: true,
                    fillColor: Color(0xFF1A1A2E),
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (value) =>
                      setState(() => _pagesPerDay = int.tryParse(value)),
                ),
                const SizedBox(height: 32),
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
                                    color: Colors.white, strokeWidth: 2))
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
    );
  }

  Widget _buildBookSelector(BuildContext context) {
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
              Container(
                width: 60,
                height: 90,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  image: _selectedBook!.coverImage != null
                      ? DecorationImage(
                          image: NetworkImage(_selectedBook!.coverImage!),
                          fit: BoxFit.cover)
                      : null,
                  color: const Color(0xFF8B5CF6),
                ),
                child: _selectedBook!.coverImage == null
                    ? const Center(
                        child: Text('📚', style: TextStyle(fontSize: 24)))
                    : null,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedBook!.title,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedBook!.authors.isNotEmpty
                          ? _selectedBook!.authors.first
                          : 'Autor desconocido',
                      style: const TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.change_circle_outlined,
                    color: Colors.white),
                tooltip: 'Cambiar libro',
                onPressed: _navigateToBookSearch,
              ),
            ],
          ),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: _navigateToBookSearch,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: const BorderSide(color: Colors.grey),
        minimumSize: const Size(double.infinity, 50),
        padding: const EdgeInsets.symmetric(vertical: 16),
      ),
      icon: const Icon(Icons.search),
      label: const Text('Seleccionar un libro'),
    );
  }
}
