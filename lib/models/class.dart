// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

Welcome welcomeFromJson(String str) => Welcome.fromJson(json.decode(str));

String welcomeToJson(Welcome data) => json.encode(data.toJson());

class Welcome {
    bool success;
    Data data;

    Welcome({
        required this.success,
        required this.data,
    });

    factory Welcome.fromJson(Map<String, dynamic> json) => Welcome(
        success: json["success"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "data": data.toJson(),
    };
}

class Data {
    List<Class> classes;
    Pagination pagination;

    Data({
        required this.classes,
        required this.pagination,
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        classes: List<Class>.from(json["classes"].map((x) => Class.fromJson(x))),
        pagination: Pagination.fromJson(json["pagination"]),
    );

    Map<String, dynamic> toJson() => {
        "classes": List<dynamic>.from(classes.map((x) => x.toJson())),
        "pagination": pagination.toJson(),
    };
}

class Class {
    Classroom classroom;
    Schedule schedule;
    String id;
    String name;
    String level;
    String section;
    String term;
    String academicYear;
    String color;
    List<SubjectTeacher> subjectTeachers;
    List<String> students;
    List<Subject> subjects;
    List<dynamic> classDefault;
    int capacity;
    Fees fees;
    List<dynamic> feeStructures;
    bool isActive;
    DateTime createdAt;
    DateTime updatedAt;
    int v;
    Teacher? classTeacher;
    int totalFees;
    int currentEnrollment;
    int availableSlots;
    bool hasFeeStructure;
    dynamic feeStructureDetails;
    String classId;
    EnrollmentStats enrollmentStats;

    Class({
        required this.classroom,
        required this.schedule,
        required this.id,
        required this.name,
        required this.level,
        required this.section,
        required this.term,
        required this.academicYear,
        required this.color,
        required this.subjectTeachers,
        required this.students,
        required this.subjects,
        required this.classDefault,
        required this.capacity,
        required this.fees,
        required this.feeStructures,
        required this.isActive,
        required this.createdAt,
        required this.updatedAt,
        required this.v,
        this.classTeacher,
        required this.totalFees,
        required this.currentEnrollment,
        required this.availableSlots,
        required this.hasFeeStructure,
        required this.feeStructureDetails,
        required this.classId,
        required this.enrollmentStats,
    });

    factory Class.fromJson(Map<String, dynamic> json) => Class(
        classroom: Classroom.fromJson(json["classroom"]),
        schedule: Schedule.fromJson(json["schedule"]),
        id: json["_id"],
        name: json["name"],
        level: json["level"],
        section: json["section"],
        term: json["term"],
        academicYear: json["academicYear"],
        color: json["color"],
        subjectTeachers: List<SubjectTeacher>.from(json["subjectTeachers"].map((x) => SubjectTeacher.fromJson(x))),
        students: List<String>.from(json["students"].map((x) => x)),
        subjects: List<Subject>.from(json["subjects"].map((x) => Subject.fromJson(x))),
        classDefault: List<dynamic>.from(json["default"].map((x) => x)),
        capacity: json["capacity"],
        fees: Fees.fromJson(json["fees"]),
        feeStructures: List<dynamic>.from(json["feeStructures"].map((x) => x)),
        isActive: json["isActive"],
        createdAt: DateTime.parse(json["createdAt"]),
        updatedAt: DateTime.parse(json["updatedAt"]),
        v: json["__v"],
        classTeacher: json["classTeacher"] == null ? null : Teacher.fromJson(json["classTeacher"]),
        totalFees: json["totalFees"],
        currentEnrollment: json["currentEnrollment"],
        availableSlots: json["availableSlots"],
        hasFeeStructure: json["hasFeeStructure"],
        feeStructureDetails: json["feeStructureDetails"],
        classId: json["id"],
        enrollmentStats: EnrollmentStats.fromJson(json["enrollmentStats"]),
    );

