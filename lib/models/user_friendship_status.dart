import 'package:book_app_f/models/user.dart';

class UserFriendshipStatus {
  final User user;
  final String? friendshipStatus;
  final String? friendshipId;
  final bool isRequester;

  UserFriendshipStatus({
    required this.user,
    this.friendshipStatus,
    this.friendshipId,
    this.isRequester = false,
  });

  factory UserFriendshipStatus.fromJson(Map<String, dynamic> json) {
    // Si el usuario ya viene como objeto anidado, usarlo directamente
    if (json.containsKey('user') && json['user'] is Map<String, dynamic>) {
      return UserFriendshipStatus(
        user: User.fromJson(json['user']),
        friendshipStatus: json['friendshipStatus'] as String?,
        friendshipId: json['friendshipId'] as String?,
        isRequester: json['isRequester'] as bool? ?? false,
      );
    }

    // Extraer datos de amistad antes de crear el User
    final friendshipStatus = json['friendshipStatus'] as String?;
    final friendshipId = json['friendshipId'] as String?;
    final isRequester = json['isRequester'] as bool? ?? false;

    // Crear una copia del json sin los campos de amistad para el User
    final userJson = Map<String, dynamic>.from(json)
      ..remove('friendshipStatus')
      ..remove('friendshipId')
      ..remove('isRequester');

    return UserFriendshipStatus(
      user: User.fromJson(userJson),
      friendshipStatus: friendshipStatus,
      friendshipId: friendshipId,
      isRequester: isRequester,
    );
  }
}
