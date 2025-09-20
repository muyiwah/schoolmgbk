// To parse this JSON data, do
//
//     final studentFullModel = studentFullModelFromJson(jsonString);

import 'dart:convert';

StudentFullModel studentFullModelFromJson(String str) =>
    StudentFullModel.fromJson(json.decode(str));

String studentFullModelToJson(StudentFullModel data) =>
    json.encode(data.toJson());

class StudentFullModel {
  bool? success;
  Data? data;

  StudentFullModel({this.success, this.data});

  factory StudentFullModel.fromJson(Map<String, dynamic> json) =>
      StudentFullModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  Student? student;
  List<RecentPayment>? recentPayments;
  List<RecentAssignment>? recentAssignments;

  Data({this.student, this.recentPayments, this.recentAssignments});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    student: json["student"] == null ? null : Student.fromJson(json["student"]),
    recentPayments:
        json["recentPayments"] == null
            ? []
            : List<RecentPayment>.from(
              json["recentPayments"]!.map((x) => RecentPayment.fromJson(x)),
            ),
    recentAssignments:
        json["recentAssignments"] == null
            ? []
            : List<RecentAssignment>.from(
              json["recentAssignments"]!.map(
                (x) => RecentAssignment.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "student": student?.toJson(),
    "recentPayments":
        recentPayments == null
            ? []
            : List<dynamic>.from(recentPayments!.map((x) => x.toJson())),
    "recentAssignments":
        recentAssignments == null
            ? []
            : List<dynamic>.from(recentAssignments!.map((x) => x.toJson())),
  };
}

class RecentAssignment {
  String? id;
  String? title;
  String? description;
  String? subject;
  String? recentAssignmentClass;
  dynamic teacher;
  DateTime? dueDate;
  int? maxMarks;
  String? instructions;
  List<Attachment>? attachments;
  String? term;
  String? academicYear;
  String? status;
  List<Submission>? submissions;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;

  RecentAssignment({
    this.id,
    this.title,
    this.description,
    this.subject,
    this.recentAssignmentClass,
    this.teacher,
    this.dueDate,
    this.maxMarks,
    this.instructions,
    this.attachments,
    this.term,
    this.academicYear,
    this.status,
    this.submissions,
    this.createdAt,
    this.updatedAt,
    this.v,
  });

  factory RecentAssignment.fromJson(
    Map<String, dynamic> json,
  ) => RecentAssignment(
    id: json["_id"],
    title: json["title"],
    description: json["description"],
    subject: json["subject"],
    recentAssignmentClass: json["class"],
    teacher: json["teacher"],
    dueDate: json["dueDate"] == null ? null : DateTime.parse(json["dueDate"]),
    maxMarks: json["maxMarks"],
    instructions: json["instructions"],
    attachments:
        json["attachments"] == null
            ? []
            : List<Attachment>.from(
              json["attachments"]!.map((x) => Attachment.fromJson(x)),
            ),
    term: json["term"],
    academicYear: json["academicYear"],
    status: json["status"],
    submissions:
        json["submissions"] == null
            ? []
            : List<Submission>.from(
              json["submissions"]!.map((x) => Submission.fromJson(x)),
            ),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "title": title,
    "description": description,
    "subject": subject,
    "class": recentAssignmentClass,
    "teacher": teacher,
    "dueDate": dueDate?.toIso8601String(),
    "maxMarks": maxMarks,
    "instructions": instructions,
    "attachments":
        attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "term": term,
    "academicYear": academicYear,
    "status": status,
    "submissions":
        submissions == null
            ? []
            : List<dynamic>.from(submissions!.map((x) => x.toJson())),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
  };
}

class Attachment {
  String? filename;
  String? originalName;
  String? url;
  int? size;
  String? id;

  Attachment({this.filename, this.originalName, this.url, this.size, this.id});

  factory Attachment.fromJson(Map<String, dynamic> json) => Attachment(
    filename: json["filename"],
    originalName: json["originalName"],
    url: json["url"],
    size: json["size"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "filename": filename,
    "originalName": originalName,
    "url": url,
    "size": size,
    "_id": id,
  };
}

class Submission {
  String? student;
  DateTime? submissionDate;
  String? content;
  List<Attachment>? attachments;
  String? status;
  String? id;
  String? feedback;
  String? gradedBy;
  int? marks;

  Submission({
    this.student,
    this.submissionDate,
    this.content,
    this.attachments,
    this.status,
    this.id,
    this.feedback,
    this.gradedBy,
    this.marks,
  });

  factory Submission.fromJson(Map<String, dynamic> json) => Submission(
    student: json["student"],
    submissionDate:
        json["submissionDate"] == null
            ? null
            : DateTime.parse(json["submissionDate"]),
    content: json["content"],
    attachments:
        json["attachments"] == null
            ? []
            : List<Attachment>.from(
              json["attachments"]!.map((x) => Attachment.fromJson(x)),
            ),
    status: json["status"],
    id: json["_id"],
    feedback: json["feedback"],
    gradedBy: json["gradedBy"],
    marks: json["marks"],
  );

