class Achievement {
  final String id;
  final String title;
  final String description;
  final String emoji;
  final DateTime? earnedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.emoji,
    this.earnedAt,
  });

  bool get isEarned => earnedAt != null;

  Achievement copyWith({DateTime? earnedAt}) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      emoji: emoji,
      earnedAt: earnedAt ?? this.earnedAt,
    );
  }

  static const List<Achievement> all = [
    Achievement(
      id: 'first_book',
      emoji: '📖',
      title: 'Primeira Página',
      description: '1 livro lido',
    ),
    Achievement(
      id: 'ten_books',
      emoji: '🏆',
      title: 'Leitor Dedicado',
      description: '10 livros lidos',
    ),
    Achievement(
      id: 'thirty_books',
      emoji: '🌟',
      title: 'Maratonista',
      description: '30 livros lidos',
    ),
    Achievement(
      id: 'streak_7',
      emoji: '🔥',
      title: 'Chama Viva',
      description: 'Sequência de 7 dias',
    ),
    Achievement(
      id: 'streak_30',
      emoji: '⚡',
      title: 'Imparável',
      description: 'Sequência de 30 dias',
    ),
    Achievement(
      id: 'critic',
      emoji: '⭐',
      title: 'Crítico Literário',
      description: '10 avaliações dadas',
    ),
    Achievement(
      id: 'genre_master',
      emoji: '🎭',
      title: 'Especialista',
      description: '5 livros do mesmo gênero',
    ),
    Achievement(
      id: 'speed_reader',
      emoji: '💨',
      title: 'Leitor Veloz',
      description: 'Livro lido em ≤ 3 dias',
    ),
  ];
}
