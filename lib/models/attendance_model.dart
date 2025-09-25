// Models for attendance functionality

class AttendanceRecord {
  final String studentId;
  final String status; // "present", "absent", "late"
  final String remarks;

  AttendanceRecord({
    required this.studentId,
    required this.status,
    required this.remarks,
  });

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    return AttendanceRecord(
      studentId: json['studentId'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'studentId': studentId, 'status': status, 'remarks': remarks};
  }
}

class MarkAttendanceRequest {
  final String date;
  final String term;
  final String academicYear;
  final String markerId;
  final List<AttendanceRecord> records;

  MarkAttendanceRequest({
    required this.date,
    required this.term,
    required this.academicYear,
    required this.markerId,
    required this.records,
  });

  Map<String, dynamic> toJson() {
    return {
      'date': date,
      'term': term,
      'academicYear': academicYear,
      'markerId': markerId,
      'records': records.map((record) => record.toJson()).toList(),
    };
  }
}

class StudentInfo {
  final String id;
  final String admissionNumber;
  final int age;
  final PersonalInfo personalInfo;

  StudentInfo({
    required this.id,
    required this.admissionNumber,
    required this.age,
    required this.personalInfo,
  });

  factory StudentInfo.fromJson(Map<String, dynamic> json) {
    return StudentInfo(
      id: json['_id'] ?? json['id'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      age: json['age'] ?? 0,
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'id': id,
      'admissionNumber': admissionNumber,
      'age': age,
      'personalInfo': personalInfo.toJson(),
    };
  }
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String middleName;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String stateOfOrigin;
  final String localGovernment;
  final String religion;
  final String bloodGroup;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    required this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.stateOfOrigin,
    required this.localGovernment,
    required this.religion,
    required this.bloodGroup,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'] ?? '',
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      nationality: json['nationality'] ?? '',
      stateOfOrigin: json['stateOfOrigin'] ?? '',
      localGovernment: json['localGovernment'] ?? '',
      religion: json['religion'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'stateOfOrigin': stateOfOrigin,
      'localGovernment': localGovernment,
      'religion': religion,
      'bloodGroup': bloodGroup,
    };
  }

  String get fullName =>
      '$firstName ${middleName.isNotEmpty ? '$middleName ' : ''}$lastName';
}

class AttendanceRecordDetail {
  final StudentInfo student;
  final String status;
  final String remarks;
  final String markedBy;
  final String markedAt;

  AttendanceRecordDetail({
    required this.student,
    required this.status,
    required this.remarks,
    required this.markedBy,
    required this.markedAt,
  });

  factory AttendanceRecordDetail.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordDetail(
      student: StudentInfo.fromJson(json['student'] ?? {}),
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
      markedBy: json['markedBy'] ?? '',
      markedAt: json['markedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'status': status,
      'remarks': remarks,
      'markedBy': markedBy,
      'markedAt': markedAt,
    };
  }
}

class AttendanceByDate {
  final String id;
  final String classId;
  final String date;
  final List<AttendanceRecordDetail> records;
  final String term;
  final String academicYear;
  final bool isSubmitted;
  final String? submittedBy;
  final String? submittedAt;
  final bool isLocked;
  final String createdAt;
  final String updatedAt;