  Map<String, dynamic> toJson() => {
    "student": student,
    "submissionDate": submissionDate?.toIso8601String(),
    "content": content,
    "attachments":
        attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x.toJson())),
    "status": status,
    "_id": id,
    "feedback": feedback,
    "gradedBy": gradedBy,
    "marks": marks,
  };
}

class RecentPayment {
  String? id;
  String? student;
  String? feeRecord;
  int? amount;
  String? method;
  String? reference;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? feeStructure;

  RecentPayment({
    this.id,
    this.student,
    this.feeRecord,
    this.amount,
    this.method,
    this.reference,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.feeStructure,
  });

  factory RecentPayment.fromJson(Map<String, dynamic> json) => RecentPayment(
    id: json["_id"],
    student: json["student"],
    feeRecord: json["feeRecord"],
    amount: json["amount"],
    method: json["method"],
    reference: json["reference"],
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    feeStructure: json["feeStructure"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "student": student,
    "feeRecord": feeRecord,
    "amount": amount,
    "method": method,
    "reference": reference,
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "feeStructure": feeStructure,
  };
}

class Student {
  StudentPersonalInfo? personalInfo;
  StudentContactInfo? contactInfo;
  AcademicInfo? academicInfo;
  ParentInfo? parentInfo;
  MedicalInfo? medicalInfo;
  FinancialInfo? financialInfo;
  String? id;
  String? admissionNumber;
  User? user;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? age;
  String? studentId;
  PerformanceData? performanceData;
  AttendanceData? attendanceData;

