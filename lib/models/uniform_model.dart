class UniformModel {
  final String day;
  final String uniform;
  final String id;

  UniformModel({required this.day, required this.uniform, this.id = ''});

  int get dayColor {
    switch (day.toLowerCase()) {
      case 'monday':
        return 0xFF2196F3; // Blue
      case 'tuesday':
        return 0xFF4CAF50; // Green
      case 'wednesday':
        return 0xFFFF9800; // Orange
      case 'thursday':
        return 0xFF9C27B0; // Purple
      case 'friday':
        return 0xFFF44336; // Red
      case 'saturday':
        return 0xFF607D8B; // Blue Grey
      case 'sunday':
        return 0xFF795548; // Brown
      default:
        return 0xFF9E9E9E; // Grey
    }
  }

  String get dayAbbreviation {
    switch (day.toLowerCase()) {
      case 'monday':
        return 'MON';
      case 'tuesday':
        return 'TUE';
      case 'wednesday':
        return 'WED';
      case 'thursday':
        return 'THU';
      case 'friday':
        return 'FRI';
      case 'saturday':
        return 'SAT';
      case 'sunday':
        return 'SUN';
      default:
        return day.substring(0, 3).toUpperCase();
    }
  }

  factory UniformModel.fromJson(Map<String, dynamic> json) {
    return UniformModel(
      day: json['day'] ?? '',
      uniform: json['uniform'] ?? '',
      id: json['id'] ?? json['_id'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'day': day, 'uniform': uniform, 'id': id};
  }
}

class UniformResponseModel {
  final bool success;
  final List<UniformModel> uniforms;

  UniformResponseModel({required this.success, required this.uniforms});

  factory UniformResponseModel.fromJson(Map<String, dynamic> json) {
    return UniformResponseModel(
      success: json['success'] ?? false,
      uniforms:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => UniformModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'data': uniforms.map((uniform) => uniform.toJson()).toList(),
    };
  }
}

class ClassWithUniforms {
  final String id;
  final String name;
  final String level;
  final String academicYear;
  final List<UniformModel> uniforms;
  final int uniformsCount;

  ClassWithUniforms({
    required this.id,
    required this.name,
    required this.level,
    required this.academicYear,
    required this.uniforms,
    required this.uniformsCount,
  });

  factory ClassWithUniforms.fromJson(Map<String, dynamic> json) {
    return ClassWithUniforms(
      id: json['id'] ?? json['_id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      academicYear: json['academicYear'] ?? '',
      uniforms:
          (json['uniforms'] as List<dynamic>?)
              ?.map(
                (item) => UniformModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      uniformsCount: json['uniformsCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'academicYear': academicYear,
      'uniforms': uniforms.map((uniform) => uniform.toJson()).toList(),
      'uniformsCount': uniformsCount,
    };
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
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) => UniformModel.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
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
      data:
          json['data'] != null
              ? UniformModel.fromJson(json['data'] as Map<String, dynamic>)
              : null,
    );
  }
}

class AllClassesUniformsResponse {
  final bool success;
  final String message;
  final List<ClassWithUniforms>? data;
  final int count;

  AllClassesUniformsResponse({
    required this.success,
    required this.message,
    this.data,
    required this.count,
  });

  factory AllClassesUniformsResponse.fromJson(Map<String, dynamic> json) {
    return AllClassesUniformsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          (json['data'] as List<dynamic>?)
              ?.map(
                (item) =>
                    ClassWithUniforms.fromJson(item as Map<String, dynamic>),
              )
              .toList(),
      count: json['count'] ?? 0,
    );
  }
}
