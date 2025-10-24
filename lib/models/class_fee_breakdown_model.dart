// To parse this JSON data, do
//
//     final classFeeBreakdownModel = classFeeBreakdownModelFromJson(jsonString);

import 'dart:convert';

ClassFeeBreakdownModel classFeeBreakdownModelFromJson(String str) =>
    ClassFeeBreakdownModel.fromJson(json.decode(str));

String classFeeBreakdownModelToJson(ClassFeeBreakdownModel data) =>
    json.encode(data.toJson());

class ClassFeeBreakdownModel {
  bool? success;
  String? message;
  ClassFeeBreakdownData? data;

  ClassFeeBreakdownModel({this.success, this.message, this.data});

  factory ClassFeeBreakdownModel.fromJson(Map<String, dynamic> json) =>
      ClassFeeBreakdownModel(
        success: json["success"],
        message: json["message"],
        data:
            json["data"] == null
                ? null
                : ClassFeeBreakdownData.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "success": success,
    "message": message,
    "data": data?.toJson(),
  };
}

class ClassFeeBreakdownData {
  ClassInfo? classInfo;
  AcademicTerm? academicTerm;
  FeeStructure? feeStructure;
  FeeBreakdown? feeBreakdown;
  Totals? totals;
  PaymentStatistics? paymentStatistics;
  PaymentBreakdown? paymentBreakdown;

  ClassFeeBreakdownData({
    this.classInfo,
    this.academicTerm,
    this.feeStructure,
    this.feeBreakdown,
    this.totals,
    this.paymentStatistics,
    this.paymentBreakdown,
  });

  factory ClassFeeBreakdownData.fromJson(Map<String, dynamic> json) =>
      ClassFeeBreakdownData(
        classInfo:
            json["class"] == null ? null : ClassInfo.fromJson(json["class"]),
        academicTerm:
            json["academicTerm"] == null
                ? null
                : AcademicTerm.fromJson(json["academicTerm"]),
        feeStructure:
            json["feeStructure"] == null
                ? null
                : FeeStructure.fromJson(json["feeStructure"]),
        feeBreakdown:
            json["feeBreakdown"] == null
                ? null
                : FeeBreakdown.fromJson(json["feeBreakdown"]),
        totals: json["totals"] == null ? null : Totals.fromJson(json["totals"]),
        paymentStatistics:
            json["paymentStatistics"] == null
                ? null
                : PaymentStatistics.fromJson(json["paymentStatistics"]),
        paymentBreakdown:
            json["paymentBreakdown"] == null
                ? null
                : PaymentBreakdown.fromJson(json["paymentBreakdown"]),
      );

  Map<String, dynamic> toJson() => {
    "class": classInfo?.toJson(),
    "academicTerm": academicTerm?.toJson(),
    "feeStructure": feeStructure?.toJson(),
    "feeBreakdown": feeBreakdown?.toJson(),
    "totals": totals?.toJson(),
    "paymentStatistics": paymentStatistics?.toJson(),
    "paymentBreakdown": paymentBreakdown?.toJson(),
  };
}

class ClassInfo {
  String? id;
  String? name;
  String? level;
  int? totalStudents;

  ClassInfo({this.id, this.name, this.level, this.totalStudents});

