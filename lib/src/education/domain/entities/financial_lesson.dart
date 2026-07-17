class FinancialLesson {
  final String id;
  final String category;
  final String title;
  final String shortDescription;
  final List<String> content;
  final int estimatedMinutes;
  final String level;
  final String yachayMessage;
  final String suggestedAction;

  const FinancialLesson({
    required this.id,
    required this.category,
    required this.title,
    required this.shortDescription,
    required this.content,
    required this.estimatedMinutes,
    required this.level,
    required this.yachayMessage,
    required this.suggestedAction,
  });
}
