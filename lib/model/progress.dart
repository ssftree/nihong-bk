class Progress {
  final int lastLesson;
  final int lastVocabulary;

  Progress({
    required this.lastLesson,
    required this.lastVocabulary,
  });

  factory Progress.fromJson(Map<String, dynamic> json) {
    return Progress(
      lastLesson: json['last_lesson'] as int,
      lastVocabulary: json['last_vocabulary'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'last_lesson': lastLesson,
      'last_vocabulary': lastVocabulary,
    };
  }
}
