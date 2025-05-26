class CommentUser {
  final String id;
  final String firstName;
  final String lastName1;
  final String? avatar;

  CommentUser({
    required this.id,
    required this.firstName,
    required this.lastName1,
    this.avatar,
  });

  factory CommentUser.fromJson(Map<String, dynamic> json) {
    return CommentUser(
      id: json['id']?.toString() ?? 'unknown',
      firstName: json['firstName'] ?? '',
      lastName1: json['lastName1'] ?? '',
      avatar: json['avatar'],
    );
  }
}
