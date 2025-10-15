class PaymentBreakdownResponse {
  final bool success;
  final String message;
  final PaymentBreakdownData data;

  PaymentBreakdownResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentBreakdownResponse.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdownResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaymentBreakdownData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class PaymentBreakdownData {
  final ClassInfo classInfo;
  final AcademicTerm academicTerm;
  final FeeStructure feeStructure;
  final FeeBreakdown feeBreakdown;
  final Totals totals;
  final PaymentStatistics paymentStatistics;
  final PaymentBreakdown paymentBreakdown;

  PaymentBreakdownData({
    required this.classInfo,
    required this.academicTerm,
    required this.feeStructure,
    required this.feeBreakdown,
    required this.totals,
    required this.paymentStatistics,
    required this.paymentBreakdown,
  });

  factory PaymentBreakdownData.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdownData(
      classInfo: ClassInfo.fromJson(json['class'] ?? {}),
      academicTerm: AcademicTerm.fromJson(json['academicTerm'] ?? {}),
      feeStructure: FeeStructure.fromJson(json['feeStructure'] ?? {}),
      feeBreakdown: FeeBreakdown.fromJson(json['feeBreakdown'] ?? {}),
      totals: Totals.fromJson(json['totals'] ?? {}),
      paymentStatistics: PaymentStatistics.fromJson(
        json['paymentStatistics'] ?? {},
      ),
      paymentBreakdown: PaymentBreakdown.fromJson(
        json['paymentBreakdown'] ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': classInfo.toJson(),
      'academicTerm': academicTerm.toJson(),
      'feeStructure': feeStructure.toJson(),
      'feeBreakdown': feeBreakdown.toJson(),
      'totals': totals.toJson(),
      'paymentStatistics': paymentStatistics.toJson(),
      'paymentBreakdown': paymentBreakdown.toJson(),
    };
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String level;
  final int totalStudents;

  ClassInfo({
    required this.id,
    required this.name,
    required this.level,
    required this.totalStudents,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      totalStudents: json['totalStudents'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'totalStudents': totalStudents,
    };
  }
}

class AcademicTerm {
  final String term;
  final String academicYear;

  AcademicTerm({required this.term, required this.academicYear});

  factory AcademicTerm.fromJson(Map<String, dynamic> json) {
    return AcademicTerm(
      term: json['term'] ?? '',
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'term': term, 'academicYear': academicYear};
  }
}

class FeeStructure {
  final String id;
  final int version;
  final bool isActive;
  final String createdAt;

  FeeStructure({
    required this.id,
    required this.version,
    required this.isActive,
    required this.createdAt,
  });

  factory FeeStructure.fromJson(Map<String, dynamic> json) {
    return FeeStructure(
      id: json['_id'] ?? '',
      version: json['version'] ?? 0,
      isActive: json['isActive'] ?? false,
      createdAt: json['createdAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'version': version,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}

class FeeBreakdown {
  final BaseFee baseFee;
  final List<AddOnFee> addOns;

  FeeBreakdown({required this.baseFee, required this.addOns});

  factory FeeBreakdown.fromJson(Map<String, dynamic> json) {
    return FeeBreakdown(
      baseFee: BaseFee.fromJson(json['baseFee'] ?? {}),
      addOns:
          (json['addOns'] as List<dynamic>?)
              ?.map((item) => AddOnFee.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee.toJson(),
      'addOns': addOns.map((item) => item.toJson()).toList(),
    };
  }
}

class BaseFee {
  final String name;
  final double amount;
  final String description;
  final bool compulsory;
  final String category;

  BaseFee({
    required this.name,
    required this.amount,
    required this.description,
    required this.compulsory,
    required this.category,
  });

  factory BaseFee.fromJson(Map<String, dynamic> json) {
    return BaseFee(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      compulsory: json['compulsory'] ?? false,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'description': description,
      'compulsory': compulsory,
      'category': category,
    };
  }
}

class AddOnFee {
  final String name;
  final double amount;
  final String description;
  final bool compulsory;
  final String category;

  AddOnFee({
    required this.name,
    required this.amount,
    required this.description,
    required this.compulsory,
    required this.category,
  });

  factory AddOnFee.fromJson(Map<String, dynamic> json) {
    return AddOnFee(
      name: json['name'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      description: json['description'] ?? '',
      compulsory: json['compulsory'] ?? false,
      category: json['category'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'description': description,
      'compulsory': compulsory,
      'category': category,
    };
  }
}

class Totals {
  final double baseFee;
  final double addOnFees;
  final double totalFees;
  final double totalExpectedRevenue;

  Totals({
    required this.baseFee,
    required this.addOnFees,
    required this.totalFees,
    required this.totalExpectedRevenue,
  });

  factory Totals.fromJson(Map<String, dynamic> json) {
    return Totals(
      baseFee: (json['baseFee'] ?? 0).toDouble(),
      addOnFees: (json['addOnFees'] ?? 0).toDouble(),
      totalFees: (json['totalFees'] ?? 0).toDouble(),
      totalExpectedRevenue: (json['totalExpectedRevenue'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee,
      'addOnFees': addOnFees,
      'totalFees': totalFees,
      'totalExpectedRevenue': totalExpectedRevenue,
    };
  }
}

class PaymentStatistics {
  final int totalStudents;
  final int paidStudents;
  final int partialStudents;
  final int owingStudents;
  final double totalPaidAmount;
  final double totalOutstandingAmount;
  final double overallCompletionPercentage;

  PaymentStatistics({
    required this.totalStudents,
    required this.paidStudents,
    required this.partialStudents,
    required this.owingStudents,
    required this.totalPaidAmount,
    required this.totalOutstandingAmount,
    required this.overallCompletionPercentage,
  });

  factory PaymentStatistics.fromJson(Map<String, dynamic> json) {
    return PaymentStatistics(
      totalStudents: json['totalStudents'] ?? 0,
      paidStudents: json['paidStudents'] ?? 0,
      partialStudents: json['partialStudents'] ?? 0,
      owingStudents: json['owingStudents'] ?? 0,
      totalPaidAmount: (json['totalPaidAmount'] ?? 0).toDouble(),
      totalOutstandingAmount: (json['totalOutstandingAmount'] ?? 0).toDouble(),
      overallCompletionPercentage:
          (json['overallCompletionPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'paidStudents': paidStudents,
      'partialStudents': partialStudents,
      'owingStudents': owingStudents,
      'totalPaidAmount': totalPaidAmount,
      'totalOutstandingAmount': totalOutstandingAmount,
      'overallCompletionPercentage': overallCompletionPercentage,
    };
  }
}

class PaymentBreakdown {
  final BaseFeePayment baseFee;
  final List<AddOnPayment> addOns;

  PaymentBreakdown({required this.baseFee, required this.addOns});

  factory PaymentBreakdown.fromJson(Map<String, dynamic> json) {
    return PaymentBreakdown(
      baseFee: BaseFeePayment.fromJson(json['baseFee'] ?? {}),
      addOns:
          (json['addOns'] as List<dynamic>?)
              ?.map((item) => AddOnPayment.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee.toJson(),
      'addOns': addOns.map((item) => item.toJson()).toList(),
    };
  }
}

class BaseFeePayment {
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  final double completionPercentage;

  BaseFeePayment({
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.completionPercentage,
  });

  factory BaseFeePayment.fromJson(Map<String, dynamic> json) {
    return BaseFeePayment(
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      outstandingAmount: (json['outstandingAmount'] ?? 0).toDouble(),
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'outstandingAmount': outstandingAmount,
      'completionPercentage': completionPercentage,
    };
  }
}

class AddOnPayment {
  final String name;
  final double totalAmount;
  final double paidAmount;
  final double outstandingAmount;
  final double completionPercentage;

  AddOnPayment({
    required this.name,
    required this.totalAmount,
    required this.paidAmount,
    required this.outstandingAmount,
    required this.completionPercentage,
  });

  factory AddOnPayment.fromJson(Map<String, dynamic> json) {
    return AddOnPayment(
      name: json['name'] ?? '',
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      outstandingAmount: (json['outstandingAmount'] ?? 0).toDouble(),
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'totalAmount': totalAmount,
      'paidAmount': paidAmount,
      'outstandingAmount': outstandingAmount,
      'completionPercentage': completionPercentage,
    };
  }
}
