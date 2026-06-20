class Note {
  final String id;
  final String subject;
  final String courseCode;
  final String? description;
  final String fileUrl;
  final String fileName;
  final String uploadedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Note({
    required this.id,
    required this.subject,
    required this.courseCode,
    this.description,
    required this.fileUrl,
    required this.fileName,
    required this.uploadedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      subject: map['subject'] as String,
      courseCode: map['course_code'] as String,
      description: map['description'] as String?,
      fileUrl: map['file_url'] as String,
      fileName: map['file_name'] as String,
      uploadedBy: map['uploaded_by'] as String,
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
      'subject': subject,
      'course_code': courseCode,
      if (description != null) 'description': description,
      'file_url': fileUrl,
      'file_name': fileName,
      'uploaded_by': uploadedBy,
    };
  }
}
