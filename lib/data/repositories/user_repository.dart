import '../../models/dtos/user_dto.dart';

/// Repositorio abstracto para gestionar usuarios
abstract class IUserRepository {
  /// Registra un nuevo usuario en el sistema
  ///
  /// Recibe un [UserDto] con todos los datos necesarios para el registro
  /// Retorna un [UserDto] con los datos del usuario registrado
  Future<UserDto> register(UserDto userDto);

  /// Recibe un [UserDto] con email y password
  /// Retorna un [UserDto] con los datos del usuario y su token
  Future<UserDto> login(UserDto loginDto);

  Future<void> logout();

  Future<UserDto?> getUserWithStoredToken();
}
