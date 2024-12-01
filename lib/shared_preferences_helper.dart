import 'dart:convert';
import 'package:daily_word/model/constants.dart';
import 'package:daily_word/progress/book_progress.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'model/triplevoc.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _preferences;
  static const String _autoPlayKey = 'autoPlay';
  static const String _custom = 'custom_';

  String concatKey(TripleVoc voc) {
    return "${voc.lessonId}-${voc.vocabularyId}";
  }

  Future<BookProgress> getProgressByKey(String bookId) async {
    String key = _custom + bookId;
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString(key);
    if (progressJson != null) {
      final Map<String, dynamic> decodedMap = json.decode(progressJson);
      return BookProgress.fromJson(decodedMap);
    } else {
      return BookProgress();
    }
  }

  Future<BookProgress> addVocabulary(TripleVoc voc, String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final BookProgress progress = await getProgressByKey(voc.bookIdStr);
    if (key == Enums.favoritesKey) {
      progress.markAsFavorite(voc);
    } else {
      progress.markAsCompleted(voc);
    }
    await prefs.setString(_custom + voc.bookIdStr, json.encode(progress.toJson()));
    return progress;
  }

  Future<BookProgress> addFavoriteVocabulary(TripleVoc voc) async {
    return addVocabulary(voc, Enums.favoritesKey);
  }

  Future<BookProgress> addCompletedVocabulary(TripleVoc voc) async {
    return addVocabulary(voc, Enums.completedKey);
  }

  Future<BookProgress> removeVocabulary(TripleVoc voc, String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final BookProgress progress = await getProgressByKey(key);
    if (key == Enums.favoritesKey) {
      progress.removeFavorite(voc);
    } else {
      progress.removeCompleted(voc);
    }
    await prefs.setString(_custom + voc.bookIdStr, json.encode(progress.toJson()));
    return progress;
  }

  Future<BookProgress> removeFavoriteVocabulary(TripleVoc voc) async {
    return removeVocabulary(voc, Enums.favoritesKey);
  }

  Future<BookProgress> removeCompletedVocabulary(TripleVoc voc) async {
    return removeVocabulary(voc, Enums.completedKey);
  }

  Future<bool> getAutoPlay() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_autoPlayKey) ?? false;
  }

  Future setAutoPlay(bool value) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_autoPlayKey, value);
  }
}
