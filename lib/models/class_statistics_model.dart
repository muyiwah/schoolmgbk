class ClassStatisticsModel {
  List<ClassStatistics>? classes;
  OverallStats? overallStats;
  Filters? filters;

  ClassStatisticsModel({this.classes, this.overallStats, this.filters});

  factory ClassStatisticsModel.fromJson(Map<String, dynamic> json) =>
      ClassStatisticsModel(
        classes:
            json["classes"] == null
                ? []
                : List<ClassStatistics>.from(
                  json["classes"]!.map((x) => ClassStatistics.fromJson(x)),
                ),
        overallStats:
            json["overallStats"] == null
                ? null
                : OverallStats.fromJson(json["overallStats"]),
        filters:
            json["filters"] == null ? null : Filters.fromJson(json["filters"]),
      );

  Map<String, dynamic> toJson() => {
    "classes":
        classes == null
            ? []
            : List<dynamic>.from(classes!.map((x) => x.toJson())),
    "overallStats": overallStats?.toJson(),
    "filters": filters?.toJson(),
  };
}

class ClassStatistics {
  String? id;
  String? name;
  String? level;
  ClassLevel? classLevel;
  String? section;
  String? academicYear;
  String? term;
  int? studentCount;
  int? capacity;
  int? capacityUtilization;
  FeeStructureDetails? feeStructureDetails;
  int? expectedRevenue;
  int? totalPaidAmount;
  int? paidStudentsCount;
  int? averageFeePerStudent;
  int? paymentCollectionRate;

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

  factory ClassStatistics.fromJson(Map<String, dynamic> json) =>
      ClassStatistics(
        id: json["_id"],
        name: json["name"],
        level: json["level"],
        classLevel:
            json["classLevel"] == null
                ? null
                : ClassLevel.fromJson(json["classLevel"]),
        section: json["section"],
        academicYear: json["academicYear"],
        term: json["term"],
        studentCount: json["studentCount"],
        capacity: json["capacity"],
        capacityUtilization: json["capacityUtilization"],
        feeStructureDetails:
            json["feeStructureDetails"] == null
                ? null
                : FeeStructureDetails.fromJson(json["feeStructureDetails"]),
        expectedRevenue: json["expectedRevenue"],
        totalPaidAmount: json["totalPaidAmount"],
        paidStudentsCount: json["paidStudentsCount"],
        averageFeePerStudent: json["averageFeePerStudent"],
        paymentCollectionRate: json["paymentCollectionRate"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "name": name,
    "level": level,
    "classLevel": classLevel?.toJson(),
    "section": section,
    "academicYear": academicYear,
    "term": term,
    "studentCount": studentCount,
    "capacity": capacity,
    "capacityUtilization": capacityUtilization,
    "feeStructureDetails": feeStructureDetails?.toJson(),
    "expectedRevenue": expectedRevenue,
    "totalPaidAmount": totalPaidAmount,
    "paidStudentsCount": paidStudentsCount,
    "averageFeePerStudent": averageFeePerStudent,
    "paymentCollectionRate": paymentCollectionRate,
  };
}

class ClassLevel {
  String? name;
  String? displayName;

  ClassLevel({this.name, this.displayName});

  factory ClassLevel.fromJson(Map<String, dynamic> json) =>
      ClassLevel(name: json["name"], displayName: json["displayName"]);

  Map<String, dynamic> toJson() => {"name": name, "displayName": displayName};
}

class FeeStructureDetails {
  int? baseFee;
  List<dynamic>? addOns;
  int? totalFee;
  int? requiredFeeAmount;
  int? optionalFeeAmount;
  int? requiredFeePercentage;
  int? optionalFeePercentage;

  FeeStructureDetails({
    this.baseFee,
    this.addOns,
    this.totalFee,
    this.requiredFeeAmount,
    this.optionalFeeAmount,
    this.requiredFeePercentage,
    this.optionalFeePercentage,
  });

  factory FeeStructureDetails.fromJson(Map<String, dynamic> json) =>
      FeeStructureDetails(
        baseFee: json["baseFee"],
        addOns:
            json["addOns"] == null
                ? []
                : List<dynamic>.from(json["addOns"]!.map((x) => x)),
        totalFee: json["totalFee"],
        requiredFeeAmount: json["requiredFeeAmount"],
        optionalFeeAmount: json["optionalFeeAmount"],
        requiredFeePercentage: json["requiredFeePercentage"],
        optionalFeePercentage: json["optionalFeePercentage"],
      );