  factory ClassInfo.fromJson(Map<String, dynamic> json) => ClassInfo(
    id: json["_id"],
    name: json["name"],
    level: json["level"],
    totalStudents: _parseInt(json["totalStudents"]),
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "totalStudents": totalStudents,
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

class FeeStructure {
  String? id;
  String? name;
  String? description;
  int? version;
  bool? isActive;
  String? createdAt;

  FeeStructure({
    this.id,
    this.name,
    this.description,
    this.version,
    this.isActive,
    this.createdAt,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) => FeeStructure(
    id: json["_id"],
    name: json["name"],
    description: json["description"],
    version: _parseInt(json["version"]),
    isActive: json["isActive"],
    createdAt: json["createdAt"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "description": description,
    "version": version,
    "isActive": isActive,
    "createdAt": createdAt,
  };
}

class FeeBreakdown {
  BaseFee? baseFee;
  List<AddOn>? addOns;

  FeeBreakdown({this.baseFee, this.addOns});

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) => FeeBreakdown(
    baseFee: json["baseFee"] == null ? null : BaseFee.fromJson(json["baseFee"]),
    addOns:
        json["addOns"] == null
            ? []
            : List<AddOn>.from(json["addOns"]!.map((x) => AddOn.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee?.toJson(),
    "addOns":
        addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
  };
}

class BaseFee {
  String? name;
  int? amount;
  String? description;
  bool? compulsory;
  String? category;

  BaseFee({
    this.name,
    this.amount,
    this.description,
    this.compulsory,
    this.category,
  });

  factory BaseFee.fromJson(Map<String, dynamic> json) => BaseFee(
    name: json["name"],
    amount: _parseInt(json["amount"]),
    description: json["description"],
    compulsory: json["compulsory"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "description": description,
    "compulsory": compulsory,
    "category": category,
  };
}

class AddOn {
  String? name;
  int? amount;
  String? description;
  bool? compulsory;
  String? category;

  AddOn({
    this.name,
    this.amount,
    this.description,
    this.compulsory,
    this.category,
  });

  factory AddOn.fromJson(Map<String, dynamic> json) => AddOn(
    name: json["name"],
    amount: _parseInt(json["amount"]),
    description: json["description"],
    compulsory: json["compulsory"],
    category: json["category"],
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "amount": amount,
    "description": description,
    "compulsory": compulsory,
    "category": category,
  };
}

class Totals {
  int? baseFee;
  int? addOnFees;
  int? totalFees;
  int? totalExpectedRevenue;

  Totals({
    this.baseFee,
    this.addOnFees,
    this.totalFees,
    this.totalExpectedRevenue,
  });

  factory Totals.fromJson(Map<String, dynamic> json) => Totals(
    baseFee: _parseInt(json["baseFee"]),
    addOnFees: _parseInt(json["addOnFees"]),
    totalFees: _parseInt(json["totalFees"]),
    totalExpectedRevenue: _parseInt(json["totalExpectedRevenue"]),
  );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "addOnFees": addOnFees,
    "totalFees": totalFees,
    "totalExpectedRevenue": totalExpectedRevenue,
  };
}

class PaymentStatistics {
  int? totalStudents;
  int? paidStudents;
  int? partialStudents;
  int? owingStudents;
  int? totalPaidAmount;
  int? totalOutstandingAmount;
  int? overallCompletionPercentage;

  PaymentStatistics({
    this.totalStudents,
    this.paidStudents,
    this.partialStudents,
    this.owingStudents,
    this.totalPaidAmount,
    this.totalOutstandingAmount,
    this.overallCompletionPercentage,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) =>
      PaymentStatistics(
        totalStudents: _parseInt(json["totalStudents"]),
        paidStudents: _parseInt(json["paidStudents"]),
        partialStudents: _parseInt(json["partialStudents"]),
        owingStudents: _parseInt(json["owingStudents"]),
        totalPaidAmount: _parseInt(json["totalPaidAmount"]),
        totalOutstandingAmount: _parseInt(json["totalOutstandingAmount"]),
        overallCompletionPercentage: _parseInt(
          json["overallCompletionPercentage"],
        ),
      );

  Map<String, dynamic> toJson() => {
    "totalStudents": totalStudents,
    "paidStudents": paidStudents,
    "partialStudents": partialStudents,
    "owingStudents": owingStudents,
    "totalPaidAmount": totalPaidAmount,
    "totalOutstandingAmount": totalOutstandingAmount,
    "overallCompletionPercentage": overallCompletionPercentage,
  };
}

class PaymentBreakdown {
  BaseFeePayment? baseFee;
  List<AddOnPayment>? addOns;

  PaymentBreakdown({this.baseFee, this.addOns});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) =>
      PaymentBreakdown(
        baseFee:
            json["baseFee"] == null
                ? null
                : BaseFeePayment.fromJson(json["baseFee"]),
        addOns:
            json["addOns"] == null
                ? []
                : List<AddOnPayment>.from(
                  json["addOns"]!.map((x) => AddOnPayment.fromJson(x)),
                ),
      );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee?.toJson(),
    "addOns":
        addOns == null
            ? []
            : List<dynamic>.from(addOns!.map((x) => x.toJson())),
  };
}

class BaseFeePayment {
  int? totalAmount;
  int? paidAmount;
  int? outstandingAmount;
  int? completionPercentage;

  BaseFeePayment({
    this.totalAmount,
    this.paidAmount,
    this.outstandingAmount,
    this.completionPercentage,
  });

  factory BaseFeePayment.fromJson(Map<String, dynamic> json) => BaseFeePayment(
    totalAmount: _parseInt(json["totalAmount"]),
    paidAmount: _parseInt(json["paidAmount"]),
    outstandingAmount: _parseInt(json["outstandingAmount"]),
    completionPercentage: _parseInt(json["completionPercentage"]),
  );

  Map<String, dynamic> toJson() => {
    "totalAmount": totalAmount,
    "paidAmount": paidAmount,
    "outstandingAmount": outstandingAmount,
    "completionPercentage": completionPercentage,
  };
}

class AddOnPayment {
  String? name;
  int? totalAmount;
  int? paidAmount;
  int? outstandingAmount;
  int? completionPercentage;

  AddOnPayment({
    this.name,
    this.totalAmount,
    this.paidAmount,
    this.outstandingAmount,
    this.completionPercentage,
  });

  factory AddOnPayment.fromJson(Map<String, dynamic> json) => AddOnPayment(
    name: json["name"],
    totalAmount: _parseInt(json["totalAmount"]),
    paidAmount: _parseInt(json["paidAmount"]),
    outstandingAmount: _parseInt(json["outstandingAmount"]),
    completionPercentage: _parseInt(json["completionPercentage"]),
  );

  Map<String, dynamic> toJson() => {
    "name": name,
    "totalAmount": totalAmount,
    "paidAmount": paidAmount,
    "outstandingAmount": outstandingAmount,
    "completionPercentage": completionPercentage,
  };
}

// Helper function for safe integer parsing
int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
}
