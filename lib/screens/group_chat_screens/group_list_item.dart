// lib/screens/group_chat_screens/widgets/group_list_item.dart
import 'package:book_app_f/data/repositories/auth_repository.dart';
import 'package:book_app_f/injection.dart';
import 'package:book_app_f/models/reading_group.dart';
import 'package:book_app_f/screens/group_chat_screens/group_chat_screen.dart';
import 'package:flutter/material.dart';

class GroupListItem extends StatelessWidget {
  final ReadingGroup group;
  final VoidCallback? onTap;

  const GroupListItem({
    Key? key,
    required this.group,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final book = group.book;

    return FutureBuilder<String?>(
      future: getIt<IAuthRepository>().getCurrentUserId(),
      builder: (context, snapshot) {
        final currentUserId = snapshot.data;
        final currentMember =
            currentUserId != null ? group.getMember(currentUserId) : null;

        return Card(
          color: const Color(0xFF1A1A2E),
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap ?? () => _navigateToGroupChat(context),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Encabezado con portada y título
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Portada del libro
                    Hero(
                      tag: 'book-cover-${group.id}',
                      child: Container(
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
                                child:
                                    Text('📚', style: TextStyle(fontSize: 40)),
                              )
                            : null,
                      ),
                    ),

                    // Información del grupo
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(0, 16, 16, 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Badges
                            Row(
                              children: [
                                _buildBadge(
                                  label:
                                      group.isPrivate ? 'Privado' : 'Público',
                                  color: group.isPrivate
                                      ? Colors.redAccent
                                      : Colors.green,
                                  icon: group.isPrivate
                                      ? Icons.lock
                                      : Icons.public,
                                ),
                                const SizedBox(width: 8),
                                if (currentMember != null &&
                                    currentMember.role == 'admin')
                                  _buildBadge(
                                    label: 'Admin',
                                    color: const Color(0xFF8B5CF6),
                                    icon: Icons.star,
                                  ),
                              ],
                            ),
                            const SizedBox(height: 8),

                            // Nombre del grupo
                            Text(
                              group.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Libro
                            if (book != null) ...[
                              Text(
                                book.title,
                                style: const TextStyle(
                                  color: Color(0xFF8B5CF6),
                                  fontSize: 14,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                book.authors.isNotEmpty
                                    ? book.authors.first
                                    : 'Autor desconocido',
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                            const SizedBox(height: 12),

                            // Información adicional
                            Row(
                              children: [
                                _buildInfoChip(
                                  icon: Icons.people,
                                  label: '${group.members.length}',
                                  tooltip: 'Miembros',
                                ),
                                const SizedBox(width: 12),
                                if (book?.pageCount != null)
                                  _buildInfoChip(
                                    icon: Icons.menu_book,
                                    label: '${book!.pageCount} pág',
                                    tooltip: 'Páginas totales',
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

                // Pie con progreso y acciones
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Progreso personal
                      if (currentMember != null && book?.pageCount != null)
                        _buildProgressSection(
                          currentMember: currentMember,
                          totalPages: book!.pageCount!,
                        ),

                      // Acciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Meta de lectura
                          if (group.readingGoal != null)
                            _buildGoalInfo(group.readingGoal!),

                          const Spacer(),

                          // Botones de acción
                          Row(
                            children: [
                              IconButton(
                                onPressed: () => _showGroupInfo(context),
                                icon: const Icon(Icons.info_outline),
                                color: Colors.grey,
                                tooltip: 'Información del grupo',
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton.icon(
                                onPressed: () => _navigateToGroupChat(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF8B5CF6),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: const Icon(Icons.chat, size: 18),
                                label: const Text('Chat'),
                              ),
                            ],
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
      },
    );
  }

  Widget _buildBadge({
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 12),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    String? tooltip,
  }) {
    final widget = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: Colors.grey, size: 16),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );

    return tooltip != null ? Tooltip(message: tooltip, child: widget) : widget;
  }

  Widget _buildProgressSection({
    required GroupMember currentMember,
    required int totalPages,
  }) {
    final progress = currentMember.currentPage / totalPages;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Mi progreso',
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${currentMember.currentPage}/${totalPages} páginas',
              style: const TextStyle(
                color: Color(0xFF8B5CF6),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.grey[800],
            valueColor: AlwaysStoppedAnimation<Color>(
              progress >= 1.0 ? Colors.green : const Color(0xFF8B5CF6),
            ),
            minHeight: 8,
          ),
        ),
        const SizedBox(height: 4),
        Align(
          alignment: Alignment.centerRight,
          child: Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              color: progress >= 1.0 ? Colors.green : const Color(0xFF8B5CF6),
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildGoalInfo(ReadingGoal goal) {
    final now = DateTime.now();
    final daysLeft = goal.targetFinishDate != null
        ? goal.targetFinishDate!.difference(now).inDays
        : null;

    return Row(
      children: [
        const Icon(Icons.flag, color: Colors.amber, size: 16),
        const SizedBox(width: 4),
        if (goal.pagesPerDay != null)
          Text(
            '${goal.pagesPerDay} pág/día',
            style: const TextStyle(
              color: Colors.amber,
              fontSize: 12,
            ),
          ),
        if (daysLeft != null && daysLeft > 0) ...[
          const SizedBox(width: 8),
          Text(
            '$daysLeft días',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  void _navigateToGroupChat(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GroupChatScreen(group: group),
      ),
    );
  }

  void _showGroupInfo(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A1A2E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.grey),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (group.description != null && group.description!.isNotEmpty) ...[
              const Text(
                'Descripción',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                group.description!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (group.creator != null)
              _buildInfoRow(
                icon: Icons.person,
                label: 'Creado por',
                value:
                    '${group.creator!.firstName} ${group.creator!.lastName1}',
              ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.calendar_today,
              label: 'Fecha de creación',
              value: _formatDate(group.createdAt),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              icon: Icons.people,
              label: 'Miembros',
              value: '${group.members.length} personas',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
