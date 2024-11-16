import '../model/triplevoc.dart';
import '../model/book.dart';


(TripleVoc, bool) getNextVocabulary(Book book, TripleVoc current, Map<String, String> completedVocabularies) {
  var currentLess = book.lessons[current.lessonId];
  var changed = false;
  if (currentLess.WordCount > current.vocabularyId + 1) {
    current.vocabularyId += 1;
    if (completedVocabularies.containsKey("${currentLess.lessonId}-${current.vocabularyId.toString()}")) {
      return getNextVocabulary(book, current, completedVocabularies);
    }
    changed = true;
  } else if (book.lessons.length > current.lessonId + 1) {
    current.lessonId += 1;
    current.vocabularyId = 0;
    if (completedVocabularies.containsKey("${currentLess.lessonId}-${current.vocabularyId.toString()}")) {
      return getNextVocabulary(book, current, completedVocabularies);
    }
    changed = true;
  }
  print("vocabulary, ${current.vocabularyId}");
  print("lesson, ${current.lessonId}"); // current.lessonId);
  return (current, changed);
}

(TripleVoc, bool) getPrevVocabulary(Book book, TripleVoc current, Map<String, String> completedVocabularies) {
  var currentLess = book.lessons[current.lessonId];
  var changed = false;
  if (current.vocabularyId - 1 >= 0) {
    current.vocabularyId -= 1;
    if (completedVocabularies.containsKey("${currentLess.lessonId}-${current.vocabularyId.toString()}")) {
      return getNextVocabulary(book, current, completedVocabularies);
    }
    changed = true;
  } else if (current.lessonId - 1 >= 0) {
    current.lessonId -= 1;
    current.vocabularyId = book.lessons[current.lessonId].WordCount - 1;
    if (completedVocabularies.containsKey("${currentLess.lessonId}-${current.vocabularyId.toString()}")) {
      return getNextVocabulary(book, current, completedVocabularies);
    }
    changed = true;
  }
  return (current, changed);
}