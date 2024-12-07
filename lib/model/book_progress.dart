import 'package:daily_word/model/triplevoc.dart';

import 'vocabulary.dart';

class StoredVocabulary {
  int timestamp;
  Vocabulary vocabulary;
  StoredVocabulary({required this.vocabulary, required this.timestamp});
}

class BookProgress {
  // key: "lessonId-vocId", value: timestamp
  late Map<String, StoredVocabulary> completedWords;
  late Map<String, StoredVocabulary> favoriteWords;
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

  void markAsCompleted(TripleVoc voc, Vocabulary vocabulary) {
    completedWords[concatKey(voc)] = StoredVocabulary(
      vocabulary: vocabulary ,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
    totalCompleted++;
  }

  void markAsFavorite(TripleVoc voc, Vocabulary vocabulary) {
    favoriteWords[concatKey(voc)] = StoredVocabulary(
      vocabulary: vocabulary ,
      timestamp: DateTime.now().millisecondsSinceEpoch,
    );
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
      'completedWords': completedWords.map((key, value) => MapEntry(key, {
            'timestamp': value.timestamp,
            'vocabulary': value.vocabulary.toJson(),
          })),
      'favoriteWords': favoriteWords.map((key, value) => MapEntry(key, {
            'timestamp': value.timestamp,
            'vocabulary': value.vocabulary.toJson(),
          })),
      'totalCompleted': totalCompleted,
    };
  }

  factory BookProgress.fromJson(Map<String, dynamic> json) {
    final progress = BookProgress();
    progress.completedWords = (json['completedWords'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        StoredVocabulary(
          timestamp: value['timestamp'],
          vocabulary: Vocabulary.fromJson(value['vocabulary']),
        ),
      ),
    );
    progress.favoriteWords = (json['favoriteWords'] as Map<String, dynamic>).map(
      (key, value) => MapEntry(
        key,
        StoredVocabulary(
          timestamp: value['timestamp'],
          vocabulary: Vocabulary.fromJson(value['vocabulary']),
        ),
      ),
    );
    progress.totalCompleted = json['totalCompleted'];
    return progress;
  }
}