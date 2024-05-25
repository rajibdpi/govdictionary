class Word {
  final String correct;
  final String incorrect;

  Word({
    required this.correct,
    required this.incorrect,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      correct: json['correct'] ?? '',
      incorrect: json['incorrect'] ?? '',
    );
  }
}
