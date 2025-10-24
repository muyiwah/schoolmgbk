// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

class ClassMetricModel {
  List<Class>? classes;
  Pagination? pagination;
  OverallStats? overallStats;

  ClassMetricModel({this.classes, this.pagination, this.overallStats});

  factory ClassMetricModel.fromJson(Map<String, dynamic> json) =>
      ClassMetricModel(
        classes:
            json["classes"] == null
                ? []
                : List<Class>.from(
                  json["classes"]!.map((x) => Class.fromJson(x)),
                ),
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        overallStats:
            json["overallStats"] == null
                ? null
                : OverallStats.fromJson(json["overallStats"]),
      );

  Map<String, dynamic> toJson() => {
    "classes":
        classes == null
            ? []
            : List<dynamic>.from(classes!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "overallStats": overallStats?.toJson(),
  };
}

class Class {
  Classroom? classroom;
  Schedule? schedule;
  String? id;
  String? name;
  String? level;
  String? section;
  String? academicYear;
  List<SubjectTeacher>? subjectTeachers;
  List<dynamic>? students;
  List<String>? subjects;
  int? capacity;
  Fees? fees;
  List<String>? feeStructures;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? activeFeeStructure;
  Teacher? classTeacher;
  List<dynamic>? classDefault;
  int? totalFees;
  int? currentEnrollment;
  int? availableSlots;
  bool? hasFeeStructure;
  dynamic feeStructureDetails;
  String? classId;
  bool? isAssignedClassTeacher;
  int? totalStudents;
  int? maleStudents;
  String? curriculumUrl;
  int? femaleStudents;
  GenderDistribution? genderDistribution;
  Attendance? attendance;
  dynamic averagePerformance;
  bool? performanceDataAvailable;
  EnrollmentStats? enrollmentStats;
  Summary? summary;

  Class({
    this.classroom,
    this.schedule,
    this.id,
    this.name,
    this.level,
    this.section,
    this.academicYear,
    this.subjectTeachers,
    this.students,
    this.subjects,
    this.capacity,
    this.fees,
    this.feeStructures,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.activeFeeStructure,
    this.classTeacher,
    this.classDefault,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.hasFeeStructure,
    this.feeStructureDetails,
    this.classId,
    this.isAssignedClassTeacher,
    this.totalStudents,
    this.maleStudents,
    this.curriculumUrl,
    this.femaleStudents,
    this.genderDistribution,
    this.attendance,
    this.averagePerformance,
    this.performanceDataAvailable,
    this.enrollmentStats,
    this.summary,
  });

  factory Class.fromJson(Map<String, dynamic> json) => Class(
    classroom:
        json["classroom"] == null
            ? null
            : Classroom.fromJson(json["classroom"]),
    schedule:
        json["schedule"] == null ? null : Schedule.fromJson(json["schedule"]),
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    section: json["section"],
    academicYear: json["academicYear"],
    subjectTeachers:
        json["subjectTeachers"] == null
            ? []
            : List<SubjectTeacher>.from(
              json["subjectTeachers"]!.map((x) => SubjectTeacher.fromJson(x)),
            ),
    students: json["students"] ?? [],
    subjects:
        json["subjects"] == null
            ? []
            : List<String>.from(
              json["subjects"]!.map(
                (x) =>
                    x is String
                        ? x
                        : (x is Map<String, dynamic>
                            ? x['id'] ?? x['_id'] ?? x.toString()
                            : x.toString()),
              ),
            ),
    capacity: json["capacity"],
    fees: json["fees"] == null ? null : Fees.fromJson(json["fees"]),
    feeStructures:
        json["feeStructures"] == null
            ? []
            : List<String>.from(
              json["feeStructures"]!.map(
                (x) =>
                    x is String
                        ? x
                        : (x is Map<String, dynamic>
                            ? x['id'] ?? x['_id'] ?? x.toString()
                            : x.toString()),
              ),
            ),
    isActive: json["isActive"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    activeFeeStructure: json["activeFeeStructure"],
    classTeacher:
        json["classTeacher"] == null
            ? null
            : Teacher.fromJson(json["classTeacher"]),
    classDefault:
        json["default"] == null
            ? []
            : List<dynamic>.from(json["default"]!.map((x) => x)),
    totalFees: json["totalFees"],
    currentEnrollment: json["currentEnrollment"],
    availableSlots: json["availableSlots"],
    hasFeeStructure: json["hasFeeStructure"],
    feeStructureDetails: json["feeStructureDetails"],
    classId: json["id"],
    isAssignedClassTeacher: json["isAssignedClassTeacher"],
    totalStudents: json["totalStudents"],
    maleStudents: json["maleStudents"],
    curriculumUrl: json["curriculumUrl"],
    femaleStudents: json["femaleStudents"],
    genderDistribution:
        json["genderDistribution"] == null
            ? null
            : GenderDistribution.fromJson(json["genderDistribution"]),
    attendance:
        json["attendance"] == null
            ? null
            : Attendance.fromJson(json["attendance"]),
    averagePerformance: json["averagePerformance"],
    performanceDataAvailable: json["performanceDataAvailable"],
    enrollmentStats:
        json["enrollmentStats"] == null
            ? null
            : EnrollmentStats.fromJson(json["enrollmentStats"]),
    summary: json["summary"] == null ? null : Summary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "classroom": classroom?.toJson(),
    "schedule": schedule?.toJson(),
    "_id": id,
    "name": name,
    "level": level,
    "section": section,
    "academicYear": academicYear,
    "subjectTeachers":
        subjectTeachers == null
            ? []
            : List<dynamic>.from(subjectTeachers!.map((x) => x.toJson())),
    // "students":
    //     students == null
    //         ? []
    //         : List<dynamic>.from(students!.map((x) => x.toJson())),
    "subjects":
        subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x)),
    "capacity": capacity,
    "fees": fees?.toJson(),
    "feeStructures":
        feeStructures == null
            ? []
            : List<dynamic>.from(feeStructures!.map((x) => x)),
    "isActive": isActive,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "activeFeeStructure": activeFeeStructure,
    "classTeacher": classTeacher?.toJson(),
    "default":
        classDefault == null
            ? []
            : List<dynamic>.from(classDefault!.map((x) => x)),
    "totalFees": totalFees,
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "hasFeeStructure": hasFeeStructure,
    "feeStructureDetails": feeStructureDetails,
    "id": classId,
    "isAssignedClassTeacher": isAssignedClassTeacher,
    "totalStudents": totalStudents,
    "maleStudents": maleStudents,
    "curriculumUrl": curriculumUrl,
    "femaleStudents": femaleStudents,
    "genderDistribution": genderDistribution?.toJson(),
    "attendance": attendance?.toJson(),
    "averagePerformance": averagePerformance,
    "performanceDataAvailable": performanceDataAvailable,
    "enrollmentStats": enrollmentStats?.toJson(),
    "summary": summary?.toJson(),
  };
}

