class CalendarEvent {
  final String id;
  final String title;
  final DateTime eventDate;
  final String icon;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CalendarEvent({
    required this.id,
    required this.title,
    required this.eventDate,
    this.icon = 'event',
    this.createdAt,
    this.updatedAt,
  });

  factory CalendarEvent.fromMap(Map<String, dynamic> map) {
    return CalendarEvent(
      id: map['id'] as String,
      title: map['title'] as String,
      eventDate: DateTime.parse(map['event_date'] as String),
      icon: map['icon'] as String? ?? 'event',
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
      'event_date': eventDate.toIso8601String().split('T').first,
      if (icon.isNotEmpty) 'icon': icon,
    };
  }

  /// Map icon string to an Icons constant name for display
  String get displayIcon {
    switch (icon) {
      case 'school':
        return 'school';
      case 'edit_document':
        return 'edit_note';
      case 'mic':
        return 'mic';
      case 'celebration':
        return 'celebration';
      case 'assignment':
        return 'assignment';
      case 'event':
      default:
        return 'event';
    }
  }
}
