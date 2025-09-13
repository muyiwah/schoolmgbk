// // To parse this JSON data, do
// //
// //     final welcome = welcomeFromJson(jsonString);

// import 'dart:convert';


// class ClassModel {
//   List<Class>? classes;
//   Pagination? pagination;

//   ClassModel({this.classes, this.pagination});

//   factory ClassModel.fromJson(Map<String, dynamic> json) => ClassModel(
//     classes:
//         json["classes"] == null
//             ? []
//             : List<Class>.from(json["classes"]!.map((x) => Class.fromJson(x))),
//     pagination:
//         json["pagination"] == null
//             ? null
//             : Pagination.fromJson(json["pagination"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "classes":
//         classes == null
//             ? []
//             : List<dynamic>.from(classes!.map((x) => x.toJson())),
//     "pagination": pagination?.toJson(),
//   };
// }

// class Class {
//   Classroom? classroom;
//   Schedule? schedule;
//   String? id;
//   String? name;
//   String? level;
//   String? section;
//   String? academicYear;
//   List<SubjectTeacher>? subjectTeachers;
//   List<String>? students;
//   int? capacity;
//   Fees? fees;
//   List<String>? feeStructures;
//   bool? isActive;
//   DateTime? createdAt;
//   DateTime? updatedAt;
//   int? v;
//   String? activeFeeStructure;
//   Teacher? classTeacher;
//   List<dynamic>? classDefault;
//   int? totalFees;
//   int? currentEnrollment;
//   int? availableSlots;
//   bool? hasFeeStructure;
//   dynamic feeStructureDetails;
//   String? classId;
//   EnrollmentStats? enrollmentStats;

//   Class({
//     this.classroom,
//     this.schedule,
//     this.id,
//     this.name,
//     this.level,
//     this.section,
//     this.academicYear,
//     this.subjectTeachers,
//     this.students,
//     this.capacity,
//     this.fees,
//     this.feeStructures,
//     this.isActive,
//     this.createdAt,
//     this.updatedAt,
//     this.v,
//     this.activeFeeStructure,
//     this.classTeacher,
//     this.classDefault,
//     this.totalFees,
//     this.currentEnrollment,
//     this.availableSlots,
//     this.hasFeeStructure,
//     this.feeStructureDetails,
//     this.classId,
//     this.enrollmentStats,
//   });

//   factory Class.fromJson(Map<String, dynamic> json) => Class(
//     classroom:
//         json["classroom"] == null
//             ? null
//             : Classroom.fromJson(json["classroom"]),
//     schedule:
//         json["schedule"] == null ? null : Schedule.fromJson(json["schedule"]),
//     id: json["_id"],
//     name: json["name"],
//     level: json["level"],
//     section: json["section"],
//     academicYear: json["academicYear"],
//     subjectTeachers:
//         json["subjectTeachers"] == null
//             ? []
//             : List<SubjectTeacher>.from(
//               json["subjectTeachers"]!.map((x) => SubjectTeacher.fromJson(x)),
//             ),
//     students:
//         json["students"] == null
//             ? []
//             : List<String>.from(json["students"]!.map((x) => x)),
//     capacity: json["capacity"],
//     fees: json["fees"] == null ? null : Fees.fromJson(json["fees"]),
//     feeStructures:
//         json["feeStructures"] == null
//             ? []
//             : List<String>.from(json["feeStructures"]!.map((x) => x)),
//     isActive: json["isActive"],
//     createdAt:
//         json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
//     updatedAt:
//         json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
//     v: json["__v"],
//     activeFeeStructure: json["activeFeeStructure"],
//     classTeacher:
//         json["classTeacher"] == null
//             ? null
//             : Teacher.fromJson(json["classTeacher"]),
//     classDefault:
//         json["default"] == null
//             ? []
//             : List<dynamic>.from(json["default"]!.map((x) => x)),
//     totalFees: json["totalFees"],
//     currentEnrollment: json["currentEnrollment"],
//     availableSlots: json["availableSlots"],
//     hasFeeStructure: json["hasFeeStructure"],
//     feeStructureDetails: json["feeStructureDetails"],
//     classId: json["id"],
//     enrollmentStats:
//         json["enrollmentStats"] == null
//             ? null
//             : EnrollmentStats.fromJson(json["enrollmentStats"]),
//   );

//   Map<String, dynamic> toJson() => {
//     "classroom": classroom?.toJson(),
//     "schedule": schedule?.toJson(),
//     "_id": id,
//     "name": name,
//     "level": level,
//     "section": section,
//     "academicYear": academicYear,
//     "subjectTeachers":
//         subjectTeachers == null
//             ? []
//             : List<dynamic>.from(subjectTeachers!.map((x) => x.toJson())),
//     "students":
//         students == null ? [] : List<dynamic>.from(students!.map((x) => x)),
//     "capacity": capacity,
//     "fees": fees?.toJson(),
//     "feeStructures":
//         feeStructures == null
//             ? []
//             : List<dynamic>.from(feeStructures!.map((x) => x)),
//     "isActive": isActive,
//     "createdAt": createdAt?.toIso8601String(),
//     "updatedAt": updatedAt?.toIso8601String(),
//     "__v": v,
//     "activeFeeStructure": activeFeeStructure,
//     "classTeacher": classTeacher?.toJson(),
//     "default":
//         classDefault == null
//             ? []
//             : List<dynamic>.from(classDefault!.map((x) => x)),
//     "totalFees": totalFees,
//     "currentEnrollment": currentEnrollment,
//     "availableSlots": availableSlots,
//     "hasFeeStructure": hasFeeStructure,
//     "feeStructureDetails": feeStructureDetails,
//     "id": classId,
//     "enrollmentStats": enrollmentStats?.toJson(),
//   };
// }

