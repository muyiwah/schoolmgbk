class UniformModel {
  final String day;
  final String uniform;

  UniformModel({required this.day, required this.uniform});

  factory UniformModel.fromJson(Map<String, dynamic> json) {
    return UniformModel(day: json['day'] ?? '', uniform: json['uniform'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'uniform': uniform};
  }

  // Helper method to get day abbreviation
  String get dayAbbreviation {
    switch (day) {
      case 'Monday':
        return 'Mon';
      case 'Tuesday':
        return 'Tue';
      case 'Wednesday':
        return 'Wed';
      case 'Thursday':
        return 'Thu';
      case 'Friday':
        return 'Fri';
      case 'Saturday':
        return 'Sat';
      case 'Sunday':
        return 'Sun';
      default:
        return day;
    }
  }

  // Helper method to get day color
  int get dayColor {
    switch (day) {
      case 'Monday':
        return 0xFF2196F3; // Blue
      case 'Tuesday':
        return 0xFF4CAF50; // Green
      case 'Wednesday':
        return 0xFFFF9800; // Orange
      case 'Thursday':
        return 0xFF9C27B0; // Purple
      case 'Friday':
        return 0xFFF44336; // Red
      case 'Saturday':
        return 0xFF607D8B; // Blue Grey
      case 'Sunday':
        return 0xFF795548; // Brown
      default:
        return 0xFF757575; // Grey
    }
  }
}

class UniformResponse {
  final bool success;
  final String message;
  final List<UniformModel>? data;

  UniformResponse({required this.success, required this.message, this.data});

  factory UniformResponse.fromJson(Map<String, dynamic> json) {
    return UniformResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? List<UniformModel>.from(
                json['data'].map((x) => UniformModel.fromJson(x)),
              )
              : null,
    );
  }
}

class UniformSingleResponse {
  final bool success;
  final String message;
  final UniformModel? data;

  UniformSingleResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory UniformSingleResponse.fromJson(Map<String, dynamic> json) {
    return UniformSingleResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: json['data'] != null ? UniformModel.fromJson(json['data']) : null,
    );
  }
}

class ClassLevel {
  final String id;
  final String name;

  ClassLevel({required this.id, required this.name});

  factory ClassLevel.fromJson(Map<String, dynamic> json) {
    return ClassLevel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name};
  }
}

class ClassWithUniforms {
  final String id;
  final String name;
  final String level;
  final String? section;
  final String academicYear;
  final ClassLevel classLevel;
  final List<UniformModel> uniforms;

  ClassWithUniforms({
    required this.id,
    required this.name,
    required this.level,
    this.section,
    required this.academicYear,
    required this.classLevel,
    required this.uniforms,
  });

  factory ClassWithUniforms.fromJson(Map<String, dynamic> json) {
    return ClassWithUniforms(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      section: json['section'],
      academicYear: json['academicYear'] ?? '',
      classLevel: ClassLevel.fromJson(json['classLevel'] ?? {}),
      uniforms:
          json['uniforms'] != null
              ? List<UniformModel>.from(
                json['uniforms'].map((x) => UniformModel.fromJson(x)),
              )
              : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'section': section,
      'academicYear': academicYear,
      'classLevel': classLevel.toJson(),
      'uniforms': uniforms.map((x) => x.toJson()).toList(),
    };
  }

  // Helper getter for display name
  String get displayName {
    if (section != null && section!.isNotEmpty) {
      return '$name ($section)';
    }
    return name;
  }

  // Helper getter for full class info
  String get fullInfo {
    return '$displayName - $level ($academicYear)';
  }

  // Helper to get uniforms count
  int get uniformsCount => uniforms.length;

  // Helper to check if class has uniforms
  bool get hasUniforms => uniforms.isNotEmpty;
}

class AllClassesUniformsResponse {
  final bool success;
  final String message;
  final int count;
  final List<ClassWithUniforms>? data;

  AllClassesUniformsResponse({
    required this.success,
    required this.message,
    required this.count,
    this.data,
  });

  factory AllClassesUniformsResponse.fromJson(Map<String, dynamic> json) {
    return AllClassesUniformsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      count: json['count'] ?? 0,
      data:
          json['data'] != null
              ? List<ClassWithUniforms>.from(
                json['data'].map((x) => ClassWithUniforms.fromJson(x)),
              )
              : null,
    );
  }
}
