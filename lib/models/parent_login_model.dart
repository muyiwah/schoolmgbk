// To parse this JSON data, do
//
//     final parentLoginModel = parentLoginModelFromJson(jsonString);

import 'dart:convert';

ParentLoginModel parentLoginModelFromJson(String str) =>
    ParentLoginModel.fromJson(json.decode(str));

String parentLoginModelToJson(ParentLoginModel data) =>
    json.encode(data.toJson());

class ParentLoginModel {
  bool? success;
  String? message;
  ParentLoginData? data;

  ParentLoginModel({this.success, this.message, this.data});

  factory ParentLoginModel.fromJson(
    Map<String, dynamic> json,
  ) => ParentLoginModel(
    success: json["success"],
    message: json["message"],
    data: json["data"] == null ? null : ParentLoginData.fromJson(json["data"]),
  );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ParentLoginData {
  User? user;
  String? token;
  ParentDetails? parentDetails;

  ParentLoginData({this.user, this.token, this.parentDetails});

  factory ParentLoginData.fromJson(Map<String, dynamic> json) =>
      ParentLoginData(
        user: json["user"] == null ? null : User.fromJson(json["user"]),
        token: json["token"],
        parentDetails:
            json["parentDetails"] == null
                ? null
                : ParentDetails.fromJson(json["parentDetails"]),
      );

  Map<String, dynamic> toJson() => {
    "user": user?.toJson(),
    "token": token,
    "parentDetails": parentDetails?.toJson(),
  };
}

class User {
  String? id;
  String? email;
  String? role;
  String? firstName;
  String? lastName;
  String? fullName;
  String? lastLogin;

