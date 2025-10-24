class AllTermsClassStatisticsModel {
  final List<ClassStatistics> classes;
  final List<TermGroup> groupedByTerm;
  final OverallStats overallStats;
  final List<String> availableTerms;
  final List<String> availableAcademicYears;
  final Filters filters;

  AllTermsClassStatisticsModel({
    required this.classes,
    required this.groupedByTerm,
    required this.overallStats,
    required this.availableTerms,
    required this.availableAcademicYears,
    required this.filters,
  });

  factory AllTermsClassStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AllTermsClassStatisticsModel(
      classes:
          (json['classes'] as List<dynamic>?)
              ?.map((x) => ClassStatistics.fromJson(x))
              .toList() ??
          [],
      groupedByTerm:
          (json['groupedByTerm'] as List<dynamic>?)
              ?.map((x) => TermGroup.fromJson(x))
              .toList() ??
          [],
      overallStats: OverallStats.fromJson(json['overallStats'] ?? {}),
      availableTerms:
          (json['availableTerms'] as List<dynamic>?)
              ?.map((x) => x.toString())
              .toList() ??
          [],
      availableAcademicYears:
          (json['availableAcademicYears'] as List<dynamic>?)
              ?.map((x) => x.toString())
              .toList() ??
          [],
      filters: Filters.fromJson(json['filters'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes': classes.map((x) => x.toJson()).toList(),
      'groupedByTerm': groupedByTerm.map((x) => x.toJson()).toList(),
      'overallStats': overallStats.toJson(),
      'availableTerms': availableTerms,
      'availableAcademicYears': availableAcademicYears,
      'filters': filters.toJson(),
    };
  }
}

class TermGroup {
  final String academicYear;
  final String term;
  final List<ClassStatistics> classes;

  TermGroup({
    required this.academicYear,
    required this.term,
    required this.classes,
  });

  factory TermGroup.fromJson(Map<String, dynamic> json) {
    return TermGroup(
      academicYear: json['academicYear']?.toString() ?? '',
      term: json['term']?.toString() ?? '',
      classes:
          (json['classes'] as List<dynamic>?)
              ?.map((x) => ClassStatistics.fromJson(x))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'academicYear': academicYear,
      'term': term,
      'classes': classes.map((x) => x.toJson()).toList(),
    };
  }
}

class ClassStatistics {
  final String? id;
  final String? name;
  final String? level;
  final ClassLevel? classLevel;
  final String? section;
  final String? academicYear;
  final String? term;
  final int? studentCount;
  final int? capacity;
  final double? capacityUtilization;
  final FeeStructureDetails? feeStructureDetails;
  final int? expectedRevenue;
  final int? totalPaidAmount;
  final int? paidStudentsCount;
  final int? averageFeePerStudent;
  final double? paymentCollectionRate;

  ClassStatistics({
    this.id,
    this.name,
    this.level,
    this.classLevel,
    this.section,
    this.academicYear,
    this.term,
    this.studentCount,
    this.capacity,
    this.capacityUtilization,
    this.feeStructureDetails,
    this.expectedRevenue,
    this.totalPaidAmount,
    this.paidStudentsCount,
    this.averageFeePerStudent,
    this.paymentCollectionRate,
  });

  factory ClassStatistics.fromJson(Map<String, dynamic> json) {
    return ClassStatistics(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      level: json['level']?.toString(),
      classLevel:
          json['classLevel'] != null
              ? ClassLevel.fromJson(json['classLevel'])
              : null,
      section: json['section']?.toString(),
      academicYear: json['academicYear']?.toString(),
      term: json['term']?.toString(),
      studentCount: json['studentCount'] as int?,
      capacity: json['capacity'] as int?,
      capacityUtilization: (json['capacityUtilization'] as num?)?.toDouble(),
      feeStructureDetails:
          json['feeStructureDetails'] != null
              ? FeeStructureDetails.fromJson(json['feeStructureDetails'])
              : null,
      expectedRevenue: json['expectedRevenue'] as int?,
      totalPaidAmount: json['totalPaidAmount'] as int?,
      paidStudentsCount: json['paidStudentsCount'] as int?,
      averageFeePerStudent: json['averageFeePerStudent'] as int?,
      paymentCollectionRate:
          (json['paymentCollectionRate'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'classLevel': classLevel?.toJson(),
      'section': section,
      'academicYear': academicYear,
      'term': term,
      'studentCount': studentCount,
      'capacity': capacity,
      'capacityUtilization': capacityUtilization,
      'feeStructureDetails': feeStructureDetails?.toJson(),
      'expectedRevenue': expectedRevenue,
      'totalPaidAmount': totalPaidAmount,
      'paidStudentsCount': paidStudentsCount,
      'averageFeePerStudent': averageFeePerStudent,
      'paymentCollectionRate': paymentCollectionRate,
    };
  }
}

class ClassLevel {
  final String? id;
  final String? name;
  final String? displayName;
  final String? category;
  final String? formattedName;

  ClassLevel({
    this.id,
    this.name,
    this.displayName,
    this.category,
    this.formattedName,
  });

  factory ClassLevel.fromJson(Map<String, dynamic> json) {
    return ClassLevel(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      displayName: json['displayName']?.toString(),
      category: json['category']?.toString(),
      formattedName: json['formattedName']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'displayName': displayName,
      'category': category,
      'formattedName': formattedName,
    };
  }
}

class FeeStructureDetails {
  final String? id;
  final String? name;
  final String? description;
  final int? baseFee;
  final List<AddOn> addOns;
  final int? totalFee;
  final int? requiredFeeAmount;
  final int? optionalFeeAmount;
  final double? requiredFeePercentage;
  final double? optionalFeePercentage;
  final int? version;
  final bool? isActive;
  final String? createdAt;

  FeeStructureDetails({
    this.id,
    this.name,
    this.description,
    this.baseFee,
    required this.addOns,
    this.totalFee,
    this.requiredFeeAmount,
    this.optionalFeeAmount,
    this.requiredFeePercentage,
    this.optionalFeePercentage,
    this.version,
    this.isActive,
    this.createdAt,
  });

  factory FeeStructureDetails.fromJson(Map<String, dynamic> json) {
    return FeeStructureDetails(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      description: json['description']?.toString(),
      baseFee: json['baseFee'] as int?,
      addOns:
          (json['addOns'] as List<dynamic>?)
              ?.map((x) => AddOn.fromJson(x))
              .toList() ??
          [],
      totalFee: json['totalFee'] as int?,
      requiredFeeAmount: json['requiredFeeAmount'] as int?,
      optionalFeeAmount: json['optionalFeeAmount'] as int?,
      requiredFeePercentage:
          (json['requiredFeePercentage'] as num?)?.toDouble(),
      optionalFeePercentage:
          (json['optionalFeePercentage'] as num?)?.toDouble(),
      version: json['version'] as int?,
      isActive: json['isActive'] as bool?,
      createdAt: json['createdAt']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'baseFee': baseFee,
      'addOns': addOns.map((x) => x.toJson()).toList(),
      'totalFee': totalFee,
      'requiredFeeAmount': requiredFeeAmount,
      'optionalFeeAmount': optionalFeeAmount,
      'requiredFeePercentage': requiredFeePercentage,
      'optionalFeePercentage': optionalFeePercentage,
      'version': version,
      'isActive': isActive,
      'createdAt': createdAt,
    };
  }
}

class AddOn {
  final String? id;
  final String? name;
  final int? amount;
  final bool? compulsory;
  final bool? isActive;

  AddOn({this.id, this.name, this.amount, this.compulsory, this.isActive});

  factory AddOn.fromJson(Map<String, dynamic> json) {
    return AddOn(
      id: json['_id']?.toString(),
      name: json['name']?.toString(),
      amount: json['amount'] as int?,
      compulsory: json['compulsory'] as bool?,
      isActive: json['isActive'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'amount': amount,
      'compulsory': compulsory,
      'isActive': isActive,
    };
  }
}

class OverallStats {
  final int? totalClasses;
  final int? totalStudents;
  final int? totalExpectedRevenue;
  final int? totalPaidAmount;
  final double? averageStudentsPerClass;
  final int? averageFeePerStudent;
  final double? overallCollectionRate;
  final ClassWithHighestFee? classWithHighestFee;
  final FeeStructureStats? feeStructureStats;

  OverallStats({
    this.totalClasses,
    this.totalStudents,
    this.totalExpectedRevenue,
    this.totalPaidAmount,
    this.averageStudentsPerClass,
    this.averageFeePerStudent,
    this.overallCollectionRate,
    this.classWithHighestFee,
    this.feeStructureStats,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalClasses: json['totalClasses'] as int?,
      totalStudents: json['totalStudents'] as int?,
      totalExpectedRevenue: json['totalExpectedRevenue'] as int?,
      totalPaidAmount: json['totalPaidAmount'] as int?,
      averageStudentsPerClass:
          (json['averageStudentsPerClass'] as num?)?.toDouble(),
      averageFeePerStudent: json['averageFeePerStudent'] as int?,
      overallCollectionRate:
          (json['overallCollectionRate'] as num?)?.toDouble(),
      classWithHighestFee:
          json['classWithHighestFee'] != null
              ? ClassWithHighestFee.fromJson(json['classWithHighestFee'])
              : null,
      feeStructureStats:
          json['feeStructureStats'] != null
              ? FeeStructureStats.fromJson(json['feeStructureStats'])
              : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalClasses': totalClasses,
      'totalStudents': totalStudents,
      'totalExpectedRevenue': totalExpectedRevenue,
      'totalPaidAmount': totalPaidAmount,
      'averageStudentsPerClass': averageStudentsPerClass,
      'averageFeePerStudent': averageFeePerStudent,
      'overallCollectionRate': overallCollectionRate,
      'classWithHighestFee': classWithHighestFee?.toJson(),
      'feeStructureStats': feeStructureStats?.toJson(),
    };
  }
}

class ClassWithHighestFee {
  final String? name;
  final String? level;
  final String? section;
  final int? totalPaidAmount;
  final int? studentCount;

  ClassWithHighestFee({
    this.name,
    this.level,
    this.section,
    this.totalPaidAmount,
    this.studentCount,
  });

  factory ClassWithHighestFee.fromJson(Map<String, dynamic> json) {
    return ClassWithHighestFee(
      name: json['name']?.toString(),
      level: json['level']?.toString(),
      section: json['section']?.toString(),
      totalPaidAmount: json['totalPaidAmount'] as int?,
      studentCount: json['studentCount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'level': level,
      'section': section,
      'totalPaidAmount': totalPaidAmount,
      'studentCount': studentCount,
    };
  }
}

class FeeStructureStats {
  final int? classesWithFeeStructure;
  final double? averageRequiredFeePercentage;
  final double? averageOptionalFeePercentage;
  final int? totalRequiredFeeAmount;
  final int? totalOptionalFeeAmount;

  FeeStructureStats({
    this.classesWithFeeStructure,
    this.averageRequiredFeePercentage,
    this.averageOptionalFeePercentage,
    this.totalRequiredFeeAmount,
    this.totalOptionalFeeAmount,
  });

  factory FeeStructureStats.fromJson(Map<String, dynamic> json) {
    return FeeStructureStats(
      classesWithFeeStructure: json['classesWithFeeStructure'] as int?,
      averageRequiredFeePercentage:
          (json['averageRequiredFeePercentage'] as num?)?.toDouble(),
      averageOptionalFeePercentage:
          (json['averageOptionalFeePercentage'] as num?)?.toDouble(),
      totalRequiredFeeAmount: json['totalRequiredFeeAmount'] as int?,
      totalOptionalFeeAmount: json['totalOptionalFeeAmount'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classesWithFeeStructure': classesWithFeeStructure,
      'averageRequiredFeePercentage': averageRequiredFeePercentage,
      'averageOptionalFeePercentage': averageOptionalFeePercentage,
      'totalRequiredFeeAmount': totalRequiredFeeAmount,
      'totalOptionalFeeAmount': totalOptionalFeeAmount,
    };
  }
}

class Filters {
  final String? term;
  final String? academicYear;

  Filters({this.term, this.academicYear});

  factory Filters.fromJson(Map<String, dynamic> json) {
    return Filters(
      term: json['term']?.toString(),
      academicYear: json['academicYear']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'term': term, 'academicYear': academicYear};
  }
}
