// To parse this JSON data, do
//
//     final singleParentFullDetailsModel = singleParentFullDetailsModelFromJson(jsonString);

import 'dart:convert';

// Helper function to safely parse string fields with detailed logging
String? safeParseString(Map<String, dynamic> json, String fieldName) {
  try {
    final value = json[fieldName];
    if (value == null) return null;
    if (value is String) return value;
    print(
      'DEBUG: Field "$fieldName" is not a String, converting from ${value.runtimeType} to String',
    );
    return value.toString();
  } catch (e) {
    print('DEBUG: Error parsing field "$fieldName": $e');
    return null;
  }
}

SingleParentFullDetailsModel singleParentFullDetailsModelFromJson(String str) {
  try {
    print('DEBUG: Starting JSON decode');
    final Map<String, dynamic> jsonData = json.decode(str);
    print('DEBUG: JSON decode successful, starting model parsing');
    return SingleParentFullDetailsModel.fromJson(jsonData);
  } catch (e, stackTrace) {
    print('DEBUG: Error in singleParentFullDetailsModelFromJson: $e');
    print('DEBUG: Stack trace: $stackTrace');
    rethrow;
  }
}

String singleParentFullDetailsModelToJson(SingleParentFullDetailsModel data) =>
    json.encode(data.toJson());

class SingleParentFullDetailsModel {
  bool? success;
  Data? data;

  SingleParentFullDetailsModel({this.success, this.data});

