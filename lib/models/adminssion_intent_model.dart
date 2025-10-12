// To parse this JSON data, do
//
//     final admissionIntentModel = admissionIntentModelFromJson(jsonString);

import 'dart:convert';

AdmissionIntentModel admissionIntentModelFromJson(String str) =>
    AdmissionIntentModel.fromJson(json.decode(str));

String admissionIntentModelToJson(AdmissionIntentModel data) =>
    json.encode(data.toJson());

class AdmissionIntentModel {
  bool? success;
  Data? data;

  AdmissionIntentModel({this.success, this.data});

  factory AdmissionIntentModel.fromJson(Map<String, dynamic> json) =>
      AdmissionIntentModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  List<Admission>? admissions;
  Pagination? pagination;

  Data({this.admissions, this.pagination});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    admissions:
        json["admissions"] == null
            ? []
            : List<Admission>.from(
              json["admissions"]!.map((x) => Admission.fromJson(x)),
            ),
    pagination:
        json["pagination"] == null
            ? null
            : Pagination.fromJson(json["pagination"]),
  );

  Map<String, dynamic> toJson() => {
    "admissions":
        admissions == null
            ? []
            : List<dynamic>.from(admissions!.map((x) => x.toJson())),
    "pagination": pagination?.toJson(),
  };
}

class Admission {
  String? id;
  PersonalInfo? personalInfo;
  ContactInfo? contactInfo;
  AcademicInfo? academicInfo;
  ParentInfo? parentInfo;
  MedicalInfo? medicalInfo;
  SenInfo? senInfo;
  Permissions? permissions;
  SessionInfo? sessionInfo;
  BackgroundInfo? backgroundInfo;
  LegalInfo? legalInfo;
  FundingInfo? fundingInfo;
  FinancialInfo? financialInfo;
  String? status;
  ReviewInfo? reviewInfo;
  AdmissionInfo? admissionInfo;
  String? additionalInfo;
  DateTime? submittedAt;
  String? submittedBy;
  DateTime? createdAt;
  DateTime? updatedAt;

  Admission({
    this.id,
    this.personalInfo,
    this.contactInfo,
    this.academicInfo,
    this.parentInfo,
    this.medicalInfo,
    this.senInfo,
    this.permissions,
    this.sessionInfo,
    this.backgroundInfo,
    this.legalInfo,
    this.fundingInfo,
    this.financialInfo,
    this.status,
    this.reviewInfo,
    this.admissionInfo,
    this.additionalInfo,
    this.submittedAt,
    this.submittedBy,
    this.createdAt,
    this.updatedAt,
  });

  factory Admission.fromJson(Map<String, dynamic> json) => Admission(
    id: json["_id"],
    personalInfo:
        json["personalInfo"] == null
            ? null
            : PersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : ContactInfo.fromJson(json["contactInfo"]),
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
    senInfo: json["senInfo"] == null ? null : SenInfo.fromJson(json["senInfo"]),
    permissions:
        json["permissions"] == null
            ? null
            : Permissions.fromJson(json["permissions"]),
    sessionInfo:
        json["sessionInfo"] == null
            ? null
            : SessionInfo.fromJson(json["sessionInfo"]),
    backgroundInfo:
        json["backgroundInfo"] == null
            ? null
            : BackgroundInfo.fromJson(json["backgroundInfo"]),
    legalInfo:
        json["legalInfo"] == null
            ? null
            : LegalInfo.fromJson(json["legalInfo"]),
    fundingInfo:
        json["fundingInfo"] == null
            ? null
            : FundingInfo.fromJson(json["fundingInfo"]),
    financialInfo:
        json["financialInfo"] == null
            ? null
            : FinancialInfo.fromJson(json["financialInfo"]),
    status: json["status"],
    reviewInfo:
        json["reviewInfo"] == null
            ? null
            : ReviewInfo.fromJson(json["reviewInfo"]),
    admissionInfo:
        json["admissionInfo"] == null
            ? null
            : AdmissionInfo.fromJson(json["admissionInfo"]),
    additionalInfo: json["additionalInfo"],
    submittedAt:
        json["submittedAt"] == null
            ? null
            : DateTime.parse(json["submittedAt"]),
    submittedBy: json["submittedBy"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "academicInfo": academicInfo?.toJson(),
    "parentInfo": parentInfo?.toJson(),
    "medicalInfo": medicalInfo?.toJson(),
    "senInfo": senInfo?.toJson(),
    "permissions": permissions?.toJson(),
    "sessionInfo": sessionInfo?.toJson(),
    "backgroundInfo": backgroundInfo?.toJson(),
    "legalInfo": legalInfo?.toJson(),
    "fundingInfo": fundingInfo?.toJson(),
    "financialInfo": financialInfo?.toJson(),
    "status": status,
    "reviewInfo": reviewInfo?.toJson(),
    "admissionInfo": admissionInfo?.toJson(),
    "additionalInfo": additionalInfo,
    "submittedAt": submittedAt?.toIso8601String(),
    "submittedBy": submittedBy,
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
  };
}

class AcademicInfo {
  DesiredClass? desiredClass;
  String? academicYear;
  DateTime? admissionDate;
  String? studentType;