    Map<String, dynamic> toJson() => {
        "classroom": classroom.toJson(),
        "schedule": schedule.toJson(),
        "_id": id,
        "name": name,
        "level": level,
        "section": section,
        "term": term,
        "academicYear": academicYear,
        "color": color,
        "subjectTeachers": List<dynamic>.from(subjectTeachers.map((x) => x.toJson())),
        "students": List<dynamic>.from(students.map((x) => x)),
        "subjects": List<dynamic>.from(subjects.map((x) => x.toJson())),
        "default": List<dynamic>.from(classDefault.map((x) => x)),
        "capacity": capacity,
        "fees": fees.toJson(),
        "feeStructures": List<dynamic>.from(feeStructures.map((x) => x)),
        "isActive": isActive,
        "createdAt": createdAt.toIso8601String(),
        "updatedAt": updatedAt.toIso8601String(),
        "__v": v,
        "classTeacher": classTeacher?.toJson(),
        "totalFees": totalFees,
        "currentEnrollment": currentEnrollment,
        "availableSlots": availableSlots,
        "hasFeeStructure": hasFeeStructure,
        "feeStructureDetails": feeStructureDetails,
        "id": classId,
        "enrollmentStats": enrollmentStats.toJson(),
    };
}

class Teacher {
    PersonalInfo personalInfo;
    String id;
    String staffId;
    int yearsOfService;
    String teacherId;

    Teacher({
        required this.personalInfo,
        required this.id,
        required this.staffId,
        required this.yearsOfService,
        required this.teacherId,
    });

    factory Teacher.fromJson(Map<String, dynamic> json) => Teacher(
        personalInfo: PersonalInfo.fromJson(json["personalInfo"]),
        id: json["_id"],
        staffId: json["staffId"],
        yearsOfService: json["yearsOfService"],
        teacherId: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "personalInfo": personalInfo.toJson(),
        "_id": id,
        "staffId": staffId,
        "yearsOfService": yearsOfService,
        "id": teacherId,
    };
}

class PersonalInfo {
    String firstName;
    String lastName;

    PersonalInfo({
        required this.firstName,
        required this.lastName,
    });

    factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
        firstName: json["firstName"],
        lastName: json["lastName"],
    );

    Map<String, dynamic> toJson() => {
        "firstName": firstName,
        "lastName": lastName,
    };
}

class Classroom {
    String building;
    String roomNumber;
    String floor;

    Classroom({
        required this.building,
        required this.roomNumber,
        required this.floor,
    });

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
    int currentEnrollment;
    int availableSlots;
    String enrollmentPercentage;

    EnrollmentStats({
        required this.currentEnrollment,
        required this.availableSlots,
        required this.enrollmentPercentage,
    });

    factory EnrollmentStats.fromJson(Map<String, dynamic> json) => EnrollmentStats(
        currentEnrollment: json["currentEnrollment"],
        availableSlots: json["availableSlots"],
        enrollmentPercentage: json["enrollmentPercentage"],
    );

    Map<String, dynamic> toJson() => {
        "currentEnrollment": currentEnrollment,
        "availableSlots": availableSlots,
        "enrollmentPercentage": enrollmentPercentage,
    };
}

class Fees {
    Fees();

    factory Fees.fromJson(Map<String, dynamic> json) => Fees(
    );

    Map<String, dynamic> toJson() => {
    };
}

class Schedule {
    String startTime;
    String endTime;
    List<String> days;

    Schedule({
        required this.startTime,
        required this.endTime,
        required this.days,
    });

    factory Schedule.fromJson(Map<String, dynamic> json) => Schedule(
        startTime: json["startTime"],
        endTime: json["endTime"],
        days: List<String>.from(json["days"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "startTime": startTime,
        "endTime": endTime,
        "days": List<dynamic>.from(days.map((x) => x)),
    };
}

class SubjectTeacher {
    Teacher teacher;
    String subject;
    String subjectText;
    String id;
    String subjectTeacherId;

    SubjectTeacher({
        required this.teacher,
        required this.subject,
        required this.subjectText,
        required this.id,
        required this.subjectTeacherId,
    });

    factory SubjectTeacher.fromJson(Map<String, dynamic> json) => SubjectTeacher(
        teacher: Teacher.fromJson(json["teacher"]),
        subject: json["subject"],
        subjectText: json["subjectText"],
        id: json["_id"],
        subjectTeacherId: json["id"],
    );

    Map<String, dynamic> toJson() => {
        "teacher": teacher.toJson(),
        "subject": subject,
        "subjectText": subjectText,
        "_id": id,
        "id": subjectTeacherId,
    };
}

class Subject {
    String id;
    String name;

    Subject({
        required this.id,
        required this.name,
    });

    factory Subject.fromJson(Map<String, dynamic> json) => Subject(
        id: json["_id"],
        name: json["name"],
    );

    Map<String, dynamic> toJson() => {
        "_id": id,
        "name": name,
    };
}

class Pagination {
    int currentPage;
    int totalPages;
    int totalClasses;
    bool hasNext;
    bool hasPrev;

    Pagination({
        required this.currentPage,
        required this.totalPages,
        required this.totalClasses,
        required this.hasNext,
        required this.hasPrev,
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