  factory SingleParentFullDetailsModel.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing SingleParentFullDetailsModel class');
    try {
      return SingleParentFullDetailsModel(
        success: json["success"],
        data: json["data"] == null ? null : Data.fromJson(json["data"]),
      );
    } catch (e) {
      print('DEBUG: Error in SingleParentFullDetailsModel.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {"success": success, "data": data?.toJson()};
}

class Data {
  Parent? parent;
  List<Child>? children;
  List<Communication>? communications;
  FinancialSummary? financialSummary;
  DataCurrentTerm? currentTerm;

  Data({
    this.parent,
    this.children,
    this.communications,
    this.financialSummary,
    this.currentTerm,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing Data class');
    try {
      return Data(
        parent: json["parent"] == null ? null : Parent.fromJson(json["parent"]),
        children:
            json["children"] == null
                ? []
                : List<Child>.from(
                  json["children"]!.map((x) => Child.fromJson(x)),
                ),
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
                : DataCurrentTerm.fromJson(json["currentTerm"]),
      );
    } catch (e) {
      print('DEBUG: Error in Data.fromJson: $e');
      rethrow;
    }
  }

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

class Child {
  Student? student;
  ChildCurrentTerm? currentTerm;
  List<PaymentHistory>? paymentHistory;
  FeeSummary? feeSummary;

  Child({this.student, this.currentTerm, this.paymentHistory, this.feeSummary});

  factory Child.fromJson(Map<String, dynamic> json) => Child(
    student: json["student"] == null ? null : Student.fromJson(json["student"]),
    currentTerm:
        json["currentTerm"] == null
            ? null
            : ChildCurrentTerm.fromJson(json["currentTerm"]),
    paymentHistory:
        json["paymentHistory"] == null
            ? []
            : List<PaymentHistory>.from(
              json["paymentHistory"]!.map((x) => PaymentHistory.fromJson(x)),
            ),
    feeSummary:
        json["feeSummary"] == null
            ? null
            : FeeSummary.fromJson(json["feeSummary"]),
  );

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

class ChildCurrentTerm {
  String? academicYear;
  String? term;
  FeeRecord? feeRecord;
  String? status;
  int? amountOwed;

  ChildCurrentTerm({
    this.academicYear,
    this.term,
    this.feeRecord,
    this.status,
    this.amountOwed,
  });

  factory ChildCurrentTerm.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing ChildCurrentTerm class');
    try {
      return ChildCurrentTerm(
        academicYear: safeParseString(json, "academicYear"),
        term: safeParseString(json, "term"),
        feeRecord:
            json["feeRecord"] == null
                ? null
                : FeeRecord.fromJson(json["feeRecord"]),
        status: safeParseString(json, "status"),
        amountOwed: json["amountOwed"],
      );
    } catch (e) {
      print('DEBUG: Error in ChildCurrentTerm.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "academicYear": academicYear,
    "term": term,
    "feeRecord": feeRecord?.toJson(),
    "status": status,
    "amountOwed": amountOwed,
  };
}

class FeeRecord {
  AcademicTerm? academicTerm;
  FeeDetails? feeDetails;
  String? id;
  String? student;
  List<Payment>? payments;
  DateTime? createdAt;
  DateTime? updatedAt;
  int? v;
  int? amountPaid;
  int? baseFeePaid;
  int? baseFeeBalance;
  List<dynamic>? addOnBalances;
  int? balance;
  String? status;
  String? feeRecordId;

  FeeRecord({
    this.academicTerm,
    this.feeDetails,
    this.id,
    this.student,
    this.payments,
    this.createdAt,
    this.updatedAt,
    this.v,
    this.amountPaid,
    this.baseFeePaid,
    this.baseFeeBalance,
    this.addOnBalances,
    this.balance,
    this.status,
    this.feeRecordId,
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
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    student:
        json["student"] is String
            ? json["student"]
            : json["student"]?.toString(),
    payments:
        json["payments"] == null
            ? []
            : List<Payment>.from(
              json["payments"]!.map((x) => Payment.fromJson(x)),
            ),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    updatedAt:
        json["updatedAt"] == null ? null : DateTime.parse(json["updatedAt"]),
    v: json["__v"],
    amountPaid: json["amountPaid"],
    baseFeePaid: json["baseFeePaid"],
    baseFeeBalance: json["baseFeeBalance"],
    addOnBalances:
        json["addOnBalances"] == null
            ? []
            : List<dynamic>.from(json["addOnBalances"]!.map((x) => x)),
    balance: json["balance"],
    status:
        json["status"] is String ? json["status"] : json["status"]?.toString(),
    feeRecordId: json["id"] is String ? json["id"] : json["id"]?.toString(),
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
    "createdAt": createdAt?.toIso8601String(),
    "updatedAt": updatedAt?.toIso8601String(),
    "__v": v,
    "amountPaid": amountPaid,
    "baseFeePaid": baseFeePaid,
    "baseFeeBalance": baseFeeBalance,
    "addOnBalances":
        addOnBalances == null
            ? []
            : List<dynamic>.from(addOnBalances!.map((x) => x)),
    "balance": balance,
    "status": status,
    "id": feeRecordId,
  };
}

class AcademicTerm {
  String? academicTermClass;
  String? term;
  String? academicYear;

  AcademicTerm({this.academicTermClass, this.term, this.academicYear});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing AcademicTerm class');
    try {
      return AcademicTerm(
        academicTermClass: safeParseString(json, "class"),
        term: safeParseString(json, "term"),
        academicYear: safeParseString(json, "academicYear"),
      );
    } catch (e) {
      print('DEBUG: Error in AcademicTerm.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "class": academicTermClass,
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
    baseFee: json["baseFee"],
    totalFee: json["totalFee"],
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
  DateTime? date;
  String? method;
  String? reference;
  String? status;
  String? id;
  String? paymentId;
  DateTime? verifiedAt;
  GatewayResponse? gatewayResponse;
  String? recordedBy;
  String? description;

  Payment({
    this.paymentBreakdown,
    this.amount,
    this.date,
    this.method,
    this.reference,
    this.status,
    this.id,
    this.paymentId,
    this.verifiedAt,
    this.gatewayResponse,
    this.recordedBy,
    this.description,
  });

  factory Payment.fromJson(Map<String, dynamic> json) => Payment(
    paymentBreakdown:
        json["paymentBreakdown"] == null
            ? null
            : PaymentBreakdown.fromJson(json["paymentBreakdown"]),
    amount: json["amount"],
    date: json["date"] == null ? null : DateTime.parse(json["date"]),
    method:
        json["method"] is String ? json["method"] : json["method"]?.toString(),
    reference:
        json["reference"] is String
            ? json["reference"]
            : json["reference"]?.toString(),
    status:
        json["status"] is String ? json["status"] : json["status"]?.toString(),
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    paymentId: json["id"] is String ? json["id"] : json["id"]?.toString(),
    verifiedAt:
        json["verifiedAt"] == null ? null : DateTime.parse(json["verifiedAt"]),
    gatewayResponse:
        json["gatewayResponse"] == null
            ? null
            : GatewayResponse.fromJson(json["gatewayResponse"]),
    recordedBy:
        json["recordedBy"] is String
            ? json["recordedBy"]
            : json["recordedBy"]?.toString(),
    description:
        json["description"] is String
            ? json["description"]
            : json["description"]?.toString(),
  );

  Map<String, dynamic> toJson() => {
    "paymentBreakdown": paymentBreakdown?.toJson(),
    "amount": amount,
    "date": date?.toIso8601String(),
    "method": method,
    "reference": reference,
    "status": status,
    "_id": id,
    "id": paymentId,
    "verifiedAt": verifiedAt?.toIso8601String(),
    "gatewayResponse": gatewayResponse?.toJson(),
    "recordedBy": recordedBy,
    "description": description,
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
  DateTime? gatewayResponsePaidAt;
  DateTime? gatewayResponseCreatedAt;
  String? channel;
  String? currency;
  String? ipAddress;
  Metadata? metadata;
  Log? log;
  int? fees;
  dynamic feesSplit;
  Authorization? authorization;
  Customer? customer;
  dynamic plan;
  dynamic orderId;
  DateTime? paidAt;
  DateTime? createdAt;
  int? requestedAmount;
  dynamic posTransactionData;
  dynamic source;
  dynamic feesBreakdown;
  dynamic connect;
  DateTime? transactionDate;

  GatewayResponse({
    this.id,
    this.domain,
    this.status,
    this.reference,
    this.receiptNumber,
    this.amount,
    this.message,
    this.gatewayResponse,
    this.gatewayResponsePaidAt,
    this.gatewayResponseCreatedAt,
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
    this.paidAt,
    this.createdAt,
    this.requestedAmount,
    this.posTransactionData,
    this.source,
    this.feesBreakdown,
    this.connect,
    this.transactionDate,
  });

  factory GatewayResponse.fromJson(
    Map<String, dynamic> json,
  ) => GatewayResponse(
    id: json["id"],
    domain: json["domain"],
    status: json["status"],
    reference: json["reference"],
    receiptNumber: json["receipt_number"],
    amount: json["amount"],
    message: json["message"],
    gatewayResponse: json["gateway_response"],
    gatewayResponsePaidAt:
        json["paid_at"] == null ? null : DateTime.parse(json["paid_at"]),
    gatewayResponseCreatedAt:
        json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    channel: json["channel"],
    currency: json["currency"],
    ipAddress: json["ip_address"],
    metadata:
        json["metadata"] == null ? null : Metadata.fromJson(json["metadata"]),
    log: json["log"] == null ? null : Log.fromJson(json["log"]),
    fees: json["fees"],
    feesSplit: json["fees_split"],
    authorization:
        json["authorization"] == null
            ? null
            : Authorization.fromJson(json["authorization"]),
    customer:
        json["customer"] == null ? null : Customer.fromJson(json["customer"]),
    plan: json["plan"],
    orderId: json["order_id"],
    paidAt: json["paidAt"] == null ? null : DateTime.parse(json["paidAt"]),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
    requestedAmount: json["requested_amount"],
    posTransactionData: json["pos_transaction_data"],
    source: json["source"],
    feesBreakdown: json["fees_breakdown"],
    connect: json["connect"],
    transactionDate:
        json["transaction_date"] == null
            ? null
            : DateTime.parse(json["transaction_date"]),
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
    "paid_at": gatewayResponsePaidAt?.toIso8601String(),
    "created_at": gatewayResponseCreatedAt?.toIso8601String(),
    "channel": channel,
    "currency": currency,
    "ip_address": ipAddress,
    "metadata": metadata?.toJson(),
    "log": log?.toJson(),
    "fees": fees,
    "fees_split": feesSplit,
    "authorization": authorization?.toJson(),
    "customer": customer?.toJson(),
    "plan": plan,
    "order_id": orderId,
    "paidAt": paidAt?.toIso8601String(),
    "createdAt": createdAt?.toIso8601String(),
    "requested_amount": requestedAmount,
    "pos_transaction_data": posTransactionData,
    "source": source,
    "fees_breakdown": feesBreakdown,
    "connect": connect,
    "transaction_date": transactionDate?.toIso8601String(),
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
    startTime: json["start_time"],
    timeSpent: json["time_spent"],
    attempts: json["attempts"],
    errors: json["errors"],
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

  factory History.fromJson(Map<String, dynamic> json) =>
      History(type: json["type"], message: json["message"], time: json["time"]);

  Map<String, dynamic> toJson() => {
    "type": type,
    "message": message,
    "time": time,
  };
}

class Metadata {
  String? studentId;
  String? feeRecordId;
  String? paymentIndex;
  String? parentId;
  String? paymentId;
  String? feeStructureId;

  Metadata({
    this.studentId,
    this.feeRecordId,
    this.paymentIndex,
    this.parentId,
    this.paymentId,
    this.feeStructureId,
  });

  factory Metadata.fromJson(Map<String, dynamic> json) => Metadata(
    studentId: json["studentId"],
    feeRecordId: json["feeRecordId"],
    paymentIndex: json["paymentIndex"],
    parentId: json["parentId"],
    paymentId: json["paymentId"],
    feeStructureId: json["feeStructureId"],
  );

  Map<String, dynamic> toJson() => {
    "studentId": studentId,
    "feeRecordId": feeRecordId,
    "paymentIndex": paymentIndex,
    "parentId": parentId,
    "paymentId": paymentId,
    "feeStructureId": feeStructureId,
  };
}

class PaymentBreakdown {
  int? baseFeeAmount;
  List<dynamic>? addOnPayments;

  PaymentBreakdown({this.baseFeeAmount, this.addOnPayments});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) =>
      PaymentBreakdown(
        baseFeeAmount: json["baseFeeAmount"],
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
    totalFees: json["totalFees"],
    totalPaid: json["totalPaid"],
    outstandingBalance: json["outstandingBalance"],
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
  ClassId? allFeeRecordClass;
  int? totalFee;
  int? amountPaid;
  int? balance;
  String? status;

  AllFeeRecord({
    this.academicYear,
    this.term,
    this.allFeeRecordClass,
    this.totalFee,
    this.amountPaid,
    this.balance,
    this.status,
  });

  factory AllFeeRecord.fromJson(Map<String, dynamic> json) => AllFeeRecord(
    academicYear: json["academicYear"],
    term: json["term"],
    allFeeRecordClass:
        json["class"] == null ? null : ClassId.fromJson(json["class"]),
    totalFee: json["totalFee"],
    amountPaid: json["amountPaid"],
    balance: json["balance"],
    status: json["status"],
  );

  Map<String, dynamic> toJson() => {
    "academicYear": academicYear,
    "term": term,
    "class": allFeeRecordClass?.toJson(),
    "totalFee": totalFee,
    "amountPaid": amountPaid,
    "balance": balance,
    "status": status,
  };
}

class ClassId {
  String? id;
  String? name;
  String? level;
  int? totalFees;
  int? currentEnrollment;
  dynamic availableSlots;
  dynamic feeStructureDetails;
  String? classIdId;

  ClassId({
    this.id,
    this.name,
    this.level,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.feeStructureDetails,
    this.classIdId,
  });

  factory ClassId.fromJson(Map<String, dynamic> json) => ClassId(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    totalFees: json["totalFees"],
    currentEnrollment: json["currentEnrollment"],
    availableSlots: json["availableSlots"],
    feeStructureDetails: json["feeStructureDetails"],
    classIdId: json["id"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "totalFees": totalFees,
    "currentEnrollment": currentEnrollment,
    "availableSlots": availableSlots,
    "feeStructureDetails": feeStructureDetails,
    "id": classIdId,
  };
}

class PaymentHistory {
  String? id;
  int? amount;
  String? method;
  String? status;
  String? reference;
  DateTime? createdAt;
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
    amount: json["amount"],
    method: json["method"],
    status: json["status"],
    reference: json["reference"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
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
    "createdAt": createdAt?.toIso8601String(),
    "academicTerm": academicTerm?.toJson(),
  };
}

class Student {
  String? id;
  String? admissionNumber;
  StudentPersonalInfo? personalInfo;
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
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    admissionNumber:
        json["admissionNumber"] is String
            ? json["admissionNumber"]
            : json["admissionNumber"]?.toString(),
    personalInfo:
        json["personalInfo"] == null
            ? null
            : StudentPersonalInfo.fromJson(json["personalInfo"]),
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
  ClassId? currentClass;
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
            : ClassId.fromJson(json["currentClass"]),
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
    outstandingBalance: json["outstandingBalance"],
    feeStatus: json["feeStatus"],
    totalFees: json["totalFees"],
    paidAmount: json["paidAmount"],
  );

  Map<String, dynamic> toJson() => {
    "outstandingBalance": outstandingBalance,
    "feeStatus": feeStatus,
    "totalFees": totalFees,
    "paidAmount": paidAmount,
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
  };
}

class Communication {
  String? id;
  String? message;
  Sender? sender;
  List<Sender>? recipients;
  String? communicationType;
  ClassId? classId;
  List<Reply>? replies;
  List<dynamic>? attachments;
  bool? isAnnouncement;
  DateTime? createdAt;

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
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    message:
        json["message"] is String
            ? json["message"]
            : json["message"]?.toString(),
    sender: json["sender"] == null ? null : Sender.fromJson(json["sender"]),
    recipients:
        json["recipients"] == null
            ? []
            : List<Sender>.from(
              json["recipients"]!.map((x) => Sender.fromJson(x)),
            ),
    communicationType:
        json["communicationType"] is String
            ? json["communicationType"]
            : json["communicationType"]?.toString(),
    classId: json["classId"] == null ? null : ClassId.fromJson(json["classId"]),
    replies:
        json["replies"] == null
            ? []
            : List<Reply>.from(json["replies"]!.map((x) => Reply.fromJson(x))),
    attachments:
        json["attachments"] == null
            ? []
            : List<dynamic>.from(json["attachments"]!.map((x) => x)),
    isAnnouncement: json["isAnnouncement"],
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
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
        replies == null
            ? []
            : List<dynamic>.from(replies!.map((x) => x.toJson())),
    "attachments":
        attachments == null
            ? []
            : List<dynamic>.from(attachments!.map((x) => x)),
    "isAnnouncement": isAnnouncement,
    "createdAt": createdAt?.toIso8601String(),
  };
}

class Sender {
  String? id;
  String? role;
  String? firstName;
  String? lastName;

  Sender({this.id, this.role, this.firstName, this.lastName});

  factory Sender.fromJson(Map<String, dynamic> json) => Sender(
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    role: json["role"] is String ? json["role"] : json["role"]?.toString(),
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
    "_id": id,
    "role": role,
    "firstName": firstName,
    "lastName": lastName,
  };
}

class Reply {
  String? sender;
  String? message;
  String? id;
  DateTime? createdAt;

  Reply({this.sender, this.message, this.id, this.createdAt});

  factory Reply.fromJson(Map<String, dynamic> json) => Reply(
    sender:
        json["sender"] is String ? json["sender"] : json["sender"]?.toString(),
    message:
        json["message"] is String
            ? json["message"]
            : json["message"]?.toString(),
    id: json["_id"] is String ? json["_id"] : json["_id"]?.toString(),
    createdAt:
        json["createdAt"] == null ? null : DateTime.parse(json["createdAt"]),
  );

  Map<String, dynamic> toJson() => {
    "sender": sender,
    "message": message,
    "_id": id,
    "createdAt": createdAt?.toIso8601String(),
  };
}

class DataCurrentTerm {
  String? academicYear;
  String? term;

  DataCurrentTerm({this.academicYear, this.term});

  factory DataCurrentTerm.fromJson(Map<String, dynamic> json) =>
      DataCurrentTerm(academicYear: json["academicYear"], term: json["term"]);

  Map<String, dynamic> toJson() => {"academicYear": academicYear, "term": term};
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

class Parent {
  String? id;
  ParentPersonalInfo? personalInfo;
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

  factory Parent.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing Parent class');
    try {
      return Parent(
        id: safeParseString(json, "_id"),
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
        user: json["user"] == null ? null : User.fromJson(json["user"]),
      );
    } catch (e) {
      print('DEBUG: Error in Parent.fromJson: $e');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() => {
    "_id": id,
    "personalInfo": personalInfo?.toJson(),
    "contactInfo": contactInfo?.toJson(),
    "professionalInfo": professionalInfo?.toJson(),
    "user": user?.toJson(),
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

class ParentPersonalInfo {
  String? title;
  String? firstName;
  String? lastName;
  String? middleName;
  DateTime? dateOfBirth;
  String? gender;
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

  factory ParentPersonalInfo.fromJson(Map<String, dynamic> json) {
    print('DEBUG: Parsing ParentPersonalInfo class');
    try {
      return ParentPersonalInfo(
        title: safeParseString(json, "title"),
        firstName: safeParseString(json, "firstName"),
        lastName: safeParseString(json, "lastName"),
        middleName: safeParseString(json, "middleName"),
        dateOfBirth:
            json["dateOfBirth"] == null
                ? null
                : DateTime.parse(json["dateOfBirth"]),
        gender: safeParseString(json, "gender"),
        maritalStatus: safeParseString(json, "maritalStatus"),
      );
    } catch (e) {
      print('DEBUG: Error in ParentPersonalInfo.fromJson: $e');
      rethrow;
    }
  }

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

class ProfessionalInfo {
  WorkAddress? workAddress;
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
        workAddress:
            json["workAddress"] == null
                ? null
                : WorkAddress.fromJson(json["workAddress"]),
        occupation:
            json["occupation"] is String
                ? json["occupation"]
                : json["occupation"]?.toString(),
        employer:
            json["employer"] is String
                ? json["employer"]
                : json["employer"]?.toString(),
        annualIncome: json["annualIncome"],
      );

  Map<String, dynamic> toJson() => {
    "workAddress": workAddress?.toJson(),
    "occupation": occupation,
    "employer": employer,
    "annualIncome": annualIncome,
  };
}

class WorkAddress {
  WorkAddress();

  factory WorkAddress.fromJson(Map<String, dynamic> json) => WorkAddress();

  Map<String, dynamic> toJson() => {};
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
