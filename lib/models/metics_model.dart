// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';



class MetricModel {
  Overview? overview;
  Students? students;
  Finances? finances;
  Academics? academics;
  Staff? staff;

  MetricModel({
    this.overview,
    this.students,
    this.finances,
    this.academics,
    this.staff,
  });

  factory MetricModel.fromJson(Map<String, dynamic> json) => MetricModel(
    overview:
        json["overview"] == null ? null : Overview.fromJson(json["overview"]),
    students:
        json["students"] == null ? null : Students.fromJson(json["students"]),
    finances:
        json["finances"] == null ? null : Finances.fromJson(json["finances"]),
    academics:
        json["academics"] == null
            ? null
            : Academics.fromJson(json["academics"]),
    staff: json["staff"] == null ? null : Staff.fromJson(json["staff"]),
  );

  Map<String, dynamic> toJson() => {
    "overview": overview?.toJson(),
    "students": students?.toJson(),
    "finances": finances?.toJson(),
    "academics": academics?.toJson(),
    "staff": staff?.toJson(),
  };
}

class Academics {
  Classes? classes;
  Assignments? assignments;

  Academics({this.classes, this.assignments});

  factory Academics.fromJson(Map<String, dynamic> json) => Academics(
    classes: json["classes"] == null ? null : Classes.fromJson(json["classes"]),
    assignments:
        json["assignments"] == null
            ? null
            : Assignments.fromJson(json["assignments"]),
  );

  Map<String, dynamic> toJson() => {
    "classes": classes?.toJson(),
    "assignments": assignments?.toJson(),
  };
}

class Assignments {
  List<ByDepartment>? status;
  List<dynamic>? metrics;
  List<dynamic>? performance;

  Assignments({this.status, this.metrics, this.performance});

