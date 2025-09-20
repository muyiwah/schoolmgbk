class ClassResponse {
  final bool success;
  final String message;
  final ClassData data;

  ClassResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ClassResponse.fromJson(Map<String, dynamic> json) {
    return ClassResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: ClassData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'success': success,
      'message': message,
      'data': data.toJson(),
    };
  }
}

class ClassData {
  final List<ClassModel> classes;
  final PaginationInfo pagination;

  ClassData({
    required this.classes,
    required this.pagination,
  });

  factory ClassData.fromJson(Map<String, dynamic> json) {
    return ClassData(
      classes: json['classes'] != null
          ? List<ClassModel>.from(
              json['classes'].map((x) => ClassModel.fromJson(x)))
          : [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classes': classes.map((x) => x.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class ClassModel {
  final String id;
  final String name;
  final String level;
  final String? section;
  final String term;
  final String academicYear;
  final String? color;
  final String? classTeacher;
  final List<SubjectTeacher> subjectTeachers;
  final List<String> students;
  final List<String> subjects;
  final int capacity;
  final Classroom? classroom;
  final Schedule? schedule;
  final Map<String, dynamic>? fees;
  final List<String> feeStructures;
  final String? activeFeeStructure;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int v;

  // Virtual fields
  final int? totalFees;
  final int? currentEnrollment;
  final int? availableSlots;
  final bool? hasFeeStructure;
  final dynamic feeStructureDetails;

  ClassModel({
    required this.id,
    required this.name,
    required this.level,
    this.section,
    required this.term,
    required this.academicYear,
    this.color,
    this.classTeacher,
    required this.subjectTeachers,
    required this.students,
    required this.subjects,
    required this.capacity,
    this.classroom,
    this.schedule,
    this.fees,
    required this.feeStructures,
    this.activeFeeStructure,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    required this.v,
    this.totalFees,
    this.currentEnrollment,
    this.availableSlots,
    this.hasFeeStructure,
    this.feeStructureDetails,
  });

  factory ClassModel.fromJson(Map<String, dynamic> json) {
    return ClassModel(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? '',
      level: json['level'] ?? '',
      section: json['section'],
      term: json['term'] ?? '',
      academicYear: json['academicYear'] ?? '',
      color: json['color'],
      classTeacher: json['classTeacher'],
      subjectTeachers: json['subjectTeachers'] != null
          ? List<SubjectTeacher>.from(
              json['subjectTeachers'].map((x) => SubjectTeacher.fromJson(x)))
          : [],
      students: json['students'] != null
          ? List<String>.from(json['students'])
          : [],
      subjects: json['subjects'] != null
          ? List<String>.from(json['subjects'])
          : [],
      capacity: json['capacity'] ?? 0,
      classroom: json['classroom'] != null
          ? Classroom.fromJson(json['classroom'])
          : null,
      schedule: json['schedule'] != null
          ? Schedule.fromJson(json['schedule'])
          : null,
      fees: json['fees'],
      feeStructures: json['feeStructures'] != null
          ? List<String>.from(json['feeStructures'])
          : [],
      activeFeeStructure: json['activeFeeStructure'],
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      v: json['__v'] ?? 0,
      totalFees: json['totalFees'],
      currentEnrollment: json['currentEnrollment'],
      availableSlots: json['availableSlots'],
      hasFeeStructure: json['hasFeeStructure'],
      feeStructureDetails: json['feeStructureDetails'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'level': level,
      'section': section,
      'term': term,
      'academicYear': academicYear,
      'color': color,
      'classTeacher': classTeacher,
      'subjectTeachers': subjectTeachers.map((x) => x.toJson()).toList(),
      'students': students,
      'subjects': subjects,
      'capacity': capacity,
      'classroom': classroom?.toJson(),
      'schedule': schedule?.toJson(),
      'fees': fees,
      'feeStructures': feeStructures,
      'activeFeeStructure': activeFeeStructure,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      '__v': v,
      'totalFees': totalFees,
      'currentEnrollment': currentEnrollment,
      'availableSlots': availableSlots,
      'hasFeeStructure': hasFeeStructure,
      'feeStructureDetails': feeStructureDetails,
    };
  }

  // Helper getter for display name
  String get displayName {
    if (section != null && section!.isNotEmpty) {
      return '$name ($section)';
    }
    return name;
  }

  // Helper getter for full class info
  String get fullInfo {
    return '$displayName - $level ($academicYear)';
  }
}

class SubjectTeacher {
  final String teacher;
  final String subject;
  final String subjectText;

  SubjectTeacher({
    required this.teacher,
    required this.subject,
    required this.subjectText,
  });

  factory SubjectTeacher.fromJson(Map<String, dynamic> json) {
    return SubjectTeacher(
      teacher: json['teacher'] ?? '',
      subject: json['subject'] ?? '',
      subjectText: json['subjectText'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'teacher': teacher,
      'subject': subject,
      'subjectText': subjectText,
    };
  }
}

class Classroom {
  final String? building;
  final String? roomNumber;
  final String? floor;

  Classroom({
    this.building,
    this.roomNumber,
    this.floor,
  });

  factory Classroom.fromJson(Map<String, dynamic> json) {
    return Classroom(
      building: json['building'],
      roomNumber: json['roomNumber'],
      floor: json['floor'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'building': building,
      'roomNumber': roomNumber,
      'floor': floor,
    };
  }
}

class Schedule {
  final String? startTime;
  final String? endTime;
  final List<String> days;

  Schedule({
    this.startTime,
    this.endTime,
    required this.days,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      startTime: json['startTime'],
      endTime: json['endTime'],
      days: json['days'] != null
          ? List<String>.from(json['days'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'days': days,
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalItems;
  final int itemsPerPage;
  final bool hasNextPage;
  final bool hasPreviousPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalItems,
    required this.itemsPerPage,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalItems: json['totalItems'] ?? 0,
      itemsPerPage: json['itemsPerPage'] ?? 10,
      hasNextPage: json['hasNextPage'] ?? false,
      hasPreviousPage: json['hasPreviousPage'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalItems': totalItems,
      'itemsPerPage': itemsPerPage,
      'hasNextPage': hasNextPage,
      'hasPreviousPage': hasPreviousPage,
    };
  }
}
