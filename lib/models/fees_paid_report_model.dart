// To parse this JSON data, do
//
//     final feesPaidReportModel = feesPaidReportModelFromJson(jsonString);

import 'dart:convert';

FeesPaidReportModel feesPaidReportModelFromJson(String str) =>
    FeesPaidReportModel.fromJson(json.decode(str));

String feesPaidReportModelToJson(FeesPaidReportModel data) =>
    json.encode(data.toJson());

class FeesPaidReportModel {
  bool? success;
  FeesPaidReportData? data;

  FeesPaidReportModel({this.success, this.data});

  factory FeesPaidReportModel.fromJson(Map<String, dynamic> json) =>
      FeesPaidReportModel(
        success: json["success"],
        data:
            json["data"] == null
                ? null
                : FeesPaidReportData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class FeesPaidReportData {
  List<StudentFeeRecord>? students;
  List<StudentFeeRecord>? owingStudents;
  FeesStatistics? statistics;
  Pagination? pagination;
  FeesFilters? filters;

  FeesPaidReportData({
    this.students,
    this.owingStudents,
    this.statistics,
    this.pagination,
    this.filters,
  });

  factory FeesPaidReportData.fromJson(
    Map<String, dynamic> json,
  ) => FeesPaidReportData(
    students:
        json["students"] == null
            ? []
            : List<StudentFeeRecord>.from(
              json["students"]!.map((x) => StudentFeeRecord.fromJson(x)),
            ),
    owingStudents:
        json["owingStudents"] == null
            ? []
            : List<StudentFeeRecord>.from(
              json["owingStudents"]!.map((x) => StudentFeeRecord.fromJson(x)),
            ),
    statistics:
        json["statistics"] == null
            ? null
            : FeesStatistics.fromJson(json["statistics"]),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
    filters:
        json["filters"] == null ? null : FeesFilters.fromJson(json["filters"]),
  );

  Map<String, dynamic> toJson() => {
    "students":
        students == null
            ? []
            : List<dynamic>.from(students!.map((x) => x.toJson())),
    "owingStudents":
        owingStudents == null
            ? []
            : List<dynamic>.from(owingStudents!.map((x) => x.toJson())),
    "statistics": statistics?.toJson(),
    "pagination": pagination?.toJson(),
    "filters": filters?.toJson(),
  };
}

class StudentFeeRecord {
  String? id;
  String? admissionNumber;
  String? studentName;
  String? className;
  String? classLevel;
  String? parentName;
  String? parentEmail;
  String? parentPhone;
  int? outstandingBalance;
  int? totalFees;
  int? paidAmount;
  DateTime? lastPaymentDate;
  String? paymentStatus;
  int? paymentRate;
  String? academicYear;
  String? term;

  StudentFeeRecord({
    this.id,
    this.admissionNumber,
    this.studentName,
    this.className,
    this.classLevel,
    this.parentName,
    this.parentEmail,
    this.parentPhone,
    this.outstandingBalance,
    this.totalFees,
    this.paidAmount,
    this.lastPaymentDate,
    this.paymentStatus,
    this.paymentRate,
    this.academicYear,
    this.term,
  });

  factory StudentFeeRecord.fromJson(Map<String, dynamic> json) =>
      StudentFeeRecord(
        id: json["_id"],
        admissionNumber: json["admissionNumber"],
        studentName: json["studentName"],
        className: json["className"],
        classLevel: json["classLevel"],
        parentName: json["parentName"],
        parentEmail: json["parentEmail"],
        parentPhone: json["parentPhone"],
        outstandingBalance: json["outstandingBalance"],
        totalFees: json["totalFees"],
        paidAmount: json["paidAmount"],
        lastPaymentDate:
            json["lastPaymentDate"] == null
                ? null
                : DateTime.parse(json["lastPaymentDate"]),
        paymentStatus: json["paymentStatus"],
        paymentRate: json["paymentRate"],
        academicYear: json["academicYear"],
        term: json["term"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "admissionNumber": admissionNumber,
    "studentName": studentName,
    "className": className,
    "classLevel": classLevel,
    "parentName": parentName,
    "parentEmail": parentEmail,
    "parentPhone": parentPhone,
    "outstandingBalance": outstandingBalance,
    "totalFees": totalFees,
    "paidAmount": paidAmount,
    "lastPaymentDate": lastPaymentDate?.toIso8601String(),
    "paymentStatus": paymentStatus,
    "paymentRate": paymentRate,
    "academicYear": academicYear,
    "term": term,
  };
}

class FeesStatistics {
  AcademicYearStats? currentAcademicYear;
  TermStats? currentTerm;

  FeesStatistics({this.currentAcademicYear, this.currentTerm});

  factory FeesStatistics.fromJson(Map<String, dynamic> json) => FeesStatistics(
    currentAcademicYear:
        json["currentAcademicYear"] == null
            ? null
            : AcademicYearStats.fromJson(json["currentAcademicYear"]),
    currentTerm:
        json["currentTerm"] == null
            ? null
            : TermStats.fromJson(json["currentTerm"]),
  );

  Map<String, dynamic> toJson() => {
    "currentAcademicYear": currentAcademicYear?.toJson(),
    "currentTerm": currentTerm?.toJson(),
  };
}

class AcademicYearStats {
  int? year;
  int? totalStudents;
  int? totalFees;
  int? totalPaid;
  int? totalOutstanding;
  int? paidStudents;
  int? owingStudents;

  AcademicYearStats({
    this.year,
    this.totalStudents,
    this.totalFees,
    this.totalPaid,
    this.totalOutstanding,
    this.paidStudents,
    this.owingStudents,
  });

  factory AcademicYearStats.fromJson(Map<String, dynamic> json) =>
      AcademicYearStats(
        year: json["year"],
        totalStudents: json["totalStudents"],
        totalFees: json["totalFees"],
        totalPaid: json["totalPaid"],
        totalOutstanding: json["totalOutstanding"],
        paidStudents: json["paidStudents"],
        owingStudents: json["owingStudents"],
      );

  Map<String, dynamic> toJson() => {
    "year": year,
    "totalStudents": totalStudents,
    "totalFees": totalFees,
    "totalPaid": totalPaid,
    "totalOutstanding": totalOutstanding,
    "paidStudents": paidStudents,
    "owingStudents": owingStudents,
  };
}

class TermStats {
  String? term;
  int? year;
  int? totalStudents;
  int? totalFees;
  int? totalPaid;
  int? totalOutstanding;
  int? paidStudents;
  int? owingStudents;

  TermStats({
    this.term,
    this.year,
    this.totalStudents,
    this.totalFees,
    this.totalPaid,
    this.totalOutstanding,
    this.paidStudents,
    this.owingStudents,
  });

  factory TermStats.fromJson(Map<String, dynamic> json) => TermStats(
    term: json["term"],
    year: json["year"],
    totalStudents: json["totalStudents"],
    totalFees: json["totalFees"],
    totalPaid: json["totalPaid"],
    totalOutstanding: json["totalOutstanding"],
    paidStudents: json["paidStudents"],
    owingStudents: json["owingStudents"],
  );

  Map<String, dynamic> toJson() => {
    "term": term,
    "year": year,
    "totalStudents": totalStudents,
    "totalFees": totalFees,
    "totalPaid": totalPaid,
    "totalOutstanding": totalOutstanding,
    "paidStudents": paidStudents,
    "owingStudents": owingStudents,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalCount: json["totalCount"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalCount": totalCount,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}

class FeesFilters {
  String? classId;
  String? startDate;
  String? endDate;
  String? paymentStatus;
  String? academicYear;
  String? term;
  String? search;

  FeesFilters({
    this.classId,
    this.startDate,
    this.endDate,
    this.paymentStatus,
    this.academicYear,
    this.term,
    this.search,
  });

  factory FeesFilters.fromJson(Map<String, dynamic> json) => FeesFilters(
    classId: json["classId"],
    startDate: json["startDate"],
    endDate: json["endDate"],
    paymentStatus: json["paymentStatus"],
    academicYear: json["academicYear"],
    term: json["term"],
    search: json["search"],
  );

  Map<String, dynamic> toJson() => {
    "classId": classId,
    "startDate": startDate,
    "endDate": endDate,
    "paymentStatus": paymentStatus,
    "academicYear": academicYear,
    "term": term,
    "search": search,
  };
}
