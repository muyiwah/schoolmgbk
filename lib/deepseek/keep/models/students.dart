// models/student.dart
class Student {
  final String id;
  final String name;
  final String grade;
  final String parentName;
  final String parentPhone;
  final String? email;
  final String? address;
  final DateTime? dateOfBirth;
  final DateTime enrollmentDate;
  final double outstandingFees;
  final String? photoUrl;

  Student({
    required this.id,
    required this.name,
    required this.grade,
    required this.parentName,
    required this.parentPhone,
    this.email,
    this.address,
    this.dateOfBirth,
    DateTime? enrollmentDate,
    this.outstandingFees = 0,
    this.photoUrl,
  }) : enrollmentDate = enrollmentDate ?? DateTime.now();

  factory Student.fromMap(Map<String, dynamic> data, String id) {
    return Student(
      id: id,
      name: data['name'] ?? '',
      grade: data['grade'] ?? '',
      parentName: data['parentName'] ?? '',
      parentPhone: data['parentPhone'] ?? '',
      email: data['email'],
      address: data['address'],
      dateOfBirth: data['dateOfBirth']?.toDate(),
      enrollmentDate: data['enrollmentDate']?.toDate() ?? DateTime.now(),
      outstandingFees: (data['outstandingFees'] ?? 0).toDouble(),
      photoUrl: data['photoUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'parentName': parentName,
      'parentPhone': parentPhone,
      'email': email,
      'address': address,
      'dateOfBirth': dateOfBirth,
      'enrollmentDate': enrollmentDate,
      'outstandingFees': outstandingFees,
      'photoUrl': photoUrl,
    };
  }

  bool get hasOutstandingFees => outstandingFees > 0;
}
