class PromotionModel {
  final String id;
  final String academicYear;
  final DateTime promotionDate;
  final List<PromotionItem> promotions;
  final String processedBy;
  final int totalStudents;
  final int promotedCount;
  final int repeatedCount;
  final int graduatedCount;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  PromotionModel({
    required this.id,
    required this.academicYear,
    required this.promotionDate,
    required this.promotions,
    required this.processedBy,
    required this.totalStudents,
    required this.promotedCount,
    required this.repeatedCount,
    required this.graduatedCount,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    return PromotionModel(
      id: json['_id'] ?? json['id'] ?? '',
      academicYear: json['academicYear'] ?? '',
      promotionDate: DateTime.parse(
        json['promotionDate'] ?? DateTime.now().toIso8601String(),
      ),
      promotions:
          (json['promotions'] as List<dynamic>?)
              ?.map((item) => PromotionItem.fromJson(item))
              .toList() ??
          [],
      processedBy: json['processedBy']?['_id'] ?? json['processedBy'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
      promotedCount: json['promotedCount'] ?? 0,
      repeatedCount: json['repeatedCount'] ?? 0,
      graduatedCount: json['graduatedCount'] ?? 0,
      notes: json['notes'],
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
      'academicYear': academicYear,
      'promotionDate': promotionDate.toIso8601String(),
      'promotions': promotions.map((item) => item.toJson()).toList(),
      'processedBy': processedBy,
      'totalStudents': totalStudents,
      'promotedCount': promotedCount,
      'repeatedCount': repeatedCount,
      'graduatedCount': graduatedCount,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}

class PromotionItem {
  final String studentId;
  final String studentName;
  final String admissionNumber;
  final String fromClassId;
  final String fromClassName;
  final String? toClassId;
  final String? toClassName;
  final String status; // 'promoted', 'repeated', 'graduated'
  final String? remarks;

  PromotionItem({
    required this.studentId,
    required this.studentName,
    required this.admissionNumber,
    required this.fromClassId,
    required this.fromClassName,
    this.toClassId,
    this.toClassName,
    required this.status,
    this.remarks,
  });

  factory PromotionItem.fromJson(Map<String, dynamic> json) {
    return PromotionItem(
      studentId: json['student']?['_id'] ?? json['student'] ?? '',
      studentName:
          json['student']?['personalInfo'] != null
              ? '${json['student']['personalInfo']['firstName'] ?? ''} ${json['student']['personalInfo']['lastName'] ?? ''}'
              : '',
      admissionNumber: json['student']?['admissionNumber'] ?? '',
      fromClassId: json['fromClass']?['_id'] ?? json['fromClass'] ?? '',
      fromClassName: json['fromClass']?['name'] ?? '',
      toClassId: json['toClass']?['_id'] ?? json['toClass'],
      toClassName: json['toClass']?['name'],
      status: json['status'] ?? 'promoted',
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': studentId,
      'fromClass': fromClassId,
      'toClass': toClassId,
      'status': status,
      'remarks': remarks,
    };
  }
}

class PromotionEligibleStudent {
  final String id;
  final String name;
  final String admissionNumber;
  final String gender;
  final int age;
  final String parentName;
  final String feeStatus;
  final int outstandingBalance;
  final bool isEligible;

  PromotionEligibleStudent({
    required this.id,
    required this.name,
    required this.admissionNumber,
    required this.gender,
    required this.age,
    required this.parentName,
    required this.feeStatus,
    required this.outstandingBalance,
    required this.isEligible,
  });

  factory PromotionEligibleStudent.fromJson(Map<String, dynamic> json) {
    return PromotionEligibleStudent(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      gender: json['gender'] ?? '',
      age: json['age'] ?? 0,
      parentName: json['parentName'] ?? 'N/A',
      feeStatus: json['feeStatus'] ?? 'unpaid',
      outstandingBalance: json['outstandingBalance'] ?? 0,
      isEligible: json['isEligible'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'admissionNumber': admissionNumber,
      'gender': gender,
      'age': age,
      'parentName': parentName,
      'feeStatus': feeStatus,
      'isEligible': isEligible,
    };
  }
}

class AvailableClass {
  final String id;
  final String name;
  final String level;
  final int capacity;
  final int currentEnrollment;
  final int availableSlots;

  AvailableClass({
    required this.id,
    required this.name,
    required this.level,
    required this.capacity,
    required this.currentEnrollment,
    required this.availableSlots,
  });

  factory AvailableClass.fromJson(Map<String, dynamic> json) {
    return AvailableClass(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      capacity: json['capacity'] ?? 0,
      currentEnrollment:
          json['currentEnrollment'] ?? json['students']?.length ?? 0,
      availableSlots: json['availableSlots'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'capacity': capacity,
      'currentEnrollment': currentEnrollment,
      'availableSlots': availableSlots,
    };
  }
}

class PromotionEligibleResponse {
  final bool success;
  final PromotionEligibleData data;

  PromotionEligibleResponse({required this.success, required this.data});

  factory PromotionEligibleResponse.fromJson(Map<String, dynamic> json) {
    return PromotionEligibleResponse(
      success: json['success'] ?? false,
      data: PromotionEligibleData.fromJson(json['data'] ?? {}),
    );
  }
}

class PromotionEligibleData {
  final CurrentClass currentClass;
  final List<PromotionEligibleStudent> eligibleStudents;
  final List<AvailableClass> availableClasses;
  final PromotionSummary summary;

  PromotionEligibleData({
    required this.currentClass,
    required this.eligibleStudents,
    required this.availableClasses,
    required this.summary,
  });

  factory PromotionEligibleData.fromJson(Map<String, dynamic> json) {
    return PromotionEligibleData(
      currentClass: CurrentClass.fromJson(json['currentClass'] ?? {}),
      eligibleStudents:
          (json['eligibleStudents'] as List<dynamic>?)
              ?.map((item) => PromotionEligibleStudent.fromJson(item))
              .toList() ??
          [],
      availableClasses:
          (json['availableClasses'] as List<dynamic>?)
              ?.map((item) => AvailableClass.fromJson(item))
              .toList() ??
          [],
      summary: PromotionSummary.fromJson(json['summary'] ?? {}),
    );
  }
}

class CurrentClass {
  final String id;
  final String name;
  final String level;

  CurrentClass({required this.id, required this.name, required this.level});

  factory CurrentClass.fromJson(Map<String, dynamic> json) {
    return CurrentClass(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
    );
  }
}

class PromotionSummary {
  final int totalStudents;
  final int eligibleCount;
  final int ineligibleCount;

  PromotionSummary({
    required this.totalStudents,
    required this.eligibleCount,
    required this.ineligibleCount,
  });

  factory PromotionSummary.fromJson(Map<String, dynamic> json) {
    return PromotionSummary(
      totalStudents: json['totalStudents'] ?? 0,
      eligibleCount: json['eligibleCount'] ?? 0,
      ineligibleCount: json['ineligibleCount'] ?? 0,
    );
  }
}

class PromotionHistoryResponse {
  final bool success;
  final PromotionHistoryData data;

  PromotionHistoryResponse({required this.success, required this.data});

  factory PromotionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return PromotionHistoryResponse(
      success: json['success'] ?? false,
      data: PromotionHistoryData.fromJson(json['data'] ?? {}),
    );
  }
}

class PromotionHistoryData {
  final List<PromotionModel> promotions;
  final PaginationInfo pagination;

  PromotionHistoryData({required this.promotions, required this.pagination});

  factory PromotionHistoryData.fromJson(Map<String, dynamic> json) {
    return PromotionHistoryData(
      promotions:
          (json['promotion'] as List<dynamic>?)
              ?.map((item) => PromotionModel.fromJson(item))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalRecords;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalRecords,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalRecords: json['totalRecords'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

class PromotionRequest {
  final String fromClassId;
  final String? toClassId;
  final String academicYear;
  final String? processedBy;
  final List<String>? studentIds;
  final String promotionType;
  final String term;

  PromotionRequest({
    required this.fromClassId,
    this.toClassId,
    required this.academicYear,
    this.processedBy,
    this.studentIds,
    this.promotionType = 'promoted',
    this.term = 'First Term',
  });

  Map<String, dynamic> toJson() {
    return {
      'fromClassId': fromClassId,
      'toClassId': toClassId,
      'academicYear': academicYear,
      'processedBy': processedBy,
      'studentIds': studentIds,
      'promotionType': promotionType,
      'term': term,
    };
  }
}

class IndividualPromotionRequest {
  final String studentId;
  final String? toClassId;
  final String academicYear;
  final String promotionType;
  final String? remarks;

  IndividualPromotionRequest({
    required this.studentId,
    this.toClassId,
    required this.academicYear,
    this.promotionType = 'promoted',
    this.remarks,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'toClassId': toClassId,
      'academicYear': academicYear,
      'promotionType': promotionType,
      'remarks': remarks,
    };
  }
}

