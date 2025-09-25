class AdmissionModel {
  final String id;
  final StudentInfo studentInfo;
  final ParentInfo parentInfo;
  final AcademicInfo academicInfo;
  final String status;
  final ReviewInfo? reviewInfo;
  final AdmissionInfo? admissionInfo;
  final String? additionalInfo;
  final DateTime submittedAt;
  final String? submittedBy;

  AdmissionModel({
    required this.id,
    required this.studentInfo,
    required this.parentInfo,
    required this.academicInfo,
    required this.status,
    this.reviewInfo,
    this.admissionInfo,
    this.additionalInfo,
    required this.submittedAt,
    this.submittedBy,
  });

  factory AdmissionModel.fromJson(Map<String, dynamic> json) {
    return AdmissionModel(
      id: json['_id'] ?? json['id'] ?? '',
      studentInfo: StudentInfo.fromJson(json['studentInfo'] ?? {}),
      parentInfo: ParentInfo.fromJson(json['parentInfo'] ?? {}),
      academicInfo: AcademicInfo.fromJson(json['academicInfo'] ?? {}),
      status: json['status'] ?? 'pending',
      reviewInfo:
          json['reviewInfo'] != null
              ? ReviewInfo.fromJson(json['reviewInfo'])
              : null,
      admissionInfo:
          json['admissionInfo'] != null
              ? AdmissionInfo.fromJson(json['admissionInfo'])
              : null,
      additionalInfo: json['additionalInfo'],
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      submittedBy: json['submittedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentInfo': studentInfo.toJson(),
      'parentInfo': parentInfo.toJson(),
      'academicInfo': academicInfo.toJson(),
      'status': status,
      'reviewInfo': reviewInfo?.toJson(),
      'admissionInfo': admissionInfo?.toJson(),
      'additionalInfo': additionalInfo,
      'submittedAt': submittedAt.toIso8601String(),
      'submittedBy': submittedBy,
    };
  }

  String get fullName => studentInfo.fullName;
  String get statusDisplay => _getStatusDisplay(status);
  int get age => studentInfo.age;

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'admitted':
        return 'Admitted';
      default:
        return status;
    }
  }
}

class StudentInfo {
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String? picture;
  final String? previousSchool;

  StudentInfo({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.picture,
    this.previousSchool,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(
        json['dateOfBirth'] ?? DateTime.now().toIso8601String(),
      ),
      gender: json['gender'] ?? '',
      picture: json['picture'],
      previousSchool: json['previousSchool'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'picture': picture,
      'previousSchool': previousSchool,
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  int get age {
    final now = DateTime.now();
    int age = now.year - dateOfBirth.year;
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }
    return age;
  }
}

class ParentInfo {
  final String name;
  final String phone;
  final String email;
  final String occupation;
  final String address;

  ParentInfo({
    required this.name,
    required this.phone,
    required this.email,
    required this.occupation,
    required this.address,
  });

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      occupation: json['occupation'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'occupation': occupation,
      'address': address,
    };
  }
}

class AcademicInfo {
  final String desiredClass;
  final String desiredClassId; // Store the actual class ID for functionality
  final String academicYear;

  AcademicInfo({
    required this.desiredClass,
    required this.desiredClassId,
    required this.academicYear,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) {
    String desiredClass = '';
    String desiredClassId = '';

    // Handle both string ID and populated class object
    if (json['desiredClass'] is String) {
      desiredClassId = json['desiredClass'] ?? '';
      desiredClass = desiredClassId; // Use ID as fallback for display
    } else if (json['desiredClass'] is Map<String, dynamic>) {
      // If it's a populated class object, extract both level and ID
      final classData = json['desiredClass'];
      desiredClassId = classData['_id'] ?? classData['id'] ?? '';
      desiredClass = classData['level'] ?? classData['name'] ?? desiredClassId;
    }

    return AcademicInfo(
      desiredClass: desiredClass,
      desiredClassId: desiredClassId,
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desiredClass': desiredClassId, // Use ID for backend
      'desiredClassLevel': desiredClass, // Include level for reference
      'academicYear': academicYear,
    };
  }
}

class ReviewInfo {
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final String? rejectionReason;

