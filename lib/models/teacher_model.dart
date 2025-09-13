// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

class TeacherListModel {
  List<Teacher>? teachers;
  Pagination? pagination;
  Statistics? statistics;
  Filters? filters;

  TeacherListModel({
    this.teachers,
    this.pagination,
    this.statistics,
    this.filters,
  });

  factory TeacherListModel.fromJson(Map<String, dynamic> json) =>
      TeacherListModel(
        teachers:
            json["teachers"] == null
                ? []
                : List<Teacher>.from(
                  json["teachers"]!.map((x) => Teacher.fromJson(x)),
                ),
        pagination:
            json["pagination"] == null
                ? null
                : Pagination.fromJson(json["pagination"]),
        statistics:
            json["statistics"] == null
                ? null
                : Statistics.fromJson(json["statistics"]),
        filters:
            json["filters"] == null ? null : Filters.fromJson(json["filters"]),
      );

  Map<String, dynamic> toJson() => {
    "teachers":
        teachers == null
            ? []
            : List<dynamic>.from(teachers!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
    "statistics": statistics?.toJson(),
    "filters": filters?.toJson(),
  };
}

class Filters {
  String? status;
  bool? includeClasses;

  Filters({this.status, this.includeClasses});

  factory Filters.fromJson(Map<String, dynamic> json) =>
      Filters(status: json["status"], includeClasses: json["includeClasses"]);

  Map<String, dynamic> toJson() => {
    "status": status,
    "includeClasses": includeClasses,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalTeachers;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalTeachers,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalTeachers: json["totalTeachers"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalTeachers": totalTeachers,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}

class Statistics {
  int? total;
  ByDepartment? byDepartment;
  ByStatus? byStatus;
  ByEmploymentType? byEmploymentType;
  int? averageSalary;
  ClassTeachers? classTeachers;

  Statistics({
    this.total,
    this.byDepartment,
    this.byStatus,
    this.byEmploymentType,
    this.averageSalary,
    this.classTeachers,
  });

  factory Statistics.fromJson(Map<String, dynamic> json) => Statistics(
    total: json["total"],
    byDepartment:
        json["byDepartment"] == null
            ? null
            : ByDepartment.fromJson(json["byDepartment"]),
    byStatus:
        json["byStatus"] == null ? null : ByStatus.fromJson(json["byStatus"]),
    byEmploymentType:
        json["byEmploymentType"] == null
            ? null
            : ByEmploymentType.fromJson(json["byEmploymentType"]),
    averageSalary: json["averageSalary"],
    classTeachers:
        json["classTeachers"] == null
            ? null
            : ClassTeachers.fromJson(json["classTeachers"]),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "byDepartment": byDepartment?.toJson(),
    "byStatus": byStatus?.toJson(),
    "byEmploymentType": byEmploymentType?.toJson(),
    "averageSalary": averageSalary,
    "classTeachers": classTeachers?.toJson(),
  };
}

class ByDepartment {
  int? science;

  ByDepartment({this.science});

  factory ByDepartment.fromJson(Map<String, dynamic> json) =>
      ByDepartment(science: json["Science"]);

  Map<String, dynamic> toJson() => {"Science": science};
}

class ByEmploymentType {
  ByEmploymentType();

  factory ByEmploymentType.fromJson(Map<String, dynamic> json) =>
      ByEmploymentType();

  Map<String, dynamic> toJson() => {};
}

class ByStatus {
  int? active;

  ByStatus({this.active});

  factory ByStatus.fromJson(Map<String, dynamic> json) =>
      ByStatus(active: json["active"]);

  Map<String, dynamic> toJson() => {"active": active};
}

class ClassTeachers {
  int? totalClassTeachers;
  int? classesWithClassTeachers;
  int? teachersWithMultipleClasses;

  ClassTeachers({
    this.totalClassTeachers,
    this.classesWithClassTeachers,
    this.teachersWithMultipleClasses,
  });

  factory ClassTeachers.fromJson(Map<String, dynamic> json) => ClassTeachers(
    totalClassTeachers: json["totalClassTeachers"],
    classesWithClassTeachers: json["classesWithClassTeachers"],
    teachersWithMultipleClasses: json["teachersWithMultipleClasses"],
  );

  Map<String, dynamic> toJson() => {
    "totalClassTeachers": totalClassTeachers,
    "classesWithClassTeachers": classesWithClassTeachers,
    "teachersWithMultipleClasses": teachersWithMultipleClasses,
  };
}

class Teacher {
  PersonalInfo? personalInfo;
  Contact? contactInfo;
  EmploymentInfo? employmentInfo;
  String? id;
  User? user;
  String? staffId;
  List<Qualification>? qualifications;
  List<String>? subjects;
  List<String>? classes;
  String? status;
  int? yearsOfService;
  String? teacherId;
  String? fullName;
  TeachingInfo? teachingInfo;
  List<String>? allClasses;
  Contact? contactSummary;
  EmploymentSummary? employmentSummary;
  Roles? roles;

  Teacher({
    this.personalInfo,
    this.contactInfo,
    this.employmentInfo,
    this.id,
    this.user,
    this.staffId,
    this.qualifications,
    this.subjects,
    this.classes,
    this.status,
    this.yearsOfService,
    this.teacherId,
    this.fullName,
    this.teachingInfo,
    this.allClasses,
    this.contactSummary,
    this.employmentSummary,
    this.roles,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    print(json["allClasses"]);
    return Teacher(
      personalInfo:
          json["personalInfo"] == null
              ? null
              : PersonalInfo.fromJson(json["personalInfo"]),
      contactInfo:
          json["contactInfo"] == null
              ? null
              : Contact.fromJson(json["contactInfo"]),
      employmentInfo:
          json["employmentInfo"] == null
              ? null
              : EmploymentInfo.fromJson(json["employmentInfo"]),
      id: json["_id"],
      user: json["user"] == null ? null : User.fromJson(json["user"]),
      staffId: json["staffId"],
      qualifications:
          json["qualifications"] == null
              ? []
              : List<Qualification>.from(
                json["qualifications"]!.map((x) => Qualification.fromJson(x)),
              ),
      subjects:
          json["subjects"] == null
              ? []
              : List<String>.from(json["subjects"]!.map((x) => x)),
      classes:
          json["classes"] == null
              ? []
              : List<String>.from(json["classes"]!.map((x) => x)),
      status: json["status"],
      yearsOfService: json["yearsOfService"],
      teacherId: json["id"],
      fullName: json["fullName"],
      teachingInfo:
          json["teachingInfo"] == null
              ? null
              : TeachingInfo.fromJson(json["teachingInfo"]),
      // allClasses:
      //     json["allClasses"] == null
      //         ? []
      //         : List<String>.from(json["allClasses"]!.map((x) => x)),
      contactSummary:
          json["contactSummary"] == null
              ? null
              : Contact.fromJson(json["contactSummary"]),
      employmentSummary:
          json["employmentSummary"] == null
              ? null
              : EmploymentSummary.fromJson(json["employmentSummary"]),
      roles: json["roles"] == null ? null : Roles.fromJson(json["roles"]),
    );
  }

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "employmentInfo": employmentInfo?.toJson(),
    "_id": id,
    "user": user?.toJson(),
    "staffId": staffId,
    "qualifications":
        qualifications == null
            ? []
            : List<dynamic>.from(qualifications!.map((x) => x.toJson())),
    "subjects":
        subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x)),
    "classes":
        classes == null ? [] : List<dynamic>.from(classes!.map((x) => x)),
    "status": status,
    "yearsOfService": yearsOfService,
    "id": teacherId,
    "fullName": fullName,
    "teachingInfo": teachingInfo?.toJson(),
    "allClasses":
        allClasses == null ? [] : List<dynamic>.from(allClasses!.map((x) => x)),
    "contactSummary": contactSummary?.toJson(),
    "employmentSummary": employmentSummary?.toJson(),
    "roles": roles?.toJson(),
  };
}

class Contact {
  Address? address;
  String? primaryPhone;
  String? secondaryPhone;
  String? email;

