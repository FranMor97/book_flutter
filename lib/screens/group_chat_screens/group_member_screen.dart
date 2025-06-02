import 'package:book_app_f/models/dtos/book_dto.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/bloc/reading_group/reading_group_bloc.dart';
import '../../models/reading_group.dart';
import '../../models/user.dart';

class GroupMembersList extends StatelessWidget {
  final ReadingGroup group;
  final String currentUserId;
  final bool isAdmin;

  const GroupMembersList({
    Key? key,
    required this.group,
    required this.currentUserId,
    required this.isAdmin,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: Text(
          'Miembros del grupo (${group.members.length})',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: group.members.length,
        itemBuilder: (context, index) {
          final member = group.members[index];
          return _buildMemberCard(context, member);
        },
      ),
    );
  }

  Widget _buildMemberCard(BuildContext context, GroupMember member) {
    final User? user = member.user;
    final bool isMemberAdmin = member.role == 'admin';
    final bool isCurrentUser = member.userId == currentUserId;
    final bool canManage = isAdmin && !isCurrentUser;

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: isCurrentUser
            ? const BorderSide(color: Color(0xFF8B5CF6), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Avatar del usuario
            CircleAvatar(
              radius: 28,
              backgroundColor: isMemberAdmin
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF6B7280),
              child: user?.avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(28),
                      child: Image.network(
                        user!.avatar!,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) => Text(
                          _getInitials(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _getInitials(user),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
            ),
            const SizedBox(width: 16),

            // Información del usuario
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getUserName(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Tú',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: isMemberAdmin
                              ? const Color(0xFF8B5CF6).withOpacity(0.2)
                              : Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isMemberAdmin ? 'Administrador' : 'Miembro',
                          style: TextStyle(
                            color: isMemberAdmin
                                ? const Color(0xFF8B5CF6)
                                : Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Página ${member.currentPage}',
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

            // Opciones de administración
            if (canManage)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                color: const Color(0xFF22223B),
                onSelected: (value) =>
                    _handleMemberAction(context, member, value),
                itemBuilder: (context) => [
                  if (!isMemberAdmin)
                    const PopupMenuItem(
                      value: 'promote',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Color(0xFF8B5CF6)),
                          SizedBox(width: 8),
                          Text('Promover a admin',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  if (isMemberAdmin)
                    const PopupMenuItem(
                      value: 'demote',
                      child: Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.orange),
                          SizedBox(width: 8),
                          Text('Quitar rol de admin',
                              style: TextStyle(color: Colors.white)),
                        ],
                      ),
                    ),
                  const PopupMenuItem(
                    value: 'kick',
                    child: Row(
                      children: [
                        Icon(Icons.person_remove, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Expulsar del grupo',
                            style: TextStyle(color: Colors.white)),
                      ],
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _getInitials(User? user) {
    if (user == null) {
      return '?';
    }

    String initials = '';
    if (user.firstName.isNotEmpty) {
      initials += user.firstName[0].toUpperCase();
    }
    if (user.lastName1.isNotEmpty) {
      initials += user.lastName1[0].toUpperCase();
    }

    return initials.isEmpty ? '?' : initials;
  }

  String _getUserName(User? user) {
    if (user == null) {
      return 'Usuario desconocido';
    }

    return '${user.firstName} ${user.lastName1}';
  }

  void _handleMemberAction(
      BuildContext context, GroupMember member, String action) {
    final String memberName = _getUserName(member.user);

    // Mensajes de confirmación según la acción
    String title = '';
    String content = '';
    String confirmButtonText = '';
    Color confirmButtonColor = Colors.red;

    switch (action) {
      case 'promote':
        title = 'Promover a administrador';
        content =
            '¿Estás seguro de que quieres promover a $memberName a administrador del grupo?';
        confirmButtonText = 'Promover';
        confirmButtonColor = const Color(0xFF8B5CF6);
        break;
      case 'demote':
        title = 'Quitar rol de administrador';
        content =
            '¿Estás seguro de que quieres quitar el rol de administrador a $memberName?';
        confirmButtonText = 'Quitar rol';
        confirmButtonColor = Colors.orange;
        break;
      case 'kick':
        title = 'Expulsar del grupo';
        content =
            '¿Estás seguro de que quieres expulsar a $memberName del grupo? Esta acción no se puede deshacer.';
        confirmButtonText = 'Expulsar';
        confirmButtonColor = Colors.red;
        break;
    }

    // Mostrar diálogo de confirmación
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1A1A2E),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: Text(content, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Ejecutar la acción
              context.read<ReadingGroupBloc>().add(
                    ReadingGroupManageMember(
                      groupId: group.id,
                      memberId: member.userId,
                      action: action,
                    ),
                  );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmButtonColor,
            ),
            child: Text(confirmButtonText),
          ),
        ],
      ),
    );
  }
}

class GroupMembersProgressScreen extends StatelessWidget {
  final ReadingGroup group;
  final String currentUserId;