  Student({
    this.personalInfo,
    this.contactInfo,
    this.academicInfo,
    this.parentInfo,
    this.medicalInfo,
    this.financialInfo,
    this.id,
    this.admissionNumber,
    this.user,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.age,
    this.studentId,
    this.performanceData,
    this.attendanceData,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : StudentPersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : StudentContactInfo.fromJson(json["contactInfo"]),
    academicInfo:
        json["academicInfo"] == null
            ? null
            : AcademicInfo.fromJson(json["academicInfo"]),
    parentInfo:
        json["parentInfo"] == null
            ? null
            : ParentInfo.fromJson(json["parentInfo"]),
    medicalInfo:
        json["medicalInfo"] == null
            ? null
            : MedicalInfo.fromJson(json["medicalInfo"]),
    financialInfo:
        json["financialInfo"] == null
            ? null
            : FinancialInfo.fromJson(json["financialInfo"]),
    id: json["_id"],
    admissionNumber: json["admissionNumber"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    age: json["age"],
    studentId: json["id"],
    performanceData:
        json["performanceData"] == null
            ? null
            : PerformanceData.fromJson(json["performanceData"]),
    attendanceData:
        json["attendanceData"] == null
            ? null
            : AttendanceData.fromJson(json["attendanceData"]),
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "academicInfo": academicInfo?.toJson(),
    "parentInfo": parentInfo?.toJson(),
    "medicalInfo": medicalInfo?.toJson(),
    "financialInfo": financialInfo?.toJson(),
    "_id": id,
    "admissionNumber": admissionNumber,
    "user": user?.toJson(),
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "age": age,
    "id": studentId,
    "performanceData": performanceData?.toJson(),
    "attendanceData": attendanceData?.toJson(),
  };
}

class AcademicInfo {
  CurrentClass? currentClass;
  String? academicYear;
  DateTime? admissionDate;
  String? studentType;

  AcademicInfo({
    this.currentClass,
    this.academicYear,
    this.admissionDate,
    this.studentType,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
    currentClass:
        json["currentClass"] == null
            ? null
            : CurrentClass.fromJson(json["currentClass"]),
    academicYear: json["academicYear"],
    admissionDate:
        json["admissionDate"] == null
            ? null
            : DateTime.parse(json["admissionDate"]),
    studentType: json["studentType"],
  );

  Map<String, dynamic> toJson() => {
    "currentClass": currentClass?.toJson(),
    "academicYear": academicYear,
    "admissionDate": admissionDate?.toIso8601String(),
    "studentType": studentType,
  };
}

class CurrentClass {
  Classroom? classroom;
  Schedule? schedule;
  String? id;
  String? name;
  String? level;
  String? section;
  String? term;
  String? academicYear;
  String? color;
  List<SubjectTeacher>? subjectTeachers;
  List<String>? students;
  List<dynamic>? subjects;
  List<dynamic>? currentClassDefault;
  int? capacity;
  Fees? fees;
  List<String>? feeStructures;
  bool? isActive;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? classTeacher;
  int? totalFees;
  int? currentEnrollment;
  int? availableSlots;
  bool? hasFeeStructure;
  dynamic feeStructureDetails;
  String? currentClassId;

  CurrentClass({
    this.classroom,
    this.schedule,
    this.id,
    this.name,
    this.level,
    this.section,
    this.term,
    this.academicYear,
    this.color,
    this.subjectTeachers,
    this.students,
    this.subjects,
    this.currentClassDefault,
    this.capacity,
    this.fees,
    this.feeStructures,
    this.isActive,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.classTeacher,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.hasFeeStructure,
    this.feeStructureDetails,
    this.currentClassId,
  });

  factory CurrentClass.fromJson(Map<String, dynamic> json) => CurrentClass(
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
    term: json["term"],
    academicYear: json["academicYear"],
    color: json["color"],
    subjectTeachers:
        json["subjectTeachers"] == null
            ? []
            : List<SubjectTeacher>.from(
              json["subjectTeachers"]!.map((x) => SubjectTeacher.fromJson(x)),
            ),
    students:
        json["students"] == null
            ? []
            : List<String>.from(json["students"]!.map((x) => x)),
    subjects:
        json["subjects"] == null
            ? []
            : List<dynamic>.from(json["subjects"]!.map((x) => x)),
    currentClassDefault:
        json["default"] == null
            ? []
            : List<dynamic>.from(json["default"]!.map((x) => x)),
    capacity: json["capacity"],
    fees: json["fees"] == null ? null : Fees.fromJson(json["fees"]),
    feeStructures:
        json["feeStructures"] == null
            ? []
            : List<String>.from(json["feeStructures"]!.map((x) => x)),
    isActive: json["isActive"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    classTeacher: json["classTeacher"],
    totalFees: json["totalFees"],
    currentEnrollment: json["currentEnrollment"],
    availableSlots: json["availableSlots"],
    hasFeeStructure: json["hasFeeStructure"],
    feeStructureDetails: json["feeStructureDetails"],
    currentClassId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "classroom": classroom?.toJson(),
    "schedule": schedule?.toJson(),
    "_id": id,
    "name": name,
    "level": level,
    "section": section,
    "term": term,
    "academicYear": academicYear,
    "color": color,
    "subjectTeachers":
        subjectTeachers == null
            ? []
            : List<dynamic>.from(subjectTeachers!.map((x) => x.toJson())),
    "students":
        students == null ? [] : List<dynamic>.from(students!.map((x) => x)),
    "subjects":
        subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x)),
    "default":
        currentClassDefault == null
            ? []
            : List<dynamic>.from(currentClassDefault!.map((x) => x)),
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
    "classTeacher": classTeacher,
    "totalFees": totalFees,
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "hasFeeStructure": hasFeeStructure,
    "feeStructureDetails": feeStructureDetails,
    "id": currentClassId,
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

class Fees {
  Fees();

  factory Fees.fromJson(Map<String, dynamic> json) => Fees();

  Map<String, dynamic> toJson() => {};
}

class Schedule {
  String? startTime;
  String? endTime;
  List<String>? days;

  Schedule({this.startTime, this.endTime, this.days});

  factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
    startTime: json["startTime"],
    endTime: json["endTime"],
    days:
        json["days"] == null
            ? []
            : List<String>.from(json["days"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "startTime": startTime,
    "endTime": endTime,
    "days": days == null ? [] : List<dynamic>.from(days!.map((x) => x)),
  };
}

class SubjectTeacher {
  String? teacher;
  String? subject;
  String? subjectText;
  String? id;
  String? subjectTeacherId;

  SubjectTeacher({
    this.teacher,
    this.subject,
    this.subjectText,
    this.id,
    this.subjectTeacherId,
  });

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) => SubjectTeacher(
    teacher: json["teacher"],
    subject: json["subject"],
    subjectText: json["subjectText"],
    id: json["_id"],
    subjectTeacherId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "teacher": teacher,
    "subject": subject,
    "subjectText": subjectText,
    "_id": id,
    "id": subjectTeacherId,
  };
}

class AttendanceData {
  bool? hasAttendanceData;
  AcademicTerm? academicTerm;
  ClassInfo? classInfo;
  Statistics? statistics;

  AttendanceData({
    this.hasAttendanceData,
    this.academicTerm,
    this.classInfo,
    this.statistics,
  });

  factory AttendanceData.fromJson(Map<String, dynamic> json) => AttendanceData(
    hasAttendanceData: json["hasAttendanceData"],
    academicTerm:
        json["academicTerm"] == null
            ? null
            : AcademicTerm.fromJson(json["academicTerm"]),
    classInfo:
        json["classInfo"] == null
            ? null
            : ClassInfo.fromJson(json["classInfo"]),
    statistics:
        json["statistics"] == null
            ? null
            : Statistics.fromJson(json["statistics"]),
  );

  Map<String, dynamic> toJson() => {
    "hasAttendanceData": hasAttendanceData,
    "academicTerm": academicTerm?.toJson(),
    "classInfo": classInfo?.toJson(),
    "statistics": statistics?.toJson(),
  };
}

class AcademicTerm {
  String? term;
  String? academicYear;

  AcademicTerm({this.term, this.academicYear});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) =>
      AcademicTerm(term: json["term"], academicYear: json["academicYear"]);

  Map<String, dynamic> toJson() => {"term": term, "academicYear": academicYear};
}

class ClassInfo {
  String? name;
  String? level;
  int? totalAttendanceDays;

  ClassInfo({this.name, this.level, this.totalAttendanceDays});

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
    name: json["name"],
    level: json["level"],
    totalAttendanceDays: json["totalAttendanceDays"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "level": level,
    "totalAttendanceDays": totalAttendanceDays,
  };
}

class Statistics {
  int? totalClassDays;
  int? studentAttendanceDays;
  Breakdown? breakdown;
  StatisticsSummary? summary;

  Statistics({
    this.totalClassDays,
    this.studentAttendanceDays,
    this.breakdown,
    this.summary,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    totalClassDays: json["totalClassDays"],
    studentAttendanceDays: json["studentAttendanceDays"],
    breakdown:
        json["breakdown"] == null
            ? null
            : Breakdown.fromJson(json["breakdown"]),
    summary:
        json["summary"] == null
            ? null
            : StatisticsSummary.fromJson(json["summary"]),
  );

  Map<String, dynamic> toJson() => {
    "totalClassDays": totalClassDays,
    "studentAttendanceDays": studentAttendanceDays,
    "breakdown": breakdown?.toJson(),
    "summary": summary?.toJson(),
  };
}

class Breakdown {
  Absent? present;
  Absent? absent;
  Absent? late;
  Absent? excused;
  Absent? sick;

  Breakdown({this.present, this.absent, this.late, this.excused, this.sick});

  factory Breakdown.fromJson(Map<String, dynamic> json) => Breakdown(
    present: json["present"] == null ? null : Absent.fromJson(json["present"]),
    absent: json["absent"] == null ? null : Absent.fromJson(json["absent"]),
    late: json["late"] == null ? null : Absent.fromJson(json["late"]),
    excused: json["excused"] == null ? null : Absent.fromJson(json["excused"]),
    sick: json["sick"] == null ? null : Absent.fromJson(json["sick"]),
  );

  Map<String, dynamic> toJson() => {
    "present": present?.toJson(),
    "absent": absent?.toJson(),
    "late": late?.toJson(),
    "excused": excused?.toJson(),
    "sick": sick?.toJson(),
  };
}

class Absent {
  int? count;
  int? percentage;

  Absent({this.count, this.percentage});

  factory Absent.fromJson(Map<String, dynamic> json) =>
      Absent(count: json["count"], percentage: json["percentage"]);

  Map<String, dynamic> toJson() => {"count": count, "percentage": percentage};
}

class StatisticsSummary {
  int? presentDays;
  int? presentPercentage;
  int? absentDays;
  int? absentPercentage;
  int? lateDays;
  int? latePercentage;
  int? excusedDays;
  int? excusedPercentage;
  int? sickDays;
  int? sickPercentage;

  StatisticsSummary({
    this.presentDays,
    this.presentPercentage,
    this.absentDays,
    this.absentPercentage,
    this.lateDays,
    this.latePercentage,
    this.excusedDays,
    this.excusedPercentage,
    this.sickDays,
    this.sickPercentage,
  });

  factory StatisticsSummary.fromJson(Map<String, dynamic> json) =>
      StatisticsSummary(
        presentDays: json["presentDays"],
        presentPercentage: json["presentPercentage"],
        absentDays: json["absentDays"],
        absentPercentage: json["absentPercentage"],
        lateDays: json["lateDays"],
        latePercentage: json["latePercentage"],
        excusedDays: json["excusedDays"],
        excusedPercentage: json["excusedPercentage"],
        sickDays: json["sickDays"],
        sickPercentage: json["sickPercentage"],
      );

  Map<String, dynamic> toJson() => {
    "presentDays": presentDays,
    "presentPercentage": presentPercentage,
    "absentDays": absentDays,
    "absentPercentage": absentPercentage,
    "lateDays": lateDays,
    "latePercentage": latePercentage,
    "excusedDays": excusedDays,
    "excusedPercentage": excusedPercentage,
    "sickDays": sickDays,
    "sickPercentage": sickPercentage,
  };
}

class StudentContactInfo {
  Address? address;
  String? phone;
  String? email;

  StudentContactInfo({this.address, this.phone, this.email});

  factory StudentContactInfo.fromJson(Map<String, dynamic> json) =>
      StudentContactInfo(
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        phone: json["phone"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
    "address": address?.toJson(),
    "phone": phone,
    "email": email,
  };
}

class Address {
  String? street;
  String? city;
  String? state;
  String? country;

  Address({this.street, this.city, this.state, this.country});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "country": country,
  };
}

class FinancialInfo {
  String? feeStatus;
  int? totalFees;
  int? paidAmount;
  int? outstandingBalance;
  DetailedBreakdown? detailedBreakdown;

  FinancialInfo({
    this.feeStatus,
    this.totalFees,
    this.paidAmount,
    this.outstandingBalance,
    this.detailedBreakdown,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) => FinancialInfo(
    feeStatus: json["feeStatus"],
    totalFees: json["totalFees"],
    paidAmount: json["paidAmount"],
    outstandingBalance: json["outstandingBalance"],
    detailedBreakdown:
        json["detailedBreakdown"] == null
            ? null
            : DetailedBreakdown.fromJson(json["detailedBreakdown"]),
  );

  Map<String, dynamic> toJson() => {
    "feeStatus": feeStatus,
    "totalFees": totalFees,
    "paidAmount": paidAmount,
    "outstandingBalance": outstandingBalance,
    "detailedBreakdown": detailedBreakdown?.toJson(),
  };
}

class DetailedBreakdown {
  bool? hasFeeStructure;
  AcademicTerm? academicTerm;
  PaymentStatus? paymentStatus;

  DetailedBreakdown({
    this.hasFeeStructure,
    this.academicTerm,
    this.paymentStatus,
  });

  factory DetailedBreakdown.fromJson(Map<String, dynamic> json) =>
      DetailedBreakdown(
        hasFeeStructure: json["hasFeeStructure"],
        academicTerm:
            json["academicTerm"] == null
                ? null
                : AcademicTerm.fromJson(json["academicTerm"]),
        paymentStatus:
            json["paymentStatus"] == null
                ? null
                : PaymentStatus.fromJson(json["paymentStatus"]),
      );

  Map<String, dynamic> toJson() => {
    "hasFeeStructure": hasFeeStructure,
    "academicTerm": academicTerm?.toJson(),
    "paymentStatus": paymentStatus?.toJson(),
  };
}

class PaymentStatus {
  BaseFee? baseFee;
  List<AddOn>? addOns;
  PaymentStatusSummary? summary;
  Outstanding? outstanding;

  PaymentStatus({this.baseFee, this.addOns, this.summary, this.outstanding});

  factory PaymentStatus.fromJson(Map<String, dynamic> json) => PaymentStatus(
    baseFee: json["baseFee"] == null ? null : BaseFee.fromJson(json["baseFee"]),
    addOns:
        json["addOns"] == null
            ? []
            : List<AddOn>.from(json["addOns"]!.map((x) => AddOn.fromJson(x))),
    summary:
        json["summary"] == null
            ? null
            : PaymentStatusSummary.fromJson(json["summary"]),
    outstanding:
        json["outstanding"] == null
            ? null
            : Outstanding.fromJson(json["outstanding"]),
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee?.toJson(),
    "addOns":
        addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
    "summary": summary?.toJson(),
    "outstanding": outstanding?.toJson(),
  };
}

class AddOn {
  String? name;
  int? amount;
  int? paidAmount;
  int? balance;
  String? status;
  bool? compulsory;
  int? percentage;

  AddOn({
    this.name,
    this.amount,
    this.paidAmount,
    this.balance,
    this.status,
    this.compulsory,
    this.percentage,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    name: json["name"],
    amount: json["amount"],
    paidAmount: json["paidAmount"],
    balance: json["balance"],
    status: json["status"],
    compulsory: json["compulsory"],
    percentage: json["percentage"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "paidAmount": paidAmount,
    "balance": balance,
    "status": status,
    "compulsory": compulsory,
    "percentage": percentage,
  };
}

class BaseFee {
  int? amount;
  int? paidAmount;
  int? balance;
  String? status;
  int? percentage;

  BaseFee({
    this.amount,
    this.paidAmount,
    this.balance,
    this.status,
    this.percentage,
  });

  factory BaseFee.fromJson(Map<String, dynamic> json) => BaseFee(
    amount: json["amount"],
    paidAmount: json["paidAmount"],
    balance: json["balance"],
    status: json["status"],
    percentage: json["percentage"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "paidAmount": paidAmount,
    "balance": balance,
    "status": status,
    "percentage": percentage,
  };
}

class Outstanding {
  dynamic baseFee;
  List<dynamic>? addOns;
  Total? total;

  Outstanding({this.baseFee, this.addOns, this.total});

  factory Outstanding.fromJson(Map<String, dynamic> json) => Outstanding(
    baseFee: json["baseFee"],
    addOns:
        json["addOns"] == null
            ? []
            : List<dynamic>.from(json["addOns"]!.map((x) => x)),
    total: json["total"] == null ? null : Total.fromJson(json["total"]),
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "addOns": addOns == null ? [] : List<dynamic>.from(addOns!.map((x) => x)),
    "total": total?.toJson(),
  };
}

class Total {
  int? amount;
  String? status;

  Total({this.amount, this.status});

  factory Total.fromJson(Map<String, dynamic> json) =>
      Total(amount: json["amount"], status: json["status"]);

  Map<String, dynamic> toJson() => {"amount": amount, "status": status};
}

class PaymentStatusSummary {
  int? totalFee;
  int? totalPaid;
  int? totalBalance;
  String? overallStatus;
  int? percentage;

  PaymentStatusSummary({
    this.totalFee,
    this.totalPaid,
    this.totalBalance,
    this.overallStatus,
    this.percentage,
  });

  factory PaymentStatusSummary.fromJson(Map<String, dynamic> json) =>
      PaymentStatusSummary(
        totalFee: json["totalFee"],
        totalPaid: json["totalPaid"],
        totalBalance: json["totalBalance"],
        overallStatus: json["overallStatus"],
        percentage: json["percentage"],
      );

  Map<String, dynamic> toJson() => {
    "totalFee": totalFee,
    "totalPaid": totalPaid,
    "totalBalance": totalBalance,
    "overallStatus": overallStatus,
    "percentage": percentage,
  };
}

class MedicalInfo {
  EmergencyContact? emergencyContact;
  List<String>? allergies;
  List<String>? medications;
  List<String>? medicalConditions;

  MedicalInfo({
    this.emergencyContact,
    this.allergies,
    this.medications,
    this.medicalConditions,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) => MedicalInfo(
    emergencyContact:
        json["emergencyContact"] == null
            ? null
            : EmergencyContact.fromJson(json["emergencyContact"]),
    allergies:
        json["allergies"] == null
            ? []
            : List<String>.from(json["allergies"]!.map((x) => x)),
    medications:
        json["medications"] == null
            ? []
            : List<String>.from(json["medications"]!.map((x) => x)),
    medicalConditions:
        json["medicalConditions"] == null
            ? []
            : List<String>.from(json["medicalConditions"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "emergencyContact": emergencyContact?.toJson(),
    "allergies":
        allergies == null ? [] : List<dynamic>.from(allergies!.map((x) => x)),
    "medications":
        medications == null
            ? []
            : List<dynamic>.from(medications!.map((x) => x)),
    "medicalConditions":
        medicalConditions == null
            ? []
            : List<dynamic>.from(medicalConditions!.map((x) => x)),
  };
}

class EmergencyContact {
  String? name;
  String? relationship;
  String? phone;

  EmergencyContact({this.name, this.relationship, this.phone});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json["name"],
        relationship: json["relationship"],
        phone: json["phone"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "relationship": relationship,
    "phone": phone,
  };
}

class ParentInfo {
  Father? father;

  ParentInfo({this.father});

  factory ParentInfo.fromJson(Map<String, dynamic> json) => ParentInfo(
    father: json["father"] == null ? null : Father.fromJson(json["father"]),
  );

  Map<String, dynamic> toJson() => {"father": father?.toJson()};
}

class Father {
  FatherPersonalInfo? personalInfo;
  FatherContactInfo? contactInfo;
  ProfessionalInfo? professionalInfo;
  Preferences? preferences;
  String? id;
  String? user;
  List<String>? children;
  List<dynamic>? emergencyContacts;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? fatherId;

  Father({
    this.personalInfo,
    this.contactInfo,
    this.professionalInfo,
    this.preferences,
    this.id,
    this.user,
    this.children,
    this.emergencyContacts,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.fatherId,
  });

  factory Father.fromJson(Map<String, dynamic> json) => Father(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : FatherPersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : FatherContactInfo.fromJson(json["contactInfo"]),
    professionalInfo:
        json["professionalInfo"] == null
            ? null
            : ProfessionalInfo.fromJson(json["professionalInfo"]),
    preferences:
        json["preferences"] == null
            ? null
            : Preferences.fromJson(json["preferences"]),
    id: json["_id"],
    user: json["user"],
    children:
        json["children"] == null
            ? []
            : List<String>.from(json["children"]!.map((x) => x)),
    emergencyContacts:
        json["emergencyContacts"] == null
            ? []
            : List<dynamic>.from(json["emergencyContacts"]!.map((x) => x)),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    fatherId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "professionalInfo": professionalInfo?.toJson(),
    "preferences": preferences?.toJson(),
    "_id": id,
    "user": user,
    "children":
        children == null ? [] : List<dynamic>.from(children!.map((x) => x)),
    "emergencyContacts":
        emergencyContacts == null
            ? []
            : List<dynamic>.from(emergencyContacts!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "id": fatherId,
  };
}

class FatherContactInfo {
  Address? address;
  String? primaryPhone;
  String? email;

  FatherContactInfo({this.address, this.primaryPhone, this.email});

  factory FatherContactInfo.fromJson(Map<String, dynamic> json) =>
      FatherContactInfo(
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        primaryPhone: json["primaryPhone"],
        email: json["email"],
      );

  Map<String, dynamic> toJson() => {
    "address": address?.toJson(),
    "primaryPhone": primaryPhone,
    "email": email,
  };
}

class FatherPersonalInfo {
  String? title;
  String? firstName;
  String? lastName;
  String? middleName;
  DateTime? dateOfBirth;
  String? gender;
  String? maritalStatus;

  FatherPersonalInfo({
    this.title,
    this.firstName,
    this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
  });

  factory FatherPersonalInfo.fromJson(Map<String, dynamic> json) =>
      FatherPersonalInfo(
        title: json["title"],
        firstName: json["firstName"],
        lastName: json["lastName"],
        middleName: json["middleName"],
        dateOfBirth:
            json["dateOfBirth"] == null
                ? null
                : DateTime.parse(json["dateOfBirth"]),
        gender: json["gender"],
        maritalStatus: json["maritalStatus"],
      );

  Map<String, dynamic> toJson() => {
    "title": title,
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "gender": gender,
    "maritalStatus": maritalStatus,
  };
}

class Preferences {
  String? preferredContactMethod;
  bool? receiveNewsletters;
  bool? receiveEventNotifications;

  Preferences({
    this.preferredContactMethod,
    this.receiveNewsletters,
    this.receiveEventNotifications,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => Preferences(
    preferredContactMethod: json["preferredContactMethod"],
    receiveNewsletters: json["receiveNewsletters"],
    receiveEventNotifications: json["receiveEventNotifications"],
  );

  Map<String, dynamic> toJson() => {
    "preferredContactMethod": preferredContactMethod,
    "receiveNewsletters": receiveNewsletters,
    "receiveEventNotifications": receiveEventNotifications,
  };
}

class ProfessionalInfo {
  String? occupation;
  String? employer;
  int? annualIncome;

  ProfessionalInfo({this.occupation, this.employer, this.annualIncome});

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) =>
      ProfessionalInfo(
        occupation: json["occupation"],
        employer: json["employer"],
        annualIncome: json["annualIncome"],
      );

  Map<String, dynamic> toJson() => {
    "occupation": occupation,
    "employer": employer,
    "annualIncome": annualIncome,
  };
}

class PerformanceData {
  bool? hasPerformanceData;
  AcademicTerm? academicTerm;
  TermAverages? termAverages;
  LatestPerformance? latestPerformance;

  PerformanceData({
    this.hasPerformanceData,
    this.academicTerm,
    this.termAverages,
    this.latestPerformance,
  });

  factory PerformanceData.fromJson(Map<String, dynamic> json) =>
      PerformanceData(
        hasPerformanceData: json["hasPerformanceData"],
        academicTerm:
            json["academicTerm"] == null
                ? null
                : AcademicTerm.fromJson(json["academicTerm"]),
        termAverages:
            json["termAverages"] == null
                ? null
                : TermAverages.fromJson(json["termAverages"]),
        latestPerformance:
            json["latestPerformance"] == null
                ? null
                : LatestPerformance.fromJson(json["latestPerformance"]),
      );

  Map<String, dynamic> toJson() => {
    "hasPerformanceData": hasPerformanceData,
    "academicTerm": academicTerm?.toJson(),
    "termAverages": termAverages?.toJson(),
    "latestPerformance": latestPerformance?.toJson(),
  };
}

class LatestPerformance {
  DateTime? date;
  double? overallScore;
  Grade? overallGrade;
  String? teacherRemarks;
  List<String>? recommendations;

  LatestPerformance({
    this.date,
    this.overallScore,
    this.overallGrade,
    this.teacherRemarks,
    this.recommendations,
  });

  factory LatestPerformance.fromJson(Map<String, dynamic> json) =>
      LatestPerformance(
        date: json["date"] == null ? null : DateTime.parse(json["date"]),
        overallScore: json["overallScore"]?.toDouble(),
        overallGrade: gradeValues.map[json["overallGrade"]]!,
        teacherRemarks: json["teacherRemarks"],
        recommendations:
            json["recommendations"] == null
                ? []
                : List<String>.from(json["recommendations"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "date": date?.toIso8601String(),
    "overallScore": overallScore,
    "overallGrade": gradeValues.reverse[overallGrade],
    "teacherRemarks": teacherRemarks,
    "recommendations":
        recommendations == null
            ? []
            : List<dynamic>.from(recommendations!.map((x) => x)),
  };
}

enum Grade { EXCELLENT, VERY_GOOD }

final gradeValues = EnumValues({
  "Excellent": Grade.EXCELLENT,
  "Very Good": Grade.VERY_GOOD,
});

class TermAverages {
  Assessments? assessments;
  List<Subject>? subjects;
  Overall? overall;

  TermAverages({this.assessments, this.subjects, this.overall});

  factory TermAverages.fromJson(Map<String, dynamic> json) => TermAverages(
    assessments:
        json["assessments"] == null
            ? null
            : Assessments.fromJson(json["assessments"]),
    subjects:
        json["subjects"] == null
            ? []
            : List<Subject>.from(
              json["subjects"]!.map((x) => Subject.fromJson(x)),
            ),
    overall: json["overall"] == null ? null : Overall.fromJson(json["overall"]),
  );

  Map<String, dynamic> toJson() => {
    "assessments": assessments?.toJson(),
    "subjects":
        subjects == null
            ? []
            : List<dynamic>.from(subjects!.map((x) => x.toJson())),
    "overall": overall?.toJson(),
  };
}

class Assessments {
  Academic? academic;
  Behavioral? behavioral;

  Assessments({this.academic, this.behavioral});

  factory Assessments.fromJson(Map<String, dynamic> json) => Assessments(
    academic:
        json["academic"] == null ? null : Academic.fromJson(json["academic"]),
    behavioral:
        json["behavioral"] == null
            ? null
            : Behavioral.fromJson(json["behavioral"]),
  );

  Map<String, dynamic> toJson() => {
    "academic": academic?.toJson(),
    "behavioral": behavioral?.toJson(),
  };
}

class Academic {
  Subject? classwork;
  Subject? homework;
  Subject? participation;
  Subject? understanding;

  Academic({
    this.classwork,
    this.homework,
    this.participation,
    this.understanding,
  });

  factory Academic.fromJson(Map<String, dynamic> json) => Academic(
    classwork:
        json["classwork"] == null ? null : Subject.fromJson(json["classwork"]),
    homework:
        json["homework"] == null ? null : Subject.fromJson(json["homework"]),
    participation:
        json["participation"] == null
            ? null
            : Subject.fromJson(json["participation"]),
    understanding:
        json["understanding"] == null
            ? null
            : Subject.fromJson(json["understanding"]),
  );

  Map<String, dynamic> toJson() => {
    "classwork": classwork?.toJson(),
    "homework": homework?.toJson(),
    "participation": participation?.toJson(),
    "understanding": understanding?.toJson(),
  };
}

class Subject {
  int? actualScore;
  int? expectedScore;
  Grade? grade;
  String? name;

  Subject({this.actualScore, this.expectedScore, this.grade, this.name});

  factory Subject.fromJson(Map<String, dynamic> json) => Subject(
    actualScore: json["actualScore"],
    expectedScore: json["expectedScore"],
    grade: gradeValues.map[json["grade"]]!,
    name: json["name"],
  );

  Map<String, dynamic> toJson() => {
    "actualScore": actualScore,
    "expectedScore": expectedScore,
    "grade": gradeValues.reverse[grade],
    "name": name,
  };
}

class Behavioral {
  Subject? punctuality;
  Subject? discipline;
  Subject? cooperation;
  Subject? leadership;

  Behavioral({
    this.punctuality,
    this.discipline,
    this.cooperation,
    this.leadership,
  });

  factory Behavioral.fromJson(Map<String, dynamic> json) => Behavioral(
    punctuality:
        json["punctuality"] == null
            ? null
            : Subject.fromJson(json["punctuality"]),
    discipline:
        json["discipline"] == null
            ? null
            : Subject.fromJson(json["discipline"]),
    cooperation:
        json["cooperation"] == null
            ? null
            : Subject.fromJson(json["cooperation"]),
    leadership:
        json["leadership"] == null
            ? null
            : Subject.fromJson(json["leadership"]),
  );

  Map<String, dynamic> toJson() => {
    "punctuality": punctuality?.toJson(),
    "discipline": discipline?.toJson(),
    "cooperation": cooperation?.toJson(),
    "leadership": leadership?.toJson(),
  };
}

class Overall {
  double? averageScore;
  Grade? grade;
  int? totalRecords;
  DateTime? lastUpdated;

  Overall({this.averageScore, this.grade, this.totalRecords, this.lastUpdated});

  factory Overall.fromJson(Map<String, dynamic> json) => Overall(
    averageScore: json["averageScore"]?.toDouble(),
    grade: gradeValues.map[json["grade"]]!,
    totalRecords: json["totalRecords"],
    lastUpdated:
        json["lastUpdated"] == null
            ? null
            : DateTime.parse(json["lastUpdated"]),
  );

  Map<String, dynamic> toJson() => {
    "averageScore": averageScore,
    "grade": gradeValues.reverse[grade],
    "totalRecords": totalRecords,
    "lastUpdated": lastUpdated?.toIso8601String(),
  };
}

class StudentPersonalInfo {
  String? firstName;
  String? lastName;
  String? middleName;
  DateTime? dateOfBirth;
  String? gender;
  String? nationality;
  String? stateOfOrigin;
  String? localGovernment;
  String? religion;
  String? bloodGroup;
  String? profileImage;

  StudentPersonalInfo({
    this.firstName,
    this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.stateOfOrigin,
    this.localGovernment,
    this.religion,
    this.bloodGroup,
    this.profileImage,
  });

  factory StudentPersonalInfo.fromJson(Map<String, dynamic> json) =>
      StudentPersonalInfo(
        firstName: json["firstName"],
        lastName: json["lastName"],
        middleName: json["middleName"],
        dateOfBirth:
            json["dateOfBirth"] == null
                ? null
                : DateTime.parse(json["dateOfBirth"]),
        gender: json["gender"],
        nationality: json["nationality"],
        stateOfOrigin: json["stateOfOrigin"],
        localGovernment: json["localGovernment"],
        religion: json["religion"],
        bloodGroup: json["bloodGroup"],
        profileImage: json["profileImage"],
      );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "gender": gender,
    "nationality": nationality,
    "stateOfOrigin": stateOfOrigin,
    "localGovernment": localGovernment,
    "religion": religion,
    "bloodGroup": bloodGroup,
    "profileImage": profileImage,
  };
}

class User {
  String? id;
  String? email;

  User({this.id, this.email});

  factory User.fromJson(Map<String, dynamic> json) =>
      User(id: json["_id"], email: json["email"]);

  Map<String, dynamic> toJson() => {"_id": id, "email": email};
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
