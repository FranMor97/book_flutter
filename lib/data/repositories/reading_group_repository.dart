import 'package:book_app_f/models/comments_group.dart';
import 'package:book_app_f/models/reading_group.dart';

abstract class IReadingGroupRepository {
  /// Obtiene todos los grupos de lectura del usuario
  Future<List<ReadingGroup>> getUserGroups();

  /// Obtiene un grupo específico por ID
  Future<ReadingGroup> getGroupById(String groupId);

  /// Crea un nuevo grupo de lectura
  Future<ReadingGroup> createGroup({
    required String name,
    String? description,
    required String bookId,
    bool isPrivate = false,
    ReadingGoal? readingGoal,
  });

  /// Actualiza la configuración de un grupo
  Future<ReadingGroup> updateGroup({
    required String groupId,
    String? name,
    String? description,
    bool? isPrivate,
    ReadingGoal? readingGoal,
  });

  /// Busca grupos públicos
  Future<List<ReadingGroup>> searchPublicGroups({
    String? query,
    int page = 1,
    int limit = 10,
  });

  /// Unirse a un grupo
  Future<ReadingGroup> joinGroup(String groupId);

  /// Abandonar un grupo
  Future<void> leaveGroup(String groupId);

  /// Gestionar miembros (promover/degradar/expulsar)
  Future<ReadingGroup> manageMember({
    required String groupId,
    required String memberId,
    required String action, // 'promote', 'demote', 'kick'
  });

  /// Actualizar progreso de lectura
  Future<ReadingGroup> updateReadingProgress({
    required String groupId,
    required int currentPage,
  });

  /// Obtener mensajes de un grupo
  Future<List<GroupMessage>> getGroupMessages({
    required String groupId,
    int page = 1,
    int limit = 20,
  });

  /// Enviar mensaje a un grupo
  Future<GroupMessage> sendGroupMessage({
    required String groupId,
    required String text,
  });
}