  User({
    this.id,
    this.email,
    this.role,
    this.firstName,
    this.lastName,
    this.fullName,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
    id: json["id"],
    email: json["email"],
    role: json["role"],
    firstName: json["firstName"],
    lastName: json["lastName"],
    fullName: json["fullName"],
    lastLogin: json["lastLogin"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "email": email,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
    "fullName": fullName,
    "lastLogin": lastLogin,
  };
}

class ParentDetails {
  Parent? parent;
  List<Child>? children;
  List<Communication>? communications;
  FinancialSummary? financialSummary;
  CurrentTerm? currentTerm;

  ParentDetails({
    this.parent,
    this.children,
    this.communications,
    this.financialSummary,
    this.currentTerm,
  });

  factory ParentDetails.fromJson(Map<String, dynamic> json) => ParentDetails(
    parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
    children:
        json["children"] == null
            ? []
            : List<Child>.from(json["children"]!.map((x) => Child.fromJson(x))),
    communications:
        json["communications"] == null
            ? []
            : List<Communication>.from(
              json["communications"]!.map((x) => Communication.fromJson(x)),
            ),
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
    "communications":
        communications == null
            ? []
            : List<dynamic>.from(communications!.map((x) => x.toJson())),
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
  String? email;

  ContactInfo({this.address, this.primaryPhone, this.email});

  factory ContactInfo.fromJson(Map<String, dynamic> json) => ContactInfo(
    address: json["address"] == null ? null : Address.fromJson(json["address"]),
    primaryPhone: json["primaryPhone"],
    email: json["email"],
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

class ProfessionalInfo {
  Map<String, dynamic>? workAddress;
  String? occupation;
  String? employer;
  int? annualIncome;

  ProfessionalInfo({
    this.workAddress,
    this.occupation,
    this.employer,
    this.annualIncome,
  });

  factory ProfessionalInfo.fromJson(Map<String, dynamic> json) =>
      ProfessionalInfo(
        workAddress: json["workAddress"],
        occupation: json["occupation"],
        employer: json["employer"],
        annualIncome: _parseInt(json["annualIncome"]),
      );

  Map<String, dynamic> toJson() => {
    "workAddress": workAddress,
    "occupation": occupation,
    "employer": employer,
    "annualIncome": annualIncome,
  };
}

class Child {
  Student? student;
  CurrentTerm? currentTerm;
  List<PaymentHistory>? paymentHistory;
  FeeSummary? feeSummary;

  Child({this.student, this.currentTerm, this.paymentHistory, this.feeSummary});

  factory Child.fromJson(Map<String, dynamic> json) {
    try {
      return Child(
        student:
            json["student"] == null ? null : Student.fromJson(json["student"]),
        currentTerm:
            json["currentTerm"] == null
                ? null
                : CurrentTerm.fromJson(json["currentTerm"]),
        paymentHistory:
            json["paymentHistory"] == null
                ? []
                : List<PaymentHistory>.from(
                  json["paymentHistory"]!.map(
                    (x) => PaymentHistory.fromJson(x),
                  ),
                ),
        feeSummary:
            json["feeSummary"] == null
                ? null
                : FeeSummary.fromJson(json["feeSummary"]),
      );
    } catch (e) {
      print('🔍 DEBUG: Error parsing Child from JSON: $e');
      print('🔍 DEBUG: Child JSON keys: ${json.keys.toList()}');
      print('🔍 DEBUG: Child JSON: $json');

      // Return a minimal Child object to prevent complete failure
      return Child(
        student:
            json["student"] != null ? Student.fromJson(json["student"]) : null,
        currentTerm: null,
        paymentHistory: [],
        feeSummary: null,
      );
    }
  }

  Map<String, dynamic> toJson() => {
    "student": student?.toJson(),
    "currentTerm": currentTerm?.toJson(),
    "paymentHistory":
        paymentHistory == null
            ? []
            : List<dynamic>.from(paymentHistory!.map((x) => x.toJson())),
    "feeSummary": feeSummary?.toJson(),
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
    totalFees: _parseInt(json["totalFees"]),
    currentEnrollment: _parseInt(json["currentEnrollment"]),
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
  int? outstandingBalance;
  String? feeStatus;
  int? totalFees;
  int? paidAmount;

  FinancialInfo({
    this.outstandingBalance,
    this.feeStatus,
    this.totalFees,
    this.paidAmount,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) => FinancialInfo(
    outstandingBalance: _parseInt(json["outstandingBalance"]),
    feeStatus: json["feeStatus"],
    totalFees: _parseInt(json["totalFees"]),
    paidAmount: _parseInt(json["paidAmount"]),
  );

  Map<String, dynamic> toJson() => {
    "outstandingBalance": outstandingBalance,
    "feeStatus": feeStatus,
    "totalFees": totalFees,
    "paidAmount": paidAmount,
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
    amountOwed: _parseInt(json["amountOwed"]),
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
  AcademicTerm? academicTerm;
  FeeDetails? feeDetails;
  String? id;
  String? student;
  List<Payment>? payments;
  String? createdAt;
  String? updatedAt;
  int? amountPaid;
  int? baseFeePaid;
  int? baseFeeBalance;
  List<dynamic>? addOnBalances;
  int? balance;
  String? status;

  FeeRecord({
    this.academicTerm,
    this.feeDetails,
    this.id,
    this.student,
    this.payments,
    this.createdAt,
    this.updatedAt,
    this.amountPaid,
    this.baseFeePaid,
    this.baseFeeBalance,
    this.addOnBalances,
    this.balance,
    this.status,
  });

  factory FeeRecord.fromJson(Map<String, dynamic> json) => FeeRecord(
    academicTerm:
        json["academicTerm"] == null
            ? null
            : AcademicTerm.fromJson(json["academicTerm"]),
    feeDetails:
        json["feeDetails"] == null
            ? null
            : FeeDetails.fromJson(json["feeDetails"]),
    id: json["_id"],
    student: json["student"],
    payments:
        json["payments"] == null
            ? []
            : List<Payment>.from(
              json["payments"]!.map((x) => Payment.fromJson(x)),
            ),
    createdAt: json["createdAt"],
    updatedAt: json["updatedAt"],
    amountPaid: _parseInt(json["amountPaid"]),
    baseFeePaid: _parseInt(json["baseFeePaid"]),
    baseFeeBalance: _parseInt(json["baseFeeBalance"]),
    addOnBalances:
        json["addOnBalances"] == null
            ? []
            : List<dynamic>.from(json["addOnBalances"]!.map((x) => x)),
    balance: _parseInt(json["balance"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "academicTerm": academicTerm?.toJson(),
    "feeDetails": feeDetails?.toJson(),
    "_id": id,
    "student": student,
    "payments":
        payments == null
            ? []
            : List<dynamic>.from(payments!.map((x) => x.toJson())),
    "createdAt": createdAt,
    "updatedAt": updatedAt,
    "amountPaid": amountPaid,
    "baseFeePaid": baseFeePaid,
    "baseFeeBalance": baseFeeBalance,
    "addOnBalances":
        addOnBalances == null
            ? []
            : List<dynamic>.from(addOnBalances!.map((x) => x)),
    "balance": balance,
    "status": status,
  };
}

class AcademicTerm {
  dynamic class_;
  String? term;
  String? academicYear;

  AcademicTerm({this.class_, this.term, this.academicYear});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) => AcademicTerm(
    class_: json["class"],
    term: json["term"],
    academicYear: json["academicYear"],
  );

  Map<String, dynamic> toJson() => {
    "class": class_,
    "term": term,
    "academicYear": academicYear,
  };
}

class FeeDetails {
  int? baseFee;
  int? totalFee;
  List<dynamic>? addOns;

  FeeDetails({this.baseFee, this.totalFee, this.addOns});

  factory FeeDetails.fromJson(Map<String, dynamic> json) => FeeDetails(
    baseFee: _parseInt(json["baseFee"]),
    totalFee: _parseInt(json["totalFee"]),
    addOns:
        json["addOns"] == null
            ? []
            : List<dynamic>.from(json["addOns"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "totalFee": totalFee,
    "addOns": addOns == null ? [] : List<dynamic>.from(addOns!.map((x) => x)),
  };
}

class Payment {
  PaymentBreakdown? paymentBreakdown;
  int? amount;
  String? date;
  String? method;
  String? reference;
  String? status;
  String? id;
  String? verifiedAt;
  GatewayResponse? gatewayResponse;
  String? description;
  String? recordedBy;

  Payment({
    this.paymentBreakdown,
    this.amount,
    this.date,
    this.method,
    this.reference,
    this.status,
    this.id,
    this.verifiedAt,
    this.gatewayResponse,
    this.description,
    this.recordedBy,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentBreakdown:
        json["paymentBreakdown"] == null
            ? null
            : PaymentBreakdown.fromJson(json["paymentBreakdown"]),
    amount: _parseInt(json["amount"]),
    date: json["date"],
    method: json["method"],
    reference: json["reference"],
    status: json["status"],
    id: json["_id"],
    verifiedAt: json["verifiedAt"],
    gatewayResponse:
        json["gatewayResponse"] == null
            ? null
            : GatewayResponse.fromJson(json["gatewayResponse"]),
    description: json["description"],
    recordedBy: json["recordedBy"],
  );

  Map<String, dynamic> toJson() => {
    "paymentBreakdown": paymentBreakdown?.toJson(),
    "amount": amount,
    "date": date,
    "method": method,
    "reference": reference,
    "status": status,
    "_id": id,
    "verifiedAt": verifiedAt,
    "gatewayResponse": gatewayResponse?.toJson(),
    "description": description,
    "recordedBy": recordedBy,
  };
}

class PaymentBreakdown {
  int? baseFeeAmount;
  List<dynamic>? addOnPayments;

  PaymentBreakdown({this.baseFeeAmount, this.addOnPayments});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) =>
      PaymentBreakdown(
        baseFeeAmount: _parseInt(json["baseFeeAmount"]),
        addOnPayments:
            json["addOnPayments"] == null
                ? []
                : List<dynamic>.from(json["addOnPayments"]!.map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
    "baseFeeAmount": baseFeeAmount,
    "addOnPayments":
        addOnPayments == null
            ? []
            : List<dynamic>.from(addOnPayments!.map((x) => x)),
  };
}

class GatewayResponse {
  int? id;
  String? domain;
  String? status;
  String? reference;
  dynamic receiptNumber;
  int? amount;
  dynamic message;
  String? gatewayResponse;
  String? paidAt;
  String? createdAt;
  String? channel;
  String? currency;
  String? ipAddress;
  Map<String, dynamic>? metadata;
  Log? log;
  int? fees;
  dynamic feesSplit;
  Authorization? authorization;
  Customer? customer;
  dynamic plan;
  dynamic orderId;
  String? paidAt2;
  String? createdAt2;
  int? requestedAmount;
  dynamic posTransactionData;
  dynamic source;
  dynamic feesBreakdown;
  dynamic connect;
  String? transactionDate;

  GatewayResponse({
    this.id,
    this.domain,
    this.status,
    this.reference,
    this.receiptNumber,
    this.amount,
    this.message,
    this.gatewayResponse,
    this.paidAt,
    this.createdAt,
    this.channel,
    this.currency,
    this.ipAddress,
    this.metadata,
    this.log,
    this.fees,
    this.feesSplit,
    this.authorization,
    this.customer,
    this.plan,
    this.orderId,
    this.paidAt2,
    this.createdAt2,
    this.requestedAmount,
    this.posTransactionData,
    this.source,
    this.feesBreakdown,
    this.connect,
    this.transactionDate,
  });

  factory GatewayResponse.fromJson(Map<String, dynamic> json) =>
      GatewayResponse(
        id: _parseInt(json["id"]),
        domain: json["domain"],
        status: json["status"],
        reference: json["reference"],
        receiptNumber: json["receipt_number"],
        amount: _parseInt(json["amount"]),
        message: json["message"],
        gatewayResponse: json["gateway_response"],
        paidAt: json["paid_at"],
        createdAt: json["created_at"],
        channel: json["channel"],
        currency: json["currency"],
        ipAddress: json["ip_address"],
        metadata: json["metadata"],
        log: json["log"] == null ? null : Log.fromJson(json["log"]),
        fees: _parseInt(json["fees"]),
        feesSplit: json["fees_split"],
        authorization:
            json["authorization"] == null
                ? null
                : Authorization.fromJson(json["authorization"]),
        customer:
            json["customer"] == null
                ? null
                : Customer.fromJson(json["customer"]),
        plan: json["plan"],
        orderId: json["order_id"],
        paidAt2: json["paidAt"],
        createdAt2: json["createdAt"],
        requestedAmount: _parseInt(json["requested_amount"]),
        posTransactionData: json["pos_transaction_data"],
        source: json["source"],
        feesBreakdown: json["fees_breakdown"],
        connect: json["connect"],
        transactionDate: json["transaction_date"],
      );

  Map<String, dynamic> toJson() => {
    "id": id,
    "domain": domain,
    "status": status,
    "reference": reference,
    "receipt_number": receiptNumber,
    "amount": amount,
    "message": message,
    "gateway_response": gatewayResponse,
    "paid_at": paidAt,
    "created_at": createdAt,
    "channel": channel,
    "currency": currency,
    "ip_address": ipAddress,
    "metadata": metadata,
    "log": log?.toJson(),
    "fees": fees,
    "fees_split": feesSplit,
    "authorization": authorization?.toJson(),
    "customer": customer?.toJson(),
    "order_id": orderId,
    "paidAt": paidAt2,
    "createdAt": createdAt2,
    "requested_amount": requestedAmount,
    "pos_transaction_data": posTransactionData,
    "source": source,
    "fees_breakdown": feesBreakdown,
    "connect": connect,
    "transaction_date": transactionDate,
  };
}

class Log {
  int? startTime;
  int? timeSpent;
  int? attempts;
  int? errors;
  bool? success;
  bool? mobile;
  List<dynamic>? input;
  List<History>? history;

  Log({
    this.startTime,
    this.timeSpent,
    this.attempts,
    this.errors,
    this.success,
    this.mobile,
    this.input,
    this.history,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
    startTime: _parseInt(json["start_time"]),
    timeSpent: _parseInt(json["time_spent"]),
    attempts: _parseInt(json["attempts"]),
    errors: _parseInt(json["errors"]),
    success: json["success"],
    mobile: json["mobile"],
    input:
        json["input"] == null
            ? []
            : List<dynamic>.from(json["input"]!.map((x) => x)),
    history:
        json["history"] == null
            ? []
            : List<History>.from(
              json["history"]!.map((x) => History.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "start_time": startTime,
    "time_spent": timeSpent,
    "attempts": attempts,
    "errors": errors,
    "success": success,
    "mobile": mobile,
    "input": input == null ? [] : List<dynamic>.from(input!.map((x) => x)),
    "history":
        history == null
            ? []
            : List<dynamic>.from(history!.map((x) => x.toJson())),
  };
}

class History {
  String? type;
  String? message;
  int? time;

  History({this.type, this.message, this.time});

  factory History.fromJson(Map<String, dynamic> json) => History(
    type: json["type"],
    message: json["message"],
    time: _parseInt(json["time"]),
  );

  Map<String, dynamic> toJson() => {
    "type": type,
    "message": message,
    "time": time,
  };
}

class Authorization {
  String? authorizationCode;
  String? bin;
  String? last4;
  String? expMonth;
  String? expYear;
  String? channel;
  String? cardType;
  String? bank;
  String? countryCode;
  String? brand;
  bool? reusable;
  String? signature;
  dynamic accountName;
  dynamic receiverBankAccountNumber;
  dynamic receiverBank;

  Authorization({
    this.authorizationCode,
    this.bin,
    this.last4,
    this.expMonth,
    this.expYear,
    this.channel,
    this.cardType,
    this.bank,
    this.countryCode,
    this.brand,
    this.reusable,
    this.signature,
    this.accountName,
    this.receiverBankAccountNumber,
    this.receiverBank,
  });

  factory Authorization.fromJson(Map<String, dynamic> json) => Authorization(
    authorizationCode: json["authorization_code"],
    bin: json["bin"],
    last4: json["last4"],
    expMonth: json["exp_month"],
    expYear: json["exp_year"],
    channel: json["channel"],
    cardType: json["card_type"],
    bank: json["bank"],
    countryCode: json["country_code"],
    brand: json["brand"],
    reusable: json["reusable"],
    signature: json["signature"],
    accountName: json["account_name"],
    receiverBankAccountNumber: json["receiver_bank_account_number"],
    receiverBank: json["receiver_bank"],
  );

  Map<String, dynamic> toJson() => {
    "authorization_code": authorizationCode,
    "bin": bin,
    "last4": last4,
    "exp_month": expMonth,
    "exp_year": expYear,
    "channel": channel,
    "card_type": cardType,
    "bank": bank,
    "country_code": countryCode,
    "brand": brand,
    "reusable": reusable,
    "signature": signature,
    "account_name": accountName,
    "receiver_bank_account_number": receiverBankAccountNumber,
    "receiver_bank": receiverBank,
  };
}

class Customer {
  int? id;
  String? firstName;
  String? lastName;
  String? email;
  String? customerCode;
  dynamic phone;
  dynamic metadata;
  String? riskAction;
  dynamic internationalFormatPhone;

  Customer({
    this.id,
    this.firstName,
    this.lastName,
    this.email,
    this.customerCode,
    this.phone,
    this.metadata,
    this.riskAction,
    this.internationalFormatPhone,
  });

  factory Customer.fromJson(Map<String, dynamic> json) => Customer(
    id: json["id"],
    firstName: json["first_name"],
    lastName: json["last_name"],
    email: json["email"],
    customerCode: json["customer_code"],
    phone: json["phone"],
    metadata: json["metadata"],
    riskAction: json["risk_action"],
    internationalFormatPhone: json["international_format_phone"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "first_name": firstName,
    "last_name": lastName,
    "email": email,
    "customer_code": customerCode,
    "phone": phone,
    "metadata": metadata,
    "risk_action": riskAction,
    "international_format_phone": internationalFormatPhone,
  };
}

class PaymentHistory {
  String? id;
  int? amount;
  String? method;
  String? status;
  String? reference;
  String? createdAt;
  AcademicTerm? academicTerm;

  PaymentHistory({
    this.id,
    this.amount,
    this.method,
    this.status,
    this.reference,
    this.createdAt,
    this.academicTerm,
  });

  factory PaymentHistory.fromJson(Map<String, dynamic> json) => PaymentHistory(
    id: json["_id"],
    amount: _parseInt(json["amount"]),
    method: json["method"],
    status: json["status"],
    reference: json["reference"],
    createdAt: json["createdAt"],
    academicTerm:
        json["academicTerm"] == null
            ? null
            : AcademicTerm.fromJson(json["academicTerm"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "amount": amount,
    "method": method,
    "status": status,
    "reference": reference,
    "createdAt": createdAt,
    "academicTerm": academicTerm?.toJson(),
  };
}

class FeeSummary {
  int? totalFees;
  int? totalPaid;
  int? outstandingBalance;
  String? feeStatus;
  List<AllFeeRecord>? allFeeRecords;

  FeeSummary({
    this.totalFees,
    this.totalPaid,
    this.outstandingBalance,
    this.feeStatus,
    this.allFeeRecords,
  });

  factory FeeSummary.fromJson(Map<String, dynamic> json) => FeeSummary(
    totalFees: _parseInt(json["totalFees"]),
    totalPaid: _parseInt(json["totalPaid"]),
    outstandingBalance: _parseInt(json["outstandingBalance"]),
    feeStatus: json["feeStatus"],
    allFeeRecords:
        json["allFeeRecords"] == null
            ? []
            : List<AllFeeRecord>.from(
              json["allFeeRecords"]!.map((x) => AllFeeRecord.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "totalFees": totalFees,
    "totalPaid": totalPaid,
    "outstandingBalance": outstandingBalance,
    "feeStatus": feeStatus,
    "allFeeRecords":
        allFeeRecords == null
            ? []
            : List<dynamic>.from(allFeeRecords!.map((x) => x.toJson())),
  };
}

class AllFeeRecord {
  String? academicYear;
  String? term;
  CurrentClass? class_;
  int? totalFee;
  int? amountPaid;
  int? balance;
  String? status;

  AllFeeRecord({
    this.academicYear,
    this.term,
    this.class_,
    this.totalFee,
    this.amountPaid,
    this.balance,
    this.status,
  });

  factory AllFeeRecord.fromJson(Map<String, dynamic> json) => AllFeeRecord(
    academicYear: json["academicYear"],
    term: json["term"],
    class_: json["class"] == null ? null : CurrentClass.fromJson(json["class"]),
    totalFee: _parseInt(json["totalFee"]),
    amountPaid: _parseInt(json["amountPaid"]),
    balance: _parseInt(json["balance"]),
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "academicYear": academicYear,
    "term": term,
    "class": class_?.toJson(),
    "totalFee": totalFee,
    "amountPaid": amountPaid,
    "balance": balance,
    "status": status,
  };
}

class Communication {
  String? id;
  String? message;
  Sender? sender;
  List<Recipient>? recipients;
  String? communicationType;
  CurrentClass? classId;
  List<dynamic>? replies;
  List<dynamic>? attachments;
  bool? isAnnouncement;
  String? createdAt;

  Communication({
    this.id,
    this.message,
    this.sender,
    this.recipients,
    this.communicationType,
    this.classId,
    this.replies,
    this.attachments,
    this.isAnnouncement,
    this.createdAt,
  });

  factory Communication.fromJson(Map<String, dynamic> json) => Communication(
    id: json["_id"],
    message: json["message"],
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    recipients:
        json["recipients"] == null
            ? []
            : List<Recipient>.from(
              json["recipients"]!.map((x) => Recipient.fromJson(x)),
            ),
    communicationType: json["communicationType"],
    classId:
        json["classId"] == null ? null : CurrentClass.fromJson(json["classId"]),
    replies:
        json["replies"] == null
            ? []
            : List<dynamic>.from(json["replies"]!.map((x) => x)),
    attachments:
        json["attachments"] == null
            ? []
            : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    isAnnouncement: json["isAnnouncement"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "message": message,
    "sender": sender?.toJson(),
    "recipients":
        recipients == null
            ? []
            : List<dynamic>.from(recipients!.map((x) => x.toJson())),
    "communicationType": communicationType,
    "classId": classId?.toJson(),
    "replies":
        replies == null ? [] : List<dynamic>.from(replies!.map((x) => x)),
    "attachments":
        attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x)),
    "isAnnouncement": isAnnouncement,
    "createdAt": createdAt,
  };
}

class Sender {
  String? id;
  String? role;
  String? firstName;
  String? lastName;

  Sender({this.id, this.role, this.firstName, this.lastName});

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["_id"],
    role: json["role"],
    firstName: json["firstName"],
    lastName: json["lastName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
  };
}

class Recipient {
  String? id;
  String? role;
  String? firstName;
  String? lastName;

  Recipient({this.id, this.role, this.firstName, this.lastName});

  factory Recipient.fromJson(Map<String, dynamic> json) => Recipient(
    id: json["_id"],
    role: json["role"],
    firstName: json["firstName"],
    lastName: json["lastName"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
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
        totalFees: _parseInt(json["totalFees"]),
        totalAmountPaid: _parseInt(json["totalAmountPaid"]),
        totalAmountOwed: _parseInt(json["totalAmountOwed"]),
        numberOfChildren: _parseInt(json["numberOfChildren"]),
        childrenWithOutstandingFees: _parseInt(
          json["childrenWithOutstandingFees"],
        ),
        paymentCompletion: _parseDouble(json["paymentCompletion"]),
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

// Helper functions for safe parsing
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}
