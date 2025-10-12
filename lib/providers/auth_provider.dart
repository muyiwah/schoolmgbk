import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:schmgtsystem/models/user_model.dart';
import 'package:schmgtsystem/models/parent_login_response_model.dart';
import 'package:schmgtsystem/models/password_reset_models.dart';
import 'package:schmgtsystem/models/admin_change_password_models.dart';
import 'package:schmgtsystem/models/admin_update_status_models.dart';
import 'package:schmgtsystem/models/admin_users_model.dart';
import 'package:schmgtsystem/repository/auth_repo.dart';

import 'package:schmgtsystem/providers/profile_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/auth_state_provider.dart';

class AuthProvider extends ChangeNotifier {
  final _authRepo = locator<AuthRepo>();

  UserModel? user;
  DateTime? kycSubmissionTime;

  //set device token
  final Map<String, dynamic> _deviceToken = {'token': ''};
  Map<String, dynamic> get deviceToken {
    debugPrint('get device token $_deviceToken');
    _deviceToken;
    return _deviceToken;
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    await prefs.remove("parent_id");
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('token', token);
  }

  Future<bool> login(
    BuildContext context,
    ProfileProvider profileProvider, {
    required Map<String, dynamic> body,
  }) async {
    // print(body);
    EasyLoading.show(status: 'Logging in...');

    // body['device_id'] = await _getUniqueDeviceId();
    // body['device_info'] = await _getUniqueDeviceInfo();

    HTTPResponseModel res = await _authRepo.login(body);
    EasyLoading.dismiss();

    // print(res.data);
    if (HTTPResponseModel.isApiCallSuccess(res)) {
      //  print(res.data['user']);
      //  print(res.data['data']['user']);

      await _handleLoginSuccess(context, profileProvider, res: res, body: body);

      return true;
    } else if (res.message == 'Please verify your email before logging in') {
      print('Please verify your email before logging in');
    }

    EasyLoading.dismiss();
    return false;
  }

  resetPassword(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    EasyLoading.show(status: 'Resseting password...');

    // body['device_id'] = await _getUniqueDeviceId();
    // body['device_info'] = await _getUniqueDeviceInfo();

    HTTPResponseModel res = await _authRepo.forgotResetPassword(body);

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      print(res.data);
      print(res);
      CustomToastNotification.show(
        res.message ?? 'Password reset link sent!',
        type: ToastType.success,
      );
    } else {}