  AcademicInfo({
    this.desiredClass,
    this.academicYear,
    this.admissionDate,
    this.studentType,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) => AcademicInfo(
    desiredClass:
        json["desiredClass"] == null
            ? null
            : DesiredClass.fromJson(json["desiredClass"]),
    academicYear: json["academicYear"],
    admissionDate:
        json["admissionDate"] == null
            ? null
            : DateTime.parse(json["admissionDate"]),
    studentType: json["studentType"],
  );

  Map<String, dynamic> toJson() => {
    "desiredClass": desiredClass?.toJson(),
    "academicYear": academicYear,
    "admissionDate": admissionDate?.toIso8601String(),
    "studentType": studentType,
  };
}

class DesiredClass {
  String? id;
  String? name;
  String? level;
  String? section;
  int? capacity;

  DesiredClass({this.id, this.name, this.level, this.section, this.capacity});

  factory DesiredClass.fromJson(Map<String, dynamic> json) => DesiredClass(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    section: json["section"],
    capacity: json["capacity"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "section": section,
    "capacity": capacity,
  };
}

class AdmissionInfo {
  dynamic admittedBy;
  dynamic admittedAt;
  String? admissionNumber;
  dynamic studentId;

  AdmissionInfo({
    this.admittedBy,
    this.admittedAt,
    this.admissionNumber,
    this.studentId,
  });

  factory AdmissionInfo.fromJson(Map<String, dynamic> json) => AdmissionInfo(
    admittedBy: json["admittedBy"],
    admittedAt: json["admittedAt"],
    admissionNumber: json["admissionNumber"],
    studentId: json["studentId"],
  );

  Map<String, dynamic> toJson() => {
    "admittedBy": admittedBy,
    "admittedAt": admittedAt,
    "admissionNumber": admissionNumber,
    "studentId": studentId,
  };
}

class BackgroundInfo {
  String? previousChildcareProvider;
  List<Sibling>? siblings;
  String? interests;
  String? toiletTrainingStatus;
  String? comfortItems;
  String? sleepRoutine;
  String? behaviouralConcerns;
  String? languagesSpokenAtHome;

  BackgroundInfo({
    this.previousChildcareProvider,
    this.siblings,
    this.interests,
    this.toiletTrainingStatus,
    this.comfortItems,
    this.sleepRoutine,
    this.behaviouralConcerns,
    this.languagesSpokenAtHome,
  });

  factory BackgroundInfo.fromJson(Map<String, dynamic> json) => BackgroundInfo(
    previousChildcareProvider: json["previousChildcareProvider"],
    siblings:
        json["siblings"] == null
            ? []
            : List<Sibling>.from(
              json["siblings"]!.map((x) => Sibling.fromJson(x)),
            ),
    interests: json["interests"],
    toiletTrainingStatus: json["toiletTrainingStatus"],
    comfortItems: json["comfortItems"],
    sleepRoutine: json["sleepRoutine"],
    behaviouralConcerns: json["behaviouralConcerns"],
    languagesSpokenAtHome: json["languagesSpokenAtHome"],
  );

