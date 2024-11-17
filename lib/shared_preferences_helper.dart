import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesHelper {
  static SharedPreferences? _preferences;

  static const String _favoritesKey = 'favorites';
  static const String _completedKey = 'completedVocabularies';

  Future<Map<String, Map<String, String>>> getVocabulariesByKey(String key) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? vocabulariesJson = prefs.getString(key);
    if (vocabulariesJson != null) {
      final Map<String, dynamic> decodedMap = json.decode(vocabulariesJson);
      return decodedMap.map((key, value) {
        return MapEntry(key, Map<String, String>.from(value as Map<String, dynamic>));
      });
    } else {
      return {};
    }
  }

  Future<Map<String, Map<String, String>>> getFavoriteVocabularies() async {
    return getVocabulariesByKey(_favoritesKey);
  }

  Future<Map<String, Map<String, String>>> getCompletedVocabularies() async {
    return getVocabulariesByKey(_completedKey);
  }

  Future addVocabulary(String key, String bookId, String vocabularyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> vocabularies = await getVocabulariesByKey(key);
    if (!vocabularies.containsKey(bookId)) {
      vocabularies[bookId] = {};
    }
    final Map<String, String> vocabulary = vocabularies[bookId]!;
    vocabulary[vocabularyId] = DateTime.now().toIso8601String();
    vocabularies[bookId] = vocabulary;
    await prefs.setString(_favoritesKey, json.encode(vocabularies));
  }

  Future addFavoriteVocabulary(String bookId, String vocabularyId) async {
    addVocabulary(_favoritesKey, bookId, vocabularyId);
  }

  Future addCompletedVocabulary(String bookId, String vocabularyId) async {
    addVocabulary(_completedKey, bookId, vocabularyId);
  }

  Future removeVocabulary(String key, String bookId, String vocabularyId) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final Map<String, Map<String, String>> vocabularies = await getVocabulariesByKey(key);
    if (vocabularies.containsKey(bookId)) {
      final Map<String, String> vocabulary = vocabularies[bookId]!;
      vocabulary.remove(vocabularyId);
      vocabularies[bookId] = vocabulary;
      await prefs.setString(key, json.encode(vocabularies));
    }
  }

  Future removeFavoriteVocabulary(String bookId, String vocabularyId) async {
    removeVocabulary(_favoritesKey, bookId, vocabularyId);
  }

  Future removeCompletedVocabulary(String bookId, String vocabularyId) async {
    removeVocabulary(_completedKey, bookId, vocabularyId);
  }
}
