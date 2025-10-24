import 'package:flutter/material.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/repository/payment_repo.dart';

/// Service for admin payment management operations
class AdminPaymentService {
  /// Create new payment entry and return raw backend response
  static Future<Map<String, dynamic>?> createPaymentEntryWithResponse({
    required String studentId,
    required String academicYear,
    required String term,
    required int amount,
    required String method,
    required String paymentStatus,
    String? reference,
    String? description,
    String? remarks,
    String? receiptUrl,
    Map<String, dynamic>? feeBreakdown,
    Map<String, dynamic>? paymentBreakdown,
    required BuildContext context,
  }) async {
    try {
      // Validate required fields for creating new payment
      if (studentId.isEmpty) {
        CustomToastNotification.show(
          'Student ID is required',
          type: ToastType.error,
        );
        return null;
      }

      if (academicYear.isEmpty) {
        CustomToastNotification.show(
          'Academic year is required',
          type: ToastType.error,
        );
        return null;
      }

      if (term.isEmpty) {
        CustomToastNotification.show('Term is required', type: ToastType.error);
        return null;
      }

      if (amount <= 0) {
        CustomToastNotification.show(
          'Amount must be greater than 0',
          type: ToastType.error,
        );
        return null;
      }

      if (method.isEmpty) {
        CustomToastNotification.show(
          'Payment method is required',
          type: ToastType.error,
        );
        return null;
      }

      if (![
        'Pending',
        'Completed',
        'Failed',
        'Refunded',
      ].contains(paymentStatus)) {
        CustomToastNotification.show(
          'Invalid payment status. Must be: Pending, Completed, Failed, or Refunded',
          type: ToastType.error,
        );
        return null;
      }

      // Note: adminManualPaymentUpdate method no longer exists in PaymentRepository
      // This method call should be removed or replaced with appropriate alternative
      Navigator.of(context).pop(); // Close loading dialog
      return null;
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      CustomToastNotification.show(
        'Error creating payment entry: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  /// Create new payment entry
  static Future<bool> createPaymentEntry({
    required String studentId,
    required String academicYear,
    required String term,
    required int amount,
    required String method,
    required String paymentStatus,
    String? reference,
    String? description,
    String? remarks,
    String? receiptUrl,
    Map<String, dynamic>? feeBreakdown,
    Map<String, dynamic>? paymentBreakdown,
    required BuildContext context,
  }) async {
    try {
      // Validate required fields for creating new payment
      if (studentId.isEmpty) {
        CustomToastNotification.show(
          'Student ID is required',
          type: ToastType.error,
        );
        return false;
      }

      if (academicYear.isEmpty) {
        CustomToastNotification.show(
          'Academic year is required',
          type: ToastType.error,
        );
        return false;
      }

      if (term.isEmpty) {
        CustomToastNotification.show('Term is required', type: ToastType.error);
        return false;
      }

      if (amount <= 0) {
        CustomToastNotification.show(
          'Amount must be greater than 0',
          type: ToastType.error,
        );
        return false;
      }

      if (method.isEmpty) {
        CustomToastNotification.show(
          'Payment method is required',
          type: ToastType.error,
        );
        return false;
      }

      if (![
        'Pending',
        'Completed',
        'Failed',
        'Refunded',
      ].contains(paymentStatus)) {
        CustomToastNotification.show(
          'Invalid payment status. Must be: Pending, Completed, Failed, or Refunded',
          type: ToastType.error,
        );
        return false;
      }

      // Note: adminManualPaymentUpdate method no longer exists in PaymentRepository
      // This method call should be removed or replaced with appropriate alternative
      CustomToastNotification.show(
        'Payment entry creation not available',
        type: ToastType.error,
      );
      return false;
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      CustomToastNotification.show(
        'Error creating payment entry: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  /// Update existing payment entry
  static Future<bool> updatePaymentEntry({
    required String studentId,
    required String academicYear,
    required String term,
    String? paymentStatus,
    String? reference,
    String? remarks,
    String? description,
    String? receiptUrl,
    Map<String, dynamic>? feeBreakdown,
    Map<String, dynamic>? paymentBreakdown,
    required BuildContext context,
  }) async {
    try {
      // Validate required fields for updating payment
      if (studentId.isEmpty) {
        CustomToastNotification.show(
          'Student ID is required',
          type: ToastType.error,
        );
        return false;
      }

      if (academicYear.isEmpty) {
        CustomToastNotification.show(
          'Academic year is required',
          type: ToastType.error,
        );
        return false;
      }

      if (term.isEmpty) {
        CustomToastNotification.show('Term is required', type: ToastType.error);
        return false;
      }

      // At least one field must be provided for update
      if (paymentStatus == null &&
          reference == null &&
          remarks == null &&
          description == null &&
          receiptUrl == null &&
          feeBreakdown == null &&
          paymentBreakdown == null) {
        CustomToastNotification.show(
          'At least one field must be provided for update',
          type: ToastType.error,
        );
        return false;
      }

      if (paymentStatus != null &&
          ![
            'Pending',
            'Completed',
            'Failed',
            'Refunded',
          ].contains(paymentStatus)) {
        CustomToastNotification.show(
          'Invalid payment status. Must be: Pending, Completed, Failed, or Refunded',
          type: ToastType.error,
        );
        return false;
      }

      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // Note: adminManualPaymentUpdate method no longer exists in PaymentRepository
      // This method call should be removed or replaced with appropriate alternative
      Navigator.of(context).pop(); // Close loading dialog
      CustomToastNotification.show(
        'Payment entry update not available',
        type: ToastType.error,
      );
      return false;
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      CustomToastNotification.show(
        'Error updating payment entry: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  /// Get student payment history
  static Future<Map<String, dynamic>?> getStudentPaymentHistory({
    required String studentId,
    String? academicYear,
    String? term,
    int page = 1,
    int limit = 20,
    required BuildContext context,
  }) async {
    try {
      // Note: getStudentPaymentHistory method no longer exists in PaymentRepository
      // This method call should be removed or replaced with appropriate alternative
      CustomToastNotification.show(
        'Payment history not available',
        type: ToastType.error,
      );
      return null;
    } catch (e) {
      CustomToastNotification.show(
        'Error fetching payment history: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  /// Get student payment breakdown
  static Future<Map<String, dynamic>?> getStudentPaymentBreakdown({
    required String studentId,
    required String academicYear,
    required String term,
    required BuildContext context,
  }) async {
    try {
      // Note: getStudentPaymentBreakdown method no longer exists in PaymentRepository
      // This method call should be removed or replaced with appropriate alternative
      CustomToastNotification.show(
        'Payment breakdown not available',
        type: ToastType.error,
      );
      return null;
    } catch (e) {
      CustomToastNotification.show(
        'Error fetching payment breakdown: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  /// Validate fee breakdown structure
  static bool validateFeeBreakdown(Map<String, dynamic> feeBreakdown) {
    if (feeBreakdown.isEmpty) return false;

    // Check if base fee is present
    if (!feeBreakdown.containsKey('baseFee') ||
        feeBreakdown['baseFee'] == null) {
      return false;
    }

    // Check if base fee is a valid number
    final baseFee = feeBreakdown['baseFee'];
    if (baseFee is! int && baseFee is! double) {
      return false;
    }

    // Check add-ons if present
    if (feeBreakdown.containsKey('addOns')) {
      final addOns = feeBreakdown['addOns'];
      if (addOns is List) {
        for (final addOn in addOns) {
          if (addOn is Map<String, dynamic>) {
            if (!addOn.containsKey('name') || !addOn.containsKey('amount')) {
              return false;
            }
            if (addOn['amount'] is! int && addOn['amount'] is! double) {
              return false;
            }
          } else {
            return false;
          }
        }
      }
    }

    return true;
  }

  /// Calculate total amount from fee breakdown
  static int calculateTotalFromBreakdown(Map<String, dynamic> feeBreakdown) {
    int total = 0;

    // Add base fee
    if (feeBreakdown.containsKey('baseFee')) {
      final baseFee = feeBreakdown['baseFee'];
      if (baseFee is int) {
        total += baseFee;
      } else if (baseFee is double) {
        total += baseFee.toInt();
      }
    }

    // Add add-ons
    if (feeBreakdown.containsKey('addOns')) {
      final addOns = feeBreakdown['addOns'];
      if (addOns is List) {
        for (final addOn in addOns) {
          if (addOn is Map<String, dynamic> && addOn.containsKey('amount')) {
            final amount = addOn['amount'];
            if (amount is int) {
              total += amount;
            } else if (amount is double) {
              total += amount.toInt();
            }
          }
        }
      }
    }

    return total;
  }

  /// Generate default fee breakdown structure
  static Map<String, dynamic> generateDefaultFeeBreakdown({
    required int baseFee,
    List<Map<String, dynamic>>? addOns,
  }) {
    return {
      'baseFee': baseFee,
      'addOns': addOns ?? [],
      'totalAmount':
          baseFee +
          (addOns?.fold<int>(
                0,
                (sum, addOn) => sum + ((addOn['amount'] as num?)?.toInt() ?? 0),
              ) ??
              0),
    };
  }

  /// Update manual payment status
  static Future<Map<String, dynamic>?> updateManualPaymentStatus({
    required String studentId,
    required String academicYear,
    required String term,
    required String remarks,
    required BuildContext context,
  }) async {
    try {
      // Validate required fields
      if (studentId.isEmpty) {
        CustomToastNotification.show(
          'Student ID is required',
          type: ToastType.error,
        );
        return null;
      }

      if (academicYear.isEmpty) {
        CustomToastNotification.show(
          'Academic year is required',
          type: ToastType.error,
        );
        return null;
      }

      if (term.isEmpty) {
        CustomToastNotification.show('Term is required', type: ToastType.error);
        return null;
      }

      if (remarks.isEmpty) {
        CustomToastNotification.show(
          'Remarks are required',
          type: ToastType.error,
        );
        return null;
      }

      // Prepare payment data
      final paymentData = {
        "studentId": studentId,
        "academicYear": academicYear,
        "term": term,
        "remarks": remarks,
      };

      // Call the repository
      final paymentRepo = PaymentRepository();
      final response = await paymentRepo.updateManualPaymentStatu(paymentData);

      print(
        '🔍 AdminPaymentService: Repository response code: ${response.code}',
      );
      print(
        '🔍 AdminPaymentService: Repository response data: ${response.data}',
      );
      print(
        '🔍 AdminPaymentService: Repository response message: ${response.message}',
      );

      if (response.code == 200 || response.code == 201) {
        // Don't show toast here - let the screen handle the success display
        return response.data;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to update payment status',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error updating payment status: $e',
        type: ToastType.error,
      );
      return null;
    }
  }
}
