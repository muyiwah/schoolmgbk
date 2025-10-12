class AdmissionModel {
  final String id;
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;
  final AcademicInfo academicInfo;
  final ParentInfo parentInfo;
  final MedicalInfo? medicalInfo;
  final SenInfo? senInfo;
  final Permissions? permissions;
  final SessionInfo? sessionInfo;
  final BackgroundInfo? backgroundInfo;
  final LegalInfo? legalInfo;
  final FundingInfo? fundingInfo;
  final FinancialInfo? financialInfo;
  final String? additionalInfo;
  final String status;
  final DateTime submittedAt;
  final String? submittedBy;

  AdmissionModel({
    required this.id,
    required this.personalInfo,
    required this.contactInfo,
    required this.academicInfo,
    required this.parentInfo,
    this.medicalInfo,
    this.senInfo,
    this.permissions,
    this.sessionInfo,
    this.backgroundInfo,
    this.legalInfo,
    this.fundingInfo,
    this.financialInfo,
    this.additionalInfo,
    required this.status,
    required this.submittedAt,
    this.submittedBy,
  });

  factory AdmissionModel.fromJson(Map<String, dynamic> json) {
    return AdmissionModel(
      id: json['_id'] ?? json['id'] ?? '',
      personalInfo: PersonalInfo.fromJson(json['personalInfo'] ?? {}),
      contactInfo: ContactInfo.fromJson(json['contactInfo'] ?? {}),
      academicInfo: AcademicInfo.fromJson(json['academicInfo'] ?? {}),
      parentInfo: ParentInfo.fromJson(json['parentInfo'] ?? {}),
      medicalInfo:
          json['medicalInfo'] != null
              ? MedicalInfo.fromJson(json['medicalInfo'])
              : null,
      senInfo:
          json['senInfo'] != null ? SenInfo.fromJson(json['senInfo']) : null,
      permissions:
          json['permissions'] != null
              ? Permissions.fromJson(json['permissions'])
              : null,
      sessionInfo:
          json['sessionInfo'] != null
              ? SessionInfo.fromJson(json['sessionInfo'])
              : null,
      backgroundInfo:
          json['backgroundInfo'] != null
              ? BackgroundInfo.fromJson(json['backgroundInfo'])
              : null,
      legalInfo:
          json['legalInfo'] != null
              ? LegalInfo.fromJson(json['legalInfo'])
              : null,
      fundingInfo:
          json['fundingInfo'] != null
              ? FundingInfo.fromJson(json['fundingInfo'])
              : null,
      financialInfo:
          json['financialInfo'] != null
              ? FinancialInfo.fromJson(json['financialInfo'])
              : null,
      additionalInfo: json['additionalInfo'],
      status: json['status'] ?? 'pending',
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
      submittedBy: json['submittedBy'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'personalInfo': personalInfo.toJson(),
      'contactInfo': contactInfo.toJson(),
      'academicInfo': academicInfo.toJson(),
      'parentInfo': parentInfo.toJson(),
      'medicalInfo': medicalInfo?.toJson(),
      'senInfo': senInfo?.toJson(),
      'permissions': permissions?.toJson(),
      'sessionInfo': sessionInfo?.toJson(),
      'backgroundInfo': backgroundInfo?.toJson(),
      'legalInfo': legalInfo?.toJson(),
      'fundingInfo': fundingInfo?.toJson(),
      'financialInfo': financialInfo?.toJson(),
      'additionalInfo': additionalInfo,
      'status': status,
      'submittedAt': submittedAt.toIso8601String(),
      'submittedBy': submittedBy,
    };
  }

  String get fullName => personalInfo.fullName;
  String get statusDisplay => _getStatusDisplay(status);
  int get age => personalInfo.age;

  String _getStatusDisplay(String status) {
    switch (status) {
      case 'pending':
        return 'Pending Review';
      case 'under_review':
        return 'Under Review';
      case 'approved':
        return 'Approved';
      case 'rejected':
        return 'Rejected';
      case 'admitted':
        return 'Admitted';
      default:
        return status;
    }
  }
}

class PersonalInfo {
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime dateOfBirth;
  final String gender;
  final String? nationality;
  final String? stateOfOrigin;
  final String? localGovernment;
  final String? religion;
  final String? bloodGroup;
  final String? languagesSpokenAtHome;
  final String? ethnicBackground;
  final String? formOfIdentification;
  final String? idNumber;
  final String? idPhoto;
  final bool hasSiblings;
  final List<SiblingDetail>? siblingDetails;
  final String? profileImage;
  final String? passportPhoto;
  final String? previousSchool;

  PersonalInfo({
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.dateOfBirth,
    required this.gender,
    this.nationality,
    this.stateOfOrigin,
    this.localGovernment,
    this.religion,
    this.bloodGroup,
    this.languagesSpokenAtHome,
    this.ethnicBackground,
    this.formOfIdentification,
    this.idNumber,
    this.idPhoto,
    this.hasSiblings = false,
    this.siblingDetails,
    this.profileImage,
    this.passportPhoto,
    this.previousSchool,
  });

  factory PersonalInfo.fromJson(Map<String, dynamic> json) {
    return PersonalInfo(
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      dateOfBirth: DateTime.parse(
        json['dateOfBirth'] ?? DateTime.now().toIso8601String(),
      ),
      gender: json['gender'] ?? '',
      nationality: json['nationality'],
      stateOfOrigin: json['stateOfOrigin'],
      localGovernment: json['localGovernment'],
      religion: json['religion'],
      bloodGroup: json['bloodGroup'],
      languagesSpokenAtHome: json['languagesSpokenAtHome'],
      ethnicBackground: json['ethnicBackground'],
      formOfIdentification: json['formOfIdentification'],
      idNumber: json['idNumber'],
      idPhoto: json['idPhoto'],
      hasSiblings: json['hasSiblings'] ?? false,
      siblingDetails:
          json['siblingDetails'] != null
              ? (json['siblingDetails'] as List)
                  .map((s) => SiblingDetail.fromJson(s))
                  .toList()
              : null,
      profileImage: json['profileImage'],
      passportPhoto: json['passportPhoto'],
      previousSchool: json['previousSchool'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth.toIso8601String(),
      'gender': gender,
      'nationality': nationality,
      'stateOfOrigin': stateOfOrigin,
      'localGovernment': localGovernment,
      'religion': religion,
      'bloodGroup': bloodGroup,
      'languagesSpokenAtHome': languagesSpokenAtHome,
      'ethnicBackground': ethnicBackground,
      'formOfIdentification': formOfIdentification,
      'idNumber': idNumber,
      'idPhoto': idPhoto,
      'hasSiblings': hasSiblings,
      'siblingDetails': siblingDetails?.map((s) => s.toJson()).toList(),
      'profileImage': profileImage,
      'passportPhoto': passportPhoto,
      'previousSchool': previousSchool,
    };
  }

  String get fullName {
    if (middleName != null && middleName!.isNotEmpty) {
      return '$firstName $middleName $lastName';
    }
    return '$firstName $lastName';
  }

  int get age {
    final now = DateTime.now();
    final birthYear = dateOfBirth.year;
    final currentYear = now.year;
    int age = currentYear - birthYear;

    // Adjust if birthday hasn't occurred this year
    if (now.month < dateOfBirth.month ||
        (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
      age--;
    }

    return age;
  }
}

class SiblingDetail {
  final String name;
  final int age;
  final String relationship;

  SiblingDetail({
    required this.name,
    required this.age,
    required this.relationship,
  });

  factory SiblingDetail.fromJson(Map<String, dynamic> json) {
    return SiblingDetail(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'relationship': relationship};
  }
}

class ParentInfo {
  final String? father;
  final String? mother;
  final String? guardian;
  final Legacy? legacy;

  ParentInfo({this.father, this.mother, this.guardian, this.legacy});

  factory ParentInfo.fromJson(Map<String, dynamic> json) {
    return ParentInfo(
      father: json['father'],
      mother: json['mother'],
      guardian: json['guardian'],
      legacy: json['legacy'] != null ? Legacy.fromJson(json['legacy']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'father': father,
      'mother': mother,
      'guardian': guardian,
      'legacy': legacy?.toJson(),
    };
  }
}

class Legacy {
  final String name;
  final String phone;
  final String email;
  final String occupation;
  final String address;

  Legacy({
    required this.name,
    required this.phone,
    required this.email,
    required this.occupation,
    required this.address,
  });

  factory Legacy.fromJson(Map<String, dynamic> json) {
    return Legacy(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      occupation: json['occupation'] ?? '',
      address: json['address'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email,
      'occupation': occupation,
      'address': address,
    };
  }
}

class AcademicInfo {
  final String desiredClass;
  final String academicYear;
  final DateTime? admissionDate;
  final String? studentType;

  AcademicInfo({
    required this.desiredClass,
    required this.academicYear,
    this.admissionDate,
    this.studentType,
  });

  factory AcademicInfo.fromJson(Map<String, dynamic> json) {
    String desiredClass = '';

    // Handle both string ID and populated class object
    if (json['desiredClass'] is String) {
      desiredClass = json['desiredClass'] ?? '';
    } else if (json['desiredClass'] is Map<String, dynamic>) {
      // If it's a populated class object, extract both level and ID
      final classData = json['desiredClass'];
      desiredClass = classData['level'] ?? classData['name'] ?? '';
    }

    return AcademicInfo(
      desiredClass: desiredClass,
      academicYear: json['academicYear'] ?? '',
      admissionDate:
          json['admissionDate'] != null
              ? DateTime.parse(json['admissionDate'])
              : null,
      studentType: json['studentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desiredClass': desiredClass,
      'academicYear': academicYear,
      'admissionDate': admissionDate?.toIso8601String(),
      'studentType': studentType,
    };
  }
}

class ContactInfo {
  final Address address;
  final String? phone;
  final String? email;

  ContactInfo({required this.address, this.phone, this.email});

  factory ContactInfo.fromJson(Map<String, dynamic> json) {
    return ContactInfo(
      address: Address.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'address': address.toJson(), 'phone': phone, 'email': email};
  }
}

class Address {
  final String? streetNumber;
  final String? streetName;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  Address({
    this.streetNumber,
    this.streetName,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      streetNumber: json['streetNumber'],
      streetName: json['streetName'],
      city: json['city'],
      state: json['state'],
      country: json['country'],
      postalCode: json['postalCode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streetNumber': streetNumber,
      'streetName': streetName,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
    };
  }
}

class MedicalInfo {
  final GeneralPractitioner? generalPractitioner;
  final String? medicalHistory;
  final List<String>? allergies;
  final String? ongoingMedicalConditions;
  final String? specialNeeds;
  final String? currentMedication;
  final String? immunisationRecord;
  final String? dietaryRequirements;
  final EmergencyContact? emergencyContact;

  MedicalInfo({
    this.generalPractitioner,
    this.medicalHistory,
    this.allergies,
    this.ongoingMedicalConditions,
    this.specialNeeds,
    this.currentMedication,
    this.immunisationRecord,
    this.dietaryRequirements,
    this.emergencyContact,
  });

  factory MedicalInfo.fromJson(Map<String, dynamic> json) {
    return MedicalInfo(
      generalPractitioner:
          json['generalPractitioner'] != null
              ? GeneralPractitioner.fromJson(json['generalPractitioner'])
              : null,
      medicalHistory: json['medicalHistory'],
      allergies:
          json['allergies'] != null
              ? List<String>.from(json['allergies'])
              : null,
      ongoingMedicalConditions: json['ongoingMedicalConditions'],
      specialNeeds: json['specialNeeds'],
      currentMedication: json['currentMedication'],
      immunisationRecord: json['immunisationRecord'],
      dietaryRequirements: json['dietaryRequirements'],
      emergencyContact:
          json['emergencyContact'] != null
              ? EmergencyContact.fromJson(json['emergencyContact'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'generalPractitioner': generalPractitioner?.toJson(),
      'medicalHistory': medicalHistory,
      'allergies': allergies,
      'ongoingMedicalConditions': ongoingMedicalConditions,
      'specialNeeds': specialNeeds,
      'currentMedication': currentMedication,
      'immunisationRecord': immunisationRecord,
      'dietaryRequirements': dietaryRequirements,
      'emergencyContact': emergencyContact?.toJson(),
    };
  }
}

class GeneralPractitioner {
  final String name;
  final String address;
  final String telephoneNumber;

  GeneralPractitioner({
    required this.name,
    required this.address,
    required this.telephoneNumber,
  });

  factory GeneralPractitioner.fromJson(Map<String, dynamic> json) {
    return GeneralPractitioner(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      telephoneNumber: json['telephoneNumber'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'address': address,
      'telephoneNumber': telephoneNumber,
    };
  }
}

class EmergencyContact {
  final String name;
  final String relationship;
  final String phone;
  final String email;
  final Address address;
  final bool authorisedToCollectChild;

  EmergencyContact({
    required this.name,
    required this.relationship,
    required this.phone,
    required this.email,
    required this.address,
    required this.authorisedToCollectChild,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      name: json['name'] ?? '',
      relationship: json['relationship'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      address: Address.fromJson(json['address'] ?? {}),
      authorisedToCollectChild: json['authorisedToCollectChild'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'address': address.toJson(),
      'authorisedToCollectChild': authorisedToCollectChild,
    };
  }
}

class SenInfo {
  final bool hasSpecialNeeds;
  final bool receivingAdditionalSupport;
  final String supportDetails;
  final bool hasEHCP;
  final String ehcpDetails;

  SenInfo({
    this.hasSpecialNeeds = false,
    this.receivingAdditionalSupport = false,
    this.supportDetails = '',
    this.hasEHCP = false,
    this.ehcpDetails = '',
  });

  factory SenInfo.fromJson(Map<String, dynamic> json) {
    return SenInfo(
      hasSpecialNeeds: json['hasSpecialNeeds'] ?? false,
      receivingAdditionalSupport: json['receivingAdditionalSupport'] ?? false,
      supportDetails: json['supportDetails'] ?? '',
      hasEHCP: json['hasEHCP'] ?? false,
      ehcpDetails: json['ehcpDetails'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'hasSpecialNeeds': hasSpecialNeeds,
      'receivingAdditionalSupport': receivingAdditionalSupport,
      'supportDetails': supportDetails,
      'hasEHCP': hasEHCP,
      'ehcpDetails': ehcpDetails,
    };
  }
}

class Permissions {
  final bool emergencyMedicalTreatment;
  final bool administrationOfMedication;
  final bool firstAidConsent;
  final bool outingsAndTrips;
  final bool transportConsent;
  final bool useOfPhotosVideos;
  final bool suncreamApplication;
  final bool observationAndAssessment;

  Permissions({
    this.emergencyMedicalTreatment = false,
    this.administrationOfMedication = false,
    this.firstAidConsent = false,
    this.outingsAndTrips = false,
    this.transportConsent = false,
    this.useOfPhotosVideos = false,
    this.suncreamApplication = false,
    this.observationAndAssessment = false,
  });

  factory Permissions.fromJson(Map<String, dynamic> json) {
    return Permissions(
      emergencyMedicalTreatment: json['emergencyMedicalTreatment'] ?? false,
      administrationOfMedication: json['administrationOfMedication'] ?? false,
      firstAidConsent: json['firstAidConsent'] ?? false,
      outingsAndTrips: json['outingsAndTrips'] ?? false,
      transportConsent: json['transportConsent'] ?? false,
      useOfPhotosVideos: json['useOfPhotosVideos'] ?? false,
      suncreamApplication: json['suncreamApplication'] ?? false,
      observationAndAssessment: json['observationAndAssessment'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'emergencyMedicalTreatment': emergencyMedicalTreatment,
      'administrationOfMedication': administrationOfMedication,
      'firstAidConsent': firstAidConsent,
      'outingsAndTrips': outingsAndTrips,
      'transportConsent': transportConsent,
      'useOfPhotosVideos': useOfPhotosVideos,
      'suncreamApplication': suncreamApplication,
      'observationAndAssessment': observationAndAssessment,
    };
  }
}

class SessionInfo {
  final String? requestedStartDate;
  final String? daysOfAttendance;
  final String? fundedHours;
  final String? additionalPaidSessions;
  final String? preferredSettlingInSessions;

  SessionInfo({
    this.requestedStartDate,
    this.daysOfAttendance,
    this.fundedHours,
    this.additionalPaidSessions,
    this.preferredSettlingInSessions,
  });

  factory SessionInfo.fromJson(Map<String, dynamic> json) {
    return SessionInfo(
      requestedStartDate: json['requestedStartDate'],
      daysOfAttendance: json['daysOfAttendance'],
      fundedHours: json['fundedHours'],
      additionalPaidSessions: json['additionalPaidSessions'],
      preferredSettlingInSessions: json['preferredSettlingInSessions'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'requestedStartDate': requestedStartDate,
      'daysOfAttendance': daysOfAttendance,
      'fundedHours': fundedHours,
      'additionalPaidSessions': additionalPaidSessions,
      'preferredSettlingInSessions': preferredSettlingInSessions,
    };
  }
}

class BackgroundInfo {
  final String? previousChildcareProvider;
  final List<SiblingDetail>? siblings;
  final String? interests;
  final String? toiletTrainingStatus;
  final String? comfortItems;
  final String? sleepRoutine;
  final String? behaviouralConcerns;
  final String? languagesSpokenAtHome;

  BackgroundInfo({
    this.previousChildcareProvider,
    this.siblings,
    this.interests,
    this.toiletTrainingStatus,
    this.comfortItems,
    this.sleepRoutine,
    this.behaviouralConcerns,
    this.languagesSpokenAtHome,
  });

  factory BackgroundInfo.fromJson(Map<String, dynamic> json) {
    return BackgroundInfo(
      previousChildcareProvider: json['previousChildcareProvider'],
      siblings:
          json['siblings'] != null
              ? (json['siblings'] as List)
                  .map((s) => SiblingDetail.fromJson(s))
                  .toList()
              : null,
      interests: json['interests'],
      toiletTrainingStatus: json['toiletTrainingStatus'],
      comfortItems: json['comfortItems'],
      sleepRoutine: json['sleepRoutine'],
      behaviouralConcerns: json['behaviouralConcerns'],
      languagesSpokenAtHome: json['languagesSpokenAtHome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'previousChildcareProvider': previousChildcareProvider,
      'siblings': siblings?.map((s) => s.toJson()).toList(),
      'interests': interests,
      'toiletTrainingStatus': toiletTrainingStatus,
      'comfortItems': comfortItems,
      'sleepRoutine': sleepRoutine,
      'behaviouralConcerns': behaviouralConcerns,
      'languagesSpokenAtHome': languagesSpokenAtHome,
    };
  }
}

class LegalInfo {
  final String? legalResponsibility;
  final String? courtOrders;
  final String? safeguardingDisclosure;
  final String? parentSignature;
  final String? signatureDate;

  LegalInfo({
    this.legalResponsibility,
    this.courtOrders,
    this.safeguardingDisclosure,
    this.parentSignature,
    this.signatureDate,
  });

  factory LegalInfo.fromJson(Map<String, dynamic> json) {
    return LegalInfo(
      legalResponsibility: json['legalResponsibility'],
      courtOrders: json['courtOrders'],
      safeguardingDisclosure: json['safeguardingDisclosure'],
      parentSignature: json['parentSignature'],
      signatureDate: json['signatureDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'legalResponsibility': legalResponsibility,
      'courtOrders': courtOrders,
      'safeguardingDisclosure': safeguardingDisclosure,
      'parentSignature': parentSignature,
      'signatureDate': signatureDate,
    };
  }
}

class FundingInfo {
  final bool agreementToPayFees;
  final String? fundingAgreement;

  FundingInfo({this.agreementToPayFees = false, this.fundingAgreement});

  factory FundingInfo.fromJson(Map<String, dynamic> json) {
    return FundingInfo(
      agreementToPayFees: json['agreementToPayFees'] ?? false,
      fundingAgreement: json['fundingAgreement'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agreementToPayFees': agreementToPayFees,
      'fundingAgreement': fundingAgreement,
    };
  }
}

class FinancialInfo {
  final String feeStatus;
  final double totalFees;
  final double paidAmount;
  final double outstandingBalance;

  FinancialInfo({
    this.feeStatus = 'unpaid',
    this.totalFees = 0.0,
    this.paidAmount = 0.0,
    this.outstandingBalance = 0.0,
  });

  factory FinancialInfo.fromJson(Map<String, dynamic> json) {
    return FinancialInfo(
      feeStatus: json['feeStatus'] ?? 'unpaid',
      totalFees: (json['totalFees'] ?? 0).toDouble(),
      paidAmount: (json['paidAmount'] ?? 0).toDouble(),
      outstandingBalance: (json['outstandingBalance'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feeStatus': feeStatus,
      'totalFees': totalFees,
      'paidAmount': paidAmount,
      'outstandingBalance': outstandingBalance,
    };
  }
}

class ReviewInfo {
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? reviewNotes;
  final String? rejectionReason;

  ReviewInfo({
    this.reviewedBy,
    this.reviewedAt,
    this.reviewNotes,
    this.rejectionReason,
  });

  factory ReviewInfo.fromJson(Map<String, dynamic> json) {
    String? reviewedBy;

    // Handle both string ID and populated user object
    if (json['reviewedBy'] is String) {
      reviewedBy = json['reviewedBy'];
    } else if (json['reviewedBy'] is Map<String, dynamic>) {
      // If it's a populated user object, extract the ID
      reviewedBy = json['reviewedBy']['_id'] ?? json['reviewedBy']['id'];
    }

    return ReviewInfo(
      reviewedBy: reviewedBy,
      reviewedAt:
          json['reviewedAt'] != null
              ? DateTime.parse(json['reviewedAt'])
              : null,
      reviewNotes: json['reviewNotes'],
      rejectionReason: json['rejectionReason'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewedBy': reviewedBy,
      'reviewedAt': reviewedAt?.toIso8601String(),
      'reviewNotes': reviewNotes,
      'rejectionReason': rejectionReason,
    };
  }
}

class AdmissionInfo {
  final String? admittedBy;
  final DateTime? admittedAt;
  final String? admissionNumber;
  final String? studentId;

  AdmissionInfo({
    this.admittedBy,
    this.admittedAt,
    this.admissionNumber,
    this.studentId,
  });

  factory AdmissionInfo.fromJson(Map<String, dynamic> json) {
    String? admittedBy;

    // Handle both string ID and populated user object
    if (json['admittedBy'] is String) {
      admittedBy = json['admittedBy'];
    } else if (json['admittedBy'] is Map<String, dynamic>) {
      // If it's a populated user object, extract the ID
      admittedBy = json['admittedBy']['_id'] ?? json['admittedBy']['id'];
    }

    return AdmissionInfo(
      admittedBy: admittedBy,
      admittedAt:
          json['admittedAt'] != null
              ? DateTime.parse(json['admittedAt'])
              : null,
      admissionNumber: json['admissionNumber'],
      studentId: json['studentId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'admittedBy': admittedBy,
      'admittedAt': admittedAt?.toIso8601String(),
      'admissionNumber': admissionNumber,
      'studentId': studentId,
    };
  }
}

class AdmissionSubmissionModel {
  final PersonalInfo personalInfo;
  final ContactInfo contactInfo;
  final AcademicInfo academicInfo;
  final ParentInfo parentInfo;
  final MedicalInfo? medicalInfo;
  final SenInfo? senInfo;
  final Permissions? permissions;
  final SessionInfo? sessionInfo;
  final BackgroundInfo? backgroundInfo;
  final LegalInfo? legalInfo;
  final FundingInfo? fundingInfo;
  final FinancialInfo? financialInfo;
  final String? additionalInfo;

  AdmissionSubmissionModel({
    required this.personalInfo,
    required this.contactInfo,
    required this.academicInfo,
    required this.parentInfo,
    this.medicalInfo,
    this.senInfo,
    this.permissions,
    this.sessionInfo,
    this.backgroundInfo,
    this.legalInfo,
    this.fundingInfo,
    this.financialInfo,
    this.additionalInfo,
  });

  Map<String, dynamic> toJson() {
    return {
      'personalInfo': personalInfo.toJson(),
      'contactInfo': contactInfo.toJson(),
      'academicInfo': academicInfo.toJson(),
      'parentInfo': parentInfo.toJson(),
      'medicalInfo': medicalInfo?.toJson(),
      'senInfo': senInfo?.toJson(),
      'permissions': permissions?.toJson(),
      'sessionInfo': sessionInfo?.toJson(),
      'backgroundInfo': backgroundInfo?.toJson(),
      'legalInfo': legalInfo?.toJson(),
      'fundingInfo': fundingInfo?.toJson(),
      'financialInfo': financialInfo?.toJson(),
      'additionalInfo': additionalInfo,
    };
  }
}

class AdmissionListResponse {
  final List<AdmissionModel> admissions;
  final PaginationInfo pagination;

  AdmissionListResponse({required this.admissions, required this.pagination});

  factory AdmissionListResponse.fromJson(Map<String, dynamic> json) {
    return AdmissionListResponse(
      admissions:
          (json['data']['admissions'] as List)
              .map((item) => AdmissionModel.fromJson(item))
              .toList(),
      pagination: PaginationInfo.fromJson(json['data']['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final bool hasNextPage;
  final bool hasPrevPage;
  final int limit;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.hasNextPage,
    required this.hasPrevPage,
    required this.limit,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalCount: json['totalCount'] ?? 0,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
      limit: json['limit'] ?? 10,
    );
  }
}

class AdmissionStatistics {
  final Overview overview;
  final List<StatusBreakdown> statusBreakdown;
  final List<ClassDistribution> classDistribution;
  final List<RecentApplication> recentApplications;

  AdmissionStatistics({
    required this.overview,
    required this.statusBreakdown,
    required this.classDistribution,
    required this.recentApplications,
  });

  factory AdmissionStatistics.fromJson(Map<String, dynamic> json) {
    return AdmissionStatistics(
      overview: Overview.fromJson(json['data']['overview']),
      statusBreakdown:
          (json['data']['statusBreakdown'] as List)
              .map((item) => StatusBreakdown.fromJson(item))
              .toList(),
      classDistribution:
          (json['data']['classDistribution'] as List)
              .map((item) => ClassDistribution.fromJson(item))
              .toList(),
      recentApplications:
          (json['data']['recentApplications'] as List)
              .map((item) => RecentApplication.fromJson(item))
              .toList(),
    );
  }
}

class Overview {
  final int totalApplications;
  final double averageAge;
  final String academicYear;

  Overview({
    required this.totalApplications,
    required this.averageAge,
    required this.academicYear,
  });

  factory Overview.fromJson(Map<String, dynamic> json) {
    return Overview(
      totalApplications: json['totalApplications'] ?? 0,
      averageAge: (json['averageAge'] ?? 0).toDouble(),
      academicYear: json['academicYear'] ?? '',
    );
  }
}

class StatusBreakdown {
  final String status;
  final int count;

  StatusBreakdown({required this.status, required this.count});

  factory StatusBreakdown.fromJson(Map<String, dynamic> json) {
    return StatusBreakdown(
      status: json['status'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class ClassDistribution {
  final String className;
  final String level;
  final int count;

  ClassDistribution({
    required this.className,
    required this.level,
    required this.count,
  });

  factory ClassDistribution.fromJson(Map<String, dynamic> json) {
    return ClassDistribution(
      className: json['_id'] ?? '',
      level: json['level'] ?? '',
      count: json['count'] ?? 0,
    );
  }
}

class RecentApplication {
  final String id;
  final String studentName;
  final String desiredClass;
  final String status;
  final DateTime submittedAt;

  RecentApplication({
    required this.id,
    required this.studentName,
    required this.desiredClass,
    required this.status,
    required this.submittedAt,
  });

  factory RecentApplication.fromJson(Map<String, dynamic> json) {
    return RecentApplication(
      id: json['_id'] ?? '',
      studentName: json['studentName'] ?? '',
      desiredClass: json['desiredClass'] ?? '',
      status: json['status'] ?? '',
      submittedAt: DateTime.parse(
        json['submittedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
