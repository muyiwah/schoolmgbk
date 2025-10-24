import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/user_model.dart';
import 'package:schmgtsystem/repository/profile_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:url_launcher/url_launcher.dart';


class ProfileProvider extends ChangeNotifier {
  final _profileRepo = locator<ProfileRepo>();

  UserModel? user;

  setUserProfile(UserModel userModel) {
    user = userModel;
    notifyListeners();
  }
Future<void> makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      throw 'Could not launch $phoneNumber';
    }
  }
 



}

  // updateUserPushNotificationIds(
  //     {required String? subscriptionId, required String? pushToken}) async {
  //   Map<String, dynamic> body = {
  //     'subscription_id': subscriptionId,
  //     'push_token': pushToken,
  //   };

  //   HTTPResponseModel res = await _profileRepo.updateUserProfile(body);

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     return true;
  //   }
  //   return false;
  // }

  // updateUserAddress(Map<String, dynamic> body) async {
  //   EasyLoading.show();
  //   HTTPResponseModel res = await _profileRepo.updateUserAddress(body);
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     getUserProfile();
  //     return true;
  //   }
  //   return false;
  // }

  // updateUserProfile(Map<String, dynamic> body) async {
  //   EasyLoading.show();
  //   HTTPResponseModel res = await _profileRepo.updateUserProfile(body);
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     // TODO: Get update user profile from response ans set it to user
  //     // (instead of making another API call to get user profile)
  //     await getUserProfile();
  //     return true;
  //   }
  //   return false;
  // }

  // Future<bool> setPin(BuildContext context, String pin) async {
  //   EasyLoading.show(status: 'Setting PIN...');

  //   HTTPResponseModel res = await _profileRepo.setPin({
  //     "pin": pin,
  //     "pin_confirmation": pin,
  //   });
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     // Store encrypted pin
  //     bool saved = await EncrptyDecrypt.encryptAndSave(
  //         key: AppConstants.myPin, value: pin);
  //     log('Encrypted pin saved: $saved');

  //     await _storageService.setData(AppConstants.hasLoggedInOnce, true);
  //     // await _storageService.setData(AppConstants.hasPinSet, true);

  //     return true;
  //   }
  //   return false;
  // }
// }