  Contact({this.address, this.primaryPhone, this.secondaryPhone, this.email});

  factory Contact.fromJson(Map<String, dynamic> json) => Contact(
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    primaryPhone: json["primaryPhone"],
    secondaryPhone: json["secondaryPhone"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "address": address?.toJson(),
    "primaryPhone": primaryPhone,
    "secondaryPhone": secondaryPhone,
    "email": email,
  };
}

class Address {
  String? street;
  String? city;
  String? state;
  String? country;
  String? postalCode;

  Address({this.street, this.city, this.state, this.country, this.postalCode});

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    street: json["street"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postalCode"],
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "country": country,
    "postalCode": postalCode,
  };
}

class EmploymentInfo {
  String? department;
  int? salary;

  EmploymentInfo({this.department, this.salary});

  factory EmploymentInfo.fromJson(Map<String, dynamic> json) =>
      EmploymentInfo(department: json["department"], salary: json["salary"]);

  Map<String, dynamic> toJson() => {"department": department, "salary": salary};
}

class EmploymentSummary {
  String? department;
  int? yearsOfService;

  EmploymentSummary({this.department, this.yearsOfService});

  factory EmploymentSummary.fromJson(Map<String, dynamic> json) =>
      EmploymentSummary(
        department: json["department"],
        yearsOfService: json["yearsOfService"],
      );