  ReviewInfo({
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.rejectionReason,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    String? reviewedBy;

    // Handle both string ID and populated user object
    if (json['reviewedBy'] is String) {
      reviewedBy = json['reviewedBy'];
    } else if (json['reviewedBy'] is Map<String, dynamic>) {
      // If it's a populated user object, extract the ID
      reviewedBy = json['reviewedBy']['_id'] ?? json['reviewedBy']['id'];
    }

    return ReviewInfo(
      reviewedBy: reviewedBy,
      reviewedAt:
          json['reviewedAt'] != null
              ? DateTime.parse(json['reviewedAt'])
              : null,
      reviewNotes: json['reviewNotes'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'rejectionReason': rejectionReason,
    };
  }
}

class AdmissionInfo {
  final String? admittedBy;
  final DateTime? admittedAt;
  final String? admissionNumber;
  final String? studentId;

  AdmissionInfo({
    this.admittedBy,
    this.admittedAt,
    this.admissionNumber,
    this.studentId,
  });

  factory AdmissionInfo.fromJson(Map<String, dynamic> json) {
    String? admittedBy;

    // Handle both string ID and populated user object
    if (json['admittedBy'] is String) {
      admittedBy = json['admittedBy'];
    } else if (json['admittedBy'] is Map<String, dynamic>) {
      // If it's a populated user object, extract the ID
      admittedBy = json['admittedBy']['_id'] ?? json['admittedBy']['id'];
    }

    return AdmissionInfo(
      admittedBy: admittedBy,
      admittedAt:
          json['admittedAt'] != null
              ? DateTime.parse(json['admittedAt'])
              : null,
      admissionNumber: json['admissionNumber'],
      studentId: json['studentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admittedBy': admittedBy,
      'admittedAt': admittedAt?.toIso8601String(),
      'admissionNumber': admissionNumber,
      'studentId': studentId,
    };
  }
}

class AdmissionSubmissionModel {
  final StudentInfo studentInfo;
  final ParentInfo parentInfo;
  final AcademicInfo academicInfo;
  final String? additionalInfo;

  AdmissionSubmissionModel({
    required this.studentInfo,
    required this.parentInfo,
    required this.academicInfo,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'studentInfo': studentInfo.toJson(),
      'parentInfo': parentInfo.toJson(),
      'academicInfo': academicInfo.toJson(),
      'additionalInfo': additionalInfo,
    };
  }
}

class AdmissionListResponse {
  final List<AdmissionModel> admissions;
  final PaginationInfo pagination;

  AdmissionListResponse({required this.admissions, required this.pagination});

  factory AdmissionListResponse.fromJson(Map<String, dynamic> json) {
    return AdmissionListResponse(
      admissions:
          (json['data']['admissions'] as List)
              .map((item) => AdmissionModel.fromJson(item))
              .toList(),
      pagination: PaginationInfo.fromJson(json['data']['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int limit;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
      limit: json['limit'] ?? 10,
    );
  }
}

class AdmissionStatistics {
  final Overview overview;
  final List<StatusBreakdown> statusBreakdown;
  final List<ClassDistribution> classDistribution;
  final List<RecentApplication> recentApplications;

  AdmissionStatistics({
    required this.overview,
    required this.statusBreakdown,
    required this.classDistribution,
    required this.recentApplications,
  });

  factory AdmissionStatistics.fromJson(Map<String, dynamic> json) {
    return AdmissionStatistics(
      overview: Overview.fromJson(json['data']['overview']),
      statusBreakdown:
          (json['data']['statusBreakdown'] as List)
              .map((item) => StatusBreakdown.fromJson(item))
              .toList(),
      classDistribution:
          (json['data']['classDistribution'] as List)
              .map((item) => ClassDistribution.fromJson(item))
              .toList(),
      recentApplications:
          (json['data']['recentApplications'] as List)
              .map((item) => RecentApplication.fromJson(item))
              .toList(),
    );
  }
}

class Overview {
  final int totalApplications;
  final double averageAge;
  final String academicYear;

  Overview({
    required this.totalApplications,
    required this.averageAge,
    required this.academicYear,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      totalApplications: json['totalApplications'] ?? 0,
      averageAge: (json['averageAge'] ?? 0).toDouble(),
      academicYear: json['academicYear'] ?? '',
    );
  }
}

class StatusBreakdown {
  final String status;
  final int count;

  StatusBreakdown({required this.status, required this.count});

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ClassDistribution {
  final String className;
  final String level;
  final int count;

  ClassDistribution({
    required this.className,
    required this.level,
    required this.count,
  });

  factory ClassDistribution.fromJson(Map<String, dynamic> json) {
    return ClassDistribution(
      className: json['_id'] ?? '',
      level: json['level'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RecentApplication {
  final String id;
  final String studentName;
  final String desiredClass;
  final String status;
  final DateTime submittedAt;

  RecentApplication({
    required this.id,
    required this.studentName,
    required this.desiredClass,
    required this.status,
    required this.submittedAt,
  });

  factory RecentApplication.fromJson(Map<String, dynamic> json) {
    return RecentApplication(
      id: json['_id'] ?? '',
      studentName: json['studentName'] ?? '',
      desiredClass: json['desiredClass'] ?? '',
      status: json['status'] ?? '',
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
