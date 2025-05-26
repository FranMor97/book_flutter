// lib/models/book_comments.dart
import 'package:book_app_f/models/comment_user.dart';
import 'package:book_app_f/models/user.dart';

class BookComment {
  final String id;
  final String text;
  final int rating;
  final DateTime date;
  final String? title;
  final CommentUser user; // Usuario que hizo el comentario
  final bool isOwnComment; // Si es un comentario del usuario actual

  BookComment({
    required this.id,
    required this.text,
    required this.rating,
    required this.date,
    this.title,
    required this.user,
    this.isOwnComment = false,
  });

  factory BookComment.fromJson(Map<String, dynamic> json) {
    return BookComment(
      id: json['id'],
      text: json['text'],
      rating: json['rating'] is int ? json['rating'] : 0,
      date: json['date'] is String
          ? DateTime.parse(json['date'])
          : (json['date'] is DateTime ? json['date'] : DateTime.now()),
      title: json['title'],
      user: CommentUser.fromJson(json['user']),
      isOwnComment: json['isOwnComment'] ?? false,
    );
  }
}
