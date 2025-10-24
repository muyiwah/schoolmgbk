

import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';


class DialogService {
  DialogService._internal();
  static final DialogService _instance = DialogService._internal();
  factory DialogService() => _instance;

  showSnackBar(
    String message, {
    required AppToastType appToastType,
    Duration? duration,
  }) {
    ToastType toastType = switch (appToastType) {
      AppToastType.success => ToastType.success,
      AppToastType.error => ToastType.error,
      AppToastType.warning => ToastType.warning,
      _ => ToastType.success,
    };

    return CustomToastNotification.show(message,
        type: toastType, duration: duration);
  }
}
