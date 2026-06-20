class Profile {
  final String id;
  final String? fullName;
  final String? studentId;
  final String? email;
  final String? department;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Profile({
    required this.id,
    this.fullName,
    this.studentId,
    this.email,
    this.department,
    this.avatarUrl,
    this.role = 'student',
    this.createdAt,
    this.updatedAt,
  });

  bool get isAdmin => role == 'admin';

  factory Profile.fromMap(Map<String, dynamic> map) {
    return Profile(
      id: map['id'] as String,
      fullName: map['full_name'] as String?,
      studentId: map['student_id'] as String?,
      email: map['email'] as String?,
      department: map['department'] as String?,
      avatarUrl: map['avatar_url'] as String?,
      role: map['role'] as String? ?? 'student',
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
      if (fullName != null) 'full_name': fullName,
      if (studentId != null) 'student_id': studentId,
      if (email != null) 'email': email,
      if (department != null) 'department': department,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
      if (role.isNotEmpty) 'role': role,
    };
  }

  Profile copyWith({
    String? fullName,
    String? studentId,
    String? email,
    String? department,
    String? avatarUrl,
    String? role,
  }) {
    return Profile(
      id: id,
      fullName: fullName ?? this.fullName,
      studentId: studentId ?? this.studentId,
      email: email ?? this.email,
      department: department ?? this.department,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
