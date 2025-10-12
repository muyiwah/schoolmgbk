/// Model for admin manual payment update request
class AdminPaymentUpdateModel {
  final String studentId;
  final String academicYear;
  final String term;
  final String? paymentStatus; // 'Pending', 'Completed', 'Failed', 'Refunded'
  final String? reference;
  final int? amount;
  final String? method;
  final String? description;
  final String? remarks;
  final String? receiptUrl;
  final Map<String, dynamic>? feeBreakdown;
  final Map<String, dynamic>? paymentBreakdown;

  AdminPaymentUpdateModel({
    required this.studentId,
    required this.academicYear,
    required this.term,
    this.paymentStatus,
    this.reference,
    this.amount,
    this.method,
    this.description,
    this.remarks,
    this.receiptUrl,
    this.feeBreakdown,
    this.paymentBreakdown,
  });

  factory AdminPaymentUpdateModel.fromJson(Map<String, dynamic> json) {
    return AdminPaymentUpdateModel(
      studentId: json['studentId'] ?? '',
      academicYear: json['academicYear'] ?? '',
      term: json['term'] ?? '',
      paymentStatus: json['paymentStatus'],
      reference: json['reference'],
      amount: json['amount'],
      method: json['method'],
      description: json['description'],
      remarks: json['remarks'],
      receiptUrl: json['receiptUrl'],
      feeBreakdown:
          json['feeBreakdown'] != null
              ? Map<String, dynamic>.from(json['feeBreakdown'])
              : null,
      paymentBreakdown:
          json['paymentBreakdown'] != null
              ? Map<String, dynamic>.from(json['paymentBreakdown'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'studentId': studentId,
      'academicYear': academicYear,
      'term': term,
    };

    // Only add fields that have values
    if (paymentStatus != null) json['paymentStatus'] = paymentStatus;
    if (reference != null) json['reference'] = reference;
    if (amount != null) json['amount'] = amount;
    if (method != null) json['method'] = method;
    if (description != null) json['description'] = description;
    if (remarks != null) json['remarks'] = remarks;
    if (receiptUrl != null) json['receiptUrl'] = receiptUrl;
    if (feeBreakdown != null) json['feeBreakdown'] = feeBreakdown;
    if (paymentBreakdown != null) json['paymentBreakdown'] = paymentBreakdown;

    return json;
  }

  /// Create a copy with updated fields
  AdminPaymentUpdateModel copyWith({
    String? studentId,
    String? academicYear,
    String? term,
    String? paymentStatus,
    String? reference,
    int? amount,
    String? method,
    String? description,
    String? remarks,
    String? receiptUrl,
    Map<String, dynamic>? feeBreakdown,
    Map<String, dynamic>? paymentBreakdown,
  }) {
    return AdminPaymentUpdateModel(
      studentId: studentId ?? this.studentId,
      academicYear: academicYear ?? this.academicYear,
      term: term ?? this.term,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      reference: reference ?? this.reference,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      description: description ?? this.description,
      remarks: remarks ?? this.remarks,
      receiptUrl: receiptUrl ?? this.receiptUrl,
      feeBreakdown: feeBreakdown ?? this.feeBreakdown,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
    );
  }

  /// Validate the model for creating new payment
  bool isValidForCreate() {
    return studentId.isNotEmpty &&
        academicYear.isNotEmpty &&
        term.isNotEmpty &&
        amount != null &&
        amount! > 0 &&
        method != null &&
        method!.isNotEmpty &&
        paymentStatus != null &&
        ['Pending', 'Completed', 'Failed', 'Refunded'].contains(paymentStatus);
  }

  /// Validate the model for updating existing payment
  bool isValidForUpdate() {
    return studentId.isNotEmpty &&
        academicYear.isNotEmpty &&
        term.isNotEmpty &&
        (paymentStatus != null || reference != null || remarks != null);
  }

  /// Get validation errors for creating new payment
  List<String> getValidationErrorsForCreate() {
    final errors = <String>[];

    if (studentId.isEmpty) {
      errors.add('Student ID is required');
    }

    if (academicYear.isEmpty) {
      errors.add('Academic year is required');
    }

    if (term.isEmpty) {
      errors.add('Term is required');
    }

    if (amount == null || amount! <= 0) {
      errors.add('Amount must be greater than 0');
    }

    if (method == null || method!.isEmpty) {
      errors.add('Payment method is required');
    }

    if (paymentStatus == null ||
        ![
          'Pending',
          'Completed',
          'Failed',
          'Refunded',
        ].contains(paymentStatus)) {
      errors.add('Valid payment status is required');
    }

    return errors;
  }

  /// Get validation errors for updating existing payment
  List<String> getValidationErrorsForUpdate() {
    final errors = <String>[];

    if (studentId.isEmpty) {
      errors.add('Student ID is required');
    }

    if (academicYear.isEmpty) {
      errors.add('Academic year is required');
    }

    if (term.isEmpty) {
      errors.add('Term is required');
    }

    if (paymentStatus == null && reference == null && remarks == null) {
      errors.add('At least one field must be provided for update');
    }

    if (paymentStatus != null &&
        ![
          'Pending',
          'Completed',
          'Failed',
          'Refunded',
        ].contains(paymentStatus)) {
      errors.add('Invalid payment status');
    }

    return errors;
  }
}

/// Model for fee breakdown structure
class FeeBreakdownModel {
  final int baseFee;
  final List<FeeAddOnModel> addOns;
  final int totalAmount;

  FeeBreakdownModel({
    required this.baseFee,
    required this.addOns,
    required this.totalAmount,
  });

  factory FeeBreakdownModel.fromJson(Map<String, dynamic> json) {
    return FeeBreakdownModel(
      baseFee: json['baseFee'] ?? 0,
      addOns:
          (json['addOns'] as List<dynamic>?)
              ?.map((addOn) => FeeAddOnModel.fromJson(addOn))
              .toList() ??
          [],
      totalAmount: json['totalAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'baseFee': baseFee,
      'addOns': addOns.map((addOn) => addOn.toJson()).toList(),
      'totalAmount': totalAmount,
    };
  }

  /// Calculate total amount from base fee and add-ons
  int calculateTotal() {
    return baseFee + addOns.fold<int>(0, (sum, addOn) => sum + addOn.amount);
  }
}

/// Model for fee add-on
class FeeAddOnModel {
  final String name;
  final int amount;
  final String? description;

  FeeAddOnModel({required this.name, required this.amount, this.description});

  factory FeeAddOnModel.fromJson(Map<String, dynamic> json) {
    return FeeAddOnModel(
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'amount': amount, 'description': description};
  }
}

/// Model for payment status update response
class PaymentStatusUpdateResponse {
  final bool success;
  final String message;
  final PaymentStatusUpdateData? data;

  PaymentStatusUpdateResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory PaymentStatusUpdateResponse.fromJson(Map<String, dynamic> json) {
    return PaymentStatusUpdateResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? PaymentStatusUpdateData.fromJson(json['data'])
              : null,
    );
  }
}

/// Model for payment status update response data
class PaymentStatusUpdateData {
  final String paymentId;
  final String studentId;
  final String academicYear;
  final String term;
  final String paymentStatus;
  final int totalAmount;
  final DateTime updatedAt;
  final String updatedBy;

  PaymentStatusUpdateData({
    required this.paymentId,
    required this.studentId,
    required this.academicYear,
    required this.term,
    required this.paymentStatus,
    required this.totalAmount,
    required this.updatedAt,
    required this.updatedBy,
  });

  factory PaymentStatusUpdateData.fromJson(Map<String, dynamic> json) {
    return PaymentStatusUpdateData(
      paymentId: json['paymentId'] ?? '',
      studentId: json['studentId'] ?? '',
      academicYear: json['academicYear'] ?? '',
      term: json['term'] ?? '',
      paymentStatus: json['paymentStatus'] ?? '',
      totalAmount: json['totalAmount'] ?? 0,
      updatedAt: DateTime.parse(json['updatedAt']),
      updatedBy: json['updatedBy'] ?? '',
    );
  }
}
