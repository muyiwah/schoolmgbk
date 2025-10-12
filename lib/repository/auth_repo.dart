import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class AuthRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> login(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/auth/login",
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

  // New password reset methods matching the Express.js routes
  Future<HTTPResponseModel> requestPasswordReset(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/auth/forgot-password",
      body: body,
    );
  }

  Future<HTTPResponseModel> resetPasswordWithOTP(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/auth/reset-password",
      body: body,
    );
  }

  Future<HTTPResponseModel> verifyOTP(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/auth/verify-otp",
      body: body,
    );
  }

  Future<HTTPResponseModel> getOTPStatus(String email) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/auth/otp-status/$email",
    );
  }

  Future<HTTPResponseModel> adminChangePassword(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/auth/admin/change-password",
      body: body,
    );
  }

  Future<HTTPResponseModel> getAllUsersWithStatus({
    int page = 1,
    int limit = 10,
    String? status,
    String? role,
    String? search,
  }) async {
    final Map<String, dynamic> queryParams = {'page': page, 'limit': limit};

    // Add optional parameters only if they are provided
    if (status != null && status.isNotEmpty) queryParams['status'] = status;
    if (role != null && role.isNotEmpty) queryParams['role'] = role;
    if (search != null && search.isNotEmpty) queryParams['search'] = search;

    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/auth/admin/users",
      params: queryParams,
    );
  }

  Future<HTTPResponseModel> adminUpdateStatus(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/auth/admin/update-status",
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
