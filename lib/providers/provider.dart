import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/app_nav_notifier.dart';
import 'package:schmgtsystem/providers/auth_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/class_level_provider.dart';
import 'package:schmgtsystem/providers/metrics_provider.dart';
import 'package:schmgtsystem/providers/parent_provider.dart';
import 'package:schmgtsystem/providers/parent_login_provider.dart';
import 'package:schmgtsystem/providers/profile_provider.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/providers/teachers_provider.dart';
import 'package:schmgtsystem/providers/admission_provider.dart';
import 'package:schmgtsystem/providers/attendance_provider.dart';
import 'package:schmgtsystem/providers/communication_provider.dart';
import 'package:schmgtsystem/providers/timetable_provider.dart';
import 'package:schmgtsystem/providers/subject_provider.dart';
import 'package:schmgtsystem/providers/uniform_provider.dart';
import 'package:schmgtsystem/repository/class_repo.dart';

class RiverpodProvider {
  static final appNavProvider = ChangeNotifierProvider<AppNavProvider>(
    (ref) => AppNavProvider(),
  );

  static final authProvider = ChangeNotifierProvider<AuthProvider>(
    (ref) => AuthProvider(),
  );

  static final profileProvider = ChangeNotifierProvider<ProfileProvider>(
    (ref) => ProfileProvider(),
  );
  static final classProvider = ChangeNotifierProvider<ClassProvider>(
    (ref) => ClassProvider(),
  );
  static final classLevelProvider = ChangeNotifierProvider<ClassLevelProvider>(
    (ref) => ClassLevelProvider(),
  );
  static final teachersProvider = ChangeNotifierProvider<TeachersProvider>(
    (ref) => TeachersProvider(),
  );

  static final parentProvider =
      StateNotifierProvider<ParentProvider, ParentState>(
        (ref) => ParentProvider(),
      );

  static final parentLoginProvider =
      StateNotifierProvider<ParentLoginProvider, ParentLoginState>(
        (ref) => ParentLoginProvider(),
      );

  static final studentProvider =
      StateNotifierProvider<StudentNotifier, StudentState>(
        (ref) => StudentNotifier(),
      );

  static final admissionProvider = ChangeNotifierProvider<AdmissionProvider>(
    (ref) => AdmissionProvider(),
  );

  static final metricsProvider = ChangeNotifierProvider<MetricsProvider>(
    (ref) => MetricsProvider(),
  );
  static final attendanceProvider = ChangeNotifierProvider<AttendanceProvider>(
    (ref) => AttendanceProvider(),
  );

  static final communicationProvider =
      ChangeNotifierProvider<CommunicationProvider>(
        (ref) => CommunicationProvider(),
      );

  static final timetableProvider = ChangeNotifierProvider<TimetableProvider>(
    (ref) => TimetableProvider(),
  );

  static final subjectProvider = ChangeNotifierProvider<SubjectProvider>(
    (ref) => SubjectProvider(),
  );

  static final uniformProvider =
      StateNotifierProvider<UniformNotifier, UniformState>(
        (ref) => UniformNotifier(ClassRepo()),
      );
}
