class GenreStat {
  final String genre;
  final int count;

  GenreStat({
    required this.genre,
    required this.count,
  });

  factory GenreStat.fromJson(Map<String, dynamic> json) {
    return GenreStat(
      genre: json['genre'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}
