// To parse this JSON data, do
//
//     final sfaffModel = sfaffModelFromJson(jsonString);

import 'dart:convert';

SfaffModel sfaffModelFromJson(String str) =>
    SfaffModel.fromJson(json.decode(str));

String sfaffModelToJson(SfaffModel data) => json.encode(data.toJson());

class SfaffModel {
  bool? success;
  Data? data;

  SfaffModel({this.success, this.data});

  factory SfaffModel.fromJson(Map<String, dynamic> json) => SfaffModel(
    success: json["success"],
    data: json["data"] == null ? null : Data.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Staff>? staff;
  Pagination? pagination;

  Data({this.staff, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    staff:
        json["staff"] == null
            ? []
            : List<Staff>.from(json["staff"]!.map((x) => Staff.fromJson(x))),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "staff":
        staff == null ? [] : List<dynamic>.from(staff!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalStaff;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalStaff,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalStaff: json["totalStaff"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalStaff": totalStaff,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}

class Staff {
  PersonalInfo? personalInfo;
  ContactInfo? contactInfo;
  EmploymentInfo? employmentInfo;
  EmergencyContact? emergencyContact;
  String? id;
  User? user;
  List<Qualification>? qualifications;
  List<dynamic>? subjects;
  List<Class>? classes;
  List<Document>? documents;
  String? status;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? yearsOfService;
  String? staffId;
  String? staffStaffId;

  Staff({
    this.personalInfo,
    this.contactInfo,
    this.employmentInfo,
    this.emergencyContact,
    this.id,
    this.user,
    this.qualifications,
    this.subjects,
    this.classes,
    this.documents,
    this.status,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.yearsOfService,
    this.staffId,
    this.staffStaffId,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : PersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : ContactInfo.fromJson(json["contactInfo"]),
    employmentInfo:
        json["employmentInfo"] == null
            ? null
            : EmploymentInfo.fromJson(json["employmentInfo"]),
    emergencyContact:
        json["emergencyContact"] == null
            ? null
            : EmergencyContact.fromJson(json["emergencyContact"]),
    id: json["_id"],
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    qualifications:
        json["qualifications"] == null
            ? []
            : List<Qualification>.from(
              json["qualifications"]!.map((x) => Qualification.fromJson(x)),
            ),
    subjects:
        json["subjects"] == null
            ? []
            : List<dynamic>.from(json["subjects"]!.map((x) => x)),
    classes:
        json["classes"] == null
            ? []
            : List<Class>.from(json["classes"]!.map((x) => Class.fromJson(x))),
    documents:
        json["documents"] == null
            ? []
            : List<Document>.from(
              json["documents"]!.map((x) => Document.fromJson(x)),
            ),
    status: json["status"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    yearsOfService: json["yearsOfService"],
    staffId: json["id"],
    staffStaffId: json["staffId"],
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "employmentInfo": employmentInfo?.toJson(),
    "emergencyContact": emergencyContact?.toJson(),
    "_id": id,
    "user": user?.toJson(),
    "qualifications":
        qualifications == null
            ? []
            : List<dynamic>.from(qualifications!.map((x) => x.toJson())),
    "subjects":
        subjects == null ? [] : List<dynamic>.from(subjects!.map((x) => x)),
    "classes":
        classes == null
            ? []
            : List<dynamic>.from(classes!.map((x) => x.toJson())),
    "documents":
        documents == null
            ? []
            : List<dynamic>.from(documents!.map((x) => x.toJson())),
    "status": status,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "yearsOfService": yearsOfService,
    "id": staffId,
    "staffId": staffStaffId,
  };
}

class Class {
  String? id;
  String? name;
  String? level;
  int? totalFees;
  int? currentEnrollment;
  dynamic availableSlots;
  dynamic feeStructureDetails;
  String? classId;

  Class({
    this.id,
    this.name,
    this.level,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.feeStructureDetails,
    this.classId,
  });

  factory Class.fromJson(Map<String, dynamic> json) => Class(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    totalFees: json["totalFees"],
    currentEnrollment: json["currentEnrollment"],
    availableSlots: json["availableSlots"],
    feeStructureDetails: json["feeStructureDetails"],
    classId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "totalFees": totalFees,
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "feeStructureDetails": feeStructureDetails,
    "id": classId,
  };
}

class ContactInfo {
  Address? address;
  String? primaryPhone;
  String? secondaryPhone;
  String? email;

  ContactInfo({
    this.address,
    this.primaryPhone,
    this.secondaryPhone,
    this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
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

class Document {
  String? type;
  String? id;
  DateTime? uploadDate;
  String? documentId;

  Document({this.type, this.id, this.uploadDate, this.documentId});

  factory Document.fromJson(Map<String, dynamic> json) => Document(
    type: json["type"],
    id: json["_id"],
    uploadDate:
        json["uploadDate"] == null ? null : DateTime.parse(json["uploadDate"]),
    documentId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "_id": id,
    "uploadDate": uploadDate?.toIso8601String(),
    "id": documentId,
  };
}

class EmergencyContact {
  String? name;
  String? phone;
  String? relationship;

  EmergencyContact({this.name, this.phone, this.relationship});

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json["name"],
        phone: json["phone"],
        relationship: json["relationship"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "relationship": relationship,
  };
}

class EmploymentInfo {
  String? department;
  int? salary;
  BankDetails? bankDetails;
  String? employeeType;
  String? position;
  DateTime? joinDate;
  dynamic contractEndDate;

  EmploymentInfo({
    this.department,
    this.salary,
    this.bankDetails,
    this.employeeType,
    this.position,
    this.joinDate,
    this.contractEndDate,
  });

  factory EmploymentInfo.fromJson(Map<String, dynamic> json) => EmploymentInfo(
    department: json["department"],
    salary: json["salary"],
    bankDetails:
        json["bankDetails"] == null
            ? null
            : BankDetails.fromJson(json["bankDetails"]),
    employeeType: json["employeeType"],
    position: json["position"],
    joinDate:
        json["joinDate"] == null ? null : DateTime.parse(json["joinDate"]),
    contractEndDate: json["contractEndDate"],
  );

  Map<String, dynamic> toJson() => {
    "department": department,
    "salary": salary,
    "bankDetails": bankDetails?.toJson(),
    "employeeType": employeeType,
    "position": position,
    "joinDate": joinDate?.toIso8601String(),
    "contractEndDate": contractEndDate,
  };
}

class BankDetails {
  String? bankName;
  String? accountNumber;
  String? accountName;

  BankDetails({this.bankName, this.accountNumber, this.accountName});

  factory BankDetails.fromJson(Map<String, dynamic> json) => BankDetails(
    bankName: json["bankName"],
    accountNumber: json["accountNumber"],
    accountName: json["accountName"],
  );

  Map<String, dynamic> toJson() => {
    "bankName": bankName,
    "accountNumber": accountNumber,
    "accountName": accountName,
  };
}

class PersonalInfo {
  String? firstName;
  String? lastName;
  String? middleName;
  String? gender;
  String? nationality;
  String? title;
  DateTime? dateOfBirth;
  String? maritalStatus;
  String? stateOfOrigin;
  dynamic profilePhoto;

  PersonalInfo({
    this.firstName,
    this.lastName,
    this.middleName,
    this.gender,
    this.nationality,
    this.title,
    this.dateOfBirth,
    this.maritalStatus,
    this.stateOfOrigin,
    this.profilePhoto,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json["firstName"],
    lastName: json["lastName"],
    middleName: json["middleName"],
    gender: json["gender"],
    nationality: json["nationality"],
    title: json["title"],
    dateOfBirth:
        json["dateOfBirth"] == null
            ? null
            : DateTime.parse(json["dateOfBirth"]),
    maritalStatus: json["maritalStatus"],
    stateOfOrigin: json["stateOfOrigin"],
    profilePhoto: json["profilePhoto"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "gender": gender,
    "nationality": nationality,
    "title": title,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "maritalStatus": maritalStatus,
    "stateOfOrigin": stateOfOrigin,
    "profilePhoto": profilePhoto,
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

class User {
  String? id;
  String? email;
  String? profileImage;
  String? role;
  bool? isActive;
  DateTime? lastLogin;

  User({this.id, this.email, this.profileImage, this.role, this.isActive, this.lastLogin});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"],
    profileImage: json["profileImage"],
    role: json["role"],
    email: json["email"],
    isActive: json["isActive"],
    lastLogin:
        json["lastLogin"] == null ? null : DateTime.parse(json["lastLogin"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "profileImage": profileImage,
    "role": role,
    "isActive": isActive,
    "lastLogin": lastLogin?.toIso8601String(),
  };
}
