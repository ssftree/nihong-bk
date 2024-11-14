class Lesson {
  final String lessonId;
  final String lessonTitle;

  Lesson({required this.lessonId, required this.lessonTitle});

  // Factory method to parse from JSON
  factory Lesson.fromJson(Map<String, dynamic> json) {
    return Lesson(
      lessonId: json['lessonID'] as String, // Make sure the key matches your JSON structure
      lessonTitle: json['lessTitle'] as String, // Make sure the key matches your JSON structure
    );
  }

  // Method to convert Lesson object to JSON
  Map<String, dynamic> toJson() {
    return {
      'lessonID': lessonId,
      'lessTitle': lessonTitle,
    };
  }
}
