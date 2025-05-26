import 'package:book_app_f/models/user.dart';

class BookComment {
  final String id;
  final String text;
  final int rating;
  final DateTime date;
  final String? title;
  final User user; // Usuario que hizo el comentario
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
}
