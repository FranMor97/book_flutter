// lib/screens/profile/user_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/bloc/user_profile/user_profile_bloc.dart';
import '../../models/dtos/user_dto.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastName1Controller = TextEditingController();
  final _lastName2Controller = TextEditingController();
  final _mobilePhoneController = TextEditingController();

  DateTime _birthDate = DateTime.now();
  final _dateFormat = DateFormat('dd/MM/yyyy');

  // Mantener referencia al usuario actual
  UserDto? _currentUser;

  @override
  void initState() {
    super.initState();
    context.read<UserProfileBloc>().add(UserProfileLoad());
  }

  @override
  void dispose() {
    _appNameController.dispose();
    _firstNameController.dispose();
    _lastName1Controller.dispose();
    _lastName2Controller.dispose();
    _mobilePhoneController.dispose();
    super.dispose();
  }

  void _populateFormFields(UserDto user) {
    // Guardar referencia al usuario actual
    _currentUser = user;

    // Actualizar controladores sin setState
    _appNameController.text = user.appName;
    _firstNameController.text = user.firstName;
    _lastName1Controller.text = user.lastName1;
    _lastName2Controller.text = user.lastName2 ?? '';
    _mobilePhoneController.text = user.mobilePhone;

    // Normalizar la fecha para evitar problemas de zona horaria
    _birthDate = DateTime(user.birthDate.year, user.birthDate.month,
        user.birthDate.day, 12, 0, 0);
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _birthDate,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      helpText: 'Seleccionar fecha de nacimiento',
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
      // Asegurarnos de que se guarde exactamente la fecha seleccionada
      // sin correcciones por zona horaria
      setState(() {
        // Crear una nueva fecha usando año, mes y día para evitar problemas de zona horaria
        _birthDate = DateTime(picked.year, picked.month, picked.day, 12, 0, 0);

        print('Fecha seleccionada: ${_dateFormat.format(_birthDate)}');
        print('Día seleccionado: ${_birthDate.day}');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Mi Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: BlocConsumer<UserProfileBloc, UserProfileState>(
        listener: (context, state) {
          if (state is UserProfileUpdateSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Perfil actualizado correctamente'),
                backgroundColor: Colors.green,
              ),
            );
          } else if (state is UserProfileError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Error: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is UserProfileLoaded) {
            // Llamar a _populateFormFields desde el listener
            _populateFormFields(state.user);
          }
        },
        builder: (context, state) {
          if (state is UserProfileLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }

          if (state is UserProfileLoaded) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Avatar o foto de perfil
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: const Color(0xFF8B5CF6),
                        child: Text(
                          state.user.firstName.isNotEmpty
                              ? state.user.firstName
                                  .substring(0, 1)
                                  .toUpperCase()
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Email (no editable)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A1A2E),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(color: Colors.grey),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            state.user.email,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Nombre de la aplicación
                    TextFormField(
                      controller: _appNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre de la App',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.apps, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre de la aplicación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nombre
                    TextFormField(
                      controller: _firstNameController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon: Icon(Icons.person, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su nombre';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Primer apellido
                    TextFormField(
                      controller: _lastName1Controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Primer apellido',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.person_outline, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su primer apellido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Segundo apellido (opcional)
                    TextFormField(
                      controller: _lastName2Controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Segundo apellido (opcional)',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.person_outline, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Teléfono móvil
                    TextFormField(
                      controller: _mobilePhoneController,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        labelText: 'Teléfono móvil',
                        labelStyle: TextStyle(color: Colors.grey),
                        prefixIcon:
                            Icon(Icons.phone_android, color: Colors.grey),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                        ),
                        filled: true,
                        fillColor: Color(0xFF1A1A2E),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su número de teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Fecha de nacimiento
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          labelStyle: TextStyle(color: Colors.grey),
                          prefixIcon:
                              Icon(Icons.calendar_today, color: Colors.grey),
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.grey),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                          ),
                          filled: true,
                          fillColor: Color(0xFF1A1A2E),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _dateFormat.format(_birthDate),
                              style: const TextStyle(color: Colors.white),
                            ),
                            const Icon(Icons.arrow_drop_down,
                                color: Color(0xFF8B5CF6)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Botón de guardar cambios
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state is UserProfileUpdating
                            ? null
                            : () {
                                if (_formKey.currentState!.validate() &&
                                    _currentUser != null) {
                                  // Crear DTO para actualización con fecha normalizada
                                  final userDto = UserDto.forUpdate(
                                    id: _currentUser!.id!,
                                    appName: _appNameController.text,
                                    firstName: _firstNameController.text,
                                    lastName1: _lastName1Controller.text,
                                    lastName2: _lastName2Controller.text.isEmpty
                                        ? null
                                        : _lastName2Controller.text,
                                    mobilePhone: _mobilePhoneController.text,
                                    birthDate: DateTime(
                                        _birthDate.year,
                                        _birthDate.month,
                                        _birthDate.day,
                                        12,
                                        0,
                                        0),
                                    avatar: _currentUser!.avatar,
                                  );

                                  // Disparar evento de actualización
                                  context.read<UserProfileBloc>().add(
                                        UserProfileUpdate(userDto: userDto),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: state is UserProfileUpdating
                            ? const CircularProgressIndicator(
                                color: Colors.white)
                            : const Text('GUARDAR CAMBIOS'),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          if (state is UserProfileError) {
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
                    onPressed: () =>
                        context.read<UserProfileBloc>().add(UserProfileLoad()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
