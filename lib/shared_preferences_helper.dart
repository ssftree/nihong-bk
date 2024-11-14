import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'model/progress.dart';


class SharedPreferencesHelper {
  static SharedPreferences? _preferences;

  static const String _favoritesKey = 'favorites';
  static const String _progressKey = 'progress';

  Future<Map<String, Progress>> getProgressData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? progressJson = prefs.getString(_progressKey);

    // Decode JSON if it exists and map to ProgressModel instances, otherwise return an empty map
    if (progressJson != null) {
      final Map<String, dynamic> jsonData = json.decode(progressJson);
      return jsonData.map((key, value) =>
          MapEntry(key, Progress.fromJson(Map<String, dynamic>.from(value))));
    } else {
      return {};
    }
  }

  Future<Progress?> getProgressForBook(String bookId) async {
    final Map<String, Progress> progressData = await getProgressData();
    if (progressData.containsKey(bookId)) {
      return progressData[bookId];
    } else {
      return Progress(lastLesson: 1, lastVocabulary: 1);
    }
  }


}