class Attendance {
  int? present;
  int? absent;
  int? late;
  int? total;
  int? attendanceRate;

  Attendance({
    this.present,
    this.absent,
    this.late,
    this.total,
    this.attendanceRate,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) => Attendance(
    present: json["present"],
    absent: json["absent"],
    late: json["late"],
    total: json["total"],
    attendanceRate: json["attendanceRate"],
  );

  Map<String, dynamic> toJson() => {
    "present": present,
    "absent": absent,
    "late": late,
    "total": total,
    "attendanceRate": attendanceRate,
  };
}

class Teacher {
  ClassTeacherPersonalInfo? personalInfo;
  String? id;
  User? user;
  String? staffId;
  int? yearsOfService;
  String? teacherId;
  String? role;
  String? displayRole;

  Teacher({
    this.personalInfo,
    this.id,
    this.user,
    this.staffId,
    this.yearsOfService,
    this.teacherId,
    this.role,
    this.displayRole,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : ClassTeacherPersonalInfo.fromJson(json["personalInfo"]),
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    staffId: json["staffId"],
    yearsOfService: json["yearsOfService"],
    teacherId: json["id"],
    role: json["role"],
    displayRole: json["displayRole"],
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "_id": id,
    "user": user?.toJson(),
    "staffId": staffId,
    "yearsOfService": yearsOfService,
    "id": teacherId,
    "role": role,
    "displayRole": displayRole,
  };
}

class ClassTeacherPersonalInfo {
  String? firstName;
  String? lastName;

  ClassTeacherPersonalInfo({this.firstName, this.lastName});

  factory ClassTeacherPersonalInfo.fromJson(Map<String, dynamic> json) =>
      ClassTeacherPersonalInfo(
        firstName: json["firstName"],
        lastName: json["lastName"],
      );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
  };
}

class User {
  String? id;
  String? email;
  String? role;
  String? firstName;
  String? lastName;

  User({this.id, this.email, this.role, this.firstName, this.lastName});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    email: json["email"],
    role: json["role"],
    firstName: json["firstName"],
    lastName: json["lastName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
  };
}

class Classroom {
  String? building;
  String? roomNumber;
  String? floor;

  Classroom({this.building, this.roomNumber, this.floor});

  factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
    building: json["building"],
    roomNumber: json["roomNumber"],
    floor: json["floor"],
  );

  Map<String, dynamic> toJson() => {
    "building": building,
    "roomNumber": roomNumber,
    "floor": floor,
  };
}

class EnrollmentStats {
  int? currentEnrollment;
  int? availableSlots;
  String? enrollmentPercentage;
  int? capacity;

  EnrollmentStats({
    this.currentEnrollment,
    this.availableSlots,
    this.enrollmentPercentage,
    this.capacity,
  });