  Map<String, dynamic> toJson() => {
    "baseFee": baseFee,
    "addOns": addOns == null ? [] : List<dynamic>.from(addOns!.map((x) => x)),
    "totalFee": totalFee,
    "requiredFeeAmount": requiredFeeAmount,
    "optionalFeeAmount": optionalFeeAmount,
    "requiredFeePercentage": requiredFeePercentage,
    "optionalFeePercentage": optionalFeePercentage,
  };
}

class OverallStats {
  int? totalClasses;
  int? totalStudents;
  int? totalExpectedRevenue;
  int? totalPaidAmount;
  int? averageStudentsPerClass;
  int? averageFeePerStudent;
  int? overallCollectionRate;
  ClassWithHighestFee? classWithHighestFee;
  FeeStructureStats? feeStructureStats;

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

  factory OverallStats.fromJson(Map<String, dynamic> json) => OverallStats(
    totalClasses: json["totalClasses"],
    totalStudents: json["totalStudents"],
    totalExpectedRevenue: json["totalExpectedRevenue"],
    totalPaidAmount: json["totalPaidAmount"],
    averageStudentsPerClass: json["averageStudentsPerClass"],
    averageFeePerStudent: json["averageFeePerStudent"],
    overallCollectionRate: json["overallCollectionRate"],
    classWithHighestFee:
        json["classWithHighestFee"] == null
            ? null
            : ClassWithHighestFee.fromJson(json["classWithHighestFee"]),
    feeStructureStats:
        json["feeStructureStats"] == null
            ? null
            : FeeStructureStats.fromJson(json["feeStructureStats"]),
  );

  Map<String, dynamic> toJson() => {
    "totalClasses": totalClasses,
    "totalStudents": totalStudents,
    "totalExpectedRevenue": totalExpectedRevenue,
    "totalPaidAmount": totalPaidAmount,
    "averageStudentsPerClass": averageStudentsPerClass,
    "averageFeePerStudent": averageFeePerStudent,
    "overallCollectionRate": overallCollectionRate,
    "classWithHighestFee": classWithHighestFee?.toJson(),
    "feeStructureStats": feeStructureStats?.toJson(),
  };
}

class ClassWithHighestFee {
  String? name;
  String? level;
  String? section;
  int? totalPaidAmount;
  int? studentCount;

  ClassWithHighestFee({
    this.name,
    this.level,
    this.section,
    this.totalPaidAmount,
    this.studentCount,
  });

  factory ClassWithHighestFee.fromJson(Map<String, dynamic> json) =>
      ClassWithHighestFee(
        name: json["name"],
        level: json["level"],
        section: json["section"],
        totalPaidAmount: json["totalPaidAmount"],
        studentCount: json["studentCount"],
      );

  Map<String, dynamic> toJson() => {
    "name": name,
    "level": level,
    "section": section,
    "totalPaidAmount": totalPaidAmount,
    "studentCount": studentCount,
  };
}

class FeeStructureStats {
  int? classesWithFeeStructure;
  int? averageRequiredFeePercentage;
  int? averageOptionalFeePercentage;
  int? totalRequiredFeeAmount;
  int? totalOptionalFeeAmount;

  FeeStructureStats({
    this.classesWithFeeStructure,
    this.averageRequiredFeePercentage,
    this.averageOptionalFeePercentage,
    this.totalRequiredFeeAmount,
    this.totalOptionalFeeAmount,
  });

  factory FeeStructureStats.fromJson(Map<String, dynamic> json) =>
      FeeStructureStats(
        classesWithFeeStructure: json["classesWithFeeStructure"],
        averageRequiredFeePercentage: json["averageRequiredFeePercentage"],
        averageOptionalFeePercentage: json["averageOptionalFeePercentage"],
        totalRequiredFeeAmount: json["totalRequiredFeeAmount"],
        totalOptionalFeeAmount: json["totalOptionalFeeAmount"],
      );

  Map<String, dynamic> toJson() => {
    "classesWithFeeStructure": classesWithFeeStructure,
    "averageRequiredFeePercentage": averageRequiredFeePercentage,
    "averageOptionalFeePercentage": averageOptionalFeePercentage,
    "totalRequiredFeeAmount": totalRequiredFeeAmount,
    "totalOptionalFeeAmount": totalOptionalFeeAmount,
  };
}

class Filters {
  String? term;
  String? academicYear;

  Filters({this.term, this.academicYear});

  factory Filters.fromJson(Map<String, dynamic> json) =>
      Filters(term: json["term"], academicYear: json["academicYear"]);

  Map<String, dynamic> toJson() => {"term": term, "academicYear": academicYear};
}
