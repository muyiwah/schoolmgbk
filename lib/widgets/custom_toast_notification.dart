import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:schmgtsystem/constants/appcolor.dart';


enum ToastType { success, error, warning }

class CustomToastNotification {
  static show(
    String title, {
    ToastType type = ToastType.success,
    bool isFilled = false,
    bool? bottomPosition = false,
    Duration? duration,
  }) async {
    showToastWidget(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        margin: EdgeInsets.symmetric(horizontal: 36.0),
        decoration: BoxDecoration(
          color: isFilled ? getToastColor(type) : AppColors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: AppColors.shadowGrey.withOpacity(0.08),
              spreadRadius: 2,
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(2.0),
              decoration: BoxDecoration(
                color: getToastColor(type),
                shape: BoxShape.circle,
              ),
              child:Icon(Icons.abc)
              //  SvgPicture.asset(getToastIcon(type)
              //  ),
            ),
            SizedBox(width: 16.0),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: isFilled ? AppColors.white : getToastColor(type),
                  fontSize: 13.sp,
                  // letterSpacing: 0.5,
                  // fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
      position: bottomPosition == true
          ? StyledToastPosition.bottom
          : StyledToastPosition.top,
      animation: bottomPosition == true
          ? StyledToastAnimation.slideFromBottom
          : StyledToastAnimation.slideFromTop,
      duration: duration,
    );
  }

  static showBottomToast(BuildContext context, String title) async {
    showToast(
      title,
      context: context,
      position: StyledToastPosition.bottom,
      animation: StyledToastAnimation.fade,
      reverseAnimation: StyledToastAnimation.fade,
      animDuration: Duration(seconds: 1),
      duration: Duration(seconds: 3),
      backgroundColor: AppColors.transparentBlack,
      textStyle: TextStyle(fontSize: 12.5, color: AppColors.white),
    );
  }

  // static String getToastIcon(ToastType type) {
  //   switch (type) {
  //     case ToastType.success:
  //       return SvgPaths.successToast;
  //     case ToastType.error:
  //       return SvgPaths.errorToast;
  //     case ToastType.warning:
  //       return SvgPaths.warningToast;

  //     default:
  //       return SvgPaths.successToast;
  //   }
  // }

  static Color getToastColor(ToastType type) {
    switch (type) {
      case ToastType.success:
        return AppColors.successGreen;
      case ToastType.error:
        return AppColors.errorRed;
      case ToastType.warning:
        return AppColors.orangeWarning;

      default:
        return AppColors.successGreen;
    }
  }
}
