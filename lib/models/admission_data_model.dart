/// Comprehensive model for handling admission data from backend
/// This model handles all the nested structures and provides safe parsing
class AdmissionDataModel {
  final PersonalInfoData personalInfo;
  final ContactInfoData contactInfo;
  final AcademicInfoData academicInfo;
  final ParentInfoData parentInfo;
  final MedicalInfoData? medicalInfo;
  final SenInfoData? senInfo;
  final PermissionsData? permissions;
  final SessionInfoData? sessionInfo;
  final BackgroundInfoData? backgroundInfo;
  final LegalInfoData? legalInfo;
  final FundingInfoData? fundingInfo;
  final FinancialInfoData? financialInfo;
  final String? additionalInfo;

  AdmissionDataModel({
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

  factory AdmissionDataModel.fromJson(Map<String, dynamic> json) {
    return AdmissionDataModel(
      personalInfo: PersonalInfoData.fromJson(json['personalInfo'] ?? {}),
      contactInfo: ContactInfoData.fromJson(json['contactInfo'] ?? {}),
      academicInfo: AcademicInfoData.fromJson(json['academicInfo'] ?? {}),
      parentInfo: ParentInfoData.fromJson(json['parentInfo'] ?? {}),
      medicalInfo:
          json['medicalInfo'] != null
              ? MedicalInfoData.fromJson(json['medicalInfo'])
              : null,
      senInfo:
          json['senInfo'] != null
              ? SenInfoData.fromJson(json['senInfo'])
              : null,
      permissions:
          json['permissions'] != null
              ? PermissionsData.fromJson(json['permissions'])
              : null,
      sessionInfo:
          json['sessionInfo'] != null
              ? SessionInfoData.fromJson(json['sessionInfo'])
              : null,
      backgroundInfo:
          json['backgroundInfo'] != null
              ? BackgroundInfoData.fromJson(json['backgroundInfo'])
              : null,
      legalInfo:
          json['legalInfo'] != null
              ? LegalInfoData.fromJson(json['legalInfo'])
              : null,
      fundingInfo:
          json['fundingInfo'] != null
              ? FundingInfoData.fromJson(json['fundingInfo'])
              : null,
      financialInfo:
          json['financialInfo'] != null
              ? FinancialInfoData.fromJson(json['financialInfo'])
              : null,
      additionalInfo: json['additionalInfo'],
    );
  }

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

class PersonalInfoData {
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? nationality;
  final String? stateOfOrigin;
  final String? localGovernment;
  final String? religion;
  final String? bloodGroup;
  final String? languagesSpokenAtHome;
  final String? ethnicBackground;
  final String? formOfIdentification;
  final String? idNumber;
  final bool hasSiblings;
  final List<SiblingDetailData> siblingDetails;
  final String? profileImage;
  final String? previousSchool;

  PersonalInfoData({
    required this.firstName,
    this.middleName,
    required this.lastName,
    this.dateOfBirth,
    this.gender,
    this.nationality,
    this.stateOfOrigin,
    this.localGovernment,
    this.religion,
    this.bloodGroup,
    this.languagesSpokenAtHome,
    this.ethnicBackground,
    this.formOfIdentification,
    this.idNumber,
    this.hasSiblings = false,
    this.siblingDetails = const [],
    this.profileImage,
    this.previousSchool,
  });

  factory PersonalInfoData.fromJson(Map<String, dynamic> json) {
    return PersonalInfoData(
      firstName: json['firstName'] ?? '',
      middleName: json['middleName'],
      lastName: json['lastName'] ?? '',
      dateOfBirth:
          json['dateOfBirth'] != null
              ? DateTime.tryParse(json['dateOfBirth'])
              : null,
      gender: json['gender'],
      nationality: json['nationality'],
      stateOfOrigin: json['stateOfOrigin'],
      localGovernment: json['localGovernment'],
      religion: json['religion'],
      bloodGroup: json['bloodGroup'],
      languagesSpokenAtHome: json['languagesSpokenAtHome'],
      ethnicBackground: json['ethnicBackground'],
      formOfIdentification: json['formOfIdentification'],
      idNumber: json['idNumber'],
      hasSiblings: json['hasSiblings'] ?? false,
      siblingDetails: _parseSiblingDetails(json['siblingDetails']),
      profileImage: json['profileImage'],
      previousSchool: json['previousSchool'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'middleName': middleName,
      'lastName': lastName,
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0],
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
      'hasSiblings': hasSiblings,
      'siblingDetails': siblingDetails.map((s) => s.toJson()).toList(),
      'profileImage': profileImage,
      'previousSchool': previousSchool,
    };
  }

  static List<SiblingDetailData> _parseSiblingDetails(dynamic rawSiblings) {
    if (rawSiblings == null) return [];
    if (rawSiblings is! List) return [];

    return rawSiblings
        .map((e) {
          if (e is Map<String, dynamic>) {
            return SiblingDetailData.fromJson(e);
          } else {
            // Try to extract from object properties
            try {
              final obj = e as dynamic;
              return SiblingDetailData(
                name: obj.name ?? '',
                age: obj.age ?? 0,
                relationship: obj.relationship ?? '',
              );
            } catch (_) {
              return SiblingDetailData(name: '', age: 0, relationship: '');
            }
          }
        })
        .where((s) => s.name.isNotEmpty)
        .toList();
  }
}

class SiblingDetailData {
  final String name;
  final int age;
  final String relationship;

  SiblingDetailData({
    required this.name,
    required this.age,
    required this.relationship,
  });

  factory SiblingDetailData.fromJson(Map<String, dynamic> json) {
    return SiblingDetailData(
      name: json['name'] ?? '',
      age: json['age'] ?? 0,
      relationship: json['relationship'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'age': age, 'relationship': relationship};
  }
}

class ContactInfoData {
  final AddressData address;
  final String? phone;
  final String? email;

  ContactInfoData({required this.address, this.phone, this.email});

  factory ContactInfoData.fromJson(Map<String, dynamic> json) {
    return ContactInfoData(
      address: AddressData.fromJson(json['address'] ?? {}),
      phone: json['phone'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'address': address.toJson(), 'phone': phone, 'email': email};
  }
}

class AddressData {
  final String? streetNumber;
  final String? streetName;
  final String? city;
  final String? state;
  final String? country;
  final String? postalCode;

  AddressData({
    this.streetNumber,
    this.streetName,
    this.city,
    this.state,
    this.country,
    this.postalCode,
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
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

class AcademicInfoData {
  final ClassInfoData? desiredClass;
  final String? academicYear;
  final DateTime? admissionDate;
  final String? studentType;

  AcademicInfoData({
    this.desiredClass,
    this.academicYear,
    this.admissionDate,
    this.studentType,
  });

  factory AcademicInfoData.fromJson(Map<String, dynamic> json) {
    return AcademicInfoData(
      desiredClass: _parseDesiredClass(json['desiredClass']),
      academicYear: json['academicYear'],
      admissionDate:
          json['admissionDate'] != null
              ? DateTime.tryParse(json['admissionDate'])
              : null,
      studentType: json['studentType'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'desiredClass': desiredClass?.toJson(),
      'academicYear': academicYear,
      'admissionDate': admissionDate?.toIso8601String().split('T')[0],
      'studentType': studentType,
    };
  }

  static ClassInfoData? _parseDesiredClass(dynamic desiredClass) {
    if (desiredClass == null) return null;

    if (desiredClass is Map<String, dynamic>) {
      return ClassInfoData.fromJson(desiredClass);
    } else if (desiredClass is String) {
      // If it's just a string ID, create a minimal class info
      return ClassInfoData(
        id: desiredClass,
        name: '',
        level: '',
        section: '',
        capacity: 0,
      );
    }

    return null;
  }
}

class ClassInfoData {
  final String id;
  final String name;
  final String level;
  final String section;
  final int capacity;

  ClassInfoData({
    required this.id,
    required this.name,
    required this.level,
    required this.section,
    required this.capacity,
  });

  factory ClassInfoData.fromJson(Map<String, dynamic> json) {
    return ClassInfoData(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      section: json['section'] ?? '',
      capacity: json['capacity'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'section': section,
      'capacity': capacity,
    };
  }
}

class ParentInfoData {
  final String? father;
  final String? mother;
  final String? guardian;
  final LegacyParentData? legacy;

  ParentInfoData({this.father, this.mother, this.guardian, this.legacy});

  factory ParentInfoData.fromJson(Map<String, dynamic> json) {
    return ParentInfoData(
      father: json['father'],
      mother: json['mother'],
      guardian: json['guardian'],
      legacy:
          json['legacy'] != null
              ? LegacyParentData.fromJson(json['legacy'])
              : null,
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

class LegacyParentData {
  final String name;
  final String phone;
  final String email;
  final String occupation;
  final String address;

  LegacyParentData({
    required this.name,
    required this.phone,
    required this.email,
    required this.occupation,
    required this.address,
  });

  factory LegacyParentData.fromJson(Map<String, dynamic> json) {
    return LegacyParentData(
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

class MedicalInfoData {
  final GeneralPractitionerData? generalPractitioner;
  final String? medicalHistory;
  final List<String> allergies;
  final String? ongoingMedicalConditions;
  final String? specialNeeds;
  final String? currentMedication;
  final String? immunisationRecord;
  final String? dietaryRequirements;
  final EmergencyContactData? emergencyContact;

  MedicalInfoData({
    this.generalPractitioner,
    this.medicalHistory,
    this.allergies = const [],
    this.ongoingMedicalConditions,
    this.specialNeeds,
    this.currentMedication,
    this.immunisationRecord,
    this.dietaryRequirements,
    this.emergencyContact,
  });

  factory MedicalInfoData.fromJson(Map<String, dynamic> json) {
    return MedicalInfoData(
      generalPractitioner:
          json['generalPractitioner'] != null
              ? GeneralPractitionerData.fromJson(json['generalPractitioner'])
              : null,
      medicalHistory: json['medicalHistory'],
      allergies:
          json['allergies'] is List
              ? (json['allergies'] as List).cast<String>()
              : [],
      ongoingMedicalConditions: json['ongoingMedicalConditions'],
      specialNeeds: json['specialNeeds'],
      currentMedication: json['currentMedication'],
      immunisationRecord: json['immunisationRecord'],
      dietaryRequirements: json['dietaryRequirements'],
      emergencyContact:
          json['emergencyContact'] != null
              ? EmergencyContactData.fromJson(json['emergencyContact'])
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

class GeneralPractitionerData {
  final String? name;
  final String? address;
  final String? telephoneNumber;

  GeneralPractitionerData({this.name, this.address, this.telephoneNumber});

  factory GeneralPractitionerData.fromJson(Map<String, dynamic> json) {
    return GeneralPractitionerData(
      name: json['name'],
      address: json['address'],
      telephoneNumber: json['telephoneNumber'],
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

class EmergencyContactData {
  final String? name;
  final String? relationship;
  final String? phone;
  final String? email;
  final AddressData? address;
  final bool? authorisedToCollectChild;

  EmergencyContactData({
    this.name,
    this.relationship,
    this.phone,
    this.email,
    this.address,
    this.authorisedToCollectChild,
  });

  factory EmergencyContactData.fromJson(Map<String, dynamic> json) {
    return EmergencyContactData(
      name: json['name'],
      relationship: json['relationship'],
      phone: json['phone'],
      email: json['email'],
      address:
          json['address'] != null
              ? AddressData.fromJson(json['address'])
              : null,
      authorisedToCollectChild: json['authorisedToCollectChild'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'relationship': relationship,
      'phone': phone,
      'email': email,
      'address': address?.toJson(),
      'authorisedToCollectChild': authorisedToCollectChild,
    };
  }
}

class SenInfoData {
  final bool hasSpecialNeeds;
  final bool receivingAdditionalSupport;
  final String? supportDetails;
  final bool hasEHCP;
  final String? ehcpDetails;

  SenInfoData({
    this.hasSpecialNeeds = false,
    this.receivingAdditionalSupport = false,
    this.supportDetails,
    this.hasEHCP = false,
    this.ehcpDetails,
  });

  factory SenInfoData.fromJson(Map<String, dynamic> json) {
    return SenInfoData(
      hasSpecialNeeds: json['hasSpecialNeeds'] ?? false,
      receivingAdditionalSupport: json['receivingAdditionalSupport'] ?? false,
      supportDetails: json['supportDetails'],
      hasEHCP: json['hasEHCP'] ?? false,
      ehcpDetails: json['ehcpDetails'],
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

class PermissionsData {
  final bool emergencyMedicalTreatment;
  final bool administrationOfMedication;
  final bool firstAidConsent;
  final bool outingsAndTrips;
  final bool transportConsent;
  final bool useOfPhotosVideos;
  final bool suncreamApplication;
  final bool observationAndAssessment;

  PermissionsData({
    this.emergencyMedicalTreatment = false,
    this.administrationOfMedication = false,
    this.firstAidConsent = false,
    this.outingsAndTrips = false,
    this.transportConsent = false,
    this.useOfPhotosVideos = false,
    this.suncreamApplication = false,
    this.observationAndAssessment = false,
  });

  factory PermissionsData.fromJson(Map<String, dynamic> json) {
    return PermissionsData(
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

class SessionInfoData {
  final String? requestedStartDate;
  final String? daysOfAttendance;
  final String? fundedHours;
  final String? additionalPaidSessions;
  final String? preferredSettlingInSessions;

  SessionInfoData({
    this.requestedStartDate,
    this.daysOfAttendance,
    this.fundedHours,
    this.additionalPaidSessions,
    this.preferredSettlingInSessions,
  });

  factory SessionInfoData.fromJson(Map<String, dynamic> json) {
    return SessionInfoData(
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

class BackgroundInfoData {
  final String? previousChildcareProvider;
  final List<SiblingDetailData> siblings;
  final String? interests;
  final String? toiletTrainingStatus;
  final String? comfortItems;
  final String? sleepRoutine;
  final String? behaviouralConcerns;
  final String? languagesSpokenAtHome;

  BackgroundInfoData({
    this.previousChildcareProvider,
    this.siblings = const [],
    this.interests,
    this.toiletTrainingStatus,
    this.comfortItems,
    this.sleepRoutine,
    this.behaviouralConcerns,
    this.languagesSpokenAtHome,
  });

  factory BackgroundInfoData.fromJson(Map<String, dynamic> json) {
    return BackgroundInfoData(
      previousChildcareProvider: json['previousChildcareProvider'],
      siblings: PersonalInfoData._parseSiblingDetails(json['siblings']),
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
      'siblings': siblings.map((s) => s.toJson()).toList(),
      'interests': interests,
      'toiletTrainingStatus': toiletTrainingStatus,
      'comfortItems': comfortItems,
      'sleepRoutine': sleepRoutine,
      'behaviouralConcerns': behaviouralConcerns,
      'languagesSpokenAtHome': languagesSpokenAtHome,
    };
  }
}

class LegalInfoData {
  final String? legalResponsibility;
  final String? courtOrders;
  final String? safeguardingDisclosure;
  final String? parentSignature;
  final String? signatureDate;

  LegalInfoData({
    this.legalResponsibility,
    this.courtOrders,
    this.safeguardingDisclosure,
    this.parentSignature,
    this.signatureDate,
  });

  factory LegalInfoData.fromJson(Map<String, dynamic> json) {
    return LegalInfoData(
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

class FundingInfoData {
  final bool agreementToPayFees;
  final String? fundingAgreement;

  FundingInfoData({this.agreementToPayFees = false, this.fundingAgreement});

  factory FundingInfoData.fromJson(Map<String, dynamic> json) {
    return FundingInfoData(
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

class FinancialInfoData {
  final String feeStatus;
  final double totalFees;
  final double paidAmount;
  final double outstandingBalance;

  FinancialInfoData({
    this.feeStatus = 'unpaid',
    this.totalFees = 0.0,
    this.paidAmount = 0.0,
    this.outstandingBalance = 0.0,
  });

  factory FinancialInfoData.fromJson(Map<String, dynamic> json) {
    return FinancialInfoData(
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
