import 'dart:io';
import 'package:book_app_f/routes/book_routes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../data/bloc/register_bloc/register_bloc.dart';
import '../../../models/dtos/user_dto.dart';

class AdminRegisterScreen extends StatefulWidget {
  const AdminRegisterScreen({super.key});

  @override
  State<AdminRegisterScreen> createState() => _AdminRegisterScreenState();
}

class _AdminRegisterScreenState extends State<AdminRegisterScreen> {
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
  String _userType = 'client'; // 'client' o 'admin'

  final _dateFormat = DateFormat('dd/MM/yyyy');

  @override
  void initState() {
    super.initState();
    _appNameController.addListener(_updateFormState);
    _firstNameController.addListener(_updateFormState);
    _emailController.addListener(_updateFormState);
    _passwordController.addListener(_updateFormState);
    _confirmPasswordController.addListener(_updateFormState);
    _lastName1Controller.addListener(_updateFormState);
    _idNumberController.addListener(_updateFormState);
    _mobilePhoneController.addListener(_updateFormState);
  }

  void _updateFormState() {
    if (context.mounted) {
      context.read<RegisterBloc>().add(
            RegisterFormChanged(
              appName: _appNameController.text,
              firstName: _firstNameController.text,
              email: _emailController.text,
              password: _passwordController.text,
              confirmPassword: _confirmPasswordController.text,
              lastName1: _lastName1Controller.text,
              lastName2: _lastName2Controller.text,
              idNumber: _idNumberController.text,
              mobilePhone: _mobilePhoneController.text,
              birthDate: _birthDate,
              acceptTerms: _acceptTerms,
            ),
          );
    }
  }

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
    );

    if (picked != null && picked != _birthDate) {
      setState(() {
        _birthDate = picked;
        _updateFormState();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return BlocConsumer<RegisterBloc, RegisterState>(
      listener: (context, state) {
        if (state is RegisterSuccess) {
          final userTypeText =
              _userType == 'admin' ? 'Administrador' : 'Usuario';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$userTypeText registrado exitosamente'),
              backgroundColor: Colors.green,
            ),
          );
          // Limpiar el formulario después del registro exitoso
          _clearForm();
        } else if (state is RegisterFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.error),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      builder: (context, state) {
        bool isButtonEnabled = _acceptTerms;
        if (state is RegisterFormState) {
          isButtonEnabled = state.isValid && _acceptTerms;
        }

        return Scaffold(
          backgroundColor: const Color(0xFF0A0A0F),
          appBar: AppBar(
            title: const Text(
              'Registro de Usuarios',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: const Color(0xFF1A1A2E),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => context.goNamed(AppRouter.adminUsers),
            ),
            elevation: 0,
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Header
                    _buildHeader(),

                    const SizedBox(height: 32),

                    // Selector de tipo de usuario
                    _buildUserTypeSelector(),

                    const SizedBox(height: 24),

                    // Datos personales
                    _buildSectionTitle('Datos Personales'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _appNameController,
                      label: 'Nombre de la Aplicación',
                      icon: Icons.apps,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el nombre de la aplicación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                          child: _buildTextField(
                            controller: _firstNameController,
                            label: 'Nombre',
                            icon: Icons.person,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildTextField(
                            controller: _lastName1Controller,
                            label: 'Primer Apellido',
                            icon: Icons.person_outline,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Requerido';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lastName2Controller,
                      label: 'Segundo Apellido (Opcional)',
                      icon: Icons.person_outline,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _idNumberController,
                      label: 'Número de Identificación',
                      icon: Icons.badge,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese su número de identificación';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildDatePicker(),
                    const SizedBox(height: 24),

                    // Datos de contacto
                    _buildSectionTitle('Datos de Contacto'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Correo Electrónico',
                      icon: Icons.email,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el correo electrónico';
                        }
                        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                            .hasMatch(value)) {
                          return 'Por favor ingrese un correo electrónico válido';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _mobilePhoneController,
                      label: 'Teléfono Móvil',
                      icon: Icons.phone_android,
                      keyboardType: TextInputType.phone,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(15),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Por favor ingrese el número de teléfono';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Credenciales
                    _buildSectionTitle('Credenciales de Acceso'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      label: 'Contraseña',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
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

                    _buildTextField(
                      controller: _confirmPasswordController,
                      label: 'Confirmar Contraseña',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirmPassword,
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.grey,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword = !_obscureConfirmPassword;
                          });
                        },
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
                    _buildTermsCheckbox(),
                    const SizedBox(height: 32),

                    // Botón de registro
                    state is RegisterLoading
                        ? const Center(
                            child: CircularProgressIndicator(
                              color: Color(0xFF8B5CF6),
                            ),
                          )
                        : ElevatedButton(
                            onPressed: isButtonEnabled
                                ? () {
                                    if (_formKey.currentState?.validate() ??
                                        false) {
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
                                        role: _userType,
                                      );

                                      context.read<RegisterBloc>().add(
                                            RegisterSubmitted(userDto: userDto),
                                          );
                                    }
                                  }
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF8B5CF6),
                              disabledBackgroundColor: Colors.grey[700],
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              _userType == 'admin'
                                  ? 'CREAR ADMINISTRADOR'
                                  : 'CREAR USUARIO',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF1A1A2E),
            shape: BoxShape.circle,
            border: Border.all(
              color: const Color(0xFF8B5CF6),
              width: 2,
            ),
          ),
          child: Icon(
            _userType == 'admin'
                ? Icons.admin_panel_settings
                : Icons.person_add,
            size: 40,
            color: const Color(0xFF8B5CF6),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          _userType == 'admin' ? 'Crear Administrador' : 'Crear Usuario',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _userType == 'admin'
              ? 'Registra un nuevo administrador con privilegios completos'
              : 'Registra un nuevo usuario con acceso básico',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withOpacity(0.7),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUserTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _userType = 'client';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _userType == 'client'
                      ? const Color(0xFF8B5CF6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person,
                      color: _userType == 'client'
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Usuario',
                      style: TextStyle(
                        color: _userType == 'client'
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _userType = 'admin';
                });
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _userType == 'admin'
                      ? const Color(0xFF8B5CF6)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.admin_panel_settings,
                      color: _userType == 'admin'
                          ? Colors.white
                          : Colors.white.withOpacity(0.6),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Administrador',
                      style: TextStyle(
                        color: _userType == 'admin'
                            ? Colors.white
                            : Colors.white.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xFF8B5CF6),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool obscureText = false,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        prefixIcon: Icon(icon, color: Colors.white.withOpacity(0.7)),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF1A1A2E),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF8B5CF6)),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.red),
        ),
      ),
    );
  }

  Widget _buildDatePicker() {
    return GestureDetector(
      onTap: () => _selectDate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A2E),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today,
              color: Colors.white.withOpacity(0.7),
            ),
            const SizedBox(width: 16),
            Text(
              'Fecha de nacimiento: ${_dateFormat.format(_birthDate)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.arrow_drop_down,
              color: Colors.white.withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
              _updateFormState();
            });
          },
          fillColor: MaterialStateProperty.resolveWith((states) {
            if (states.contains(MaterialState.selected)) {
              return const Color(0xFF8B5CF6);
            }
            return Colors.transparent;
          }),
          side: BorderSide(
            color: Colors.white.withOpacity(0.5),
            width: 2,
          ),
        ),
        Expanded(
          child: Text(
            'He leído y acepto los términos y condiciones y la política de privacidad',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }

  void _clearForm() {
    _appNameController.clear();
    _firstNameController.clear();
    _emailController.clear();
    _passwordController.clear();
    _confirmPasswordController.clear();
    _lastName1Controller.clear();
    _lastName2Controller.clear();
    _idNumberController.clear();
    _mobilePhoneController.clear();
    setState(() {
      _birthDate = DateTime(DateTime.now().year - 18);
      _acceptTerms = false;
      _userType = 'client';
    });
  }
}
