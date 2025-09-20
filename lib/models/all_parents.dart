// To parse this JSON data, do
//
//     final allParentsModel = allParentsModelFromJson(jsonString);

import 'dart:convert';

AllParentsModel allParentsModelFromJson(String str) =>
    AllParentsModel.fromJson(json.decode(str));

String allParentsModelToJson(AllParentsModel data) =>
    json.encode(data.toJson());

class AllParentsModel {
  bool? success;
  Data? data;

  AllParentsModel({this.success, this.data});

  factory AllParentsModel.fromJson(Map<String, dynamic> json) =>
      AllParentsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Parent>? parents;
  Pagination? pagination;

  Data({this.parents, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    parents:
        json["parents"] == null
            ? []
            : List<Parent>.from(
              json["parents"]!.map((x) => Parent.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "parents":
        parents == null
            ? []
            : List<dynamic>.from(parents!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalParents;
  bool? hasNext;
  bool? hasPrev;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalParents,
    this.hasNext,
    this.hasPrev,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalParents: json["totalParents"],
    hasNext: json["hasNext"],
    hasPrev: json["hasPrev"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalParents": totalParents,
    "hasNext": hasNext,
    "hasPrev": hasPrev,
  };
}

class Parent {
  ParentPersonalInfo? personalInfo;
  ContactInfo? contactInfo;
  ProfessionalInfo? professionalInfo;
  Preferences? preferences;
  String? id;
  User? user;
  List<Child>? children;
  List<dynamic>? emergencyContacts;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  String? parentId;

  Parent({
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
    this.parentId,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : ParentPersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : ContactInfo.fromJson(json["contactInfo"]),
    professionalInfo:
        json["professionalInfo"] == null
            ? null
            : ProfessionalInfo.fromJson(json["professionalInfo"]),
    preferences:
        json["preferences"] == null
            ? null
            : Preferences.fromJson(json["preferences"]),
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
    children:
        json["children"] == null
            ? []
            : List<Child>.from(json["children"]!.map((x) => Child.fromJson(x))),
    emergencyContacts:
        json["emergencyContacts"] == null
            ? []
            : List<dynamic>.from(json["emergencyContacts"]!.map((x) => x)),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    parentId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "professionalInfo": professionalInfo?.toJson(),
    "preferences": preferences?.toJson(),
    "_id": id,
    "user": user?.toJson(),
    "children":
        children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
    "emergencyContacts":
        emergencyContacts == null
            ? []
            : List<dynamic>.from(emergencyContacts!.map((x) => x)),
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "id": parentId,
  };
}

class Child {
  ChildPersonalInfo? personalInfo;
  AcademicInfo? academicInfo;
  String? id;
  String? admissionNumber;
  dynamic age;
  String? childId;

  Child({
    this.personalInfo,
    this.academicInfo,
    this.id,
    this.admissionNumber,
    this.age,
    this.childId,
  });

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    personalInfo:
        json["personalInfo"] == null
            ? null
            : ChildPersonalInfo.fromJson(json["personalInfo"]),
    academicInfo:
        json["academicInfo"] == null
            ? null
            : AcademicInfo.fromJson(json["academicInfo"]),
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    admissionNumber:
        json["admissionNumber"] is String
            ? json["admissionNumber"]
            : json["admissionNumber"]?.toString(),
    age: json["age"],
    childId: json["id"] is String ? json["id"] : json["id"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "personalInfo": personalInfo?.toJson(),
    "academicInfo": academicInfo?.toJson(),
    "_id": id,
    "admissionNumber": admissionNumber,
    "age": age,
    "id": childId,
  };
}

class AcademicInfo {
  CurrentClass? currentClass;

  AcademicInfo({this.currentClass});

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
    currentClass:
        json["currentClass"] != null && json["currentClass"] is String
            ? currentClassValues.map[json["currentClass"]]
            : null,
  );

  Map<String, dynamic> toJson() => {
    "currentClass": currentClassValues.reverse[currentClass],
  };
}

enum CurrentClass {
  THE_68_C1_BC41_BD5_E0_B3115_DF680_D,
  THE_68_C3_E24_F0_EBD0_DCCA8_AE7197,
}

final currentClassValues = EnumValues({
  "68c1bc41bd5e0b3115df680d": CurrentClass.THE_68_C1_BC41_BD5_E0_B3115_DF680_D,
  "68c3e24f0ebd0dcca8ae7197": CurrentClass.THE_68_C3_E24_F0_EBD0_DCCA8_AE7197,
});

class ChildPersonalInfo {
  String? firstName;
  String? lastName;

  ChildPersonalInfo({this.firstName, this.lastName});

  factory ChildPersonalInfo.fromJson(Map<String, dynamic> json) =>
      ChildPersonalInfo(
        firstName:
            json["firstName"] is String
                ? json["firstName"]
                : json["firstName"]?.toString(),
        lastName:
            json["lastName"] is String
                ? json["lastName"]
                : json["lastName"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "lastName": lastName,
  };
}

class ContactInfo {
  Address? address;
  String? primaryPhone;
  String? email;

  ContactInfo({this.address, this.primaryPhone, this.email});

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    primaryPhone:
        json["primaryPhone"] is String
            ? json["primaryPhone"]
            : json["primaryPhone"]?.toString(),
    email: json["email"] is String ? json["email"] : json["email"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "address": address?.toJson(),
    "primaryPhone": primaryPhone,
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
    street:
        json["street"] is String ? json["street"] : json["street"]?.toString(),
    city: json["city"] is String ? json["city"] : json["city"]?.toString(),
    state: json["state"] is String ? json["state"] : json["state"]?.toString(),
    country:
        json["country"] is String
            ? json["country"]
            : json["country"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "street": street,
    "city": city,
    "state": state,
    "country": country,
  };
}

class ParentPersonalInfo {
  Title? title;
  String? firstName;
  String? lastName;
  String? middleName;
  DateTime? dateOfBirth;
  Gender? gender;
  String? maritalStatus;

  ParentPersonalInfo({
    this.title,
    this.firstName,
    this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
  });

  factory ParentPersonalInfo.fromJson(Map<String, dynamic> json) =>
      ParentPersonalInfo(
        title:
            json["title"] != null && json["title"] is String
                ? titleValues.map[json["title"]]
                : null,
        firstName:
            json["firstName"] is String
                ? json["firstName"]
                : json["firstName"]?.toString(),
        lastName:
            json["lastName"] is String
                ? json["lastName"]
                : json["lastName"]?.toString(),
        middleName:
            json["middleName"] is String
                ? json["middleName"]
                : json["middleName"]?.toString(),
        dateOfBirth:
            json["dateOfBirth"] == null
                ? null
                : DateTime.parse(json["dateOfBirth"]),
        gender:
            json["gender"] != null && json["gender"] is String
                ? genderValues.map[json["gender"]]
                : null,
        maritalStatus:
            json["maritalStatus"] is String
                ? json["maritalStatus"]
                : json["maritalStatus"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
    "title": titleValues.reverse[title],
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "gender": genderValues.reverse[gender],
    "maritalStatus": maritalStatus,
  };
}

enum Gender { FEMALE, MALE }

final genderValues = EnumValues({"female": Gender.FEMALE, "male": Gender.MALE});

enum Title { MR, MRS }

final titleValues = EnumValues({"Mr": Title.MR, "Mrs": Title.MRS});

class Preferences {
  PreferredContactMethod? preferredContactMethod;
  bool? receiveNewsletters;
  bool? receiveEventNotifications;

  Preferences({
    this.preferredContactMethod,
    this.receiveNewsletters,
    this.receiveEventNotifications,
  });

  factory Preferences.fromJson(Map<String, dynamic> json) => Preferences(
    preferredContactMethod:
        json["preferredContactMethod"] != null &&
                json["preferredContactMethod"] is String
            ? preferredContactMethodValues.map[json["preferredContactMethod"]]
            : null,
    receiveNewsletters: json["receiveNewsletters"],
    receiveEventNotifications: json["receiveEventNotifications"],
  );

  Map<String, dynamic> toJson() => {
    "preferredContactMethod":
        preferredContactMethodValues.reverse[preferredContactMethod],
    "receiveNewsletters": receiveNewsletters,
    "receiveEventNotifications": receiveEventNotifications,
  };
}

enum PreferredContactMethod { EMAIL }

final preferredContactMethodValues = EnumValues({
  "email": PreferredContactMethod.EMAIL,
});

class ProfessionalInfo {
  String? occupation;
  String? employer;
  int? annualIncome;
  Address? workAddress;
  String? workPhone;

  ProfessionalInfo({
    this.occupation,
    this.employer,
    this.annualIncome,
    this.workAddress,
    this.workPhone,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) =>
      ProfessionalInfo(
        occupation:
            json["occupation"] is String
                ? json["occupation"]
                : json["occupation"]?.toString(),
        employer:
            json["employer"] is String
                ? json["employer"]
                : json["employer"]?.toString(),
        annualIncome: json["annualIncome"],
        workAddress:
            json["workAddress"] == null
                ? null
                : Address.fromJson(json["workAddress"]),
        workPhone: json["workPhone"],
      );

  Map<String, dynamic> toJson() => {
    "occupation": occupation,
    "employer": employer,
    "annualIncome": annualIncome,
    "workAddress": workAddress?.toJson(),
    "workPhone": workPhone,
  };
}

class User {
  String? id;
  String? email;
  bool? isActive;

  User({this.id, this.email, this.isActive});

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    email: json["email"] is String ? json["email"] : json["email"]?.toString(),
    isActive: json["isActive"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "email": email,
    "isActive": isActive,
  };
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
