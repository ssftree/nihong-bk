class VocabularyController {
  final SharedPreferencesHelper prefs;
  
  VocabularyController(this.prefs);

  Future<void> markAsCompleted(String bookId, String vocabularyId, Map<String, String> completedVocabularies) async {
    completedVocabularies[vocabularyId] = DateTime.now().toIso8601String();
    await prefs.addCompletedVocabulary(bookId, vocabularyId);
  }

  Future<void> markAsFavorite(String bookId, String vocabularyId, Map<String, String> favoriteVocabularies) async {
    favoriteVocabularies[vocabularyId] = DateTime.now().toIso8601String();
    await prefs.addFavoriteVocabulary(bookId, vocabularyId);
  }
  
  // ... 其他状态管理方法
} 