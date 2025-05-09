// models/school.dart
class School {
  final String id;
  final String name;
  final String address;
  final String phone;
  final String? email;
  final String? website;
  final String? logoUrl;
  final String? motto;
  final DateTime establishedDate;

  School({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    this.email,
    this.website,
    this.logoUrl,
    this.motto,
    DateTime? establishedDate,
  }) : establishedDate = establishedDate ?? DateTime.now();

  factory School.fromMap(Map<String, dynamic> data, String id) {
    return School(
      id: id,
      name: data['name'] ?? '',
      address: data['address'] ?? '',
      phone: data['phone'] ?? '',
      email: data['email'],
      website: data['website'],
      logoUrl: data['logoUrl'],
      motto: data['motto'],
      establishedDate: data['establishedDate']?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'address': address,
      'phone': phone,
      'email': email,
      'website': website,
      'logoUrl': logoUrl,
      'motto': motto,
      'establishedDate': establishedDate,
    };
  }
}
