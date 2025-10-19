
class Quiz {
  final String id;
  final String title;
  final String description;
  final String category;
  final bool isPublished;
  final int durationMinutes;
  final int totalQuestions;
  final String createdByUid;
  final String imageUrl;

  const Quiz({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.isPublished,
    required this.durationMinutes,
    required this.totalQuestions,
    required this.createdByUid,
    required this.imageUrl,
  });
}
