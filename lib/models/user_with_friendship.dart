import 'package:book_app_f/models/user.dart';

class UserWithFriendshipId {
  final User user;
  final String friendshipId;

  UserWithFriendshipId({
    required this.user,
    required this.friendshipId,
  });

  factory UserWithFriendshipId.fromJson(Map<String, dynamic> json) {
    // Extraer friendshipId antes de crear el User
    final friendshipId = json['friendshipId'] as String;

    // Crear una copia del json sin friendshipId para el User
    final userJson = Map<String, dynamic>.from(json)..remove('friendshipId');

    return UserWithFriendshipId(
      user: User.fromJson(userJson),
      friendshipId: friendshipId,
    );
  }
}