  Map<String, dynamic> toJson() => {
    "previousChildcareProvider": previousChildcareProvider,
    "siblings":
        siblings == null
            ? []
            : List<dynamic>.from(siblings!.map((x) => x.toJson())),
    "interests": interests,
    "toiletTrainingStatus": toiletTrainingStatus,
    "comfortItems": comfortItems,
    "sleepRoutine": sleepRoutine,
    "behaviouralConcerns": behaviouralConcerns,
    "languagesSpokenAtHome": languagesSpokenAtHome,
  };
}

class Sibling {
  String? name;
  int? age;

  Sibling({this.name, this.age});

  factory Sibling.fromJson(Map<String, dynamic> json) =>
      Sibling(name: json["name"], age: json["age"]);

  Map<String, dynamic> toJson() => {"name": name, "age": age};
}

class ContactInfo {
  Address? address;
  String? phone;
  String? email;

  ContactInfo({this.address, this.phone, this.email});

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
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
  String? streetNumber;
  String? streetName;
  String? city;
  String? state;
  String? country;
  String? postalCode;

  Address({
    this.streetNumber,
    this.streetName,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) => Address(
    streetNumber: json["streetNumber"],
    streetName: json["streetName"],
    city: json["city"],
    state: json["state"],
    country: json["country"],
    postalCode: json["postalCode"],
  );

  Map<String, dynamic> toJson() => {
    "streetNumber": streetNumber,
    "streetName": streetName,
    "city": city,
    "state": state,
    "country": country,
    "postalCode": postalCode,
  };
}

class FinancialInfo {
  String? feeStatus;
  int? totalFees;
  int? paidAmount;
  int? outstandingBalance;

  FinancialInfo({
    this.feeStatus,
    this.totalFees,
    this.paidAmount,
    this.outstandingBalance,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) => FinancialInfo(
    feeStatus: json["feeStatus"],
    totalFees: json["totalFees"],
    paidAmount: json["paidAmount"],
    outstandingBalance: json["outstandingBalance"],
  );

  Map<String, dynamic> toJson() => {
    "feeStatus": feeStatus,
    "totalFees": totalFees,
    "paidAmount": paidAmount,
    "outstandingBalance": outstandingBalance,
  };
}

class FundingInfo {
  bool? agreementToPayFees;
  String? fundingAgreement;

  FundingInfo({this.agreementToPayFees, this.fundingAgreement});

  factory FundingInfo.fromJson(Map<String, dynamic> json) => FundingInfo(
    agreementToPayFees: json["agreementToPayFees"],
    fundingAgreement: json["fundingAgreement"],
  );

  Map<String, dynamic> toJson() => {
    "agreementToPayFees": agreementToPayFees,
    "fundingAgreement": fundingAgreement,
  };
}

class LegalInfo {
  String? legalResponsibility;
  String? courtOrders;
  String? safeguardingDisclosure;
  String? parentSignature;
  DateTime? signatureDate;

  LegalInfo({
    this.legalResponsibility,
    this.courtOrders,
    this.safeguardingDisclosure,
    this.parentSignature,
    this.signatureDate,
  });

  factory LegalInfo.fromJson(Map<String, dynamic> json) => LegalInfo(
    legalResponsibility: json["legalResponsibility"],
    courtOrders: json["courtOrders"],
    safeguardingDisclosure: json["safeguardingDisclosure"],
    parentSignature: json["parentSignature"],
    signatureDate:
        json["signatureDate"] == null
            ? null
            : DateTime.parse(json["signatureDate"]),
  );

  Map<String, dynamic> toJson() => {
    "legalResponsibility": legalResponsibility,
    "courtOrders": courtOrders,
    "safeguardingDisclosure": safeguardingDisclosure,
    "parentSignature": parentSignature,
    "signatureDate": signatureDate?.toIso8601String(),
  };
}

class MedicalInfo {
  GeneralPractitioner? generalPractitioner;
  String? medicalHistory;
  List<String>? allergies;
  String? ongoingMedicalConditions;
  String? specialNeeds;
  String? currentMedication;
  String? immunisationRecord;
  String? dietaryRequirements;
  EmergencyContact? emergencyContact;

