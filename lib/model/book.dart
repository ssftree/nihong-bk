import 'TripleVoc.dart';
import 'lesson.dart';

class Book {
  final String bookId;
  final String title;
  final List<Lesson> lessons;
  final int totalVocabularies;

  Book({
    required this.bookId,
    required this.title,
    required this.lessons,
    required this.totalVocabularies,
  });

  // Factory method to parse from JSON
  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      bookId: json['book_id'] as String,
      title: json['title'] as String,
      lessons: (json['lessons'] as List)
          .map((lessonJson) => Lesson.fromJson(lessonJson as Map<String, dynamic>))
          .toList(),
      totalVocabularies: (json['total_vocabulary'] as int),
    );
  }

  // Method to convert Book object to JSON
  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'title': title,
      "total_vocabulary": totalVocabularies,
      'lessons': lessons.map((lesson) => lesson.toJson()).toList(),
    };
  }
}

