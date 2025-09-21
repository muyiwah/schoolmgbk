import 'package:get_it/get_it.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/repository/assignment_repo.dart';
import 'package:schmgtsystem/repository/attendance_repo.dart';
import 'package:schmgtsystem/repository/auth_repo.dart';
import 'package:schmgtsystem/providers/auth_provider.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/repository/class_level_repo.dart';
import 'package:schmgtsystem/repository/metrics_repo.dart';
import 'package:schmgtsystem/repository/parent_repo.dart';
import 'package:schmgtsystem/repository/profile_repo.dart';
import 'package:schmgtsystem/repository/staff_repo.dart';
import 'package:schmgtsystem/repository/student_performance_repo.dart';
import 'package:schmgtsystem/repository/students_repo.dart';
import 'package:schmgtsystem/repository/subject_repo.dart';
import 'package:schmgtsystem/repository/teacher_repo.dart';
import 'package:schmgtsystem/repository/time_table_repo.dart';
import 'package:schmgtsystem/services/dialog_service.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/services/navigator_service.dart';
import 'package:schmgtsystem/teacher111.dart';

GetIt locator = GetIt.instance;

enum Env { test, prod }

Future<void> setupLocator({Env? env = Env.prod}) async {
  if (env == Env.test) {
    locator.registerLazySingleton<MockHttpServices>(() => MockHttpServices());
  }

  // await _setupSharedPreferences();

  locator.registerLazySingleton(() => NavigatorService());
  locator.registerLazySingleton(() => HttpService());
  locator.registerLazySingleton(() => DialogService());

  locator.registerLazySingleton(() => AuthRepo());
  locator.registerLazySingleton(() => ProfileRepo());
  locator.registerLazySingleton(() => StudentsRepo());
  locator.registerLazySingleton(() => MetricsRepo());
  locator.registerLazySingleton(() => TeacherRepo());
  locator.registerLazySingleton(() => StaffRepo());

  locator.registerLazySingleton(() => TimeTableRepo());
  locator.registerLazySingleton(() => StudentPerformanceRepo());

  locator.registerLazySingleton(() => ParentRepo());
  locator.registerLazySingleton(() => AssignmentRepo());
  locator.registerLazySingleton(() => AttendanceRepo());
  locator.registerLazySingleton(() => ClassRepo());
  locator.registerLazySingleton(() => ClassLevelRepo());
  locator.registerLazySingleton(() => SubjectRepo());
}

// Future<void> _setupSharedPreferences() async {
//   StorageService.createSharedPref();
//   locator.registerLazySingleton(() => StorageService());
// }

class MockHttpServices {
  Future<dynamic> postHttp(String url, {Map<String, dynamic>? data}) async {
    return Future.value();
  }

  Future<dynamic> getHttp(String url) async {
    return Future.value();
  }

  Future<dynamic> patchHttp(String url, {Map<String, dynamic>? data}) async {
    return Future.value();
  }

  Future<dynamic> deleteHttp(String url) async {
    return Future.value();
  }
}

unregisterGetIt() {
  locator.reset();
}
