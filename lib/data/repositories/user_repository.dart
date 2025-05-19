import '../../models/dtos/user_dto.dart';

abstract class UserRepository {
  /// Recibe un [UserDto] con todos los datos necesarios para el registro
  /// Retorna un [UserDto] con los datos del usuario registrado
  Future<UserDto> register(UserDto userDto);
}