  Map<String, dynamic> toJson() => {
    "department": department,
    "yearsOfService": yearsOfService,
  };
}

class PersonalInfo {
  String? firstName;
  String? lastName;
  String? middleName;
  String? gender;
  String? nationality;

  PersonalInfo({
    this.firstName,
    this.lastName,
    this.middleName,
    this.gender,
    this.nationality,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json["firstName"],
    lastName: json["lastName"],
    middleName: json["middleName"],
    gender: json["gender"],
    nationality: json["nationality"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "gender": gender,
    "nationality": nationality,
  };
}

class Qualification {
  String? degree;
  String? institution;
  String? id;
  String? qualificationId;

  Qualification({this.degree, this.institution, this.id, this.qualificationId});

  factory Qualification.fromJson(Map<String, dynamic> json) => Qualification(
    degree: json["degree"],
    institution: json["institution"],
    id: json["_id"],
    qualificationId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "degree": degree,
    "institution": institution,
    "_id": id,
    "id": qualificationId,
  };
}

class Roles {
  bool? isClassTeacher;
  bool? isSubjectTeacher;
  int? classTeacherCount;
  int? subjectTeacherCount;

  Roles({
    this.isClassTeacher,
    this.isSubjectTeacher,
    this.classTeacherCount,
    this.subjectTeacherCount,
  });

  factory Roles.fromJson(Map<String, dynamic> json) => Roles(
    isClassTeacher: json["isClassTeacher"],
    isSubjectTeacher: json["isSubjectTeacher"],
    classTeacherCount: json["classTeacherCount"],
    subjectTeacherCount: json["subjectTeacherCount"],
  );

  Map<String, dynamic> toJson() => {
    "isClassTeacher": isClassTeacher,
    "isSubjectTeacher": isSubjectTeacher,
    "classTeacherCount": classTeacherCount,
    "subjectTeacherCount": subjectTeacherCount,
  };
}

class TeachingInfo {
  List<String>? subjects;
  int? subjectCount;
  int? classCount;
  bool? isClassTeacher;
  List<ClassTeacherClass>? classTeacherClasses;
  List<String>? subjectTeacherClasses;
  int? yearsOfService;
  String? classTeacherOf;
  String? teachesSubjects;

  TeachingInfo({
    this.subjects,
    this.subjectCount,
    this.classCount,
    this.isClassTeacher,
    this.classTeacherClasses,
    this.subjectTeacherClasses,
    this.yearsOfService,
    this.classTeacherOf,
    this.teachesSubjects,
  });

  factory TeachingInfo.fromJson(Map<String, dynamic> json) => TeachingInfo(
    subjects:
        json["subjects"] == null
            ? []
            : List<String>.from(json["subjects"]!.map((x) => x)),
    subjectCount: json["subjectCount"],
    classCount: json["classCount"],
    isClassTeacher: json["isClassTeacher"],
    classTeacherClasses:
        json["classTeacherClasses"] == null
            ? []
            : List<ClassTeacherClass>.from(
              json["classTeacherClasses"]!.map(
                (x) => ClassTeacherClass.fromJson(x),
              ),
            ),
    subjectTeacherClasses:
        json["subjectTeacherClasses"] == null
            ? []
            : List<String>.from(json["subjectTeacherClasses"]!.map((x) => x)),
    yearsOfService: json["yearsOfService"],
    classTeacherOf: json["classTeacherOf"],
    teachesSubjects: json["teachesSubjects"],
  );

  Map<String, dynamic> toJson() => {
    "subjects":
        subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x)),
    "subjectCount": subjectCount,
    "classCount": classCount,
    "isClassTeacher": isClassTeacher,
    "classTeacherClasses":
        classTeacherClasses == null
            ? []
            : List<dynamic>.from(classTeacherClasses!.map((x) => x.toJson())),
    "subjectTeacherClasses":
        subjectTeacherClasses == null
            ? []
            : List<dynamic>.from(subjectTeacherClasses!.map((x) => x)),
    "yearsOfService": yearsOfService,
    "classTeacherOf": classTeacherOf,
    "teachesSubjects": teachesSubjects,
  };
}

class ClassTeacherClass {
  String? id;
  String? name;
  String? level;
  String? section;
  String? academicYear;

  ClassTeacherClass({
    this.id,
    this.name,
    this.level,
    this.section,
    this.academicYear,
  });

  factory ClassTeacherClass.fromJson(Map<String, dynamic> json) =>
      ClassTeacherClass(
        id: json["_id"],
        name: json["name"],
        level: json["level"],
        section: json["section"],
        academicYear: json["academicYear"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "section": section,
    "academicYear": academicYear,
  };
}

class User {
  String? id;
  String? email;
  String? role;
  bool? isActive;

  User({this.id, this.email, this.role, this.isActive});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    email: json["email"],
    role: json["role"],
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "role": role,
    "isActive": isActive,
  };
}