  AttendanceByDate({
    required this.id,
    required this.classId,
    required this.date,
    required this.records,
    required this.term,
    required this.academicYear,
    required this.isSubmitted,
    this.submittedBy,
    this.submittedAt,
    required this.isLocked,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AttendanceByDate.fromJson(Map<String, dynamic> json) {
    try {
      // Handle submittedBy - it can be either a String or an object
      String? submittedByString;
      if (json['submittedBy'] != null) {
        if (json['submittedBy'] is String) {
          submittedByString = json['submittedBy'];
        } else if (json['submittedBy'] is Map<String, dynamic>) {
          final submittedByObj = json['submittedBy'] as Map<String, dynamic>;
          submittedByString =
              submittedByObj['firstName'] ?? submittedByObj['_id'] ?? '';
        }
      }

      // Handle submittedAt - it can be either a String or a DateTime
      String? submittedAtString;
      if (json['submittedAt'] != null) {
        if (json['submittedAt'] is String) {
          submittedAtString = json['submittedAt'];
        } else if (json['submittedAt'] is DateTime) {
          submittedAtString = json['submittedAt'].toIso8601String();
        }
      }

      final records =
          (json['records'] as List<dynamic>?)
              ?.map((record) => AttendanceRecordDetail.fromJson(record))
              .toList() ??
          [];

      return AttendanceByDate(
        id: json['_id'] ?? '',
        classId: json['class'] ?? '',
        date: json['date'] ?? '',
        records: records,
        term: json['term'] ?? '',
        academicYear: json['academicYear'] ?? '',
        isSubmitted: json['isSubmitted'] ?? false,
        submittedBy: submittedByString,
        submittedAt: submittedAtString,
        isLocked: json['isLocked'] ?? false,
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
    } catch (e) {
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'class': classId,
      'date': date,
      'records': records.map((record) => record.toJson()).toList(),
      'term': term,
      'academicYear': academicYear,
      'isSubmitted': isSubmitted,
      'submittedBy': submittedBy,
      'submittedAt': submittedAt,
      'isLocked': isLocked,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class AttendanceByDateResponse {
  final bool success;
  final AttendanceByDateData data;

  AttendanceByDateResponse({required this.success, required this.data});

  factory AttendanceByDateResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceByDateResponse(
      success: json['success'] ?? false,
      data: AttendanceByDateData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class AttendanceByDateData {
  final AttendanceByDate attendance;

  AttendanceByDateData({required this.attendance});

  factory AttendanceByDateData.fromJson(Map<String, dynamic> json) {
    return AttendanceByDateData(
      attendance: AttendanceByDate.fromJson(json['attendance'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'attendance': attendance.toJson()};
  }
}

// Summary Models
class StudentSummary {
  final String id;
  final String name;
  final String admissionNumber;

  StudentSummary({
    required this.id,
    required this.name,
    required this.admissionNumber,
  });

  factory StudentSummary.fromJson(Map<String, dynamic> json) {
    return StudentSummary(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'admissionNumber': admissionNumber};
  }
}

class AttendanceRecordSummary {
  final String date;
  final String status;
  final String remarks;

  AttendanceRecordSummary({
    required this.date,
    required this.status,
    required this.remarks,
  });

  factory AttendanceRecordSummary.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordSummary(
      date: json['date'] ?? '',
      status: json['status'] ?? '',
      remarks: json['remarks'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'date': date, 'status': status, 'remarks': remarks};
  }
}

class StudentAttendanceSummary {
  final StudentSummary student;
  final int totalDays;
  final int presentCount;
  final int absentCount;
  final int attendanceRate;
  final List<AttendanceRecordSummary> records;

  StudentAttendanceSummary({
    required this.student,
    required this.totalDays,
    required this.presentCount,
    required this.absentCount,
    required this.attendanceRate,
    required this.records,
  });

  factory StudentAttendanceSummary.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceSummary(
      student: StudentSummary.fromJson(json['student'] ?? {}),
      totalDays: json['totalDays'] ?? 0,
      presentCount: json['presentCount'] ?? 0,
      absentCount: json['absentCount'] ?? 0,
      attendanceRate: json['attendanceRate'] ?? 0,
      records:
          (json['records'] as List<dynamic>?)
              ?.map((record) => AttendanceRecordSummary.fromJson(record))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'student': student.toJson(),
      'totalDays': totalDays,
      'presentCount': presentCount,
      'absentCount': absentCount,
      'attendanceRate': attendanceRate,
      'records': records.map((record) => record.toJson()).toList(),
    };
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String level;

  ClassInfo({required this.id, required this.name, required this.level});

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'name': name, 'level': level};
  }
}

class AttendanceSummaryResponse {
  final bool success;
  final AttendanceSummaryData data;

  AttendanceSummaryResponse({required this.success, required this.data});

  factory AttendanceSummaryResponse.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryResponse(
      success: json['success'] ?? false,
      data: AttendanceSummaryData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class AttendanceSummaryData {
  final ClassInfo classInfo;
  final List<StudentAttendanceSummary> summary;
  final int totalAttendanceDays;

  AttendanceSummaryData({
    required this.classInfo,
    required this.summary,
    required this.totalAttendanceDays,
  });

  factory AttendanceSummaryData.fromJson(Map<String, dynamic> json) {
    return AttendanceSummaryData(
      classInfo: ClassInfo.fromJson(json['class'] ?? {}),
      summary:
          (json['summary'] as List<dynamic>?)
              ?.map((item) => StudentAttendanceSummary.fromJson(item))
              .toList() ??
          [],
      totalAttendanceDays: json['totalAttendanceDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': classInfo.toJson(),
      'summary': summary.map((item) => item.toJson()).toList(),
      'totalAttendanceDays': totalAttendanceDays,
    };
  }
}
