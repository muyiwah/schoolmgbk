class ClassLevelModel {
  final String id;
  final String name;
  final String displayName;
  final String? description;
  final int order;
  final String category;
  final bool isActive;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  ClassLevelModel({
    required this.id,
    required this.name,
    required this.displayName,
    this.description,
    required this.order,
    required this.category,
    required this.isActive,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory ClassLevelModel.fromJson(Map<String, dynamic> json) {
    return ClassLevelModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      displayName: json['displayName'] ?? '',
      description: json['description'],
      order: json['order'] ?? 0,
      category: json['category'] ?? '',
      isActive: json['isActive'] ?? true,
      createdBy: json['createdBy'] ?? '', // Backend doesn't provide this
      updatedBy: json['updatedBy'] ?? '', // Backend doesn't provide this
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'displayName': displayName,
      'description': description,
      'order': order,
      'category': category,
      'isActive': isActive,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ClassLevelModel copyWith({
    String? id,
    String? name,
    String? displayName,
    String? description,
    int? order,
    String? category,
    bool? isActive,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ClassLevelModel(
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      description: description ?? this.description,
      order: order ?? this.order,
      category: category ?? this.category,
      isActive: isActive ?? this.isActive,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class ClassLevelsResponseModel {
  final List<ClassLevelModel> classLevels;
  final int totalCount;
  final int activeCount;
  final Map<String, int> categoryCounts;

  ClassLevelsResponseModel({
    required this.classLevels,
    required this.totalCount,
    required this.activeCount,
    required this.categoryCounts,
  });

  factory ClassLevelsResponseModel.fromJson(Map<String, dynamic> json) {
    return ClassLevelsResponseModel(
      classLevels:
          (json['data'] as List? ?? [])
              .map((e) => ClassLevelModel.fromJson(e))
              .toList(),
      totalCount: json['count'] ?? 0, // Backend uses 'count' not 'totalCount'
      activeCount: json['activeCount'] ?? 0,
      categoryCounts: Map<String, int>.from(json['categoryCounts'] ?? {}),
    );
  }
}

class BulkCreateClassLevelsModel {
  final List<Map<String, dynamic>> levels;

  BulkCreateClassLevelsModel({required this.levels});

  Map<String, dynamic> toJson() {
    return {'levels': levels};
  }

  // Validation method
  bool isValid() {
    if (levels.isEmpty) return false;

    for (var level in levels) {
      if (level['name']?.toString().isEmpty == true ||
          level['displayName']?.toString().isEmpty == true) {
        return false;
      }
    }
    return true;
  }

  // Get validation errors
  List<String> getValidationErrors() {
    List<String> errors = [];

    if (levels.isEmpty) {
      errors.add('At least one class level is required');
    }

    for (int i = 0; i < levels.length; i++) {
      var level = levels[i];
      if (level['name']?.toString().isEmpty == true) {
        errors.add('Level ${i + 1}: Name is required');
      }
      if (level['displayName']?.toString().isEmpty == true) {
        errors.add('Level ${i + 1}: Display name is required');
      }
    }

    return errors;
  }
}

class ReorderClassLevelsModel {
  final List<Map<String, dynamic>> reorderData;

  ReorderClassLevelsModel({required this.reorderData});

  Map<String, dynamic> toJson() {
    return {'reorderData': reorderData};
  }
}
