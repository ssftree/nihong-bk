class CustomLesson {
  final String id;
  final String softLink;

  CustomLesson({required this.id, required this.softLink});

  factory CustomLesson.fromJson(Map<String, dynamic> json) {
    return CustomLesson(
      id: json['id'] as String,
      softLink: json['soft_link'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'soft_link': softLink,
    };
  }

}