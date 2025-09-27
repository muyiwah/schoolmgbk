class TimetableModel {
  final String id;
  final String classId;
  final String academicYear;
  final String term;
  final String type;
  final List<DaySchedule> schedule;
  final bool isActive;
  final String createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  TimetableModel({
    required this.id,
    required this.classId,
    required this.academicYear,
    required this.term,
    required this.type,
    required this.schedule,
    required this.isActive,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TimetableModel.fromJson(Map<String, dynamic> json) {
    return TimetableModel(
      id: json['_id'] ?? '',
      classId:
          json['class'] is String
              ? json['class']
              : json['class']?['_id'] ?? json['class']?['id'] ?? '',
      academicYear: json['academicYear'] ?? '',
      term: json['term'] ?? '',
      type: json['type'] ?? 'regular',
      schedule:
          (json['schedule'] as List<dynamic>?)
              ?.map((day) => DaySchedule.fromJson(day))
              .toList() ??
          [],
      isActive: json['isActive'] ?? true,
      createdBy:
          json['createdBy'] is String
              ? json['createdBy']
              : json['createdBy']?['_id'] ?? json['createdBy']?['id'] ?? '',
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'class': classId,
      'academicYear': academicYear,
      'term': term,
      'type': type,
      'schedule': schedule.map((day) => day.toJson()).toList(),
      'isActive': isActive,
      'createdBy': createdBy,
    };
  }
}

class DaySchedule {
  final String day;
  final List<Period> periods;

  DaySchedule({required this.day, required this.periods});

  factory DaySchedule.fromJson(Map<String, dynamic> json) {
    return DaySchedule(
      day: json['day'] ?? '',
      periods:
          (json['periods'] as List<dynamic>?)
              ?.map((period) => Period.fromJson(period))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'day': day,
      'periods': periods.map((period) => period.toJson()).toList(),
    };
  }
}

class Period {
  final String startTime;
  final String endTime;
  final String subject;
  final String? teacher;
  final String? room;
  final String? notes;

  Period({
    required this.startTime,
    required this.endTime,
    required this.subject,
    this.teacher,
    this.room,
    this.notes,
  });

  factory Period.fromJson(Map<String, dynamic> json) {
    return Period(
      startTime: json['startTime'] ?? '',
      endTime: json['endTime'] ?? '',
      subject: json['subject'] ?? '',
      teacher:
          json['teacher'] is String
              ? json['teacher']
              : json['teacher']?['_id'] ?? json['teacher']?['id'],
      room: json['room'],
      notes: json['notes'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'subject': subject,
      'teacher': teacher,
      'room': room,
      'notes': notes,
    };
  }
}

class CreateTimetableRequest {
  final String classId;
  final String academicYear;
  final String term;
  final String type;
  final List<DaySchedule> schedule;
  final String createdBy;
  final bool checkTeacherAvailability;

  CreateTimetableRequest({
    required this.classId,
    required this.academicYear,
    required this.term,
    required this.type,
    required this.schedule,
    required this.createdBy,
    this.checkTeacherAvailability = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'classId': classId,
      'academicYear': academicYear,
      'term': term,
      'type': type,
      'schedule': schedule.map((day) => day.toJson()).toList(),
      'createdBy': createdBy,
      'checkTeacherAvailability': checkTeacherAvailability,
    };
  }
}

class UpdateTimetableRequest {
  final String? academicYear;
  final String? term;
  final String? type;
  final List<DaySchedule>? schedule;
  final bool? isActive;

  UpdateTimetableRequest({
    this.academicYear,
    this.term,
    this.type,
    this.schedule,
    this.isActive,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (academicYear != null) data['academicYear'] = academicYear;
    if (term != null) data['term'] = term;
    if (type != null) data['type'] = type;
    if (schedule != null)
      data['schedule'] = schedule!.map((day) => day.toJson()).toList();
    if (isActive != null) data['isActive'] = isActive;
    return data;
  }
}

class TimetableStatistics {
  final int totalPeriods;
  final int totalSubjects;
  final int totalTeachers;
  final int daysScheduled;

  TimetableStatistics({
    required this.totalPeriods,
    required this.totalSubjects,
    required this.totalTeachers,
    required this.daysScheduled,
  });

  factory TimetableStatistics.fromJson(Map<String, dynamic> json) {
    return TimetableStatistics(
      totalPeriods: json['totalPeriods'] ?? 0,
      totalSubjects: json['totalSubjects'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? 0,
      daysScheduled: json['daysScheduled'] ?? 0,
    );
  }
}

class TimetableDetailsResponse {
  final TimetableModel timetable;
  final TimetableStatistics statistics;

  TimetableDetailsResponse({required this.timetable, required this.statistics});

  factory TimetableDetailsResponse.fromJson(Map<String, dynamic> json) {
    return TimetableDetailsResponse(
      timetable: TimetableModel.fromJson(json['timetable']),
      statistics: TimetableStatistics.fromJson(json['statistics']),
    );
  }
}

class TimetableListResponse {
  final List<TimetableModel> timetables;
  final PaginationInfo pagination;

  TimetableListResponse({required this.timetables, required this.pagination});

  factory TimetableListResponse.fromJson(Map<String, dynamic> json) {
    return TimetableListResponse(
      timetables:
          (json['timetables'] as List<dynamic>)
              .map((timetable) => TimetableModel.fromJson(timetable))
              .toList(),
      pagination: PaginationInfo.fromJson(json['pagination']),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalTimetables;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalTimetables,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalTimetables: json['totalTimetables'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }
}

// Enums for timetable types and terms
enum TimetableType {
  regular('regular'),
  examination('examination');

  const TimetableType(this.value);
  final String value;
}

enum Term {
  first('First'),
  second('Second'),
  third('Third');

  const Term(this.value);
  final String value;
}

enum DayOfWeek {
  monday('Monday'),
  tuesday('Tuesday'),
  wednesday('Wednesday'),
  thursday('Thursday'),
  friday('Friday'),
  saturday('Saturday'),
  sunday('Sunday');

  const DayOfWeek(this.value);
  final String value;
}
