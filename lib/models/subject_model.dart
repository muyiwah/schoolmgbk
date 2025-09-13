// models/subject_model.dart
class Subject {
  final String id;
  final String name;
  final String? code;
  final String category;
  final String department;
  final String difficulty;
  final bool isActive;
  final String? description;

  Subject({
    required this.id,
    required this.name,
    this.code,
    required this.category,
    required this.department,
    required this.difficulty,
    required this.isActive,
    this.description,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['_id'],
      name: json['name'],
      code: json['code'],
      category: json['category'],
      department: json['department'],
      difficulty: json['difficulty'],
      isActive: json['isActive'],
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'category': category,
      'department': department,
      'difficulty': difficulty,
      'isActive': isActive,
      'description': description,
    };
  }
}
