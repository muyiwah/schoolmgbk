import 'dart:convert';

ParentLoginResponse parentLoginResponseFromJson(String str) =>
    ParentLoginResponse.fromJson(json.decode(str));

String parentLoginResponseToJson(ParentLoginResponse data) =>
    json.encode(data.toJson());

class ParentLoginResponse {
  bool? success;
  String? message;
  ParentData? data;

  ParentLoginResponse({this.success, this.message, this.data});

  factory ParentLoginResponse.fromJson(Map<String, dynamic> json) =>
      ParentLoginResponse(
        success: json["success"],
        message: json["message"],
        data: json["data"] == null ? null : ParentData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ParentData {
  Parent? parent;
  List<Child>? children;
  List<dynamic>? communications;
  FinancialSummary? financialSummary;
  CurrentTerm? currentTerm;

  ParentData({
    this.parent,
    this.children,
    this.communications,
    this.financialSummary,
    this.currentTerm,
  });

  factory ParentData.fromJson(Map<String, dynamic> json) => ParentData(
    parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
    children:
        json["children"] == null
            ? []
            : List<Child>.from(json["children"]!.map((x) => Child.fromJson(x))),
    communications:
        json["communications"] == null
            ? []
            : List<dynamic>.from(json["communications"]!.map((x) => x)),
    financialSummary:
        json["financialSummary"] == null
            ? null
            : FinancialSummary.fromJson(json["financialSummary"]),
    currentTerm:
        json["currentTerm"] == null
            ? null
            : CurrentTerm.fromJson(json["currentTerm"]),
  );

  Map<String, dynamic> toJson() => {
    "parent": parent?.toJson(),
    "children":
        children == null
            ? []
            : List<dynamic>.from(children!.map((x) => x.toJson())),
    "communications": communications,
    "financialSummary": financialSummary?.toJson(),
    "currentTerm": currentTerm?.toJson(),
  };
}

class Parent {
  String? id;
  PersonalInfo? personalInfo;
  ContactInfo? contactInfo;
  ProfessionalInfo? professionalInfo;
  User? user;

  Parent({
    this.id,
    this.personalInfo,
    this.contactInfo,
    this.professionalInfo,
    this.user,
  });

  factory Parent.fromJson(Map<String, dynamic> json) => Parent(
    id: json["_id"],
    personalInfo:
        json["personalInfo"] == null
            ? null
            : PersonalInfo.fromJson(json["personalInfo"]),
    contactInfo:
        json["contactInfo"] == null
            ? null
            : ContactInfo.fromJson(json["contactInfo"]),
    professionalInfo:
        json["professionalInfo"] == null
            ? null
            : ProfessionalInfo.fromJson(json["professionalInfo"]),
    user: json["user"] == null ? null : User.fromJson(json["user"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "professionalInfo": professionalInfo?.toJson(),
    "user": user?.toJson(),
  };
}

class PersonalInfo {
  String? title;
  String? firstName;
  String? lastName;
  String? middleName;
  String? dateOfBirth;
  String? gender;
  String? maritalStatus;

  PersonalInfo({
    this.title,
    this.firstName,
    this.lastName,
    this.middleName,
    this.dateOfBirth,
    this.gender,
    this.maritalStatus,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) => PersonalInfo(
    title: json["title"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    middleName: json["middleName"],
    dateOfBirth: json["dateOfBirth"],
    gender: json["gender"],
    maritalStatus: json["maritalStatus"],
  );

  Map<String, dynamic> toJson() => {
    "title": title,
    "firstName": firstName,
    "lastName": lastName,
    "middleName": middleName,
    "dateOfBirth": dateOfBirth,
    "gender": gender,
    "maritalStatus": maritalStatus,
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

class ProfessionalInfo {
  WorkAddress? workAddress;
  String? occupation;
  String? employer;
  String? workPhone;
  int? annualIncome;

  ProfessionalInfo({
    this.workAddress,
    this.occupation,
    this.employer,
    this.workPhone,
    this.annualIncome,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) =>
      ProfessionalInfo(
        workAddress:
            json["workAddress"] == null
                ? null
                : WorkAddress.fromJson(json["workAddress"]),
        occupation: json["occupation"],
        employer: json["employer"],
        workPhone: json["workPhone"],
        annualIncome: json["annualIncome"],
      );

  Map<String, dynamic> toJson() => {
    "workAddress": workAddress?.toJson(),
    "occupation": occupation,
    "employer": employer,
    "workPhone": workPhone,
    "annualIncome": annualIncome,
  };
}

class WorkAddress {
  String? streetNumber;
  String? streetName;
  String? city;
  String? state;
  String? country;
  String? postalCode;

  WorkAddress({
    this.streetNumber,
    this.streetName,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory WorkAddress.fromJson(Map<String, dynamic> json) => WorkAddress(
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

class User {
  String? id;
  String? email;
  String? firstName;
  String? lastName;
  String? fullName;
  String? role;
  bool? isActive;
  String? lastLogin;

  User({
    this.id,
    this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    this.role,
    this.isActive,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"] ?? json["_id"],
    email: json["email"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    role: json["role"],
    isActive: json["isActive"],
    lastLogin: json["lastLogin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "role": role,
    "isActive": isActive,
    "lastLogin": lastLogin,
  };
}

class Child {
  Student? student;
  CurrentTerm? currentTerm;
  List<dynamic>? paymentHistory;

  Child({this.student, this.currentTerm, this.paymentHistory});

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    student: json["student"] == null ? null : Student.fromJson(json["student"]),
    currentTerm:
        json["currentTerm"] == null
            ? null
            : CurrentTerm.fromJson(json["currentTerm"]),
    paymentHistory:
        json["paymentHistory"] == null
            ? []
            : List<dynamic>.from(json["paymentHistory"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "student": student?.toJson(),
    "currentTerm": currentTerm?.toJson(),
    "paymentHistory": paymentHistory,
  };
}

class Student {
  String? id;
  String? admissionNumber;
  PersonalInfo? personalInfo;
  AcademicInfo? academicInfo;
  FinancialInfo? financialInfo;

  Student({
    this.id,
    this.admissionNumber,
    this.personalInfo,
    this.academicInfo,
    this.financialInfo,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
    id: json["_id"],
    admissionNumber: json["admissionNumber"],
    personalInfo:
        json["personalInfo"] == null
            ? null
            : PersonalInfo.fromJson(json["personalInfo"]),
    academicInfo:
        json["academicInfo"] == null
            ? null
            : AcademicInfo.fromJson(json["academicInfo"]),
    financialInfo:
        json["financialInfo"] == null
            ? null
            : FinancialInfo.fromJson(json["financialInfo"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "admissionNumber": admissionNumber,
    "personalInfo": personalInfo?.toJson(),
    "academicInfo": academicInfo?.toJson(),
    "financialInfo": financialInfo?.toJson(),
  };
}

class AcademicInfo {
  CurrentClass? currentClass;
  String? academicYear;
  String? admissionDate;
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
    admissionDate: json["admissionDate"],
    studentType: json["studentType"],
  );

  Map<String, dynamic> toJson() => {
    "currentClass": currentClass?.toJson(),
    "academicYear": academicYear,
    "admissionDate": admissionDate,
    "studentType": studentType,
  };
}

class CurrentClass {
  String? id;
  String? name;
  String? level;
  int? totalFees;
  int? currentEnrollment;
  dynamic availableSlots;
  dynamic feeStructureDetails;

  CurrentClass({
    this.id,
    this.name,
    this.level,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.feeStructureDetails,
  });

  factory CurrentClass.fromJson(Map<String, dynamic> json) => CurrentClass(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    totalFees: json["totalFees"],
    currentEnrollment: json["currentEnrollment"],
    availableSlots: json["availableSlots"],
    feeStructureDetails: json["feeStructureDetails"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "totalFees": totalFees,
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "feeStructureDetails": feeStructureDetails,
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

class CurrentTerm {
  String? academicYear;
  String? term;
  FeeRecord? feeRecord;
  String? status;
  int? amountOwed;
  FeeDetails? feeDetails;

  CurrentTerm({
    this.academicYear,
    this.term,
    this.feeRecord,
    this.status,
    this.amountOwed,
    this.feeDetails,
  });

  factory CurrentTerm.fromJson(Map<String, dynamic> json) => CurrentTerm(
    academicYear: json["academicYear"],
    term: json["term"],
    feeRecord:
        json["feeRecord"] == null
            ? null
            : FeeRecord.fromJson(json["feeRecord"]),
    status: json["status"],
    amountOwed: json["amountOwed"],
    feeDetails:
        json["feeDetails"] == null
            ? null
            : FeeDetails.fromJson(json["feeDetails"]),
  );

  Map<String, dynamic> toJson() => {
    "academicYear": academicYear,
    "term": term,
    "feeRecord": feeRecord?.toJson(),
    "status": status,
    "amountOwed": amountOwed,
    "feeDetails": feeDetails?.toJson(),
  };
}

class FeeRecord {
  String? id;
  AcademicTerm? academicTerm;
  FeeDetails? feeDetails;
  int? amountPaid;
  int? balance;
  String? status;
  int? baseFeePaid;
  int? baseFeeBalance;
  List<dynamic>? addOnBalances;
  List<dynamic>? payments;

  FeeRecord({
    this.id,
    this.academicTerm,
    this.feeDetails,
    this.amountPaid,
    this.balance,
    this.status,
    this.baseFeePaid,
    this.baseFeeBalance,
    this.addOnBalances,
    this.payments,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) => FeeRecord(
    id: json["_id"],
    academicTerm:
        json["academicTerm"] == null
            ? null
            : AcademicTerm.fromJson(json["academicTerm"]),
    feeDetails:
        json["feeDetails"] == null
            ? null
            : FeeDetails.fromJson(json["feeDetails"]),
    amountPaid: json["amountPaid"],
    balance: json["balance"],
    status: json["status"],
    baseFeePaid: json["baseFeePaid"],
    baseFeeBalance: json["baseFeeBalance"],
    addOnBalances:
        json["addOnBalances"] == null
            ? []
            : List<dynamic>.from(json["addOnBalances"]!.map((x) => x)),
    payments:
        json["payments"] == null
            ? []
            : List<dynamic>.from(json["payments"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "academicTerm": academicTerm?.toJson(),
    "feeDetails": feeDetails?.toJson(),
    "amountPaid": amountPaid,
    "balance": balance,
    "status": status,
    "baseFeePaid": baseFeePaid,
    "baseFeeBalance": baseFeeBalance,
    "addOnBalances": addOnBalances,
    "payments": payments,
  };
}

class AcademicTerm {
  String? classId;
  String? term;
  String? academicYear;

  AcademicTerm({this.classId, this.term, this.academicYear});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) => AcademicTerm(
    classId: json["class"],
    term: json["term"],
    academicYear: json["academicYear"],
  );

  Map<String, dynamic> toJson() => {
    "class": classId,
    "term": term,
    "academicYear": academicYear,
  };
}

class FeeDetails {
  int? baseFee;
  List<AddOn>? addOns;
  int? totalFee;

  FeeDetails({this.baseFee, this.addOns, this.totalFee});

  factory FeeDetails.fromJson(Map<String, dynamic> json) => FeeDetails(
    baseFee: json["baseFee"],
    addOns:
        json["addOns"] == null
            ? []
            : List<AddOn>.from(json["addOns"]!.map((x) => AddOn.fromJson(x))),
    totalFee: json["totalFee"],
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "addOns":
        addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
    "totalFee": totalFee,
  };
}

class AddOn {
  String? name;
  int? amount;
  bool? compulsory;
  bool? isActive;
  int? paidAmount;
  String? id;

  AddOn({
    this.name,
    this.amount,
    this.compulsory,
    this.isActive,
    this.paidAmount,
    this.id,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    name: json["name"],
    amount: json["amount"],
    compulsory: json["compulsory"],
    isActive: json["isActive"],
    paidAmount: json["paidAmount"],
    id: json["_id"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "compulsory": compulsory,
    "isActive": isActive,
    "paidAmount": paidAmount,
    "_id": id,
  };
}

class FinancialSummary {
  int? totalFees;
  int? totalAmountPaid;
  int? totalAmountOwed;
  int? numberOfChildren;
  int? childrenWithOutstandingFees;
  double? paymentCompletion;

  FinancialSummary({
    this.totalFees,
    this.totalAmountPaid,
    this.totalAmountOwed,
    this.numberOfChildren,
    this.childrenWithOutstandingFees,
    this.paymentCompletion,
  });

  factory FinancialSummary.fromJson(Map<String, dynamic> json) =>
      FinancialSummary(
        totalFees: json["totalFees"],
        totalAmountPaid: json["totalAmountPaid"],
        totalAmountOwed: json["totalAmountOwed"],
        numberOfChildren: json["numberOfChildren"],
        childrenWithOutstandingFees: json["childrenWithOutstandingFees"],
        paymentCompletion: json["paymentCompletion"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
    "totalFees": totalFees,
    "totalAmountPaid": totalAmountPaid,
    "totalAmountOwed": totalAmountOwed,
    "numberOfChildren": numberOfChildren,
    "childrenWithOutstandingFees": childrenWithOutstandingFees,
    "paymentCompletion": paymentCompletion,
  };
}