  MedicalInfo({
    this.generalPractitioner,
    this.medicalHistory,
    this.allergies,
    this.ongoingMedicalConditions,
    this.specialNeeds,
    this.currentMedication,
    this.immunisationRecord,
    this.dietaryRequirements,
    this.emergencyContact,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) => MedicalInfo(
    generalPractitioner:
        json["generalPractitioner"] == null
            ? null
            : GeneralPractitioner.fromJson(json["generalPractitioner"]),
    medicalHistory: json["medicalHistory"],
    allergies:
        json["allergies"] == null
            ? []
            : List<String>.from(json["allergies"]!.map((x) => x)),
    ongoingMedicalConditions: json["ongoingMedicalConditions"],
    specialNeeds: json["specialNeeds"],
    currentMedication: json["currentMedication"],
    immunisationRecord: json["immunisationRecord"],
    dietaryRequirements: json["dietaryRequirements"],
    emergencyContact:
        json["emergencyContact"] == null
            ? null
            : EmergencyContact.fromJson(json["emergencyContact"]),
  );

  Map<String, dynamic> toJson() => {
    "generalPractitioner": generalPractitioner?.toJson(),
    "medicalHistory": medicalHistory,
    "allergies":
        allergies == null ? [] : List<dynamic>.from(allergies!.map((x) => x)),
    "ongoingMedicalConditions": ongoingMedicalConditions,
    "specialNeeds": specialNeeds,
    "currentMedication": currentMedication,
    "immunisationRecord": immunisationRecord,
    "dietaryRequirements": dietaryRequirements,
    "emergencyContact": emergencyContact?.toJson(),
  };
}

class EmergencyContact {
  String? name;
  String? relationship;
  String? phone;
  String? email;
  Address? address;
  bool? authorisedToCollectChild;