  const GroupMembersProgressScreen({
    Key? key,
    required this.group,
    required this.currentUserId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Ordenar miembros por progreso (mayor a menor)
    final sortedMembers = List<GroupMember>.from(group.members);
    sortedMembers.sort((a, b) => b.currentPage.compareTo(a.currentPage));

    final BookDto? book = group.book;
    final int totalPages =
        book?.pageCount ?? 100; // Valor por defecto si no hay información

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text(
          'Progreso del grupo',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF1A1A2E),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          // Información del libro
          if (book != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  // Portada del libro
                  Container(
                    width: 60,
                    height: 90,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
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
                        if (book.pageCount != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            '${book.pageCount} páginas',
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Progreso general del grupo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: _buildGroupProgress(totalPages),
          ),

          // Lista de progreso de miembros
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              itemCount: sortedMembers.length,
              itemBuilder: (context, index) {
                final member = sortedMembers[index];
                return _buildMemberProgressCard(
                    context, member, totalPages, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGroupProgress(int totalPages) {
    // Calcular progreso promedio del grupo
    int totalPagesRead = 0;
    for (var member in group.members) {
      totalPagesRead += member.currentPage;
    }

    final double averagePages =
        group.members.isNotEmpty ? totalPagesRead / group.members.length : 0;

    final double progressPercentage =
        totalPages > 0 ? (averagePages / totalPages).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Progreso general del grupo',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),

            // Barra de progreso
            LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[800],
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF8B5CF6)),
              minHeight: 10,
              borderRadius: BorderRadius.circular(5),
            ),
            const SizedBox(height: 8),

            // Detalles del progreso
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Promedio: ${averagePages.round()} páginas',
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                Text(
                  '${(progressPercentage * 100).round()}%',
                  style: const TextStyle(
                    color: Color(0xFF8B5CF6),
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            // Miembros activos
            const SizedBox(height: 16),
            Text(
              '${group.members.length} miembros participando',
              style: const TextStyle(color: Colors.grey, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberProgressCard(
    BuildContext context,
    GroupMember member,
    int totalPages,
    int rank,
  ) {
    final User? user = member.user;
    final bool isCurrentUser = member.userId == currentUserId;
    final bool isMemberAdmin = member.role == 'admin';

    // Calcular progreso
    final double progressPercentage = totalPages > 0
        ? (member.currentPage / totalPages).clamp(0.0, 1.0)
        : 0.0;

    // Determinar color del ranking
    Color rankColor = const Color(0xFF6B7280);
    if (rank == 1) rankColor = const Color(0xFFFFD700); // Oro
    if (rank == 2) rankColor = const Color(0xFFC0C0C0); // Plata
    if (rank == 3) rankColor = const Color(0xFFCD7F32); // Bronce

    return Card(
      margin: const EdgeInsets.only(bottom: 8.0),
      color: const Color(0xFF1A1A2E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: isCurrentUser
            ? const BorderSide(color: Color(0xFF8B5CF6), width: 1)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            // Ranking
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rankColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: rankColor, width: 1),
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    color: rankColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Avatar del usuario
            CircleAvatar(
              radius: 24,
              backgroundColor: isMemberAdmin
                  ? const Color(0xFF8B5CF6)
                  : const Color(0xFF6B7280),
              child: user?.avatar != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: Image.network(
                        user!.avatar!,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, _) => Text(
                          _getInitials(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    )
                  : Text(
                      _getInitials(user),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 12),

            // Información del usuario y progreso
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre y etiquetas
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          _getUserName(user),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isCurrentUser)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Tú',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (isMemberAdmin)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          margin: const EdgeInsets.only(left: 8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF8B5CF6).withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Admin',
                            style: TextStyle(
                              color: Color(0xFF8B5CF6),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Barra de progreso individual
                  LinearProgressIndicator(
                    value: progressPercentage,
                    backgroundColor: Colors.grey[800],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isCurrentUser
                          ? const Color(0xFF8B5CF6)
                          : const Color(0xFF6B7280),
                    ),
                    minHeight: 6,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),

                  // Información de páginas
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Página ${member.currentPage} de $totalPages',
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${(progressPercentage * 100).round()}%',
                        style: TextStyle(
                          color: isCurrentUser
                              ? const Color(0xFF8B5CF6)
                              : Colors.grey,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getInitials(User? user) {
    if (user == null) {
      return '?';
    }

    String initials = '';
    if (user.firstName.isNotEmpty) {
      initials += user.firstName[0].toUpperCase();
    }
    if (user.lastName1.isNotEmpty) {
      initials += user.lastName1[0].toUpperCase();
    }

    return initials.isEmpty ? '?' : initials;
  }

  String _getUserName(User? user) {
    if (user == null) {
      return 'Usuario desconocido';
    }

    return '${user.firstName} ${user.lastName1}';
  }
}
