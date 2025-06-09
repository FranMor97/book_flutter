// lib/screens/reading_groups/reading_groups_screen.dart
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:book_app_f/routes/book_routes.dart';
import 'package:book_app_f/screens/group_chat_screens/create_group_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/group_chat_screen.dart';
import 'package:book_app_f/screens/group_chat_screens/search_group_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:book_app_f/data/bloc/reading_group/reading_group_bloc.dart';
import 'package:book_app_f/data/repositories/reading_group_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:go_router/go_router.dart';

import '../../data/repositories/book_repository.dart';

class ReadingGroupsScreen extends StatelessWidget {
  const ReadingGroupsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ReadingGroupBloc(
        readingGroupRepository: getIt<IReadingGroupRepository>(),
        bookRepository: getIt<IBookRepository>(),
      )..add(ReadingGroupLoadUserGroups()),
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0A0F),
        appBar: AppBar(
          title: const Text('Grupos de Lectura',
              style: TextStyle(color: Colors.white)),
          backgroundColor: const Color(0xFF1A1A2E),
          actions: [
            IconButton(
              icon: const Icon(Icons.search, color: Colors.white),
              onPressed: () {
                context.goNamed(AppRouter.searchGroups);
              },
            ),
          ],
        ),
        body: BlocBuilder<ReadingGroupBloc, ReadingGroupState>(
          builder: (context, state) {
            if (state is ReadingGroupLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              );
            }

            if (state is ReadingGroupUserGroupsLoaded) {
              return _buildGroupsList(context, state.groups);
            }

            if (state is ReadingGroupError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error_outline,
                        size: 60, color: Colors.red),
                    const SizedBox(height: 16),
                    Text(
                      'Error: ${state.message}',
                      style: const TextStyle(color: Colors.white),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => context
                          .read<ReadingGroupBloc>()
                          .add(ReadingGroupLoadUserGroups()),
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }

            return const Center(
              child: Text(
                'Cargando grupos...',
                style: TextStyle(color: Colors.white),
              ),
            );
          },
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color(0xFF8B5CF6),
          child: const Icon(Icons.add),
          onPressed: () {},
        ),
      ),
    );
  }

  Widget _buildGroupsList(BuildContext context, List<ReadingGroup> groups) {
    if (groups.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.group_outlined,
              size: 60,
              color: Color(0xFF8B5CF6),
            ),
            const SizedBox(height: 16),
            const Text(
              'No perteneces a ningún grupo de lectura',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Crea un grupo o únete a uno existente',
              style: TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.goNamed(AppRouter.createGroupScreen);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              icon: const Icon(Icons.add),
              label: const Text('Crear grupo'),
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: () {
                context.goNamed(AppRouter.createGroupScreen);
              },
              icon: const Icon(Icons.search, color: Color(0xFF8B5CF6)),
              label: const Text(
                'Buscar grupos',
                style: TextStyle(color: Color(0xFF8B5CF6)),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groups.length,
      itemBuilder: (context, index) {
        final group = groups[index];
        final book = group.book;

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () {
              context.goNamed(AppRouter.groupChat);
            },
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con portada y título
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada del libro
                    Container(
                      width: 100,
                      height: 150,
                      margin: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.grey[800],
                        image: book?.coverImage != null
                            ? DecorationImage(
                                image: NetworkImage(book!.coverImage!),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: book?.coverImage == null
                          ? const Center(
                              child: Text('📚', style: TextStyle(fontSize: 40)),
                            )
                          : null,
                    ),

                    // Información del grupo
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Nombre del grupo
                            Text(
                              group.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Libro
                            Text(
                              book?.title ?? 'Libro sin título',
                              style: const TextStyle(
                                color: Color(0xFF8B5CF6),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // lib/screens/reading_groups/reading_groups_screen.dart (continuación)
                            // Autor
                            Text(
                              book?.authors.isNotEmpty == true
                                  ? book!.authors.first
                                  : 'Autor desconocido',
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),

                            // Miembros
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${group.members.length} miembros',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),

                            // Tipo de grupo
                            Row(
                              children: [
                                Icon(
                                  group.isPrivate ? Icons.lock : Icons.public,
                                  color: Colors.grey,
                                  size: 16,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  group.isPrivate ? 'Privado' : 'Público',
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Separador
                const Divider(
                  color: Color(0xFF2A2A3E),
                  height: 1,
                ),

                // Pie con progreso
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      // Progreso de lectura
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.menu_book,
                                  color: Color(0xFF8B5CF6),
                                  size: 16,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  _getProgressText(group, book),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            if (book?.pageCount != null && book!.pageCount! > 0)
                              _buildProgressBar(group, book.pageCount!),
                          ],
                        ),
                      ),

                      // Botón de chat
                      ElevatedButton.icon(
                        onPressed: () {
                          context.goNamed(AppRouter.groupChat);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF8B5CF6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        icon: const Icon(Icons.chat),
                        label: const Text('Chat'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getProgressText(ReadingGroup group, BookDto? book) {
    // Obtener el miembro actual
    final currentMember = group.members.firstWhere(
      (member) => member.userId == getIt<IAuthRepository>().getCurrentUserId(),
      orElse: () => group.members.first,
    );

    if (book?.pageCount == null || book!.pageCount! <= 0) {
      return 'Progreso: ${currentMember.currentPage} páginas';
    }

    final percentage =
        (currentMember.currentPage / book.pageCount! * 100).round();
    return 'Progreso: ${currentMember.currentPage}/${book.pageCount} páginas ($percentage%)';
  }

  Widget _buildProgressBar(ReadingGroup group, int totalPages) {
    // Obtener el miembro actual
    final currentMember = group.members.firstWhere(
      (member) => member.userId == getIt<IAuthRepository>().getCurrentUserId(),
      orElse: () => group.members.first,
    );

    final progress =
        totalPages > 0 ? currentMember.currentPage / totalPages : 0.0;

    return Stack(
      children: [
        // Fondo
        Container(
          height: 8,
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(4),
          ),
        ),

        // Progreso
        FractionallySizedBox(
          widthFactor: progress.clamp(0.0, 1.0),
          child: Container(
            height: 8,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }
}
