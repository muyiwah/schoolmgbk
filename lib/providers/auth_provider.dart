import 'dart:convert';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:schmgtsystem/home3.dart';
import 'package:schmgtsystem/models/user_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/repository/auth_repo.dart';

import 'package:schmgtsystem/providers/profile_provider.dart';
import 'package:schmgtsystem/services/navigator_service.dart';
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:go_router/go_router.dart';

class AuthProvider extends ChangeNotifier {
  final _authRepo = locator<AuthRepo>();
  final _navigatorService = locator<NavigatorService>();

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
   
    } else {
    
    }

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

    // user = userData;
    notifyListeners();
    profileProvider.setUserProfile(userData);


    EasyLoading.dismiss();
  context.go('/dashboard');
  
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
      String? token = res.data['token']['token'];

      return true;
    }
    return false;
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
}
