

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/app_nav_notifier.dart';
import 'package:schmgtsystem/providers/auth_provider.dart';
import 'package:schmgtsystem/providers/class_provider.dart';
import 'package:schmgtsystem/providers/profile_provider.dart';
import 'package:schmgtsystem/providers/teachers_provider.dart';

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
  static final teachersProvider = ChangeNotifierProvider<TeachersProvider>(
    (ref) => TeachersProvider(),
  );

 

  
}
