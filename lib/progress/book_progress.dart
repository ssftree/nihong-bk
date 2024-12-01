import 'package:daily_word/model/triplevoc.dart';

class BookProgress {
  // key: "lessonId-vocId", value: timestamp
  late Map<String, int> completedWords;
  late Map<String, int> favoriteWords;
  late int totalCompleted;

  BookProgress() {
    completedWords = {};
    favoriteWords = {};
    totalCompleted = 0;
  }

  String concatKey(TripleVoc voc) {
    return "${voc.lessonId}-${voc.vocabularyId}";
  }

  bool isCompleted(TripleVoc voc) {
    return completedWords.containsKey(concatKey(voc));
  }

  bool isFavorite(TripleVoc voc) {
    return favoriteWords.containsKey(concatKey(voc));
  }

  void markAsCompleted(TripleVoc voc) {
    completedWords[concatKey(voc)] = DateTime.now().millisecondsSinceEpoch;
    totalCompleted++;
  }

  void markAsFavorite(TripleVoc voc) {
    favoriteWords[concatKey(voc)] = DateTime.now().millisecondsSinceEpoch;
  }

  void removeCompleted(TripleVoc voc) {
    completedWords.remove(concatKey(voc));
    totalCompleted--;
  }

  void removeFavorite(TripleVoc voc) {
    favoriteWords.remove(concatKey(voc));
  }

  Map<String, dynamic> toJson() {
    return {
      'completedWords': completedWords,
      'favoriteWords': favoriteWords,
      'totalCompleted': totalCompleted,
    };
  }

  factory BookProgress.fromJson(Map<String, dynamic> json) {
    final progress = BookProgress();
    progress.completedWords = Map<String, int>.from(json['completedWords']);
    progress.favoriteWords = Map<String, int>.from(json['favoriteWords']);
    progress.totalCompleted = json['totalCompleted'];
    return progress;
  }
}