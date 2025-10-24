// models/subject_model.dart
class Subject {
  final String id;
  final String name;
  final String? code;
  final String category;
  final String department;
  final String level;
  final bool isActive;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Subject({
    required this.id,
    required this.name,
    this.code,
    required this.category,
    required this.department,
    required this.level,
    required this.isActive,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      code: json['code'],
      category: json['category'] ?? 'Core',
      department: json['department'] ?? 'General',
      level: json['level'] ?? 'Nursery',
      isActive: json['isActive'] ?? true,
      description: json['description'],
      createdAt:
          json['createdAt'] != null
              ? DateTime.tryParse(json['createdAt'].toString())
              : null,
      updatedAt:
          json['updatedAt'] != null
              ? DateTime.tryParse(json['updatedAt'].toString())
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'category': category,
      'department': department,
      'level': level,
      'isActive': isActive,
      'description': description,
    };
  }

  // Helper methods for enums
  static const List<String> categories = [
    'Core',
    'Elective',
    'Practical',
    'Extra-curricular',
  ];

  static const List<String> departments = [
    'Science',
    'Arts',
    'Commercial',
    'General',
  ];

  static const List<String> levels = ['Nursery', 'Primary', 'Secondary'];
}
