class Notice {
  final String id;
  final String title;
  final String content;
  final String category;
  final String createdBy;
  final String? imageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Notice({
    required this.id,
    required this.title,
    required this.content,
    this.category = 'general',
    required this.createdBy,
    this.imageUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory Notice.fromMap(Map<String, dynamic> map) {
    return Notice(
      id: map['id'] as String,
      title: map['title'] as String,
      content: map['content'] as String,
      category: map['category'] as String? ?? 'general',
      createdBy: map['created_by'] as String,
      imageUrl: map['image_url'] as String?,
      createdAt: map['created_at'] != null
          ? DateTime.parse(map['created_at'] as String)
          : null,
      updatedAt: map['updated_at'] != null
          ? DateTime.parse(map['updated_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'category': category,
      'created_by': createdBy,
      if (imageUrl != null) 'image_url': imageUrl,
    };
  }

  /// Map category string to a display label
  String get categoryLabel {
    switch (category) {
      case 'academic':
        return 'Academic';
      case 'exam':
        return 'Exam';
      case 'holiday':
        return 'Holiday';
      case 'event':
        return 'Event';
      case 'general':
      default:
        return 'General';
    }
  }
}
