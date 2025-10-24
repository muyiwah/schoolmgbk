class ClassPaymentDataResponse {
  final ClassInfo classInfo;
  final List<StudentPaymentInfo> students;
  final PaymentMetrics metrics;
  final AcademicInfo academicInfo;
  final List<dynamic> recentCommunications;

  ClassPaymentDataResponse({
    required this.classInfo,
    required this.students,
    required this.metrics,
    required this.academicInfo,
    required this.recentCommunications,
  });

  factory ClassPaymentDataResponse.fromJson(Map<String, dynamic> json) {
    return ClassPaymentDataResponse(
      classInfo: ClassInfo.fromJson(json['class'] ?? {}),
      students:
          (json['students'] as List<dynamic>?)
              ?.map((item) => StudentPaymentInfo.fromJson(item))
              .toList() ??
          [],
      metrics: PaymentMetrics.fromJson(json['metrics'] ?? {}),
      academicInfo: AcademicInfo.fromJson(json['academicInfo'] ?? {}),
      recentCommunications: json['recentCommunications'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': classInfo.toJson(),
      'students': students.map((item) => item.toJson()).toList(),
      'metrics': metrics.toJson(),
      'academicInfo': academicInfo.toJson(),
      'recentCommunications': recentCommunications,
    };
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String level;
  final String? section;
  final String? classTeacher;

  ClassInfo({
    required this.id,
    required this.name,
    required this.level,
    this.section,
    this.classTeacher,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      section: json['section'],
      classTeacher: json['classTeacher'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'section': section,
      'classTeacher': classTeacher,
    };
  }
}

class StudentPaymentInfo {
  final String id;
  final String name;
  final String admissionNumber;
  final String parentName;
  final String feeStatus;
  final String todayAttendance;

  StudentPaymentInfo({
    required this.id,
    required this.name,
    required this.admissionNumber,
    required this.parentName,
    required this.feeStatus,
    required this.todayAttendance,
  });

  factory StudentPaymentInfo.fromJson(Map<String, dynamic> json) {
    return StudentPaymentInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      parentName: json['parentName'] ?? '',
      feeStatus: json['feeStatus'] ?? '',
      todayAttendance: json['todayAttendance'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'admissionNumber': admissionNumber,
      'parentName': parentName,
      'feeStatus': feeStatus,
      'todayAttendance': todayAttendance,
    };
  }
}

class PaymentMetrics {
  final int totalStudents;
  final int maleStudents;
  final int femaleStudents;
  final GenderRatio genderRatio;
  final FeeStatus feeStatus;
  final double feeCollectionRate;
  final TodayAttendance todayAttendance;
  final double enrollmentRate;
  final int availableSlots;
  final CurrentFeeStructure currentFeeStructure;

  PaymentMetrics({
    required this.totalStudents,
    required this.maleStudents,
    required this.femaleStudents,
    required this.genderRatio,
    required this.feeStatus,
    required this.feeCollectionRate,
    required this.todayAttendance,
    required this.enrollmentRate,
    required this.availableSlots,
    required this.currentFeeStructure,
  });

  factory PaymentMetrics.fromJson(Map<String, dynamic> json) {
    return PaymentMetrics(
      totalStudents: json['totalStudents'] ?? 0,
      maleStudents: json['maleStudents'] ?? 0,
      femaleStudents: json['femaleStudents'] ?? 0,
      genderRatio: GenderRatio.fromJson(json['genderRatio'] ?? {}),
      feeStatus: FeeStatus.fromJson(json['feeStatus'] ?? {}),
      feeCollectionRate: (json['feeCollectionRate'] ?? 0).toDouble(),
      todayAttendance: TodayAttendance.fromJson(json['todayAttendance'] ?? {}),
      enrollmentRate: (json['enrollmentRate'] ?? 0).toDouble(),
      availableSlots: json['availableSlots'] ?? 0,
      currentFeeStructure: CurrentFeeStructure.fromJson(
        json['currentFeeStructure'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'maleStudents': maleStudents,
      'femaleStudents': femaleStudents,
      'genderRatio': genderRatio.toJson(),
      'feeStatus': feeStatus.toJson(),
      'feeCollectionRate': feeCollectionRate,
      'todayAttendance': todayAttendance.toJson(),
      'enrollmentRate': enrollmentRate,
      'availableSlots': availableSlots,
      'currentFeeStructure': currentFeeStructure.toJson(),
    };
  }
}

class GenderRatio {
  final double male;
  final double female;

  GenderRatio({required this.male, required this.female});

  factory GenderRatio.fromJson(Map<String, dynamic> json) {
    return GenderRatio(
      male: (json['male'] ?? 0).toDouble(),
      female: (json['female'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'male': male, 'female': female};
  }
}

class FeeStatus {
  final int paid;
  final int partial;
  final int unpaid;

  FeeStatus({required this.paid, required this.partial, required this.unpaid});

  factory FeeStatus.fromJson(Map<String, dynamic> json) {
    return FeeStatus(
      paid: json['paid'] ?? 0,
      partial: json['partial'] ?? 0,
      unpaid: json['unpaid'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'paid': paid, 'partial': partial, 'unpaid': unpaid};
  }
}

class TodayAttendance {
  final int present;
  final int absent;
  final int late;
  final int notMarked;
  final double attendancePercentage;

  TodayAttendance({
    required this.present,
    required this.absent,
    required this.late,
    required this.notMarked,
    required this.attendancePercentage,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) {
    return TodayAttendance(
      present: json['present'] ?? 0,
      absent: json['absent'] ?? 0,
      late: json['late'] ?? 0,
      notMarked: json['notMarked'] ?? 0,
      attendancePercentage: (json['attendancePercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'present': present,
      'absent': absent,
      'late': late,
      'notMarked': notMarked,
      'attendancePercentage': attendancePercentage,
    };
  }
}

class CurrentFeeStructure {
  final double baseFee;
  final double totalFee;
  final String term;
  final String academicYear;

  CurrentFeeStructure({
    required this.baseFee,
    required this.totalFee,
    required this.term,
    required this.academicYear,
  });

  factory CurrentFeeStructure.fromJson(Map<String, dynamic> json) {
    return CurrentFeeStructure(
      baseFee: (json['baseFee'] ?? 0).toDouble(),
      totalFee: (json['totalFee'] ?? 0).toDouble(),
      term: json['term'] ?? '',
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee,
      'totalFee': totalFee,
      'term': term,
      'academicYear': academicYear,
    };
  }
}

class AcademicInfo {
  final String currentAcademicYear;
  final String currentTerm;
  final String attendanceDate;

  AcademicInfo({
    required this.currentAcademicYear,
    required this.currentTerm,
    required this.attendanceDate,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) {
    return AcademicInfo(
      currentAcademicYear: json['currentAcademicYear'] ?? '',
      currentTerm: json['currentTerm'] ?? '',
      attendanceDate: json['attendanceDate'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentAcademicYear': currentAcademicYear,
      'currentTerm': currentTerm,
      'attendanceDate': attendanceDate,
    };
  }
}
