class PagesReadStats {
  final String period;
  final int pagesRead;
  final int booksCount;

  PagesReadStats({
    required this.period,
    required this.pagesRead,
    required this.booksCount,
  });

  factory PagesReadStats.fromJson(Map<String, dynamic> json) {
    return PagesReadStats(
      period: json['period'] ?? 'week',
      pagesRead: json['pagesRead'] ?? 0,
      booksCount: json['booksCount'] ?? 0,
    );
  }
}
