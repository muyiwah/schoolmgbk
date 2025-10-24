class AcademicSettingsModel {
  final String id;
  final String academicYear;
  final String currentTerm;
  final bool isActive;
  final DateTime startDate;
  final DateTime endDate;
  final List<TermModel> terms;
  final String? description;
  final String createdBy;
  final String? updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  AcademicSettingsModel({
    required this.id,
    required this.academicYear,
    required this.currentTerm,
    required this.isActive,
    required this.startDate,
    required this.endDate,
    required this.terms,
    this.description,
    required this.createdBy,
    this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AcademicSettingsModel.fromJson(Map<String, dynamic> json) {
    return AcademicSettingsModel(
      id: json['_id'] ?? json['id'] ?? '',
      academicYear: json['academicYear'] ?? '',
      currentTerm: json['currentTerm'] ?? 'First',
      isActive: json['isActive'] ?? false,
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      terms:
          (json['terms'] as List<dynamic>?)
              ?.map((term) => TermModel.fromJson(term))
              .toList() ??
          [],
      description: json['description'],
      createdBy:
          json['createdBy'] is String
              ? json['createdBy']
              : json['createdBy']?['_id'] ?? '',
      updatedBy:
          json['updatedBy'] is String
              ? json['updatedBy']
              : json['updatedBy']?['_id'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'academicYear': academicYear,
      'currentTerm': currentTerm,
      'isActive': isActive,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'terms': terms.map((term) => term.toJson()).toList(),
      'description': description,
      'createdBy': createdBy,
      'updatedBy': updatedBy,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  AcademicSettingsModel copyWith({
    String? id,
    String? academicYear,
    String? currentTerm,
    bool? isActive,
    DateTime? startDate,
    DateTime? endDate,
    List<TermModel>? terms,
    String? description,
    String? createdBy,
    String? updatedBy,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AcademicSettingsModel(
      id: id ?? this.id,
      academicYear: academicYear ?? this.academicYear,
      currentTerm: currentTerm ?? this.currentTerm,
      isActive: isActive ?? this.isActive,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      terms: terms ?? this.terms,
      description: description ?? this.description,
      createdBy: createdBy ?? this.createdBy,
      updatedBy: updatedBy ?? this.updatedBy,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class TermModel {
  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  TermModel({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    required this.isActive,
  });

  factory TermModel.fromJson(Map<String, dynamic> json) {
    return TermModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      startDate: DateTime.parse(json['startDate']),
      endDate: DateTime.parse(json['endDate']),
      isActive: json['isActive'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'isActive': isActive,
    };
  }

  TermModel copyWith({
    String? id,
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
  }) {
    return TermModel(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
    );
  }
}

class UpdateResult {
  final int matchedCount;
  final int modifiedCount;
  final bool acknowledged;

  UpdateResult({
    required this.matchedCount,
    required this.modifiedCount,
    required this.acknowledged,
  });

  factory UpdateResult.fromJson(Map<String, dynamic> json) {
    return UpdateResult(
      matchedCount: json['matchedCount'] ?? 0,
      modifiedCount: json['modifiedCount'] ?? 0,
      acknowledged: json['acknowledged'] ?? false,
    );
  }
}

class AcademicSettingsResponse {
  final bool success;
  final String message;
  final AcademicSettingsData? data;

  AcademicSettingsResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory AcademicSettingsResponse.fromJson(Map<String, dynamic> json) {
    return AcademicSettingsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? AcademicSettingsData.fromJson(json['data'])
              : null,
    );
  }
}

class AcademicSettingsData {
  final List<AcademicSettingsModel> academicSettings;
  final PaginationInfo? pagination;
  final AcademicSettingsModel? academicSettingsSingle;
  final Statistics? statistics;
  final UpdateResult? updateResult;

  AcademicSettingsData({
    required this.academicSettings,
    this.pagination,
    this.academicSettingsSingle,
    this.statistics,
    this.updateResult,
  });

  factory AcademicSettingsData.fromJson(Map<String, dynamic> json) {
    // Handle different response formats
    List<AcademicSettingsModel> academicSettingsList = [];
    AcademicSettingsModel? academicSettingsSingle;

    if (json['academicSettings'] != null) {
      if (json['academicSettings'] is List) {
        // Handle list response (getAllAcademicSettings)
        academicSettingsList =
            (json['academicSettings'] as List<dynamic>)
                .map((settings) => AcademicSettingsModel.fromJson(settings))
                .toList();
      } else if (json['academicSettings'] is Map<String, dynamic>) {
        // Handle single object response (create, update, setActive)
        academicSettingsSingle = AcademicSettingsModel.fromJson(
          json['academicSettings'],
        );
        academicSettingsList = [academicSettingsSingle];
      }
    }

    return AcademicSettingsData(
      academicSettings: academicSettingsList,
      pagination:
          json['pagination'] != null
              ? PaginationInfo.fromJson(json['pagination'])
              : null,
      academicSettingsSingle: academicSettingsSingle,
      statistics:
          json['statistics'] != null
              ? Statistics.fromJson(json['statistics'])
              : null,
      updateResult:
          json['updateResult'] != null
              ? UpdateResult.fromJson(json['updateResult'])
              : null,
    );
  }
}

class Statistics {
  final int totalClasses;
  final int totalStudents;
  final String currentAcademicYear;
  final String currentTerm;

  Statistics({
    required this.totalClasses,
    required this.totalStudents,
    required this.currentAcademicYear,
    required this.currentTerm,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) {
    return Statistics(
      totalClasses: _parseInt(json['totalClasses']) ?? 0,
      totalStudents: _parseInt(json['totalStudents']) ?? 0,
      currentAcademicYear: json['currentAcademicYear'] ?? '',
      currentTerm: json['currentTerm'] ?? '',
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalSettings;
  final int currentPageSettings;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalSettings,
    required this.currentPageSettings,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: _parseInt(json['currentPage']) ?? 1,
      totalPages: _parseInt(json['totalPages']) ?? 1,
      totalSettings: _parseInt(json['totalSettings']) ?? 0,
      currentPageSettings: _parseInt(json['currentPageSettings']) ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    return null;
  }
}