  EmergencyContact({
    this.name,
    this.relationship,
    this.phone,
    this.email,
    this.address,
    this.authorisedToCollectChild,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) =>
      EmergencyContact(
        name: json["name"],
        relationship: json["relationship"],
        phone: json["phone"],
        email: json["email"],
        address:
            json["address"] == null ? null : Address.fromJson(json["address"]),
        authorisedToCollectChild: json["authorisedToCollectChild"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "relationship": relationship,
    "phone": phone,
    "email": email,
    "address": address?.toJson(),
    "authorisedToCollectChild": authorisedToCollectChild,
  };
}

class GeneralPractitioner {
  String? name;
  String? address;
  String? telephoneNumber;

  GeneralPractitioner({this.name, this.address, this.telephoneNumber});

  factory GeneralPractitioner.fromJson(Map<String, dynamic> json) =>
      GeneralPractitioner(
        name: json["name"],
        address: json["address"],
        telephoneNumber: json["telephoneNumber"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "address": address,
    "telephoneNumber": telephoneNumber,
  };
}

class ParentInfo {
  dynamic father;
  dynamic mother;
  dynamic guardian;
  Legacy? legacy;

  ParentInfo({this.father, this.mother, this.guardian, this.legacy});

  factory ParentInfo.fromJson(Map<String, dynamic> json) => ParentInfo(
    father: json["father"],
    mother: json["mother"],
    guardian: json["guardian"],
    legacy: json["legacy"] == null ? null : Legacy.fromJson(json["legacy"]),
  );

  Map<String, dynamic> toJson() => {
    "father": father,
    "mother": mother,
    "guardian": guardian,
    "legacy": legacy?.toJson(),
  };
}

class Legacy {
  String? name;
  String? phone;
  String? email;
  String? occupation;
  String? address;

  Legacy({this.name, this.phone, this.email, this.occupation, this.address});

  factory Legacy.fromJson(Map<String, dynamic> json) => Legacy(
    name: json["name"],
    phone: json["phone"],
    email: json["email"],
    occupation: json["occupation"],
    address: json["address"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "phone": phone,
    "email": email,
    "occupation": occupation,
    "address": address,
  };
}

class Permissions {
  bool? emergencyMedicalTreatment;
  bool? administrationOfMedication;
  bool? firstAidConsent;
  bool? outingsAndTrips;
  bool? transportConsent;
  bool? useOfPhotosVideos;
  bool? suncreamApplication;
  bool? observationAndAssessment;

  Permissions({
    this.emergencyMedicalTreatment,
    this.administrationOfMedication,
    this.firstAidConsent,
    this.outingsAndTrips,
    this.transportConsent,
    this.useOfPhotosVideos,
    this.suncreamApplication,
    this.observationAndAssessment,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) => Permissions(
    emergencyMedicalTreatment: json["emergencyMedicalTreatment"],
    administrationOfMedication: json["administrationOfMedication"],
    firstAidConsent: json["firstAidConsent"],
    outingsAndTrips: json["outingsAndTrips"],
    transportConsent: json["transportConsent"],
    useOfPhotosVideos: json["useOfPhotosVideos"],
    suncreamApplication: json["suncreamApplication"],
    observationAndAssessment: json["observationAndAssessment"],
  );

  Map<String, dynamic> toJson() => {
    "emergencyMedicalTreatment": emergencyMedicalTreatment,
    "administrationOfMedication": administrationOfMedication,
    "firstAidConsent": firstAidConsent,
    "outingsAndTrips": outingsAndTrips,
    "transportConsent": transportConsent,
    "useOfPhotosVideos": useOfPhotosVideos,
    "suncreamApplication": suncreamApplication,
    "observationAndAssessment": observationAndAssessment,
  };
}

class PersonalInfo {
  String? firstName;
  String? middleName;
  String? lastName;
  DateTime? dateOfBirth;
  String? gender;
  String? nationality;
  String? stateOfOrigin;
  String? localGovernment;
  String? religion;
  String? bloodGroup;
  String? languagesSpokenAtHome;
  String? ethnicBackground;
  String? formOfIdentification;
  String? idNumber;
  String? idPhoto;
  bool? hasSiblings;
  List<SiblingDetail>? siblingDetails;
  String? profileImage;
  String? passportPhoto;
  String? previousSchool;
  int? age;

  PersonalInfo({
    this.firstName,
    this.middleName,
    this.lastName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.stateOfOrigin,
    this.localGovernment,
    this.religion,
    this.bloodGroup,
    this.languagesSpokenAtHome,
    this.ethnicBackground,
    this.formOfIdentification,
    this.idNumber,
    this.idPhoto,
    this.hasSiblings,
    this.siblingDetails,
    this.profileImage,
    this.passportPhoto,
    this.previousSchool,
    this.age,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    firstName: json["firstName"],
    middleName: json["middleName"],
    lastName: json["lastName"],
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
    languagesSpokenAtHome: json["languagesSpokenAtHome"],
    ethnicBackground: json["ethnicBackground"],
    formOfIdentification: json["formOfIdentification"],
    idNumber: json["idNumber"],
    idPhoto: json["idPhoto"],
    hasSiblings: json["hasSiblings"],
    siblingDetails:
        json["siblingDetails"] == null
            ? []
            : List<SiblingDetail>.from(
              json["siblingDetails"]!.map((x) => SiblingDetail.fromJson(x)),
            ),
    profileImage: json["profileImage"],
    passportPhoto: json["passportPhoto"],
    previousSchool: json["previousSchool"],
    age: json["age"],
  );

  Map<String, dynamic> toJson() => {
    "firstName": firstName,
    "middleName": middleName,
    "lastName": lastName,
    "dateOfBirth": dateOfBirth?.toIso8601String(),
    "gender": gender,
    "nationality": nationality,
    "stateOfOrigin": stateOfOrigin,
    "localGovernment": localGovernment,
    "religion": religion,
    "bloodGroup": bloodGroup,
    "languagesSpokenAtHome": languagesSpokenAtHome,
    "ethnicBackground": ethnicBackground,
    "formOfIdentification": formOfIdentification,
    "idNumber": idNumber,
    "idPhoto": idPhoto,
    "hasSiblings": hasSiblings,
    "siblingDetails":
        siblingDetails == null
            ? []
            : List<dynamic>.from(siblingDetails!.map((x) => x.toJson())),
    "profileImage": profileImage,
    "passportPhoto": passportPhoto,
    "previousSchool": previousSchool,
    "age": age,
  };
}

class SiblingDetail {
  String? name;
  int? age;
  String? relationship;

  SiblingDetail({this.name, this.age, this.relationship});

  factory SiblingDetail.fromJson(Map<String, dynamic> json) => SiblingDetail(
    name: json["name"],
    age: json["age"],
    relationship: json["relationship"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "age": age,
    "relationship": relationship,
  };
}

class ReviewInfo {
  ReviewedBy? reviewedBy;
  DateTime? reviewedAt;
  String? reviewNotes;
  String? rejectionReason;

  ReviewInfo({
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.rejectionReason,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) => ReviewInfo(
    reviewedBy:
        json["reviewedBy"] == null
            ? null
            : ReviewedBy.fromJson(json["reviewedBy"]),
    reviewedAt:
        json["reviewedAt"] == null ? null : DateTime.parse(json["reviewedAt"]),
    reviewNotes: json["reviewNotes"],
    rejectionReason: json["rejectionReason"],
  );

  Map<String, dynamic> toJson() => {
    "reviewedBy": reviewedBy?.toJson(),
    "reviewedAt": reviewedAt?.toIso8601String(),
    "reviewNotes": reviewNotes,
    "rejectionReason": rejectionReason,
  };
}

class ReviewedBy {
  String? id;
  String? firstName;
  String? lastName;
  String? email;

  ReviewedBy({this.id, this.firstName, this.lastName, this.email});

  factory ReviewedBy.fromJson(Map<String, dynamic> json) => ReviewedBy(
    id: json["_id"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    email: json["email"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "firstName": firstName,
    "lastName": lastName,
    "email": email,
  };
}

class SenInfo {
  bool? hasSpecialNeeds;
  bool? receivingAdditionalSupport;
  String? supportDetails;
  bool? hasEhcp;
  String? ehcpDetails;

  SenInfo({
    this.hasSpecialNeeds,
    this.receivingAdditionalSupport,
    this.supportDetails,
    this.hasEhcp,
    this.ehcpDetails,
  });

  factory SenInfo.fromJson(Map<String, dynamic> json) => SenInfo(
    hasSpecialNeeds: json["hasSpecialNeeds"],
    receivingAdditionalSupport: json["receivingAdditionalSupport"],
    supportDetails: json["supportDetails"],
    hasEhcp: json["hasEHCP"],
    ehcpDetails: json["ehcpDetails"],
  );

  Map<String, dynamic> toJson() => {
    "hasSpecialNeeds": hasSpecialNeeds,
    "receivingAdditionalSupport": receivingAdditionalSupport,
    "supportDetails": supportDetails,
    "hasEHCP": hasEhcp,
    "ehcpDetails": ehcpDetails,
  };
}

class SessionInfo {
  DateTime? requestedStartDate;
  String? daysOfAttendance;
  String? fundedHours;
  String? additionalPaidSessions;
  String? preferredSettlingInSessions;

  SessionInfo({
    this.requestedStartDate,
    this.daysOfAttendance,
    this.fundedHours,
    this.additionalPaidSessions,
    this.preferredSettlingInSessions,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) => SessionInfo(
    requestedStartDate:
        json["requestedStartDate"] == null
            ? null
            : DateTime.parse(json["requestedStartDate"]),
    daysOfAttendance: json["daysOfAttendance"],
    fundedHours: json["fundedHours"],
    additionalPaidSessions: json["additionalPaidSessions"],
    preferredSettlingInSessions: json["preferredSettlingInSessions"],
  );

  Map<String, dynamic> toJson() => {
    "requestedStartDate": requestedStartDate?.toIso8601String(),
    "daysOfAttendance": daysOfAttendance,
    "fundedHours": fundedHours,
    "additionalPaidSessions": additionalPaidSessions,
    "preferredSettlingInSessions": preferredSettlingInSessions,
  };
}

class Pagination {
  int? currentPage;
  int? totalPages;
  int? totalCount;
  bool? hasNextPage;
  bool? hasPrevPage;
  int? limit;

  Pagination({
    this.currentPage,
    this.totalPages,
    this.totalCount,
    this.hasNextPage,
    this.hasPrevPage,
    this.limit,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) => Pagination(
    currentPage: json["currentPage"],
    totalPages: json["totalPages"],
    totalCount: json["totalCount"],
    hasNextPage: json["hasNextPage"],
    hasPrevPage: json["hasPrevPage"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "currentPage": currentPage,
    "totalPages": totalPages,
    "totalCount": totalCount,
    "hasNextPage": hasNextPage,
    "hasPrevPage": hasPrevPage,
    "limit": limit,
  };
}
