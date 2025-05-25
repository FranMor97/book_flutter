import 'package:json_annotation/json_annotation.dart';

part 'book_user_creation_dto.g.dart';

// DTO específico para crear/actualizar BookUser cuando solo tienes el bookId como string
@JsonSerializable()
class BookUserCreationDto {
  @JsonKey(name: '_id')
  final String? id;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'bookId')
  final String bookId; // String para envío al servidor

  @JsonKey(name: 'status')
  final String status;

  @JsonKey(name: 'currentPage')
  final int currentPage;

  @JsonKey(
      name: 'startDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? startDate;

  @JsonKey(
      name: 'finishDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? finishDate;

  @JsonKey(name: 'personalRating')
  final int personalRating;

  @JsonKey(name: 'isPrivate')
  final bool isPrivate;

  @JsonKey(name: 'shareProgress')
  final bool shareProgress;

  @JsonKey(
      name: 'lastUpdated', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime lastUpdated;

  BookUserCreationDto({
    this.id,
    required this.userId,
    required this.bookId,
    this.status = 'to-read',
    this.currentPage = 0,
    this.startDate,
    this.finishDate,
    this.personalRating = 0,
    this.isPrivate = false,
    this.shareProgress = true,
    DateTime? lastUpdated,
  }) : this.lastUpdated = lastUpdated ?? DateTime.now();

  // From JSON
  factory BookUserCreationDto.fromJson(Map<String, dynamic> json) =>
      _$BookUserCreationDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$BookUserCreationDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();

  // Factory para crear un nuevo registro de lectura
  factory BookUserCreationDto.forNewReading({
    required String userId,
    required String bookId,
    String status = 'to-read',
  }) {
    return BookUserCreationDto(
      userId: userId,
      bookId: bookId,
      status: status,
      startDate: status == 'reading' ? DateTime.now() : null,
    );
  }

  // Factory para actualizar el estado de lectura
  factory BookUserCreationDto.forStatusUpdate({
    required String id,
    required String userId,
    required String bookId,
    required String status,
    int? currentPage,
    DateTime? finishDate,
  }) {
    return BookUserCreationDto(
      id: id,
      userId: userId,
      bookId: bookId,
      status: status,
      currentPage: currentPage ?? 0,
      finishDate: status == 'completed' ? finishDate ?? DateTime.now() : null,
    );
  }

  // Método para convertir a JSON para crear un nuevo registro
  Map<String, dynamic> toJsonForCreation() {
    final json = toJson();
    json.remove('_id'); // Eliminar ID para creación
    json.remove('lastUpdated'); // Se generará en el servidor
    return json;
  }
}
