import 'package:json_annotation/json_annotation.dart';

part 'book_user_dto.g.dart';

// DTO para las notas
@JsonSerializable()
class NoteDto {
  @JsonKey(name: 'page')
  final int page;

  @JsonKey(name: 'text')
  final String text;

  @JsonKey(
      name: 'createdAt', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime createdAt;

  NoteDto({
    required this.page,
    required this.text,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();

  // From JSON
  factory NoteDto.fromJson(Map<String, dynamic> json) =>
      _$NoteDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$NoteDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}

// DTO para las sesiones de lectura en las reviews
@JsonSerializable()
class ReadingSessionDto {
  @JsonKey(
      name: 'startDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? startDate;

  @JsonKey(
      name: 'endDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? endDate;

  ReadingSessionDto({
    this.startDate,
    this.endDate,
  });

  // From JSON
  factory ReadingSessionDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingSessionDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$ReadingSessionDtoToJson(this);

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();
}

// DTO para las reviews
@JsonSerializable()
class ReviewDto {
  @JsonKey(name: 'reviewId')
  final String? reviewId;

  @JsonKey(name: 'text')
  final String text;

  @JsonKey(name: 'rating')
  final int rating;

  @JsonKey(name: 'date', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime date;

  @JsonKey(name: 'title')
  final String? title;

  @JsonKey(name: 'isPublic')
  final bool isPublic;

  @JsonKey(name: 'readingSession')
  final ReadingSessionDto? readingSession;

  @JsonKey(name: 'tags')
  final List<String> tags;

  ReviewDto({
    this.reviewId,
    required this.text,
    this.rating = 0,
    DateTime? date,
    this.title,
    this.isPublic = true,
    this.readingSession,
    List<String>? tags,
  })  : this.date = date ?? DateTime.now(),
        this.tags = tags ?? [];

  // From JSON
  factory ReviewDto.fromJson(Map<String, dynamic> json) =>
      _$ReviewDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$ReviewDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();
}

// DTO para los objetivos de lectura
@JsonSerializable()
class ReadingGoalDto {
  @JsonKey(name: 'pagesPerDay')
  final int? pagesPerDay;

  @JsonKey(
      name: 'targetFinishDate',
      fromJson: _dateTimeFromNullableJson,
      toJson: _dateTimeToNullableJson)
  final DateTime? targetFinishDate;

  ReadingGoalDto({
    this.pagesPerDay,
    this.targetFinishDate,
  });

  // From JSON
  factory ReadingGoalDto.fromJson(Map<String, dynamic> json) =>
      _$ReadingGoalDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$ReadingGoalDtoToJson(this);

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();
}

// DTO principal para BookUser
@JsonSerializable()
class BookUserDto {
  @JsonKey(name: '_id') // MongoDB uses _id by default
  final String? id;

  @JsonKey(name: 'userId')
  final String userId;

  @JsonKey(name: 'bookId')
  final String bookId;

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

  @JsonKey(name: 'reviews')
  final List<ReviewDto> reviews;

  @JsonKey(name: 'notes')
  final List<NoteDto> notes;

  @JsonKey(name: 'readingGoal')
  final ReadingGoalDto? readingGoal;

  @JsonKey(name: 'isPrivate')
  final bool isPrivate;

  @JsonKey(name: 'shareProgress')
  final bool shareProgress;

  @JsonKey(
      name: 'lastUpdated', fromJson: _dateTimeFromJson, toJson: _dateTimeToJson)
  final DateTime lastUpdated;

  BookUserDto({
    this.id,
    required this.userId,
    required this.bookId,
    this.status = 'to-read',
    this.currentPage = 0,
    this.startDate,
    this.finishDate,
    this.personalRating = 0,
    List<ReviewDto>? reviews,
    List<NoteDto>? notes,
    this.readingGoal,
    this.isPrivate = false,
    this.shareProgress = true,
    DateTime? lastUpdated,
  })  : this.reviews = reviews ?? [],
        this.notes = notes ?? [],
        this.lastUpdated = lastUpdated ?? DateTime.now();

  // From JSON
  factory BookUserDto.fromJson(Map<String, dynamic> json) =>
      _$BookUserDtoFromJson(json);

  // To JSON
  Map<String, dynamic> toJson() => _$BookUserDtoToJson(this);

  // Helper methods for DateTime conversion
  static DateTime _dateTimeFromJson(String date) => DateTime.parse(date);
  static String _dateTimeToJson(DateTime date) => date.toIso8601String();

  // Helper methods for nullable DateTime conversion
  static DateTime? _dateTimeFromNullableJson(String? date) =>
      date != null ? DateTime.parse(date) : null;
  static String? _dateTimeToNullableJson(DateTime? date) =>
      date?.toIso8601String();

  // Factory para crear un nuevo registro de lectura
  factory BookUserDto.forNewReading({
    required String userId,
    required String bookId,
    String status = 'to-read',
  }) {
    return BookUserDto(
      userId: userId,
      bookId: bookId,
      status: status,
      startDate: status == 'reading' ? DateTime.now() : null,
    );
  }

  // Factory para actualizar el estado de lectura
  factory BookUserDto.forStatusUpdate({
    required String id,
    required String userId,
    required String bookId,
    required String status,
    int? currentPage,
    DateTime? finishDate,
  }) {
    return BookUserDto(
      id: id,
      userId: userId,
      bookId: bookId,
      status: status,
      currentPage: currentPage ?? 0,
      finishDate: status == 'completed' ? finishDate ?? DateTime.now() : null,
    );
  }

  // Factory para agregar una reseña
  factory BookUserDto.forAddReview({
    required String id,
    required String userId,
    required String bookId,
    required ReviewDto review,
  }) {
    return BookUserDto(
      id: id,
      userId: userId,
      bookId: bookId,
      status:
          'completed', // Asumimos que si añade reseña, el libro está completado
      reviews: [review],
    );
  }

  // Método para convertir a JSON para crear un nuevo registro
  Map<String, dynamic> toJsonForCreation() {
    // Solo incluir los campos mínimos necesarios para la creación
    return {
      'userId': userId,
      'bookId': bookId,
      'status': status,
      'currentPage': currentPage,
      'startDate': startDate?.toIso8601String(),
      // Excluir los campos reviews, notes, readingGoal y otros que puedan causar problemas
    };
  }
}
