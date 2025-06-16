// lib/screens/admin_screens/admin_books/create_book_screen.dart
import 'package:book_app_f/data/bloc/create_book/create_book_bloc.dart';
import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

class CreateBookScreen extends StatefulWidget {
  const CreateBookScreen({Key? key}) : super(key: key);

  @override
  State<CreateBookScreen> createState() => _CreateBookScreenState();
}

class _CreateBookScreenState extends State<CreateBookScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _isbnController = TextEditingController();
  final _publisherController = TextEditingController();
  final _editionController = TextEditingController();
  final _pageCountController = TextEditingController();
  final _coverImageController = TextEditingController();

  final List<TextEditingController> _authorControllers = [];
  final List<TextEditingController> _genreControllers = [];
  final List<TextEditingController> _tagControllers = [];

  String _selectedLanguage = 'Español';
  DateTime? _publicationDate;

  final List<String> _languages = [
    'Español',
    'Inglés',
    'Francés',
    'Alemán',
    'Italiano',
    'Portugués',
    'Catalán',
    'Gallego',
    'Euskera',
    'Otro'
  ];

  @override
  void initState() {
    super.initState();
    // Inicializar con al menos un campo para autor y género
    _addAuthorField();
    _addGenreField();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _isbnController.dispose();
    _publisherController.dispose();
    _editionController.dispose();
    _pageCountController.dispose();
    _coverImageController.dispose();

    for (var controller in _authorControllers) {
      controller.dispose();
    }
    for (var controller in _genreControllers) {
      controller.dispose();
    }
    for (var controller in _tagControllers) {
      controller.dispose();
    }

    super.dispose();
  }

  void _addAuthorField() {
    setState(() {
      _authorControllers.add(TextEditingController());
    });
  }

  void _removeAuthorField(int index) {
    if (_authorControllers.length > 1) {
      setState(() {
        _authorControllers[index].dispose();
        _authorControllers.removeAt(index);
      });
    }
  }

  void _addGenreField() {
    setState(() {
      _genreControllers.add(TextEditingController());
    });
  }

  void _removeGenreField(int index) {
    setState(() {
      _genreControllers[index].dispose();
      _genreControllers.removeAt(index);
    });
  }

  void _addTagField() {
    setState(() {
      _tagControllers.add(TextEditingController());
    });
  }

  void _removeTagField(int index) {
    setState(() {
      _tagControllers[index].dispose();
      _tagControllers.removeAt(index);
    });
  }

  List<String> _getAuthors() {
    return _authorControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  List<String> _getGenres() {
    return _genreControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  List<String> _getTags() {
    return _tagControllers
        .map((controller) => controller.text.trim())
        .where((text) => text.isNotEmpty)
        .toList();
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _publicationDate ?? DateTime.now(),
      firstDate: DateTime(1000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF8B5CF6),
              onPrimary: Colors.white,
              surface: Color(0xFF1A1A2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _publicationDate = picked;
      });
    }
  }

  void _submitBook(CreateBookBloc bloc) {
    if (_formKey.currentState!.validate()) {
      final authors = _getAuthors();
      if (authors.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Debe haber al menos un autor'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final newBook = BookDto.forCreation(
        title: _titleController.text.trim(),
        authors: authors,
        synopsis: _synopsisController.text.trim().isEmpty
            ? null
            : _synopsisController.text.trim(),
        isbn: _isbnController.text.trim().isEmpty
            ? null
            : _isbnController.text.trim(),
        publisher: _publisherController.text.trim().isEmpty
            ? null
            : _publisherController.text.trim(),
        publicationDate: _publicationDate,
        edition: _editionController.text.trim().isEmpty
            ? null
            : _editionController.text.trim(),
        language: _selectedLanguage,
        pageCount: _pageCountController.text.trim().isEmpty
            ? null
            : int.tryParse(_pageCountController.text.trim()),
        genres: _getGenres(),
        tags: _getTags(),
        coverImage: _coverImageController.text.trim().isEmpty
            ? null
            : _coverImageController.text.trim(),
      );

      bloc.add(CreateBookSubmit(book: newBook));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Crear Nuevo Libro',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save, color: Colors.white),
            onPressed: () => _submitBook(context.read<CreateBookBloc>()),
          ),
        ],
      ),
      body: BlocConsumer<CreateBookBloc, CreateBookState>(
        listener: (context, state) {
          if (state is CreateBookSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Libro creado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
            Future.delayed(const Duration(seconds: 1), () {
              context.pop(true); // Devolver true para indicar éxito
            });
          } else if (state is CreateBookError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is CreateBookLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }

          return _buildForm();
        },
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Título
            _buildSectionTitle('Información básica'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _titleController,
              label: 'Título *',
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'El título es requerido';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Autores
            _buildSectionTitle('Autores *'),
            const SizedBox(height: 8),
            _buildAuthorFields(),
            const SizedBox(height: 16),

            // Sinopsis
            _buildTextField(
              controller: _synopsisController,
              label: 'Sinopsis',
              maxLines: 5,
            ),
            const SizedBox(height: 24),

            // Información de publicación
            _buildSectionTitle('Información de publicación'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _isbnController,
              label: 'ISBN',
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _publisherController,
              label: 'Editorial',
            ),
            const SizedBox(height: 16),

            // Fecha de publicación
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _publicationDate != null
                          ? DateFormat('dd/MM/yyyy').format(_publicationDate!)
                          : 'Fecha de publicación',
                      style: TextStyle(
                        color: _publicationDate != null
                            ? Colors.white
                            : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today, color: Colors.grey),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _editionController,
              label: 'Edición',
            ),
            const SizedBox(height: 16),

            // Idioma
            DropdownButtonFormField<String>(
              value: _selectedLanguage,
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                labelText: 'Idioma',
                labelStyle: TextStyle(color: Colors.grey),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
              dropdownColor: const Color(0xFF1A1A2E),
              items: _languages.map((String language) {
                return DropdownMenuItem<String>(
                  value: language,
                  child: Text(language),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedLanguage = newValue;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _pageCountController,
              label: 'Número de páginas',
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  final pages = int.tryParse(value);
                  if (pages == null || pages <= 0) {
                    return 'Debe ser un número válido mayor a 0';
                  }
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // Categorización
            _buildSectionTitle('Categorización'),
            const SizedBox(height: 16),

            // Géneros
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Géneros',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
                  onPressed: _addGenreField,
                ),
              ],
            ),
            _buildGenreFields(),
            const SizedBox(height: 16),

            // Tags
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Etiquetas',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
                  onPressed: _addTagField,
                ),
              ],
            ),
            _buildTagFields(),
            const SizedBox(height: 24),

            // Imagen
            _buildSectionTitle('Imagen de portada'),
            const SizedBox(height: 16),

            _buildTextField(
              controller: _coverImageController,
              label: 'URL de la imagen',
            ),
            const SizedBox(height: 32),

            // Botón de guardar
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => _submitBook(context.read<CreateBookBloc>()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text(
                  'Crear Libro',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF8B5CF6),
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.grey),
        alignLabelWithHint: maxLines > 1,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildAuthorFields() {
    return Column(
      children: [
        ...List.generate(_authorControllers.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _authorControllers[index],
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Autor ${index + 1}',
                      labelStyle: const TextStyle(color: Colors.grey),
                      enabledBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: () => _removeAuthorField(index),
                ),
              ],
            ),
          );
        }),
        const SizedBox(height: 8),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _addAuthorField,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF8B5CF6)),
            ),
            icon: const Icon(Icons.add, color: Color(0xFF8B5CF6)),
            label: const Text(
              'Añadir autor',
              style: TextStyle(color: Color(0xFF8B5CF6)),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenreFields() {
    if (_genreControllers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(_genreControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _genreControllers[index],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Género ${index + 1}',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeGenreField(index),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildTagFields() {
    if (_tagControllers.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      children: List.generate(_tagControllers.length, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _tagControllers[index],
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Etiqueta ${index + 1}',
                    labelStyle: const TextStyle(color: Colors.grey),
                    enabledBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: const OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.remove_circle, color: Colors.red),
                onPressed: () => _removeTagField(index),
              ),
            ],
          ),
        );
      }),
    );
  }
}
