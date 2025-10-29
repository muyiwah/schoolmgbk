import 'package:flutter/material.dart';
import 'package:toastification/toastification.dart';

void showSnackbar(BuildContext context, String text) {
  toastification.show(
    alignment: Alignment.topLeft,
    type: ToastificationType.success,
    context: context, // optional if you use ToastificationWrapper
    title: text,
    autoCloseDuration: const Duration(seconds: 5),
  );
}

void showTopSnackBar(
  BuildContext context,
  String message,
  Color backgroundColor,
) {
  final mediaQuery = MediaQuery.of(context);
  final screenHeight = mediaQuery.size.height;
  final screenWidth = mediaQuery.size.width;

  // Calculate text width (approximate) to size the snackbar
  final textPainter = TextPainter(
    text: TextSpan(
      text: message,
      style: const TextStyle(color: Colors.white, fontSize: 14),
    ),
    textDirection: TextDirection.ltr,
  );
  textPainter.layout();

  final textWidth = textPainter.width;
  final padding = 24.0; // Horizontal padding for snackbar
  final snackbarWidth = (textWidth + padding).clamp(200.0, screenWidth - 32);
  final leftMargin = (screenWidth - snackbarWidth) / 2;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(
        bottom: screenHeight - 100,
        left: leftMargin,
        right: leftMargin,
      ),
    ),
  );
}
