

import 'package:get_it/get_it.dart';
import 'package:schmgtsystem/network/repository/auth_repo.dart';
import 'package:schmgtsystem/providers/auth_provider.dart';
import 'package:schmgtsystem/services/dialog_service.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/services/navigator_service.dart';

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
  // WHy is this here?
  locator.registerLazySingleton(() => AuthProvider());

  locator.registerLazySingleton(() => AuthRepo());
  // locator.registerLazySingleton(() => ProfileRepo());
  // locator.registerLazySingleton(() => TripRepo());
  // locator.registerLazySingleton(() => WalletRepo());
  // locator.registerLazySingleton(() => DeliveryRepo());

  // locator.registerLazySingleton(() => NotificationService());
  // locator.registerLazySingleton(() => LocationService());

  // locator.registerLazySingleton(() => SettingsRepo());
  // locator.registerLazySingleton(() => WalletRepo());
  // locator.registerLazySingleton(() => TransactionRepo());
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