  factory Assignments.fromJson(Map<String, dynamic> json) => Assignments(
    status:
        json["status"] == null
            ? []
            : List<ByDepartment>.from(
              json["status"]!.map((x) => ByDepartment.fromJson(x)),
            ),
    metrics:
        json["metrics"] == null
            ? []
            : List<dynamic>.from(json["metrics"]!.map((x) => x)),
    performance:
        json["performance"] == null
            ? []
            : List<dynamic>.from(json["performance"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "status":
        status == null
            ? []
            : List<dynamic>.from(status!.map((x) => x.toJson())),
    "metrics":
        metrics == null ? [] : List<dynamic>.from(metrics!.map((x) => x)),
    "performance":
        performance == null
            ? []
            : List<dynamic>.from(performance!.map((x) => x)),
  };
}

class ByDepartment {
  String? id;
  int? count;

  ByDepartment({this.id, this.count});

  factory ByDepartment.fromJson(Map<String, dynamic> json) =>
      ByDepartment(id: json["_id"], count: json["count"]);

  Map<String, dynamic> toJson() => {"_id": id, "count": count};
}

class Classes {
  int? total;
  Enrollment? enrollment;

  Classes({this.total, this.enrollment});

  factory Classes.fromJson(Map<String, dynamic> json) => Classes(
    total: json["total"],
    enrollment:
        json["enrollment"] == null
            ? null
            : Enrollment.fromJson(json["enrollment"]),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "enrollment": enrollment?.toJson(),
  };
}

class Enrollment {
  int? total;
  int? capacity;
  String? rate;
  String? utilization;
  List<EnrollmentByClass>? byClass;

  Enrollment({
    this.total,
    this.capacity,
    this.rate,
    this.utilization,
    this.byClass,
  });

  factory Enrollment.fromJson(Map<String, dynamic> json) => Enrollment(
    total: json["total"],
    capacity: json["capacity"],
    rate: json["rate"],
    utilization: json["utilization"],
    byClass:
        json["byClass"] == null
            ? []
            : List<EnrollmentByClass>.from(
              json["byClass"]!.map((x) => EnrollmentByClass.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "capacity": capacity,
    "rate": rate,
    "utilization": utilization,
    "byClass":
        byClass == null
            ? []
            : List<dynamic>.from(byClass!.map((x) => x.toJson())),
  };
}

class EnrollmentByClass {
  String? id;
  int? count;
  String? level;

  EnrollmentByClass({this.id, this.count, this.level});

  factory EnrollmentByClass.fromJson(Map<String, dynamic> json) =>
      EnrollmentByClass(
        id: json["_id"],
        count: json["count"],
        level: json["level"],
      );

  Map<String, dynamic> toJson() => {"_id": id, "count": count, "level": level};
}

class Finances {
  List<FeeStatus>? feeStatus;
  Outstanding? outstanding;
  RecentPayments? recentPayments;
  Revenue? revenue;
  List<dynamic>? paymentMethods;
  List<dynamic>? paymentTypes;

  Finances({
    this.feeStatus,
    this.outstanding,
    this.recentPayments,
    this.revenue,
    this.paymentMethods,
    this.paymentTypes,
  });

  factory Finances.fromJson(Map<String, dynamic> json) => Finances(
    feeStatus:
        json["feeStatus"] == null
            ? []
            : List<FeeStatus>.from(
              json["feeStatus"]!.map((x) => FeeStatus.fromJson(x)),
            ),
    outstanding:
        json["outstanding"] == null
            ? null
            : Outstanding.fromJson(json["outstanding"]),
    recentPayments:
        json["recentPayments"] == null
            ? null
            : RecentPayments.fromJson(json["recentPayments"]),
    revenue: json["revenue"] == null ? null : Revenue.fromJson(json["revenue"]),
    paymentMethods:
        json["paymentMethods"] == null
            ? []
            : List<dynamic>.from(json["paymentMethods"]!.map((x) => x)),
    paymentTypes:
        json["paymentTypes"] == null
            ? []
            : List<dynamic>.from(json["paymentTypes"]!.map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "feeStatus":
        feeStatus == null
            ? []
            : List<dynamic>.from(feeStatus!.map((x) => x.toJson())),
    "outstanding": outstanding?.toJson(),
    "recentPayments": recentPayments?.toJson(),
    "revenue": revenue?.toJson(),
    "paymentMethods":
        paymentMethods == null
            ? []
            : List<dynamic>.from(paymentMethods!.map((x) => x)),
    "paymentTypes":
        paymentTypes == null
            ? []
            : List<dynamic>.from(paymentTypes!.map((x) => x)),
  };
}

class FeeStatus {
  String? id;
  int? count;
  int? totalOutstanding;

  FeeStatus({this.id, this.count, this.totalOutstanding});

  factory FeeStatus.fromJson(Map<String, dynamic> json) => FeeStatus(
    id: json["_id"],
    count: json["count"],
    totalOutstanding: json["totalOutstanding"],
  );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "count": count,
    "totalOutstanding": totalOutstanding,
  };
}

class Outstanding {
  int? total;
  List<OutstandingByClass>? byClass;

  Outstanding({this.total, this.byClass});

  factory Outstanding.fromJson(Map<String, dynamic> json) => Outstanding(
    total: json["total"],
    byClass:
        json["byClass"] == null
            ? []
            : List<OutstandingByClass>.from(
              json["byClass"]!.map((x) => OutstandingByClass.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "byClass":
        byClass == null
            ? []
            : List<dynamic>.from(byClass!.map((x) => x.toJson())),
  };
}

class OutstandingByClass {
  String? id;
  int? totalOutstanding;
  int? studentsWithOutstanding;

  OutstandingByClass({
    this.id,
    this.totalOutstanding,
    this.studentsWithOutstanding,
  });

  factory OutstandingByClass.fromJson(Map<String, dynamic> json) =>
      OutstandingByClass(
        id: json["_id"],
        totalOutstanding: json["totalOutstanding"],
        studentsWithOutstanding: json["studentsWithOutstanding"],
      );

  Map<String, dynamic> toJson() => {
    "_id": id,
    "totalOutstanding": totalOutstanding,
    "studentsWithOutstanding": studentsWithOutstanding,
  };
}

class RecentPayments {
  int? amount;
  int? transactions;
  String? period;

  RecentPayments({this.amount, this.transactions, this.period});

  factory RecentPayments.fromJson(Map<String, dynamic> json) => RecentPayments(
    amount: json["amount"],
    transactions: json["transactions"],
    period: json["period"],
  );

  Map<String, dynamic> toJson() => {
    "amount": amount,
    "transactions": transactions,
    "period": period,
  };
}

class Revenue {
  List<dynamic>? trends;
  String? period;
  int? year;

  Revenue({this.trends, this.period, this.year});

  factory Revenue.fromJson(Map<String, dynamic> json) => Revenue(
    trends:
        json["trends"] == null
            ? []
            : List<dynamic>.from(json["trends"]!.map((x) => x)),
    period: json["period"],
    year: json["year"],
  );

  Map<String, dynamic> toJson() => {
    "trends": trends == null ? [] : List<dynamic>.from(trends!.map((x) => x)),
    "period": period,
    "year": year,
  };
}

class Overview {
  int? totalStudents;
  int? totalStaff;
  int? totalClasses;
  int? totalParents;
  DateTime? timestamp;
  String? academicYear;

  Overview({
    this.totalStudents,
    this.totalStaff,
    this.totalClasses,
    this.totalParents,
    this.timestamp,
    this.academicYear,
  });

  factory Overview.fromJson(Map<String, dynamic> json) => Overview(
    totalStudents: json["totalStudents"],
    totalStaff: json["totalStaff"],
    totalClasses: json["totalClasses"],
    totalParents: json["totalParents"],
    timestamp:
        json["timestamp"] == null ? null : DateTime.parse(json["timestamp"]),
    academicYear: json["academicYear"],
  );

  Map<String, dynamic> toJson() => {
    "totalStudents": totalStudents,
    "totalStaff": totalStaff,
    "totalClasses": totalClasses,
    "totalParents": totalParents,
    "timestamp": timestamp?.toIso8601String(),
    "academicYear": academicYear,
  };
}

class Staff {
  int? total;
  List<ByDepartment>? byDepartment;

  Staff({this.total, this.byDepartment});

  factory Staff.fromJson(Map<String, dynamic> json) => Staff(
    total: json["total"],
    byDepartment:
        json["byDepartment"] == null
            ? []
            : List<ByDepartment>.from(
              json["byDepartment"]!.map((x) => ByDepartment.fromJson(x)),
            ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "byDepartment":
        byDepartment == null
            ? []
            : List<dynamic>.from(byDepartment!.map((x) => x.toJson())),
  };
}

class Students {
  int? total;
  Gender? gender;
  List<AgeDistribution>? ageDistribution;
  List<ByDepartment>? typeDistribution;
  List<ByDepartment>? geographicDistribution;

  Students({
    this.total,
    this.gender,
    this.ageDistribution,
    this.typeDistribution,
    this.geographicDistribution,
  });

  factory Students.fromJson(Map<String, dynamic> json) => Students(
    total: json["total"],
    gender: json["gender"] == null ? null : Gender.fromJson(json["gender"]),
    ageDistribution:
        json["ageDistribution"] == null
            ? []
            : List<AgeDistribution>.from(
              json["ageDistribution"]!.map((x) => AgeDistribution.fromJson(x)),
            ),
    typeDistribution:
        json["typeDistribution"] == null
            ? []
            : List<ByDepartment>.from(
              json["typeDistribution"]!.map((x) => ByDepartment.fromJson(x)),
            ),
    geographicDistribution:
        json["geographicDistribution"] == null
            ? []
            : List<ByDepartment>.from(
              json["geographicDistribution"]!.map(
                (x) => ByDepartment.fromJson(x),
              ),
            ),
  );

  Map<String, dynamic> toJson() => {
    "total": total,
    "gender": gender?.toJson(),
    "ageDistribution":
        ageDistribution == null
            ? []
            : List<dynamic>.from(ageDistribution!.map((x) => x.toJson())),
    "typeDistribution":
        typeDistribution == null
            ? []
            : List<dynamic>.from(typeDistribution!.map((x) => x.toJson())),
    "geographicDistribution":
        geographicDistribution == null
            ? []
            : List<dynamic>.from(
              geographicDistribution!.map((x) => x.toJson()),
            ),
  };
}

class AgeDistribution {
  int? id;
  int? count;

  AgeDistribution({this.id, this.count});

  factory AgeDistribution.fromJson(Map<String, dynamic> json) =>
      AgeDistribution(id: json["_id"], count: json["count"]);

  Map<String, dynamic> toJson() => {"_id": id, "count": count};
}

class Gender {
  int? male;
  int? female;
  Ratio? ratio;

  Gender({this.male, this.female, this.ratio});

  factory Gender.fromJson(Map<String, dynamic> json) => Gender(
    male: json["male"],
    female: json["female"],
    ratio: json["ratio"] == null ? null : Ratio.fromJson(json["ratio"]),
  );

  Map<String, dynamic> toJson() => {
    "male": male,
    "female": female,
    "ratio": ratio?.toJson(),
  };
}

class Ratio {
  String? male;
  String? female;

  Ratio({this.male, this.female});

  factory Ratio.fromJson(Map<String, dynamic> json) =>
      Ratio(male: json["male"], female: json["female"]);

  Map<String, dynamic> toJson() => {"male": male, "female": female};
}
