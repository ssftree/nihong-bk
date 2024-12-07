import 'package:daily_word/model/triplevoc.dart';
import 'package:daily_word/model/book_progress.dart';
import 'package:daily_word/shared_preferences_helper.dart';

import '../model/vocabulary.dart';

class VocabularyManager {
  final SharedPreferencesHelper prefs;
  final Function(String) showSnackBar;
  final Function(BookProgress, bool, int) onStateChanged;

  VocabularyManager({
    required this.prefs,
    required this.showSnackBar,
    required this.onStateChanged,
  });

  Future<void> markAsCompleted(TripleVoc curVoc, Vocabulary vocabulary) async {
    final bookProgress = await prefs.addCompletedVocabulary(curVoc, vocabulary);
    onStateChanged(bookProgress, true, bookProgress.totalCompleted);
    showSnackBar('🎉 恭喜你完成了第${bookProgress.totalCompleted}个单词');
  }

  Future<void> removeFromCompleted(TripleVoc curVoc) async {
    final bookProgress = await prefs.removeCompletedVocabulary(curVoc);
    onStateChanged(bookProgress, false, bookProgress.totalCompleted);
    showSnackBar('🎉 取消已完成');
  }

  Future<void> markAsFavorite(TripleVoc curVoc, Vocabulary vocabulary) async {
    final bookProgress = await prefs.addFavoriteVocabulary(curVoc, vocabulary);
    onStateChanged(bookProgress, true, bookProgress.totalCompleted);
    showSnackBar('🎉 添加到已收藏');
  }

  Future<void> removeFromFavorite(TripleVoc curVoc) async {
    final bookProgress = await prefs.removeFavoriteVocabulary(curVoc);
    onStateChanged(bookProgress, false, bookProgress.totalCompleted);
    showSnackBar('🎉 取消收藏');
  }
} 