    EasyLoading.dismiss();
  }

  Future<void> forgotPassword(
    BuildContext context,
    ProfileProvider profileProvider, {
    required Map<String, dynamic> body,
  }) async {
    EasyLoading.show(status: 'Requesting code...');

    // body['device_id'] = await _getUniqueDeviceId();
    // body['device_info'] = await _getUniqueDeviceInfo();

    HTTPResponseModel res = await _authRepo.forgotPassword(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(
        res.message ?? 'Password reset link sent!',
        type: ToastType.success,
      );
    } else {
      CustomToastNotification.show(
        'Please check your email and try again',
        type: ToastType.error,
      );
    }
  }

  Future<bool> verifyForgotPasswordOtp({
    required String email,
    required String otp,
  }) async {
    EasyLoading.show(status: 'Verifying OTP...');

    HTTPResponseModel res = await _authRepo.verifyForgotPasswordOtp({
      "email": email,
      "otp": otp,
    });
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      print(res.data);
      print(res);
      // var token = res.data['token'];
      CustomToastNotification.show(
        res.message ?? 'OTP verified successfully',
        type: ToastType.success,
      );
      return true;
    } else {
      CustomToastNotification.show(
        res.message ?? 'OTP verification failed',
        type: ToastType.error,
      );
      return false;
    }
  }

  _handleLoginSuccess(
    BuildContext context,
    ProfileProvider profileProvider, {
    required Map body,
    required HTTPResponseModel res,
  }) async {
    UserModel userData = UserModel.fromJson(res.data['user']);
    // String? email = userData.email;
    saveToken(res.data['token']);
    // print(userData);
    print(res.data);

    // user = userData;
    notifyListeners();
    profileProvider.setUserProfile(userData);

    // Set the authentication state in the provider
    final container = ProviderScope.containerOf(context);
    container
        .read(authStateProvider.notifier)
        .setAuthenticated(
          userRole: userData.role?.toLowerCase() ?? 'admin',
          token: res.data['token'],
        );

    // If user is a parent, extract and store parent ID
    if (userData.role?.toLowerCase() == 'parent') {
      try {
        print('🔍 DEBUG: User is parent, extracting parent ID');
        print('🔍 DEBUG: User ID: ${userData.id}');
        print('🔍 DEBUG: User email: ${userData.email}');
        print('🔍 DEBUG: User name: ${userData.fullName}');

        // Extract parent ID from login response
        final parentDetails = res.data['parentDetails'];
        if (parentDetails != null && parentDetails['parent'] != null) {
          final parentId = parentDetails['parent']['_id'];
          if (parentId != null) {
            print('🔍 DEBUG: Found parent ID: $parentId');

            // Store parent ID in SharedPreferences for later use
            final prefs = await SharedPreferences.getInstance();
            await prefs.setString('parent_id', parentId);
            print('🔍 DEBUG: Stored parent ID: $parentId');
          } else {
            print('🔍 DEBUG: Parent ID not found in response');
          }
        } else {
          print('🔍 DEBUG: Parent details not found in response');
        }
      } catch (e) {
        print('🔍 DEBUG: Error handling parent login: $e');
      }
    } else {
      print('🔍 DEBUG: User role is not parent: ${userData.role}');
    }

    // Initialize global academic year service
    try {
      final academicYearService = GlobalAcademicYearService();
      final success = await academicYearService.initialize();

      if (!success) {
        await academicYearService.loadCachedData();
      }
    } catch (e) {
      // Handle initialization error silently
    }

    EasyLoading.dismiss();

    // Navigate based on user role
    if (userData.role?.toLowerCase() == 'parent') {
      context.go('/parent');
    } else if (userData.role?.toLowerCase() == 'teacher') {
      context.go('/teacher');
    } else {
      context.go('/dashboard');
    }
  }

  requestOtpCode(String email) async {
    EasyLoading.show(status: 'Sending OTP');
    HTTPResponseModel res = await _authRepo.requestOtpCode({'email': email});

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      EasyLoading.dismiss();
      return true;
    }
    EasyLoading.dismiss();
  }

  Future<bool> verifyEmail(String email, String otp) async {
    EasyLoading.show(status: 'Verifying email...');
    HTTPResponseModel res = await _authRepo.verifyEmail({
      "email": email,
      "otp": otp,
    });
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      return true;
    }
    return false;
  }

  // New password reset methods matching the Express.js implementation
  Future<PasswordResetResponseModel?> requestPasswordReset(String email) async {
    try {
      EasyLoading.show(status: 'Requesting password reset...');

      HTTPResponseModel res = await _authRepo.requestPasswordReset({
        "email": email,
      });

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final response = PasswordResetResponseModel.fromJson(res.data!);
        CustomToastNotification.show(response.message, type: ToastType.success);
        return response;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to request password reset',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error requesting password reset: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  Future<ResetPasswordResponseModel?> resetPasswordWithOTP({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      EasyLoading.show(status: 'Resetting password...');

      HTTPResponseModel res = await _authRepo.resetPasswordWithOTP({
        "email": email,
        "otp": otp,
        "newPassword": newPassword,
      });

      EasyLoading.dismiss();

      print('Password reset API response: ${res.data}');
      print('API call success: ${HTTPResponseModel.isApiCallSuccess(res)}');

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final response = ResetPasswordResponseModel.fromJson(res.data!);
        // Don't show toast here - let the UI handle it
        return response;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to reset password',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error resetting password: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  Future<VerifyOTPResponseModel?> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      EasyLoading.show(status: 'Verifying OTP...');

      HTTPResponseModel res = await _authRepo.verifyOTP({
        "email": email,
        "otp": otp,
      });

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final response = VerifyOTPResponseModel.fromJson(res.data!);
        CustomToastNotification.show(response.message, type: ToastType.success);
        return response;
      } else {
        CustomToastNotification.show(
          res.message ?? 'OTP verification failed',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error verifying OTP: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  Future<OTPStatusResponseModel?> getOTPStatus(String email) async {
    try {
      HTTPResponseModel res = await _authRepo.getOTPStatus(email);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        return OTPStatusResponseModel.fromJson(res.data!);
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  Future<AdminChangePasswordResponseModel?> adminChangePassword({
    required String userId,
    required String newPassword,
    String? reason,
  }) async {
    try {
      EasyLoading.show(status: 'Changing password...');

      HTTPResponseModel res = await _authRepo.adminChangePassword({
        "userId": userId,
        "newPassword": newPassword,
        if (reason != null) "reason": reason,
      });

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final response = AdminChangePasswordResponseModel.fromJson(res.data!);
        CustomToastNotification.show(response.message, type: ToastType.success);
        return response;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to change password',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error changing password: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  Future<AdminUpdateStatusResponseModel?> adminUpdateStatus({
    required String userId,
    required String status,
    String? reason,
  }) async {
    try {
      EasyLoading.show(status: 'Updating user status...');

      HTTPResponseModel res = await _authRepo.adminUpdateStatus({
        "userId": userId,
        "status": status,
        if (reason != null) "reason": reason,
      });

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final response = AdminUpdateStatusResponseModel.fromJson(res.data!);
        CustomToastNotification.show(response.message, type: ToastType.success);
        return response;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to update user status',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error updating user status: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  registerUser(
    BuildContext context, {
    required Map<String, dynamic> body,
  }) async {
    EasyLoading.show();
    HTTPResponseModel res = await _authRepo.signUp(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      UserModel userData = UserModel.fromJson(res.data['user']);

      // String token = res.data['token'];
      // await _storageService.setData(AppConstants.token, token);

      // set hasPinSet to false so that user is not redirected to login via PIN

      user = userData;
      notifyListeners();

      Text('data');
    }
  }

  updateUser(BuildContext context, {required Map<String, dynamic> body}) async {
    EasyLoading.show();
    HTTPResponseModel res = await _authRepo.updateProfile(body);

    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      showToast(res.data['message']);
      UserModel userData = UserModel.fromJson(res.data['user']);
      debugPrint(userData.toJson().toString());
      user = userData;
      notifyListeners();
    }
  }

  deleteAccount({required Map<String, dynamic> body}) async {
    EasyLoading.show();
    print(body);
    HTTPResponseModel res = await _authRepo.deleteAccount(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      print(res.data);
      showToast(res.data['message']);
    }
  }

  Future<AdminUsersResponseModel?> getAllUsersWithStatus({
    int page = 1,
    int limit = 10,
    String? status,
    String? role,
    String? search,
  }) async {
    try {
      EasyLoading.show(status: 'Loading users...');

      final response = await _authRepo.getAllUsersWithStatus(
        page: page,
        limit: limit,
        status: status,
        role: role,
        search: search,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final usersResponse = AdminUsersResponseModel.fromJson(response.data);
        return usersResponse;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to fetch users',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error fetching users: $e',
        type: ToastType.error,
      );
      return null;
    }
  }
}
