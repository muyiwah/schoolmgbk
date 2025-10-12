import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/enums.dart';


class ProfileRepo {
  final _httpService = locator<HttpService>();

  // Future<HTTPResponseModel> getUserProfile() async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.get,
  //     url: "user/profile",
  //   );
  // }

  // Future<HTTPResponseModel> toggleOnlineStatus() async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "toggle/online",
  //   );
  // }

  // Future<HTTPResponseModel> setPin(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.patch,
  //     url: "profile/individual/set-pin",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> updateUserProfile(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.patch,
  //     url: "profile/individual/update",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> updateUserAddress(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.patch,
  //     url: "profile/individual/update/address",
  //     body: body,
  //   );
  // }
}
