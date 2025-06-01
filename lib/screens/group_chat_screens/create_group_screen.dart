// lib/screens/reading_groups/create_group_screen.dart
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart'; // For ReadingGoal if used
import 'package:book_app_f/models/reading_group.dart'; // For ReadingGoal if used
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({Key? key}) : super(key: key);

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _bookIdController =
      TextEditingController(); // Simplified book selection
  bool _isPrivate = false;
  // ReadingGoal? _readingGoal; // Optional: Implement ReadingGoal selection UI

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _bookIdController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      context.read<ReadingGroupBloc>().add(
            ReadingGroupCreate(
              name: _nameController.text,
              description: _descriptionController.text.isNotEmpty
                  ? _descriptionController.text
                  : null,
              bookId: _bookIdController.text, // Ensure this bookId exists
              isPrivate: _isPrivate,
              // readingGoal: _readingGoal, // Optional
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReadingGroupBloc, ReadingGroupState>(
      listener: (context, state) {
        if (state is ReadingGroupOperationSuccess) {
          // Assuming a general success state
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Grupo creado con éxito'),
                backgroundColor: Colors.green),
          );
          Navigator.of(context).pop(); // Go back after creation
        } else if (state is ReadingGroupError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Error al crear grupo: ${state.message}'),
                backgroundColor: Colors.red),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: const Text('Crear Nuevo Grupo',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A2E),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildTextField(
                    controller: _nameController, labelText: 'Nombre del Grupo'),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _descriptionController,
                    labelText: 'Descripción (Opcional)',
                    isOptional: true),
                const SizedBox(height: 16),
                _buildTextField(
                    controller: _bookIdController,
                    labelText: 'ID del Libro (Requerido)'),
                const SizedBox(height: 16),
                SwitchListTile(
                  title: const Text('Grupo Privado',
                      style: TextStyle(color: Colors.white)),
                  value: _isPrivate,
                  onChanged: (bool value) {
                    setState(() {
                      _isPrivate = value;
                    });
                  },
                  activeColor: const Color(0xFF8B5CF6),
                  inactiveThumbColor: Colors.grey,
                  tileColor: const Color(0xFF1A1A2E),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                // Add ReadingGoal UI if needed here
                const SizedBox(height: 32),
                BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
                  builder: (context, state) {
                    if (state is ReadingGroupLoading) {
                      // Or a specific CreatingGroupState
                      return const Center(
                          child: CircularProgressIndicator(
                              color: Color(0xFF8B5CF6)));
                    }
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text('Crear Grupo',
                            style:
                                TextStyle(color: Colors.white, fontSize: 16)),
                        onPressed: _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
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

  Widget _buildTextField(
      {required TextEditingController controller,
      required String labelText,
      bool isOptional = false,
      int maxLines = 1}) {
    return TextFormField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.grey),
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
      ),
      maxLines: maxLines,
      validator: (value) {
        if (!isOptional && (value == null || value.isEmpty)) {
          return 'Este campo es obligatorio';
        }
        return null;
      },
    );
  }
}
