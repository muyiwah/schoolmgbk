class StudentsWithFeesModel {
  final List<StudentWithFee> students;
  final PaginationInfo pagination;
  final FeeMetrics metrics;

  StudentsWithFeesModel({
    required this.students,
    required this.pagination,
    required this.metrics,
  });

  factory StudentsWithFeesModel.fromJson(Map<String, dynamic> json) {
    return StudentsWithFeesModel(
      students:
          (json['students'] as List)
              .map((student) => StudentWithFee.fromJson(student))
              .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
      metrics: FeeMetrics.fromJson(json['metrics']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'students': students.map((student) => student.toJson()).toList(),
      'pagination': pagination.toJson(),
      'metrics': metrics.toJson(),
    };
  }
}

class StudentWithFee {
  final String id;
  final String admissionNumber;
  final String fullName;
  final String gender;
  final String className;
  final String classLevel;
  final String classSection;
  final String currentTerm;
  final String currentAcademicYear;
  final String? fatherName;
  final String? motherName;
  final String? guardianName;
  final String feeStatus;
  final int totalFees;
  final int paidAmount;
  final int outstandingBalance;
  final ParentNames parentNames;
  final List<dynamic> feeBreakdown;

  StudentWithFee({
    required this.id,
    required this.admissionNumber,
    required this.fullName,
    required this.gender,
    required this.className,
    required this.classLevel,
    required this.classSection,
    required this.currentTerm,
    required this.currentAcademicYear,
    this.fatherName,
    this.motherName,
    this.guardianName,
    required this.feeStatus,
    required this.totalFees,
    required this.paidAmount,
    required this.outstandingBalance,
    required this.parentNames,
    required this.feeBreakdown,
  });

  factory StudentWithFee.fromJson(Map<String, dynamic> json) {
    return StudentWithFee(
      id: json['_id'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      fullName: json['fullName'] ?? '',
      gender: json['gender'] ?? '',
      className: json['className'] ?? '',
      classLevel: json['classLevel'] ?? '',
      classSection: json['classSection'] ?? '',
      currentTerm: json['currentTerm'] ?? '',
      currentAcademicYear: json['currentAcademicYear'] ?? '',
      fatherName: json['fatherName'],
      motherName: json['motherName'],
      guardianName: json['guardianName'],
      feeStatus: json['feeStatus'] ?? '',
      totalFees: json['totalFees'] ?? 0,
      paidAmount: json['paidAmount'] ?? 0,
      outstandingBalance: json['outstandingBalance'] ?? 0,
      parentNames: ParentNames.fromJson(json['parentNames'] ?? {}),
      feeBreakdown: json['feeBreakdown'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'admissionNumber': admissionNumber,
      'fullName': fullName,
      'gender': gender,
      'className': className,
      'classLevel': classLevel,
      'classSection': classSection,
      'currentTerm': currentTerm,
      'currentAcademicYear': currentAcademicYear,
      'fatherName': fatherName,
      'motherName': motherName,
      'guardianName': guardianName,
      'feeStatus': feeStatus,
      'totalFees': totalFees,
      'paidAmount': paidAmount,
      'outstandingBalance': outstandingBalance,
      'parentNames': parentNames.toJson(),
      'feeBreakdown': feeBreakdown,
    };
  }
}

class ParentNames {
  final String? father;
  final String? mother;
  final String? guardian;

  ParentNames({this.father, this.mother, this.guardian});

  factory ParentNames.fromJson(Map<String, dynamic> json) {
    return ParentNames(
      father: json['father'],
      mother: json['mother'],
      guardian: json['guardian'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'father': father, 'mother': mother, 'guardian': guardian};
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalStudents;
  final int limit;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalStudents,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalStudents: json['totalStudents'] ?? 0,
      limit: json['limit'] ?? 50,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalStudents': totalStudents,
      'limit': limit,
    };
  }
}

class FeeMetrics {
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;
  final int paidStudents;
  final int partialStudents;
  final int unpaidStudents;
  final int totalFeesCollected;
  final int totalFeesOutstanding;
  final int totalClasses;
  final int averagePerClass;
  final int totalFeesExpected;

  FeeMetrics({
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.paidStudents,
    required this.partialStudents,
    required this.unpaidStudents,
    required this.totalFeesCollected,
    required this.totalFeesOutstanding,
    required this.totalClasses,
    required this.averagePerClass,
    required this.totalFeesExpected,
  });

  factory FeeMetrics.fromJson(Map<String, dynamic> json) {
    return FeeMetrics(
      totalStudents: json['totalStudents'] ?? 0,
      maleStudents: json['maleStudents'] ?? 0,
      femaleStudents: json['femaleStudents'] ?? 0,
      paidStudents: json['paidStudents'] ?? 0,
      partialStudents: json['partialStudents'] ?? 0,
      unpaidStudents: json['unpaidStudents'] ?? 0,
      totalFeesCollected: json['totalFeesCollected'] ?? 0,
      totalFeesOutstanding: json['totalFeesOutstanding'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      averagePerClass: json['averagePerClass'] ?? 0,
      totalFeesExpected: json['totalFeesExpected'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'maleStudents': maleStudents,
      'femaleStudents': femaleStudents,
      'paidStudents': paidStudents,
      'partialStudents': partialStudents,
      'unpaidStudents': unpaidStudents,
      'totalFeesCollected': totalFeesCollected,
      'totalFeesOutstanding': totalFeesOutstanding,
      'totalClasses': totalClasses,
      'averagePerClass': averagePerClass,
      'totalFeesExpected': totalFeesExpected,
    };
  }
}
