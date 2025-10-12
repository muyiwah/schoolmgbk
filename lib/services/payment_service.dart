import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class PaymentService {
  /// Initialize Stripe payment and redirect to checkout
  static Future<bool> initializeStripePayment({
    required Map<String, dynamic> paymentData,
    required VoidCallback? onSuccess,
    required Function(String)? onError,
    required VoidCallback? onClose,
  }) async {
    try {
      // Note: PaymentRepository no longer has initializePayment method
      // This method call should be removed or replaced with appropriate alternative
      onError?.call('Payment initialization not available');
      return false;
    } catch (e) {
      onError?.call('Payment initialization error: $e');
      return false;
    }
  }

  /// Launch payment URL in external browser
  static Future<bool> _launchPaymentUrl(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Create payment data structure for Stripe
  static Map<String, dynamic> createPaymentData({
    required String studentId,
    required String parentId,
    required String academicYear,
    required String term,
    required String paymentType,
    required int amount,
    required String callbackUrl,
    required String metadata,
    required String description,
    String? feeRecordId,
    Map<String, dynamic>? feeBreakdown,
    Map<String, dynamic>? transactionDetails,
  }) {
    return {
      "studentId": studentId,
      "parentId": parentId,
      "academicYear": academicYear,
      "term": term,
      "paymentType": paymentType,
      "amount": amount,
      "callbackUrl": callbackUrl,
      "metadata": metadata,
      "description": description,
      if (feeRecordId != null) "feeRecordId": feeRecordId,
      if (feeBreakdown != null) "feeBreakdown": feeBreakdown,
      if (transactionDetails != null) "transactionDetails": transactionDetails,
    };
  }

  /// Show payment initialization dialog
  static Future<void> showPaymentInitializationDialog(
    BuildContext context,
    String message,
  ) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 16),
                Text(message),
              ],
            ),
          ),
    );
  }

  /// Hide payment initialization dialog
  static void hidePaymentInitializationDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  /// Show payment success notification
  static void showPaymentSuccess(BuildContext context, String message) {
    CustomToastNotification.show(message, type: ToastType.success);
  }

  /// Show payment error notification
  static void showPaymentError(BuildContext context, String message) {
    CustomToastNotification.show(message, type: ToastType.error);
  }
}
