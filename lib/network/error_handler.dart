import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:schmgtsystem/services/dialog_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class DioErrorHandler {
  handleStringError(String errorMessage) {
    DialogService dialogService = DialogService();

    log('errorMessage:: $errorMessage');

    dialogService.showSnackBar(errorMessage, appToastType: AppToastType.error);
  }

  handleError(DioException dioError) {
    DialogService dialogService = DialogService();

    String errorMessage = 'An error occured';
    if (dioError.response?.data is Map) {
      errorMessage =
          errorMessageParser(dioError.response?.data) ?? 'An error occured';
    }
    log('errorMessage:: $errorMessage');
    dialogService.showSnackBar(errorMessage, appToastType: AppToastType.error);
  }

  String getErrorMessage(DioException? dioError) {
    if (dioError?.response?.data is Map) {
      return errorMessageParser(dioError?.response?.data) ?? 'An error occured';
    } else {
      return 'An error occured';
    }
  }

  String? errorMessageParser(
    Map errorJson, {
    showSingleError = false,
    showErrorKey = false,
  }) {
    String? message;

    bool shouldShowMessageError = errorJson['errors'] == null;

    if (errorJson['message'] is String && shouldShowMessageError) {
      return errorJson['message'];
    }

    if (errorJson['errors'] is String) return errorJson['errors'];

    if (errorJson['errors'] is List) {
      if ((errorJson['errors'] as List).isEmpty) {
        return errorJson['message'] ?? 'An error occured';
      }

      if (showSingleError) {
        return errorJson['errors'][0];
      } else {
        String msg = '';
        for (var error in errorJson['errors']) {
          String separator = msg.isEmpty ? '' : '\n';
          msg += "$separator$error";
        }
        return msg;
      }
    }

    errorJson = errorJson['errors'] ?? errorJson;

    List<String>? errorKeys = errorJson.keys.cast<String>().toList();

    formartErrorKey(String value) {
      String v = value.replaceAll('_', ' ');
      String res = v[0].toUpperCase() + v.substring(1);
      return res;
    }

    if (errorKeys.isNotEmpty) {
      if (showSingleError) {
        message = errorJson[errorKeys[0]][0];
      } else {
        String msg = '';
        for (var errorKey in errorKeys) {
          String separator = msg.isEmpty ? '' : '\n';
          var err = errorJson[errorKey];
          msg +=
              showErrorKey
                  ? "$separator${formartErrorKey(errorKey)}: ${err is String ? err : err[0]}"
                  : "$separator${err is String ? err : err[0]}";
        }
        message = msg;
      }
    }

    return message;
  }
}
