class StudentModel {
  final String id;
  final String admissionNumber;
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;
  final AcademicInfo academicInfo;
  final ParentInfo parentInfo;
  final FinancialInfo financialInfo;
  final String status;
  final int age;

  StudentModel({
    required this.id,
    required this.admissionNumber,
    required this.personalInfo,
    required this.contactInfo,
    required this.academicInfo,
    required this.parentInfo,
    required this.financialInfo,
    required this.status,
    required this.age,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['_id'] ?? json['id'] ?? '',
      admissionNumber: json['admissionNumber'] ?? '',
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      academicInfo: AcademicInfo.fromJson(json['academicInfo'] ?? {}),
      parentInfo: ParentInfo.fromJson(json['parentInfo'] ?? {}),
      financialInfo: FinancialInfo.fromJson(json['financialInfo'] ?? {}),
      status: json['status'] ?? 'active',
      age: json['age'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'admissionNumber': admissionNumber,
      'personalInfo': personalInfo.toJson(),
      'contactInfo': contactInfo.toJson(),
      'academicInfo': academicInfo.toJson(),
      'parentInfo': parentInfo.toJson(),
      'financialInfo': financialInfo.toJson(),
      'status': status,
      'age': age,
    };
  }

  String get fullName => '${personalInfo.firstName} ${personalInfo.lastName}';
  String get className => academicInfo.currentClass?.name ?? 'N/A';
  String get parentName =>
      parentInfo.father?.personalInfo.fullName ??
      parentInfo.mother?.personalInfo.fullName ??
      parentInfo.guardian?.personalInfo.fullName ??
      'N/A';
}

class PersonalInfo {
  final String firstName;
  final String lastName;
  final String? middleName;
  final String dateOfBirth;
  final String gender;
  final String nationality;
  final String stateOfOrigin;
  final String localGovernment;
  final String religion;
  final String bloodGroup;
  final String? profileImage;

  PersonalInfo({
    required this.firstName,
    required this.lastName,
    this.middleName,
    required this.dateOfBirth,
    required this.gender,
    required this.nationality,
    required this.stateOfOrigin,
    required this.localGovernment,
    required this.religion,
    required this.bloodGroup,
    this.profileImage,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      middleName: json['middleName'],
      dateOfBirth: json['dateOfBirth'] ?? '',
      gender: json['gender'] ?? '',
      nationality: json['nationality'] ?? '',
      stateOfOrigin: json['stateOfOrigin'] ?? '',
      localGovernment: json['localGovernment'] ?? '',
      religion: json['religion'] ?? '',
      bloodGroup: json['bloodGroup'] ?? '',
      profileImage: json['profileImage'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'dateOfBirth': dateOfBirth,
      'gender': gender,
      'nationality': nationality,
      'stateOfOrigin': stateOfOrigin,
      'localGovernment': localGovernment,
      'religion': religion,
      'bloodGroup': bloodGroup,
      'profileImage': profileImage,
    };
  }

  String get fullName => '$firstName $lastName';
}

class ContactInfo {
  final Address address;
  final String phone;
  final String email;

  ContactInfo({
    required this.address,
    required this.phone,
    required this.email,
  });

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      address: Address.fromJson(json['address'] ?? {}),
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'address': address.toJson(), 'phone': phone, 'email': email};
  }
}

class Address {
  final String street;
  final String city;
  final String state;
  final String country;

  Address({
    required this.street,
    required this.city,
    required this.state,
    required this.country,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      country: json['country'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'street': street, 'city': city, 'state': state, 'country': country};
  }
}

class AcademicInfo {
  final ClassInfo? currentClass;
  final String academicYear;
  final String admissionDate;
  final String studentType;

  AcademicInfo({
    this.currentClass,
    required this.academicYear,
    required this.admissionDate,
    required this.studentType,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) {
    return AcademicInfo(
      currentClass:
          json['currentClass'] != null
              ? ClassInfo.fromJson(json['currentClass'])
              : null,
      academicYear: json['academicYear'] ?? '',
      admissionDate: json['admissionDate'] ?? '',
      studentType: json['studentType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentClass': currentClass?.toJson(),
      'academicYear': academicYear,
      'admissionDate': admissionDate,
      'studentType': studentType,
    };
  }
}

class ClassInfo {
  final String id;
  final String name;
  final String level;
  final int totalFees;
  final int currentEnrollment;

  ClassInfo({
    required this.id,
    required this.name,
    required this.level,
    required this.totalFees,
    required this.currentEnrollment,
  });

  factory ClassInfo.fromJson(Map<String, dynamic> json) {
    return ClassInfo(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      totalFees: json['totalFees'] ?? 0,
      currentEnrollment: json['currentEnrollment'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'level': level,
      'totalFees': totalFees,
      'currentEnrollment': currentEnrollment,
    };
  }
}

class ParentInfo {
  final Parent? father;
  final Parent? mother;
  final Parent? guardian;

  ParentInfo({this.father, this.mother, this.guardian});

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      father: json['father'] != null ? Parent.fromJson(json['father']) : null,
      mother: json['mother'] != null ? Parent.fromJson(json['mother']) : null,
      guardian:
          json['guardian'] != null ? Parent.fromJson(json['guardian']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'father': father?.toJson(),
      'mother': mother?.toJson(),
      'guardian': guardian?.toJson(),
    };
  }
}

class Parent {
  final String id;
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;

  Parent({
    required this.id,
    required this.personalInfo,
    required this.contactInfo,
  });

  factory Parent.fromJson(Map<String, dynamic> json) {
    return Parent(
      id: json['_id'] ?? json['id'] ?? '',
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personalInfo': personalInfo.toJson(),
      'contactInfo': contactInfo.toJson(),
    };
  }
}

class FinancialInfo {
  final int outstandingBalance;
  final String feeStatus;
  final int totalFees;
  final int paidAmount;

  FinancialInfo({
    required this.outstandingBalance,
    required this.feeStatus,
    required this.totalFees,
    required this.paidAmount,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) {
    return FinancialInfo(
      outstandingBalance: json['outstandingBalance'] ?? 0,
      feeStatus: json['feeStatus'] ?? 'pending',
      totalFees: json['totalFees'] ?? 0,
      paidAmount: json['paidAmount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'outstandingBalance': outstandingBalance,
      'feeStatus': feeStatus,
      'totalFees': totalFees,
      'paidAmount': paidAmount,
    };
  }
}

class StudentsResponse {
  final bool success;
  final StudentsData data;

  StudentsResponse({required this.success, required this.data});

  factory StudentsResponse.fromJson(Map<String, dynamic> json) {
    return StudentsResponse(
      success: json['success'] ?? false,
      data: StudentsData.fromJson(json['data'] ?? {}),
    );
  }
}

class StudentsData {
  final List<StudentModel> students;
  final PaginationInfo pagination;

  StudentsData({required this.students, required this.pagination});

  factory StudentsData.fromJson(Map<String, dynamic> json) {
    return StudentsData(
      students:
          (json['students'] as List?)
              ?.map((student) => StudentModel.fromJson(student))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalStudents;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalStudents,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalStudents: json['totalStudents'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}
