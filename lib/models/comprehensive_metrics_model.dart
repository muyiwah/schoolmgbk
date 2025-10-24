class ComprehensiveMetricsModel {
  final bool success;
  final ComprehensiveMetricsData data;

  ComprehensiveMetricsModel({required this.success, required this.data});

  factory ComprehensiveMetricsModel.fromJson(Map<String, dynamic> json) {
    return ComprehensiveMetricsModel(
      success: json['success'] ?? false,
      data: ComprehensiveMetricsData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class ComprehensiveMetricsData {
  final OverviewData overview;
  final StudentsData students;
  final FinancesData finances;
  final AcademicsData academics;
  final StaffData staff;

  ComprehensiveMetricsData({
    required this.overview,
    required this.students,
    required this.finances,
    required this.academics,
    required this.staff,
  });

  factory ComprehensiveMetricsData.fromJson(Map<String, dynamic> json) {
    return ComprehensiveMetricsData(
      overview: OverviewData.fromJson(json['overview'] ?? {}),
      students: StudentsData.fromJson(json['students'] ?? {}),
      finances: FinancesData.fromJson(json['finances'] ?? {}),
      academics: AcademicsData.fromJson(json['academics'] ?? {}),
      staff: StaffData.fromJson(json['staff'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overview': overview.toJson(),
      'students': students.toJson(),
      'finances': finances.toJson(),
      'academics': academics.toJson(),
      'staff': staff.toJson(),
    };
  }
}

class OverviewData {
  final int totalStudents;
  final int totalStaff;
  final int totalClasses;
  final int totalParents;
  final String timestamp;
  final String academicYear;

  OverviewData({
    required this.totalStudents,
    required this.totalStaff,
    required this.totalClasses,
    required this.totalParents,
    required this.timestamp,
    required this.academicYear,
  });

  factory OverviewData.fromJson(Map<String, dynamic> json) {
    return OverviewData(
      totalStudents: json['totalStudents'] ?? 0,
      totalStaff: json['totalStaff'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalParents: json['totalParents'] ?? 0,
      timestamp: json['timestamp'] ?? '',
      academicYear: json['academicYear'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalStaff': totalStaff,
      'totalClasses': totalClasses,
      'totalParents': totalParents,
      'timestamp': timestamp,
      'academicYear': academicYear,
    };
  }
}

class StudentsData {
  final int total;
  final GenderDistribution gender;
  final List<AgeDistribution> ageDistribution;
  final List<TypeDistribution> typeDistribution;
  final List<GeographicDistribution> geographicDistribution;

  StudentsData({
    required this.total,
    required this.gender,
    required this.ageDistribution,
    required this.typeDistribution,
    required this.geographicDistribution,
  });

  factory StudentsData.fromJson(Map<String, dynamic> json) {
    return StudentsData(
      total: json['total'] ?? 0,
      gender: GenderDistribution.fromJson(json['gender'] ?? {}),
      ageDistribution:
          (json['ageDistribution'] as List<dynamic>?)
              ?.map((item) => AgeDistribution.fromJson(item))
              .toList() ??
          [],
      typeDistribution:
          (json['typeDistribution'] as List<dynamic>?)
              ?.map((item) => TypeDistribution.fromJson(item))
              .toList() ??
          [],
      geographicDistribution:
          (json['geographicDistribution'] as List<dynamic>?)
              ?.map((item) => GeographicDistribution.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'gender': gender.toJson(),
      'ageDistribution': ageDistribution.map((item) => item.toJson()).toList(),
      'typeDistribution':
          typeDistribution.map((item) => item.toJson()).toList(),
      'geographicDistribution':
          geographicDistribution.map((item) => item.toJson()).toList(),
    };
  }
}

class GenderDistribution {
  final int male;
  final int female;
  final GenderRatio ratio;

  GenderDistribution({
    required this.male,
    required this.female,
    required this.ratio,
  });

  factory GenderDistribution.fromJson(Map<String, dynamic> json) {
    return GenderDistribution(
      male: json['male'] ?? 0,
      female: json['female'] ?? 0,
      ratio: GenderRatio.fromJson(json['ratio'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'male': male, 'female': female, 'ratio': ratio.toJson()};
  }
}

class GenderRatio {
  final String male;
  final String female;

  GenderRatio({required this.male, required this.female});

  factory GenderRatio.fromJson(Map<String, dynamic> json) {
    return GenderRatio(
      male: json['male'] ?? '0',
      female: json['female'] ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {'male': male, 'female': female};
  }
}

class AgeDistribution {
  final dynamic id;
  final int count;

  AgeDistribution({required this.id, required this.count});

  factory AgeDistribution.fromJson(Map<String, dynamic> json) {
    return AgeDistribution(id: json['_id'], count: json['count'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count};
  }
}

class TypeDistribution {
  final String id;
  final int count;

  TypeDistribution({required this.id, required this.count});

  factory TypeDistribution.fromJson(Map<String, dynamic> json) {
    return TypeDistribution(id: json['_id'] ?? '', count: json['count'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count};
  }
}

class GeographicDistribution {
  final String id;
  final int count;

  GeographicDistribution({required this.id, required this.count});

  factory GeographicDistribution.fromJson(Map<String, dynamic> json) {
    return GeographicDistribution(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count};
  }
}

class FinancesData {
  final List<FeeStatus> feeStatus;
  final OutstandingData outstanding;
  final RecentPaymentsData recentPayments;
  final RevenueData revenue;
  final List<dynamic> paymentMethods;
  final List<dynamic> paymentTypes;

  FinancesData({
    required this.feeStatus,
    required this.outstanding,
    required this.recentPayments,
    required this.revenue,
    required this.paymentMethods,
    required this.paymentTypes,
  });

  factory FinancesData.fromJson(Map<String, dynamic> json) {
    return FinancesData(
      feeStatus:
          (json['feeStatus'] as List<dynamic>?)
              ?.map((item) => FeeStatus.fromJson(item))
              .toList() ??
          [],
      outstanding: OutstandingData.fromJson(json['outstanding'] ?? {}),
      recentPayments: RecentPaymentsData.fromJson(json['recentPayments'] ?? {}),
      revenue: RevenueData.fromJson(json['revenue'] ?? {}),
      paymentMethods: json['paymentMethods'] ?? [],
      paymentTypes: json['paymentTypes'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'feeStatus': feeStatus.map((item) => item.toJson()).toList(),
      'outstanding': outstanding.toJson(),
      'recentPayments': recentPayments.toJson(),
      'revenue': revenue.toJson(),
      'paymentMethods': paymentMethods,
      'paymentTypes': paymentTypes,
    };
  }
}

class FeeStatus {
  final String id;
  final int count;
  final int totalOutstanding;

  FeeStatus({
    required this.id,
    required this.count,
    required this.totalOutstanding,
  });

  factory FeeStatus.fromJson(Map<String, dynamic> json) {
    return FeeStatus(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
      totalOutstanding: json['totalOutstanding'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count, 'totalOutstanding': totalOutstanding};
  }
}

class OutstandingData {
  final int total;
  final List<OutstandingByClass> byClass;

  OutstandingData({required this.total, required this.byClass});

  factory OutstandingData.fromJson(Map<String, dynamic> json) {
    return OutstandingData(
      total: json['total'] ?? 0,
      byClass:
          (json['byClass'] as List<dynamic>?)
              ?.map((item) => OutstandingByClass.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'byClass': byClass.map((item) => item.toJson()).toList(),
    };
  }
}

class OutstandingByClass {
  final String id;
  final int totalOutstanding;
  final int studentsWithOutstanding;

  OutstandingByClass({
    required this.id,
    required this.totalOutstanding,
    required this.studentsWithOutstanding,
  });

  factory OutstandingByClass.fromJson(Map<String, dynamic> json) {
    return OutstandingByClass(
      id: json['_id'] ?? '',
      totalOutstanding: json['totalOutstanding'] ?? 0,
      studentsWithOutstanding: json['studentsWithOutstanding'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'totalOutstanding': totalOutstanding,
      'studentsWithOutstanding': studentsWithOutstanding,
    };
  }
}

class RecentPaymentsData {
  final int amount;
  final int transactions;
  final String period;

  RecentPaymentsData({
    required this.amount,
    required this.transactions,
    required this.period,
  });

  factory RecentPaymentsData.fromJson(Map<String, dynamic> json) {
    return RecentPaymentsData(
      amount: json['amount'] ?? 0,
      transactions: json['transactions'] ?? 0,
      period: json['period'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'amount': amount, 'transactions': transactions, 'period': period};
  }
}

class RevenueData {
  final List<dynamic> trends;
  final String period;
  final int year;

  RevenueData({required this.trends, required this.period, required this.year});

  factory RevenueData.fromJson(Map<String, dynamic> json) {
    return RevenueData(
      trends: json['trends'] ?? [],
      period: json['period'] ?? '',
      year: json['year'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {'trends': trends, 'period': period, 'year': year};
  }
}

class AcademicsData {
  final ClassesData classes;
  final AssignmentsData assignments;

  AcademicsData({required this.classes, required this.assignments});

  factory AcademicsData.fromJson(Map<String, dynamic> json) {
    return AcademicsData(
      classes: ClassesData.fromJson(json['classes'] ?? {}),
      assignments: AssignmentsData.fromJson(json['assignments'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'classes': classes.toJson(), 'assignments': assignments.toJson()};
  }
}

class ClassesData {
  final int total;
  final EnrollmentData enrollment;

  ClassesData({required this.total, required this.enrollment});

  factory ClassesData.fromJson(Map<String, dynamic> json) {
    return ClassesData(
      total: json['total'] ?? 0,
      enrollment: EnrollmentData.fromJson(json['enrollment'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'total': total, 'enrollment': enrollment.toJson()};
  }
}

class EnrollmentData {
  final int total;
  final int capacity;
  final String rate;
  final String utilization;
  final List<EnrollmentByClass> byClass;

  EnrollmentData({
    required this.total,
    required this.capacity,
    required this.rate,
    required this.utilization,
    required this.byClass,
  });

  factory EnrollmentData.fromJson(Map<String, dynamic> json) {
    return EnrollmentData(
      total: json['total'] ?? 0,
      capacity: json['capacity'] ?? 0,
      rate: json['rate'] ?? '0',
      utilization: json['utilization'] ?? '0',
      byClass:
          (json['byClass'] as List<dynamic>?)
              ?.map((item) => EnrollmentByClass.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'capacity': capacity,
      'rate': rate,
      'utilization': utilization,
      'byClass': byClass.map((item) => item.toJson()).toList(),
    };
  }
}

class EnrollmentByClass {
  final String id;
  final int count;
  final String level;

  EnrollmentByClass({
    required this.id,
    required this.count,
    required this.level,
  });

  factory EnrollmentByClass.fromJson(Map<String, dynamic> json) {
    return EnrollmentByClass(
      id: json['_id'] ?? '',
      count: json['count'] ?? 0,
      level: json['level'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count, 'level': level};
  }
}

class AssignmentsData {
  final List<dynamic> status;
  final List<dynamic> metrics;
  final List<dynamic> performance;

  AssignmentsData({
    required this.status,
    required this.metrics,
    required this.performance,
  });

  factory AssignmentsData.fromJson(Map<String, dynamic> json) {
    return AssignmentsData(
      status: json['status'] ?? [],
      metrics: json['metrics'] ?? [],
      performance: json['performance'] ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {'status': status, 'metrics': metrics, 'performance': performance};
  }
}

class StaffData {
  final int total;
  final List<StaffByDepartment> byDepartment;

  StaffData({required this.total, required this.byDepartment});

  factory StaffData.fromJson(Map<String, dynamic> json) {
    return StaffData(
      total: json['total'] ?? 0,
      byDepartment:
          (json['byDepartment'] as List<dynamic>?)
              ?.map((item) => StaffByDepartment.fromJson(item))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total': total,
      'byDepartment': byDepartment.map((item) => item.toJson()).toList(),
    };
  }
}

class StaffByDepartment {
  final String id;
  final int count;

  StaffByDepartment({required this.id, required this.count});

  factory StaffByDepartment.fromJson(Map<String, dynamic> json) {
    return StaffByDepartment(id: json['_id'] ?? '', count: json['count'] ?? 0);
  }

  Map<String, dynamic> toJson() {
    return {'_id': id, 'count': count};
  }
}
