// lib/screens/book_comments_screen.dart
import 'dart:io';

import 'package:book_app_f/data/bloc/book_comment_bloc/book_comments_bloc.dart';
import 'package:book_app_f/data/bloc/book_detail/book_detail_bloc.dart';
import 'package:book_app_f/models/book_comments.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/book_repository.dart';
import '../../data/repositories/book_user_repository.dart';
import '../../data/repositories/auth_repository.dart';
import '../../injection.dart';
import '../../models/dtos/book_user_dto.dart';

class BookCommentsScreen extends StatefulWidget {
  final String bookId;

  const BookCommentsScreen({
    super.key,
    required this.bookId,
  });

  @override
  State<BookCommentsScreen> createState() => _BookCommentsScreenState();
}

class _BookCommentsScreenState extends State<BookCommentsScreen> {
  late BookCommentsBloc bloc;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    bloc = context.read<BookCommentsBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title:
            const Text('Valoraciones', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1A1A2E),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          BlocBuilder<BookCommentsBloc, BookCommentsState>(
            builder: (context, state) {
              // Siempre mostrar el botón de añadir comentarios
              return IconButton(
                icon: const Icon(Icons.add_comment, color: Colors.white),
                onPressed: () {
                  String? userBookId;
                  if (state is BookCommentsLoaded) {
                    userBookId = state.userBookId;
                  }
                  _showAddCommentDialog(context, widget.bookId, userBookId);
                },
              );
            },
          ),
        ],
      ),
      body: BlocBuilder<BookCommentsBloc, BookCommentsState>(
        builder: (context, state) {
          if (state is BookCommentsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
            );
          }

          if (state is BookCommentsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${state.message}',
                    style: const TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context
                        .read<BookCommentsBloc>()
                        .add(BookCommentsLoad(bookId: widget.bookId)),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (state is BookCommentsLoaded) {
            if (state.comments.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.comment_outlined,
                      size: 60,
                      color: Color(0xFF8B5CF6),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'No hay valoraciones para este libro',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        _showAddCommentDialog(
                            context, widget.bookId, state.userBookId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                      ),
                      child: const Text('Añadir valoración'),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.comments.length,
              itemBuilder: (context, index) {
                final comment = state.comments[index];
                return _buildCommentCard(comment);
              },
            );
          }

          if (state is BookCommentsSubmitting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF8B5CF6)),
                  SizedBox(height: 16),
                  Text(
                    'Enviando valoración...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildCommentCard(BookComment comment) {
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: comment.isOwnComment
            ? const BorderSide(color: Color(0xFF8B5CF6), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Encabezado: usuario, fecha y valoración
            Row(
              children: [
                // Avatar o inicial del usuario
                CircleAvatar(
                  backgroundColor: const Color(0xFF8B5CF6),
                  radius: 20,
                  child: comment.user.avatar != null &&
                          comment.user.avatar!.isNotEmpty
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.network(
                            comment.user.avatar!,
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Text(
                              comment.user.firstName.isNotEmpty
                                  ? comment.user.firstName.substring(0, 1)
                                  : '?',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      : Text(
                          comment.user.firstName.isNotEmpty
                              ? comment.user.firstName.substring(0, 1)
                              : '?',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(width: 12),

                // Nombre y fecha
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${comment.user.firstName} ${comment.user.lastName1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        dateFormat.format(comment.date),
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                // Valoración en estrellas
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < comment.rating ? Icons.star : Icons.star_border,
                      color: Colors.amber,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),

            // Título (si existe)
            if (comment.title != null && comment.title!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                comment.title!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],

            // Texto del comentario
            const SizedBox(height: 8),
            Text(
              comment.text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),

            if (Platform.isWindows) ...[
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // TextButton.icon(
                  //   onPressed: () {
                  //     // Función para editar (si se implementa después)
                  //   },
                  //   icon: const Icon(Icons.edit, size: 16, color: Colors.grey),
                  //   label: const Text('Editar',
                  //       style: TextStyle(color: Colors.grey)),
                  // ),
                  const SizedBox(width: 8),
                  TextButton.icon(
                    onPressed: () {
                      bloc.add(
                        BookCommentsDeleteComment(commentId: comment.id),
                      );
                    },
                    icon: const Icon(Icons.delete,
                        size: 16, color: Colors.redAccent),
                    label: const Text('Eliminar',
                        style: TextStyle(color: Colors.redAccent)),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showAddCommentDialog(
      BuildContext context, String bookId, String? bookUserId) {
    final titleController = TextEditingController();
    final textController = TextEditingController();
    int rating = 0;
    final bloc = context.read<BookCommentsBloc>();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          backgroundColor: const Color(0xFF1A1A2E),
          title: const Text('Añadir valoración',
              style: TextStyle(color: Colors.white)),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(
                    labelText: 'Título (opcional)',
                    labelStyle: TextStyle(color: Colors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: textController,
                  style: const TextStyle(color: Colors.white),
                  maxLines: 5,
                  decoration: const InputDecoration(
                    labelText: 'Tu opinión sobre el libro',
                    labelStyle: TextStyle(color: Colors.grey),
                    alignLabelWithHint: true,
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Valoración',
                  style: TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    return IconButton(
                      icon: Icon(
                        index < rating ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                      ),
                      onPressed: () {
                        setState(() {
                          rating = index + 1;
                        });
                      },
                    );
                  }),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child:
                  const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                if (textController.text.isNotEmpty && rating > 0) {
                  final review = ReviewDto(
                    text: textController.text,
                    rating: rating,
                    title: titleController.text.isNotEmpty
                        ? titleController.text
                        : null,
                    isPublic: true,
                  );
                  Navigator.pop(context);
                  bloc.add(
                    BookCommentsAddComment(
                      bookId: bookId,
                      bookUserId: bookUserId,
                      review: review,
                    ),
                  );
                } else {
                  // Mostrar error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Debes escribir un comentario y dar una valoración'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }
}
