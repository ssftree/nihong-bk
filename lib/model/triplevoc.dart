class TripleVoc {
  int bookId;
  int lessonId;
  int vocabularyId;
  String bookIdStr= '';
  String lessonIdStr= '';
  String vocabularyIdStr= '';

  TripleVoc({
    required this.bookId,
    required this.lessonId,
    required this.vocabularyId,
  }) {
    bookIdStr = bookId.toString();
    lessonIdStr = lessonId.toString();
    vocabularyIdStr = vocabularyId.toString();
  }
}