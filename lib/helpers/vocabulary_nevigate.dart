import '../model/triplevoc.dart';
import '../model/book.dart';

(TripleVoc, bool) getNextVocabulary(Book book, TripleVoc current) {
  var currentLess = book.lessons[current.lessonId];
  var changed = false;
  if (currentLess.WordCount > current.vocabularyId + 1) {
    current.vocabularyId += 1;
    changed = true;
  } else if (book.lessons.length > current.lessonId + 1) {
    current.lessonId += 1;
    current.vocabularyId = 0;
    changed = true;
  }
  return (current, changed);
}

(TripleVoc, bool) getPrevVocabulary(Book book, TripleVoc current) {
  var changed = false;
  if (current.vocabularyId - 1 >= 0) {
    current.vocabularyId -= 1;
    changed = true;
  } else if (current.lessonId - 1 >= 0) {
    current.lessonId -= 1;
    current.vocabularyId = book.lessons[current.lessonId].WordCount - 1;
    changed = true;
  }
  return (current, changed);
}