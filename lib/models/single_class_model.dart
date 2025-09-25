// To parse this JSON data, do
//
//     final singleClass = singleClassFromJson(jsonString);

import 'dart:convert';

SingleClass singleClassFromJson(String str) =>
    SingleClass.fromJson(json.decode(str));

String singleClassToJson(SingleClass data) => json.encode(data.toJson());

class SingleClass {
  bool? success;
  Data? data;

  SingleClass({this.success, this.data});

  factory SingleClass.fromJson(Map<String, dynamic> json) => SingleClass(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  Class? dataClass;
  List<Student>? students;
  Metrics? metrics;
  AcademicInfo? academicInfo;
  List<dynamic>? recentCommunications;

  Data({
    this.dataClass,
    this.students,
    this.metrics,
    this.academicInfo,
    this.recentCommunications,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    dataClass: json["class"] == null ? null : Class.fromJson(json["class"]),
    students:
        json["students"] == null
            ? []
            : List<Student>.from(
              (json["students"] as List).map((x) => Student.fromJson(x)),
            ),
    metrics: json["metrics"] == null ? null : Metrics.fromJson(json["metrics"]),
    academicInfo:
        json["academicInfo"] == null
            ? null
            : AcademicInfo.fromJson(json["academicInfo"]),
    recentCommunications:
        json["recentCommunications"] == null
            ? []
            : List<dynamic>.from(
              (json["recentCommunications"] as List).map((x) => x),
            ),
  );

  Map<String, dynamic> toJson() => {
    "class": dataClass?.toJson(),
    "students":
        students == null
            ? []
            : List<dynamic>.from(students!.map((x) => x.toJson())),
    "metrics": metrics?.toJson(),
    "academicInfo": academicInfo?.toJson(),
    "recentCommunications":
        recentCommunications == null
            ? []
            : List<dynamic>.from(recentCommunications!.map((x) => x)),
  };
}

class AcademicInfo {
  String? currentAcademicYear;
  String? currentTerm;
  DateTime? attendanceDate;

  AcademicInfo({
    this.currentAcademicYear,
    this.currentTerm,
    this.attendanceDate,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
    currentAcademicYear: json["currentAcademicYear"],
    currentTerm: json["currentTerm"],
    attendanceDate:
        json["attendanceDate"] == null
            ? null
            : DateTime.parse(json["attendanceDate"]),
  );

  Map<String, dynamic> toJson() => {
    "currentAcademicYear": currentAcademicYear,
    "currentTerm": currentTerm,
    "attendanceDate":
        attendanceDate != null
            ? "${attendanceDate!.year.toString().padLeft(4, '0')}-${attendanceDate!.month.toString().padLeft(2, '0')}-${attendanceDate!.day.toString().padLeft(2, '0')}"
            : null,
  };
}

class Class {
  String? id;
  String? name;
  String? level;
  String? section;
  ClassTeacher? classTeacher;

  Class({this.id, this.name, this.level, this.section, this.classTeacher});

  factory Class.fromJson(Map<String, dynamic> json) => Class(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    section: json["section"],
    classTeacher:
        json["classTeacher"] == null
            ? null
            : ClassTeacher.fromJson(json["classTeacher"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "section": section,
    "classTeacher": classTeacher?.toJson(),
  };
}

class ClassTeacher {
  String? id;
  String? name;
  String? staffId;

  ClassTeacher({this.name, this.staffId, this.id});

  factory ClassTeacher.fromJson(Map<String, dynamic> json) =>
      ClassTeacher(name: json["name"], staffId: json["staffId"],id: json["id"]);

  Map<String, dynamic> toJson() => {"name": name, "staffId": staffId, "id": id};
}

class Metrics {
  int? totalStudents;
  int? maleStudents;
  int? femaleStudents;
  GenderRatio? genderRatio;
  FeeStatus? feeStatus;
  String? feeCollectionRate;
  TodayAttendance? todayAttendance;
  String? enrollmentRate;
  int? availableSlots;
  CurrentFeeStructure? currentFeeStructure;

  Metrics({
    this.totalStudents,
    this.maleStudents,
    this.femaleStudents,
    this.genderRatio,
    this.feeStatus,
    this.feeCollectionRate,
    this.todayAttendance,
    this.enrollmentRate,
    this.availableSlots,
    this.currentFeeStructure,
  });

  factory Metrics.fromJson(Map<String, dynamic> json) => Metrics(
    totalStudents: json["totalStudents"],
    maleStudents: json["maleStudents"],
    femaleStudents: json["femaleStudents"],
    genderRatio:
        json["genderRatio"] == null
            ? null
            : GenderRatio.fromJson(json["genderRatio"]),
    feeStatus:
        json["feeStatus"] == null
            ? null
            : FeeStatus.fromJson(json["feeStatus"]),
    feeCollectionRate: json["feeCollectionRate"],
    todayAttendance:
        json["todayAttendance"] == null
            ? null
            : TodayAttendance.fromJson(json["todayAttendance"]),
    enrollmentRate: json["enrollmentRate"],
    availableSlots: json["availableSlots"],
    currentFeeStructure:
        json["currentFeeStructure"] == null
            ? null
            : CurrentFeeStructure.fromJson(json["currentFeeStructure"]),
  );

  Map<String, dynamic> toJson() => {
    "totalStudents": totalStudents,
    "maleStudents": maleStudents,
    "femaleStudents": femaleStudents,
    "genderRatio": genderRatio?.toJson(),
    "feeStatus": feeStatus?.toJson(),
    "feeCollectionRate": feeCollectionRate,
    "todayAttendance": todayAttendance?.toJson(),
    "enrollmentRate": enrollmentRate,
    "availableSlots": availableSlots,
    "currentFeeStructure": currentFeeStructure?.toJson(),
  };
}

class CurrentFeeStructure {
  int? baseFee;
  int? totalFee;
  String? term;
  String? academicYear;

  CurrentFeeStructure({
    this.baseFee,
    this.totalFee,
    this.term,
    this.academicYear,
  });

  factory CurrentFeeStructure.fromJson(Map<String, dynamic> json) =>
      CurrentFeeStructure(
        baseFee: json["baseFee"],
        totalFee: json["totalFee"],
        term: json["term"],
        academicYear: json["academicYear"],
      );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "totalFee": totalFee,
    "term": term,
    "academicYear": academicYear,
  };
}

class FeeStatus {
  int? paid;
  int? partial;
  int? unpaid;

  FeeStatus({this.paid, this.partial, this.unpaid});

  factory FeeStatus.fromJson(Map<String, dynamic> json) => FeeStatus(
    paid: json["paid"],
    partial: json["partial"],
    unpaid: json["unpaid"],
  );

  Map<String, dynamic> toJson() => {
    "paid": paid,
    "partial": partial,
    "unpaid": unpaid,
  };
}

class GenderRatio {
  String? male;
  String? female;

  GenderRatio({this.male, this.female});

  factory GenderRatio.fromJson(Map<String, dynamic> json) =>
      GenderRatio(male: json["male"], female: json["female"]);

  Map<String, dynamic> toJson() => {"male": male, "female": female};
}

class TodayAttendance {
  int? present;
  int? absent;
  int? late;
  int? notMarked;
  int? attendancePercentage;

  TodayAttendance({
    this.present,
    this.absent,
    this.late,
    this.notMarked,
    this.attendancePercentage,
  });

  factory TodayAttendance.fromJson(Map<String, dynamic> json) =>
      TodayAttendance(
        present: json["present"],
        absent: json["absent"],
        late: json["late"],
        notMarked: json["notMarked"],
        attendancePercentage: json["attendancePercentage"],
      );

  Map<String, dynamic> toJson() => {
    "present": present,
    "absent": absent,
    "late": late,
    "notMarked": notMarked,
    "attendancePercentage": attendancePercentage,
  };
}

class Student {
  String? id;
  String? name;
  String? admissionNumber;
  String? parentName;
  String? feeStatus;
  String? todayAttendance;

  Student({
    this.id,
    this.name,
    this.admissionNumber,
    this.parentName,
    this.feeStatus,
    this.todayAttendance,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json["_id"],
    name: json["name"],
    admissionNumber: json["admissionNumber"],
    parentName: json["parentName"],
    feeStatus: json["feeStatus"],
    todayAttendance: json["todayAttendance"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "admissionNumber": admissionNumber,
    "parentName": parentName,
    "feeStatus": feeStatus,
    "todayAttendance": todayAttendance,
  };
}
