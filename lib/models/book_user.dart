// models/book_user.dart
import 'book.dart';
import 'dtos/book_user_dto.dart';
import 'user.dart';

class Note {
  final int page;
  final String text;
  final DateTime createdAt;

  Note({
    required this.page,
    required this.text,
    DateTime? createdAt,
  }) : this.createdAt = createdAt ?? DateTime.now();
}

class ReadingSession {
  final DateTime? startDate;
  final DateTime? endDate;

  ReadingSession({
    this.startDate,
    this.endDate,
  });
}

class Review {
  final String? reviewId;
  final String text;
  final int rating;
  final DateTime date;
  final String? title;
  final bool isPublic;
  final ReadingSession? readingSession;
  final List<String> tags;

  Review({
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
}

class ReadingGoal {
  final int? pagesPerDay;
  final DateTime? targetFinishDate;

  ReadingGoal({
    this.pagesPerDay,
    this.targetFinishDate,
  });
}

class BookUser {
  final String? id;
  final String userId;
  final Book bookId;
  final String status;
  final int currentPage;
  final DateTime? startDate;
  final DateTime? finishDate;
  final int personalRating;
  final List<Review> reviews;
  final List<Note> notes;
  final ReadingGoal? readingGoal;
  final bool isPrivate;
  final bool shareProgress;
  final DateTime lastUpdated;

  // Referencias a modelos relacionados (no están en el esquema MongoDB pero útiles en la app)
  final Book? book;
  final User? user;

  BookUser({
    this.id,
    required this.userId,
    required this.bookId,
    this.status = 'to-read',
    this.currentPage = 0,
    this.startDate,
    this.finishDate,
    this.personalRating = 0,
    List<Review>? reviews,
    List<Note>? notes,
    this.readingGoal,
    this.isPrivate = false,
    this.shareProgress = true,
    DateTime? lastUpdated,
    this.book,
    this.user,
  })  : this.reviews = reviews ?? [],
        this.notes = notes ?? [],
        this.lastUpdated = lastUpdated ?? DateTime.now();

  // Factory para crear desde DTO
  factory BookUser.fromDto(BookUserDto dto, {Book? book, User? user}) {
    return BookUser(
      id: dto.id,
      userId: dto.userId,
      bookId: dto.bookId.toBook(),
      status: dto.status,
      currentPage: dto.currentPage,
      startDate: dto.startDate,
      finishDate: dto.finishDate,
      personalRating: dto.personalRating,
      reviews: dto.reviews
          .map((reviewDto) => Review(
                reviewId: reviewDto.reviewId,
                text: reviewDto.text,
                rating: reviewDto.rating,
                date: reviewDto.date,
                title: reviewDto.title,
                isPublic: reviewDto.isPublic,
                readingSession: reviewDto.readingSession != null
                    ? ReadingSession(
                        startDate: reviewDto.readingSession!.startDate,
                        endDate: reviewDto.readingSession!.endDate,
                      )
                    : null,
                tags: reviewDto.tags,
              ))
          .toList(),
      notes: dto.notes
          .map((noteDto) => Note(
                page: noteDto.page,
                text: noteDto.text,
                createdAt: noteDto.createdAt,
              ))
          .toList(),
      readingGoal: dto.readingGoal != null
          ? ReadingGoal(
              pagesPerDay: dto.readingGoal!.pagesPerDay,
              targetFinishDate: dto.readingGoal!.targetFinishDate,
            )
          : null,
      isPrivate: dto.isPrivate,
      shareProgress: dto.shareProgress,
      lastUpdated: dto.lastUpdated,
      book: book,
      user: user,
    );
  }

  // Calcular porcentaje de progreso basado en páginas leídas
  double get progressPercentage {
    if (book == null || book!.pageCount == null || book!.pageCount! <= 0) {
      return 0.0;
    }
    return (currentPage / book!.pageCount!) * 100;
  }

  // Verificar si se ha completado el libro
  bool get isCompleted {
    return status == 'completed';
  }

  // Calcular días restantes basados en el objetivo de lectura
  int? get daysRemaining {
    if (readingGoal == null ||
        readingGoal!.targetFinishDate == null ||
        status == 'completed') {
      return null;
    }

    final now = DateTime.now();
    final difference = readingGoal!.targetFinishDate!.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }

  // Calcular páginas por día necesarias para alcanzar el objetivo
  int? get pagesPerDayNeeded {
    if (book == null ||
        book!.pageCount == null ||
        readingGoal == null ||
        readingGoal!.targetFinishDate == null ||
        status == 'completed') {
      return null;
    }

    final now = DateTime.now();
    final daysLeft = readingGoal!.targetFinishDate!.difference(now).inDays;

    if (daysLeft <= 0) {
      return book!.pageCount! - currentPage;
    }

    final pagesLeft = book!.pageCount! - currentPage;
    return (pagesLeft / daysLeft).ceil();
  }
}
