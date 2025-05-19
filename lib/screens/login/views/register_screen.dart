import 'package:book_app_f/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/bloc/register_bloc/register_bloc.dart';
import '../../../models/dtos/user_dto.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _appNameController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _lastName1Controller = TextEditingController();
  final _lastName2Controller = TextEditingController();
  final _idNumberController = TextEditingController();
  final _mobilePhoneController = TextEditingController();

  DateTime _birthDate = DateTime(DateTime.now().year - 18);
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _acceptTerms = false;

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void dispose() {
    _appNameController.dispose();
    _firstNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _lastName1Controller.dispose();
    _lastName2Controller.dispose();
    _idNumberController.dispose();
    _mobilePhoneController.dispose();
    super.dispose();
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

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocProvider(
      create: (context) => RegisterBloc(
        userRepository: context.read<UserRepository>(),
      ),
      child: BlocConsumer<RegisterBloc, RegisterState>(
        listener: (context, state) {
          if (state is RegisterSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Registro exitoso. ¡Bienvenido!'),
                backgroundColor: Colors.green,
              ),
            );
            context.goNamed('login');
          } else if (state is RegisterFailure) {
            // Mensaje de error
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.error),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Crear cuenta'),
              centerTitle: true,
              backgroundColor: colorScheme.surfaceVariant,
              foregroundColor: colorScheme.onSurfaceVariant,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Imagen de cabecera o logo
                      Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.only(bottom: 24),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: colorScheme.primaryContainer,
                          child: Icon(
                            Icons.person_add,
                            size: 50,
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),

                      // Mensaje de bienvenida
                      Text(
                        'Registro de nuevo usuario',
                        style: Theme.of(context).textTheme.titleLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),

                      // Datos personales - Primera fila
                      Text(
                        'Datos personales',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Nombre de la aplicación
                      TextFormField(
                        controller: _appNameController,
                        decoration: const InputDecoration(
                          labelText: 'Nombre de la App',
                          hintText: 'Ingrese el nombre de la aplicación',
                          prefixIcon: Icon(Icons.apps),
                          border: OutlineInputBorder(),
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
                        decoration: const InputDecoration(
                          labelText: 'Nombre',
                          hintText: 'Ingrese su nombre',
                          prefixIcon: Icon(Icons.person),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su nombre';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Primer apellido
                      TextFormField(
                        controller: _lastName1Controller,
                        decoration: const InputDecoration(
                          labelText: 'Primer apellido',
                          hintText: 'Ingrese su primer apellido',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su primer apellido';
                          }
                          return null;
                        },
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Segundo apellido (opcional)
                      TextFormField(
                        controller: _lastName2Controller,
                        decoration: const InputDecoration(
                          labelText: 'Segundo apellido (opcional)',
                          hintText: 'Ingrese su segundo apellido',
                          prefixIcon: Icon(Icons.person_outline),
                          border: OutlineInputBorder(),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),

                      // Número de identificación
                      TextFormField(
                        controller: _idNumberController,
                        decoration: const InputDecoration(
                          labelText: 'Número de identificación',
                          hintText: 'Ingrese su número de identificación',
                          prefixIcon: Icon(Icons.badge),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su número de identificación';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.text,
                      ),
                      const SizedBox(height: 16),

                      // Fecha de nacimiento
                      InkWell(
                        onTap: () => _selectDate(context),
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Fecha de nacimiento',
                            prefixIcon: Icon(Icons.calendar_today),
                            border: OutlineInputBorder(),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(_dateFormat.format(_birthDate)),
                              Icon(Icons.arrow_drop_down,
                                  color: colorScheme.primary),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Separador para datos de contacto
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Datos de contacto',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(
                          labelText: 'Correo electrónico',
                          hintText: 'Ingrese su correo electrónico',
                          prefixIcon: Icon(Icons.email),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su correo electrónico';
                          }
                          if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                              .hasMatch(value)) {
                            return 'Por favor ingrese un correo electrónico válido';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 16),

                      // Teléfono móvil
                      TextFormField(
                        controller: _mobilePhoneController,
                        decoration: const InputDecoration(
                          labelText: 'Teléfono móvil',
                          hintText: 'Ingrese su número de teléfono',
                          prefixIcon: Icon(Icons.phone_android),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese su número de teléfono';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(15),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Separador para credenciales
                      const Divider(),
                      const SizedBox(height: 8),
                      Text(
                        'Credenciales de acceso',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: colorScheme.primary,
                                ),
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      TextFormField(
                        controller: _passwordController,
                        obscureText: _obscurePassword,
                        decoration: InputDecoration(
                          labelText: 'Contraseña',
                          hintText: 'Cree una contraseña segura',
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor ingrese una contraseña';
                          }
                          if (value.length < 6) {
                            return 'La contraseña debe tener al menos 6 caracteres';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Confirmar contraseña
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          labelText: 'Confirmar contraseña',
                          hintText: 'Confirme su contraseña',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                          ),
                          border: const OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor confirme su contraseña';
                          }
                          if (value != _passwordController.text) {
                            return 'Las contraseñas no coinciden';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Términos y condiciones
                      Row(
                        children: [
                          Checkbox(
                            value: _acceptTerms,
                            onChanged: (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                          ),
                          Expanded(
                            child: Text(
                              'He leído y acepto los términos y condiciones y la política de privacidad',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Botón de registro
                      state is RegisterLoading
                          ? const Center(child: CircularProgressIndicator())
                          : FilledButton(
                              onPressed: _acceptTerms
                                  ? () {
                                      if (_formKey.currentState?.validate() ??
                                          false) {
                                        // Crear objeto UserDto para registro
                                        final userDto = UserDto.forRegistration(
                                          appName: _appNameController.text,
                                          firstName: _firstNameController.text,
                                          email: _emailController.text,
                                          password: _passwordController.text,
                                          lastName1: _lastName1Controller.text,
                                          lastName2:
                                              _lastName2Controller.text.isEmpty
                                                  ? null
                                                  : _lastName2Controller.text,
                                          idNumber: _idNumberController.text,
                                          mobilePhone:
                                              _mobilePhoneController.text,
                                          birthDate: _birthDate,
                                        );

                                        // Enviar evento de registro
                                        context.read<RegisterBloc>().add(
                                              RegisterSubmitted(
                                                  userDto: userDto),
                                            );
                                      }
                                    }
                                  : null,
                              style: FilledButton.styleFrom(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                              ),
                              child: const Text('CREAR CUENTA'),
                            ),
                      const SizedBox(height: 24),

                      // Enlace para ir a login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text('¿Ya tienes una cuenta?'),
                          TextButton(
                            onPressed: () {
                              context.goNamed('login');
                            },
                            child: const Text('Iniciar sesión'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
