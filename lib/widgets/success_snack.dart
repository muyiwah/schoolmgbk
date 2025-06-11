import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSnackbar(BuildContext context, String text) {
  toastification.show(
    alignment: Alignment.topLeft,
type: ToastificationType.success,
    context: context, // optional if you use ToastificationWrapper
    title: (text),
    autoCloseDuration: const Duration(seconds: 5),
  );
}