  factory EnrollmentStats.fromJson(Map<String, dynamic> json) =>
      EnrollmentStats(
        currentEnrollment: json["currentEnrollment"],
        availableSlots: json["availableSlots"],
        enrollmentPercentage: json["enrollmentPercentage"],
        capacity: json["capacity"],
      );

  Map<String, dynamic> toJson() => {
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "enrollmentPercentage": enrollmentPercentage,
    "capacity": capacity,
  };
}

class Fees {
  Fees();

  factory Fees.fromJson(Map<String, dynamic> json) => Fees();

  Map<String, dynamic> toJson() => {};
}

class GenderDistribution {
  int? male;
  int? female;
  Ratio? ratio;

  GenderDistribution({this.male, this.female, this.ratio});

  factory GenderDistribution.fromJson(Map<String, dynamic> json) =>
      GenderDistribution(
        male: json["male"],
        female: json["female"],
        ratio: json["ratio"] == null ? null : Ratio.fromJson(json["ratio"]),
      );

  Map<String, dynamic> toJson() => {
    "male": male,
    "female": female,
    "ratio": ratio?.toJson(),
  };
}

class Ratio {
  String? male;
  String? female;

  Ratio({this.male, this.female});

  factory Ratio.fromJson(Map<String, dynamic> json) =>
      Ratio(male: json["male"], female: json["female"]);

  Map<String, dynamic> toJson() => {"male": male, "female": female};
}

class Schedule {
  List<dynamic>? days;

  Schedule({this.days});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    days:
        json["days"] == null
            ? []
            : List<dynamic>.from(json["days"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x)),
  };
}

class Student {
  StudentPersonalInfo? personalInfo;
  String? id;
  String? admissionNumber;
  dynamic age;
  String? studentId;

  Student({
    this.personalInfo,
    this.id,
    this.admissionNumber,
    this.age,
    this.studentId,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : StudentPersonalInfo.fromJson(json["personalInfo"]),
    id: json["_id"],
    admissionNumber: json["admissionNumber"],
    age: json["age"],
    studentId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "_id": id,
    "admissionNumber": admissionNumber,
    "age": age,
    "id": studentId,
  };
}

class StudentPersonalInfo {
  String? firstName;
  String? lastName;
  String? gender;

  StudentPersonalInfo({this.firstName, this.lastName, this.gender});

  factory StudentPersonalInfo.fromJson(Map<String, dynamic> json) =>
      StudentPersonalInfo(
        firstName: json["firstName"],
        lastName: json["lastName"],
        gender: json["gender"],
      );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "gender": gender,
  };
}

class SubjectTeacher {
  Teacher? teacher;
  String? subject;
  String? id;
  String? subjectTeacherId;

  SubjectTeacher({this.teacher, this.subject, this.id, this.subjectTeacherId});

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) => SubjectTeacher(
    teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
    subject: json["subject"],
    id: json["_id"],
    subjectTeacherId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "teacher": teacher?.toJson(),
    "subject": subject,
    "_id": id,
    "id": subjectTeacherId,
  };
}

class Summary {
  int? totalTeachers;
  int? totalSubjects;
  bool? hasAttendanceData;
  bool? hasPerformanceData;

  Summary({
    this.totalTeachers,
    this.totalSubjects,
    this.hasAttendanceData,
    this.hasPerformanceData,
  });

  factory Summary.fromJson(Map<String, dynamic> json) => Summary(
    totalTeachers: json["totalTeachers"],
    totalSubjects: json["totalSubjects"],
    hasAttendanceData: json["hasAttendanceData"],
    hasPerformanceData: json["hasPerformanceData"],
  );

  Map<String, dynamic> toJson() => {
    "totalTeachers": totalTeachers,
    "totalSubjects": totalSubjects,
    "hasAttendanceData": hasAttendanceData,
    "hasPerformanceData": hasPerformanceData,
  };
}

class OverallStats {
  int? totalStudents;
  int? totalMaleStudents;
  int? totalFemaleStudents;
  int? classesWithClassTeacher;
  int? averageAttendance;

  OverallStats({
    this.totalStudents,
    this.totalMaleStudents,
    this.totalFemaleStudents,
    this.classesWithClassTeacher,
    this.averageAttendance,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) => OverallStats(
    totalStudents: json["totalStudents"],
    totalMaleStudents: json["totalMaleStudents"],
    totalFemaleStudents: json["totalFemaleStudents"],
    classesWithClassTeacher: json["classesWithClassTeacher"],
    averageAttendance: json["averageAttendance"],
  );

  Map<String, dynamic> toJson() => {
    "totalStudents": totalStudents,
    "totalMaleStudents": totalMaleStudents,
    "totalFemaleStudents": totalFemaleStudents,
    "classesWithClassTeacher": classesWithClassTeacher,
    "averageAttendance": averageAttendance,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalClasses;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalClasses,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalClasses: json["totalClasses"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalClasses": totalClasses,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}
