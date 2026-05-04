import 'package:equatable/equatable.dart';

enum BookStatus { wantToRead, reading, read }

class Book extends Equatable {
  final String id;
  final String title;
  final String author;
  final BookStatus status;
  final int totalPages;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? targetDate;
  final int currentPage;
  final int? rating;
  final String? review;
  final List<String> genres;
  final String? coverUrl;

  const Book({
    required this.id,
    required this.title,
    required this.author,
    required this.status,
    required this.totalPages,
    this.startDate,
    this.endDate,
    this.targetDate,
    this.currentPage = 0,
    this.rating,
    this.review,
    this.genres = const [],
    this.coverUrl,
  });

  double? get pagesPerDay {
    if (status != BookStatus.read || startDate == null || endDate == null) {
      return null;
    }
    final days = endDate!.difference(startDate!).inDays;
    return days <= 0 ? totalPages.toDouble() : totalPages / days;
  }

  double? get pagesPerDayTarget {
    if (status != BookStatus.reading || startDate == null || targetDate == null) return null;
    final days = targetDate!.difference(startDate!).inDays;
    return days <= 0 ? totalPages.toDouble() : totalPages / days;
  }

  double? get readingProgress =>
      totalPages > 0 ? (currentPage / totalPages).clamp(0.0, 1.0) : null;

  DateTime? get estimatedCompletionDate {
    if (status != BookStatus.reading || startDate == null || currentPage <= 0) return null;
    final daysElapsed = DateTime.now().difference(startDate!).inDays;
    // Mínimo 3 dias para ter um ritmo confiável — com 1-2 dias o dado é ruído
    if (daysElapsed < 3) return null;
    final pace = currentPage / daysElapsed;
    if (pace <= 0) return null;
    final remaining = totalPages - currentPage;
    if (remaining <= 0) return null;
    final daysLeft = (remaining / pace).ceil();
    return DateTime.now().add(Duration(days: daysLeft));
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    BookStatus? status,
    int? totalPages,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? targetDate,
    int? currentPage,
    int? rating,
    String? review,
    List<String>? genres,
    String? coverUrl,
    bool clearStartDate = false,
    bool clearEndDate = false,
    bool clearTargetDate = false,
    bool clearRating = false,
    bool clearReview = false,
    bool clearCoverUrl = false,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      status: status ?? this.status,
      totalPages: totalPages ?? this.totalPages,
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      currentPage: currentPage ?? this.currentPage,
      rating: clearRating ? null : (rating ?? this.rating),
      review: clearReview ? null : (review ?? this.review),
      genres: genres ?? this.genres,
      coverUrl: clearCoverUrl ? null : (coverUrl ?? this.coverUrl),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        author,
        status,
        totalPages,
        startDate,
        endDate,
        targetDate,
        currentPage,
        rating,
        review,
        genres,
        coverUrl,
      ];
}
