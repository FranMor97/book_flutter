// lib/screens/group_chat_screens/widgets/reading_progress_widget.dart
import 'package:book_app_f/models/reading_group.dart';
import 'package:flutter/material.dart';

class ReadingProgressWidget extends StatelessWidget {
  final ReadingGroup group;
  final String currentUserId;
  final VoidCallback? onUpdateProgress;

  const ReadingProgressWidget({
    Key? key,
    required this.group,
    required this.currentUserId,
    this.onUpdateProgress,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final book = group.book;
    final totalPages = book?.pageCount ?? 0;
    final currentMember = group.getMember(currentUserId);

    if (currentMember == null || totalPages <= 0) {
      return const SizedBox.shrink();
    }

    // Calcular estadísticas
    final myProgress = currentMember.currentPage / totalPages;
    final groupStats = _calculateGroupStats();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A2E),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y botón de actualizar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Progreso de Lectura',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (onUpdateProgress != null)
                IconButton(
                  onPressed: onUpdateProgress,
                  icon: const Icon(Icons.edit, color: Color(0xFF8B5CF6)),
                  tooltip: 'Actualizar progreso',
                ),
            ],
          ),
          const SizedBox(height: 16),

          // Mi progreso
          _buildProgressSection(
            title: 'Mi Progreso',
            currentPage: currentMember.currentPage,
            totalPages: totalPages,
            progress: myProgress,
            color: const Color(0xFF8B5CF6),
            icon: Icons.person,
          ),
          const SizedBox(height: 16),

          // Progreso del grupo
          _buildProgressSection(
            title: 'Promedio del Grupo',
            currentPage: groupStats['averagePages']!.round(),
            totalPages: totalPages,
            progress: groupStats['averageProgress']!,
            color: const Color(0xFFEC4899),
            icon: Icons.group,
          ),
          const SizedBox(height: 16),

          // Estadísticas adicionales
          _buildStatsRow(groupStats),

          // Meta de lectura si existe
          if (group.readingGoal != null) ...[
            const SizedBox(height: 16),
            _buildReadingGoal(),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressSection({
    required String title,
    required int currentPage,
    required int totalPages,
    required double progress,
    required Color color,
    required IconData icon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            Container(
              height: 24,
              decoration: BoxDecoration(
                color: Colors.grey[800],
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            FractionallySizedBox(
              widthFactor: progress.clamp(0.0, 1.0),
              child: Container(
                height: 24,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [color, color.withOpacity(0.6)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            Positioned.fill(
              child: Center(
                child: Text(
                  '$currentPage / $totalPages páginas (${(progress * 100).round()}%)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatsRow(Map<String, double> stats) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildStatItem(
          label: 'Líder',
          value: '${stats['maxPages']!.round()} pág',
          icon: Icons.emoji_events,
          color: Colors.amber,
        ),
        _buildStatItem(
          label: 'Miembros activos',
          value: '${stats['activeMembers']!.round()}/${group.members.length}',
          icon: Icons.people_alt,
          color: Colors.green,
        ),
        _buildStatItem(
          label: 'Completado',
          value: '${stats['completedMembers']!.round()}',
          icon: Icons.check_circle,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildReadingGoal() {
    final goal = group.readingGoal!;
    final now = DateTime.now();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF8B5CF6).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flag, color: Color(0xFF8B5CF6), size: 20),
              SizedBox(width: 8),
              Text(
                'Meta de Lectura',
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (goal.pagesPerDay != null)
            Text(
              '${goal.pagesPerDay} páginas por día',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          if (goal.targetFinishDate != null) ...[
            const SizedBox(height: 4),
            Text(
              'Fecha objetivo: ${_formatDate(goal.targetFinishDate!)}',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            if (goal.targetFinishDate!.isAfter(now))
              Text(
                '${goal.targetFinishDate!.difference(now).inDays} días restantes',
                style: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
          ],
        ],
      ),
    );
  }

  Map<String, double> _calculateGroupStats() {
    int totalPages = 0;
    int maxPages = 0;
    int activeMembers = 0;
    int completedMembers = 0;
    final bookPages = group.book?.pageCount ?? 1;

    for (var member in group.members) {
      totalPages += member.currentPage;
      if (member.currentPage > maxPages) {
        maxPages = member.currentPage;
      }
      if (member.currentPage > 0) {
        activeMembers++;
      }
      if (member.currentPage >= bookPages) {
        completedMembers++;
      }
    }

    final averagePages =
        group.members.isNotEmpty ? totalPages / group.members.length : 0.0;

    final averageProgress = bookPages > 0 ? averagePages / bookPages : 0.0;

    return {
      'averagePages': averagePages,
      'averageProgress': averageProgress,
      'maxPages': maxPages.toDouble(),
      'activeMembers': activeMembers.toDouble(),
      'completedMembers': completedMembers.toDouble(),
    };
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
