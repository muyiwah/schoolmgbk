import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class AuthRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> login(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "login",
      body: body,
    );
  }

  Future<HTTPResponseModel> forgotResetPassword(
    Map<String, dynamic> body,
  ) async {
    print(body);
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "reset-password",
      body: body,
    );
  }

  Future<HTTPResponseModel> forgotPassword(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "forgot-password",
      body: body,
    );
  }

  Future<HTTPResponseModel> verifyForgotPasswordOtp(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "verify-otp",
      body: body,
    );
  }

  Future<HTTPResponseModel> updatePushNotificationId(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "device-token",
      body: body,
    );
  }

  // Future<HTTPResponseModel> loginWithPin(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/login-with-pin",
  //     body: body,
  //   );
  // }

  Future<HTTPResponseModel> signUp(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "register",
      body: body,
    );
  }

  Future<HTTPResponseModel> updateProfile(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.patch,
      url: "user/profile",
      body: body,
    );
  }

  Future<HTTPResponseModel> deleteAccount(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "users/delete-account",
      body: body,
    );
  }

  Future<HTTPResponseModel> verifyEmail(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "verify-email",
      body: body,
    );
  }

  // Future<HTTPResponseModel> verifyOtp(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/verify-otp-code",
  //     body: body,
  //   );
  // }

  Future<HTTPResponseModel> requestOtpCode(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "resend-otp",
      body: body,
    );
  }

  Future<HTTPResponseModel> resoleAccountNumber(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "resolve-account",
      body: body,
    );
  }

  Future<HTTPResponseModel> withdrawRequest(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "wallet/withdraw",
      body: body,
    );
  }

  Future<HTTPResponseModel> userProfile(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "profile",
      body: body,
    );
  }

  // Future<HTTPResponseModel> changeCredentials(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/change-credentials",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> resetPassword(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/reset-password",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> resetPin(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/reset-pin",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> updateUserDevice(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "profile/update-device",
  //     body: body,
  //   );
  // }

  // Future<HTTPResponseModel> logout(Map<String, dynamic> body) async {
  //   return await _httpService.runApi(
  //     type: ApiRequestType.post,
  //     url: "access-control/logout",
  //     body: body,
  //   );
  // }
}
