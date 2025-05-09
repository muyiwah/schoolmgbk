// models/fee.dart
class FeeStructure {
  final String id;
  final String name;
  final String academicYear;
  final Map<String, double> components;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;

  FeeStructure({
    required this.id,
    required this.name,
    required this.academicYear,
    required this.components,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  factory FeeStructure.fromMap(Map<String, dynamic> data, String id) {
    return FeeStructure(
      id: id,
      name: data['name'] ?? '',
      academicYear: data['academicYear'] ?? '',
      components: Map<String, double>.from(data['components'] ?? {}),
      effectiveFrom: data['effectiveFrom']?.toDate() ?? DateTime.now(),
      effectiveTo: data['effectiveTo']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'academicYear': academicYear,
      'components': components,
      'effectiveFrom': effectiveFrom,
      'effectiveTo': effectiveTo,
    };
  }

  double get totalFee =>
      components.values.fold(0, (sum, amount) => sum + amount);
}


// models/payment.dart
class Payment {
  final String id;
  final String studentId;
  final double amount;
  final DateTime date;
  final String method;
  final String? reference;
  final String? notes;
  final DateTime recordedAt;
  final String recordedBy;

  Payment({
    required this.id,
    required this.studentId,
    required this.amount,
    required this.date,
    required this.method,
    this.reference,
    this.notes,
    DateTime? recordedAt,
    required this.recordedBy,
  }) : recordedAt = recordedAt ?? DateTime.now();

  factory Payment.fromMap(Map<String, dynamic> data, String id) {
    return Payment(
      id: id,
      studentId: data['studentId'] ?? '',
      amount: (data['amount'] ?? 0).toDouble(),
      date: data['date']?.toDate() ?? DateTime.now(),
      method: data['method'] ?? 'Cash',
      reference: data['reference'],
      notes: data['notes'],
      recordedAt: data['recordedAt']?.toDate(),
      recordedBy: data['recordedBy'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId,
      'amount': amount,
      'date': date,
      'method': method,
      'reference': reference,
      'notes': notes,
      'recordedAt': recordedAt,
      'recordedBy': recordedBy,
    };
  }
}