// class Teacher {
//   PersonalInfo? personalInfo;
//   String? id;
//   String? staffId;
//   int? yearsOfService;
//   String? teacherId;

//   Teacher({
//     this.personalInfo,
//     this.id,
//     this.staffId,
//     this.yearsOfService,
//     this.teacherId,
//   });

//   factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
//     personalInfo:
//         json["personalInfo"] == null
//             ? null
//             : PersonalInfo.fromJson(json["personalInfo"]),
//     id: json["_id"],
//     staffId: json["staffId"],
//     yearsOfService: json["yearsOfService"],
//     teacherId: json["id"],
//   );

//   Map<String, dynamic> toJson() => {
//     "personalInfo": personalInfo?.toJson(),
//     "_id": id,
//     "staffId": staffId,
//     "yearsOfService": yearsOfService,
//     "id": teacherId,
//   };
// }

// class PersonalInfo {
//   String? firstName;
//   String? lastName;

//   PersonalInfo({this.firstName, this.lastName});

//   factory PersonalInfo.fromJson(Map<String, dynamic> json) =>
//       PersonalInfo(firstName: json["firstName"], lastName: json["lastName"]);

//   Map<String, dynamic> toJson() => {
//     "firstName": firstName,
//     "lastName": lastName,
//   };
// }

// class Classroom {
//   String? building;
//   String? roomNumber;
//   String? floor;

//   Classroom({this.building, this.roomNumber, this.floor});

//   factory Classroom.fromJson(Map<String, dynamic> json) => Classroom(
//     building: json["building"],
//     roomNumber: json["roomNumber"],
//     floor: json["floor"],
//   );

//   Map<String, dynamic> toJson() => {
//     "building": building,
//     "roomNumber": roomNumber,
//     "floor": floor,
//   };
// }

// class EnrollmentStats {
//   int? currentEnrollment;
//   int? availableSlots;
//   String? enrollmentPercentage;

//   EnrollmentStats({
//     this.currentEnrollment,
//     this.availableSlots,
//     this.enrollmentPercentage,
//   });

//   factory EnrollmentStats.fromJson(Map<String, dynamic> json) =>
//       EnrollmentStats(
//         currentEnrollment: json["currentEnrollment"],
//         availableSlots: json["availableSlots"],
//         enrollmentPercentage: json["enrollmentPercentage"],
//       );

//   Map<String, dynamic> toJson() => {
//     "currentEnrollment": currentEnrollment,
//     "availableSlots": availableSlots,
//     "enrollmentPercentage": enrollmentPercentage,
//   };
// }

// class Fees {
//   Fees();

//   factory Fees.fromJson(Map<String, dynamic> json) => Fees();

//   Map<String, dynamic> toJson() => {};
// }

// class Schedule {
//   List<dynamic>? days;

//   Schedule({this.days});

//   factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
//     days:
//         json["days"] == null
//             ? []
//             : List<dynamic>.from(json["days"]!.map((x) => x)),
//   );

//   Map<String, dynamic> toJson() => {
//     "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x)),
//   };
// }

// class SubjectTeacher {
//   Teacher? teacher;
//   String? subject;
//   String? id;
//   String? subjectTeacherId;

//   SubjectTeacher({this.teacher, this.subject, this.id, this.subjectTeacherId});

//   factory SubjectTeacher.fromJson(Map<String, dynamic> json) => SubjectTeacher(
//     teacher: json["teacher"] == null ? null : Teacher.fromJson(json["teacher"]),
//     subject: json["subject"],
//     id: json["_id"],
//     subjectTeacherId: json["id"],
//   );

//   Map<String, dynamic> toJson() => {
//     "teacher": teacher?.toJson(),
//     "subject": subject,
//     "_id": id,
//     "id": subjectTeacherId,
//   };
// }

// class Pagination {
//   int? currentPage;
//   int? totalPages;
//   int? totalClasses;
//   bool? hasNext;
//   bool? hasPrev;

//   Pagination({
//     this.currentPage,
//     this.totalPages,
//     this.totalClasses,
//     this.hasNext,
//     this.hasPrev,
//   });

//   factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
//     currentPage: json["currentPage"],
//     totalPages: json["totalPages"],
//     totalClasses: json["totalClasses"],
//     hasNext: json["hasNext"],
//     hasPrev: json["hasPrev"],
//   );

//   Map<String, dynamic> toJson() => {
//     "currentPage": currentPage,
//     "totalPages": totalPages,
//     "totalClasses": totalClasses,
//     "hasNext": hasNext,
//     "hasPrev": hasPrev,
//   };
// }
