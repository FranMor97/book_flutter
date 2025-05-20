import '../../models/dtos/user_dto.dart';

/// Repositorio abstracto para gestionar usuarios
abstract class UserRepository {
  /// Registra un nuevo usuario en el sistema
  ///
  /// Recibe un [UserDto] con todos los datos necesarios para el registro
  /// Retorna un [UserDto] con los datos del usuario registrado
  Future<UserDto> register(UserDto userDto);

  /// Inicia sesión con email y contraseña
  ///
  /// Recibe un [UserDto] con email y password
  /// Retorna un [UserDto] con los datos del usuario y su token
  Future<UserDto> login(UserDto loginDto);

  /// Cierra la sesión del usuario actual
  Future<void> logout();

  /// Obtiene el usuario actual usando el token almacenado
  ///
  /// Retorna null si no hay un token válido
  Future<UserDto?> getUserWithStoredToken();
}
