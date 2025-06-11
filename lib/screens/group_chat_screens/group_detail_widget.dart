import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/bloc/reading_group/reading_group_bloc.dart';
import '../../models/reading_group.dart';
import '../../models/dtos/book_dto.dart';

class GroupDetailWidget extends StatelessWidget {
  final ReadingGroup group;

  const GroupDetailWidget({
    super.key,
    required this.group,
  });

  @override
  Widget build(BuildContext context) {
    // Obtener datos del libro
    final BookDto? book = group.book;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabecera con la portada del libro y el nombre del grupo
          _buildHeader(context, book),

          // Detalles del grupo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Descripción del grupo
                if (group.description != null &&
                    group.description!.isNotEmpty) ...[
                  Text(
                    'Descripción',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    group.description!,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Datos del libro
                Text(
                  'Libro actual',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildBookInfo(context, book),
                const SizedBox(height: 16),

                // Progreso del grupo
                Text(
                  'Progreso de lectura',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildProgressInfo(context, book),
                const SizedBox(height: 16),

                // Miembros del grupo
                Text(
                  'Miembros (${group.members.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 8),
                _buildMembersList(context),
                const SizedBox(height: 24),

                // Botones de acción
                _buildActionButtons(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, BookDto? book) {
    return Stack(
      children: [
        // Imagen de fondo (portada del libro)
        Container(
          height: 200,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
            ),
            image: book?.coverImage != null
                ? DecorationImage(
                    image: NetworkImage(book!.coverImage!),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4),
                      BlendMode.darken,
                    ),
                  )
                : null,
          ),
        ),

        // Overlay con información del grupo
        Container(
          height: 200,
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.transparent,
                Colors.black.withOpacity(0.7),
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tipo de grupo (público/privado)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: group.isPrivate ? Colors.redAccent : Colors.green,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  group.isPrivate ? 'Privado' : 'Público',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // Nombre del grupo
              Text(
                group.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              // Creador del grupo
              if (group.creator != null)
                Text(
                  'Creado por ${group.creator!.firstName} ${group.creator!.lastName1}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBookInfo(BuildContext context, BookDto? book) {
    if (book == null) {
      return const Card(
        color: Color(0xFF1A1A2E),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Información del libro no disponible',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    return Card(
      color: const Color(0xFF1A1A2E),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            // Miniatura de la portada
            Container(
              width: 60,
              height: 90,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                image: book.coverImage != null
                    ? DecorationImage(
                        image: NetworkImage(book.coverImage!),
                        fit: BoxFit.cover,
                      )
                    : null,
                color: const Color(0xFF8B5CF6),
              ),
              child: book.coverImage == null
                  ? const Center(
                      child: Text('📚', style: TextStyle(fontSize: 24)),
                    )
                  : null,
            ),
            const SizedBox(width: 16),

            // Detalles del libro
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authors.isNotEmpty
                        ? book.authors.first
                        : 'Autor desconocido',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  if (book.pageCount != null)
                    Text(
                      '${book.pageCount} páginas',
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Botón para ver detalles del libro
            IconButton(
              icon: const Icon(Icons.info_outline, color: Colors.white),
              onPressed: () {
                if (book.id != null) {
                  context.pushNamed(
                    'book-detail',
                    pathParameters: {'id': book.id!},
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressInfo(BuildContext context, BookDto? book) {
    // Obtener mi progreso (usuario actual)
    final myMember = group.members.firstWhere(
      (member) =>
          member.userId == 'userId', // TODO: Reemplazar con el userId real
      orElse: () => group.members.first,
    );

    // Calcular porcentajes
    double myProgress = 0.0;
    double groupProgress = 0.0;

    if (book != null && book.pageCount != null && book.pageCount! > 0) {
      myProgress = myMember.currentPage / book.pageCount!;

      // Calcular el promedio del grupo
      int totalPages = 0;
      for (var member in group.members) {
        totalPages += member.currentPage;
      }
      groupProgress = totalPages / (group.members.length * book.pageCount!);
    }

    return Card(
      color: const Color(0xFF1A1A2E),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Mi progreso
            const Text(
              'Mi progreso',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: myProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${myMember.currentPage} páginas',
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                if (book != null && book.pageCount != null)
                  Text(
                    '${(myProgress * 100).round()}%',
                    style:
                        const TextStyle(color: Color(0xFF8B5CF6), fontSize: 12),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Progreso del grupo
            const Text(
              'Progreso del grupo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: groupProgress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[800],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFFEC4899)),
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 4),
            if (book != null && book.pageCount != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${(groupProgress * 100).round()}%',
                    style:
                        const TextStyle(color: Color(0xFFEC4899), fontSize: 12),
                  ),
                ],
              ),
            const SizedBox(height: 16),

            // Botón para actualizar progreso
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _showUpdateProgressDialog(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF8B5CF6),
                ),
                icon: const Icon(Icons.update),
                label: const Text('Actualizar mi progreso'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context) {
    final pageController = TextEditingController();
    // Obtener mi miembro
    final myMember = group.members.firstWhere(
      (member) =>
          member.userId == 'userId', // TODO: Reemplazar con el userId real
      orElse: () => group.members.first,
    );

    // Pre-llenar con la página actual
    pageController.text = myMember.currentPage.toString();

    final BookDto? book = group.book;
    final int? maxPages = book?.pageCount;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Actualizar progreso',
            style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: pageController,
              keyboardType: TextInputType.number,
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
                labelText: 'Página actual',
                labelStyle: const TextStyle(color: Colors.grey),
                helperText:
                    maxPages != null ? 'Máximo: $maxPages páginas' : null,
                helperStyle: const TextStyle(color: Colors.grey),
                enabledBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF8B5CF6)),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final page = int.tryParse(pageController.text);
              if (page != null && page >= 0) {
                Navigator.pop(context);

                // Actualizar progreso
                context.read<ReadingGroupBloc>().add(
                      ReadingGroupUpdateProgress(
                        groupId: group.id,
                        currentPage: page,
                      ),
                    );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            child: const Text('Actualizar'),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersList(BuildContext context) {
    if (group.members.isEmpty) {
      return const Card(
        color: Color(0xFF1A1A2E),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'No hay miembros en este grupo',
            style: TextStyle(color: Colors.white),
          ),
        ),
      );
    }

    // Mostrar solo los primeros 3 miembros
    final displayMembers = group.members.take(3).toList();

    return Card(
      color: const Color(0xFF1A1A2E),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            ...displayMembers
                .map((member) => _buildMemberItem(context, member)),

            // Botón para ver todos los miembros si hay más de 3
            if (group.members.length > 3)
              TextButton.icon(
                onPressed: () {
                  // TODO: Navegar a la pantalla de miembros
                },
                icon: const Icon(Icons.people, color: Color(0xFF8B5CF6)),
                label: Text(
                  'Ver todos los ${group.members.length} miembros',
                  style: const TextStyle(color: Color(0xFF8B5CF6)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberItem(BuildContext context, GroupMember member) {
    final user = member.user;
    final isCurrentUser =
        member.userId == 'userId'; // TODO: Reemplazar con el userId real
    final isAdmin = member.role == 'admin';

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: const Color(0xFF8B5CF6),
        child: user?.avatar != null
            ? ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(user!.avatar!),
              )
            : Text(
                user?.firstName != null && user!.firstName.isNotEmpty
                    ? user.firstName.substring(0, 1).toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
      title: Text(
        user != null
            ? '${user.firstName} ${user.lastName1}'
            : 'Usuario ${member.userId.substring(0, 4)}',
        style: TextStyle(
          color: Colors.white,
          fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      subtitle: Text(
        isAdmin ? 'Administrador' : 'Miembro',
        style: TextStyle(
          color: isAdmin ? const Color(0xFF8B5CF6) : Colors.grey,
          fontSize: 12,
        ),
      ),
      trailing: Text(
        'Pág. ${member.currentPage}',
        style: const TextStyle(
          color: Colors.grey,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final isAdmin = group.members.any((member) =>
        member.userId == 'userId' &&
        member.role == 'admin'); // TODO: Reemplazar con el userId real

    return Column(
      children: [
        // Botón de chat
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              // TODO: Navegar a la pantalla de chat
            },
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFF8B5CF6),
            ),
            icon: const Icon(Icons.chat),
            label: const Text('Ir al chat del grupo'),
          ),
        ),

        const SizedBox(height: 8),

        // Botón de editar grupo (solo para administradores)
        if (isAdmin)
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                // TODO: Navegar a la pantalla de edición
              },
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                side: const BorderSide(color: Color(0xFF8B5CF6)),
              ),
              icon: const Icon(Icons.edit),
              label: const Text('Editar grupo'),
            ),
          ),

        const SizedBox(height: 8),

        // Botón de salir del grupo
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () {
              _showLeaveGroupConfirmation(context);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
            ),
            icon: const Icon(Icons.exit_to_app),
            label: const Text('Abandonar grupo'),
          ),
        ),
      ],
    );
  }

  void _showLeaveGroupConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: const Text('Abandonar grupo',
            style: TextStyle(color: Colors.white)),
        content: const Text(
          '¿Estás seguro de que quieres abandonar este grupo de lectura? Esta acción no se puede deshacer.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);

              // Abandonar el grupo
              context.read<ReadingGroupBloc>().add(
                    ReadingGroupLeave(groupId: group.id),
                  );

              // Navegar hacia atrás después de un momento
              Future.delayed(const Duration(milliseconds: 300), () {
                Navigator.pop(context);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Abandonar'),
          ),
        ],
      ),
    );
  }
}
