class TripleVoc {
  int bookId;
  int lessonId;
  int vocabularyId;

  TripleVoc({
    required this.bookId,
    required this.lessonId,
    required this.vocabularyId,
  });

  String getBookIdString() {
    return bookId.toString();
  }

  String getLessonIdString() {
    return lessonId.toString();
  }

  String getVocabularyIdString() {
    return vocabularyId.toString();
  }
}