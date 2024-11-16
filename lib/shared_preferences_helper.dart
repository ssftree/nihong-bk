import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _preferences;

  static const String _favoritesKey = 'favorites';
  static const String _completedVocabulariesKey = 'completedVocabularies';

  Future<Map<String, Map<String, String>>> getCompletedVocabularies() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? completedVocabulariesJson = prefs.getString(_completedVocabulariesKey);
    if (completedVocabulariesJson != null) {
      final Map<String, dynamic> decodedMap = json.decode(completedVocabulariesJson);
      return decodedMap.map((key, value) {
        return MapEntry(key, Map<String, String>.from(value as Map<String, dynamic>));
      });
    } else {
      return {};
    }
  }

  Future addCompletedVocabulary(String bookId, String vocabularyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> completedVocabularies = await getCompletedVocabularies();
    if (!completedVocabularies.containsKey(bookId)) {
      completedVocabularies[bookId] = {};
    }
    final Map<String, String> vocabulary = completedVocabularies[bookId]!;
    vocabulary[vocabularyId] = DateTime.now().toIso8601String();
    completedVocabularies[bookId] = vocabulary;
    await prefs.setString(_completedVocabulariesKey, json.encode(completedVocabularies));
  }

  Future<Map<String, Map<String, String>>> getFavoriteVocabularies() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? favoritesVocabulariesJson = prefs.getString(_favoritesKey);
    if (favoritesVocabulariesJson != null) {
      final Map<String, dynamic> decodedMap = json.decode(favoritesVocabulariesJson);
      return decodedMap.map((key, value) {
        return MapEntry(key, Map<String, String>.from(value as Map<String, dynamic>));
      });
    } else {
      return {};
    }
  }

  Future addFavoriteVocabulary(String bookId, String vocabularyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> favoriteVocabularies = await getFavoriteVocabularies();
    if (!favoriteVocabularies.containsKey(bookId)) {
      favoriteVocabularies[bookId] = {};
    }
    final Map<String, String> vocabulary = favoriteVocabularies[bookId]!;
    vocabulary[vocabularyId] = DateTime.now().toIso8601String();
    favoriteVocabularies[bookId] = vocabulary;
    await prefs.setString(_favoritesKey, json.encode(favoriteVocabularies));
  }

  Future removeFavoriteVocabulary(String bookId, String vocabularyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> favoriteVocabularies = await getFavoriteVocabularies();
    if (favoriteVocabularies.containsKey(bookId)) {
      final Map<String, String> vocabulary = favoriteVocabularies[bookId]!;
      vocabulary.remove(vocabularyId);
      favoriteVocabularies[bookId] = vocabulary;
      await prefs.setString(_favoritesKey, json.encode(favoriteVocabularies));
    }
  }
}
