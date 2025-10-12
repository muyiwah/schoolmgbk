// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:schmgtsystem/models/parent_login_model.dart';
// import 'package:schmgtsystem/services/payment_service.dart';
// import 'package:schmgtsystem/providers/provider.dart';
// import 'package:schmgtsystem/services/fee_manager.dart';

// /// Helper class for Stripe payment initialization
// class StripePaymentHelper {
//   /// Initialize Stripe payment with current fee data
//   static Future<void> initializePaymentWithCurrentData({
//     required BuildContext context,
//     required Map<String, bool> selectedFees,
//     required Map<String, int> partialPaymentAmounts,
//     required FeeDetails? feeDetails,
//     required FeeRecord? feeRecord,
//     required WidgetRef ref,
//     required VoidCallback? onSuccess,
//   }) async {
//     try {
//       // Show payment initialization dialog
//       PaymentService.showPaymentInitializationDialog(
//         context,
//         'Initializing payment...',
//       );

//       // Get parent and student information
//       final parentLoginProvider = ProviderScope.containerOf(
//         context,
//       ).read(RiverpodProvider.parentLoginProvider.notifier);

//       final children = parentLoginProvider.children ?? [];
//       if (children.isEmpty) {
//         PaymentService.hidePaymentInitializationDialog(context);
//         _showErrorDialog(context, 'No children found');
//         return;
//       }

//       final selectedChild = children[0]; // Use first child for now
//       final studentId = selectedChild.student?.id ?? '';
//       final parentId = parentLoginProvider.currentParent?.id ?? '';
//       final classId =
//           selectedChild.student?.academicInfo?.currentClass?.id ?? '';

//       if (studentId.isEmpty || parentId.isEmpty || classId.isEmpty) {
//         PaymentService.hidePaymentInitializationDialog(context);
//         _showErrorDialog(
//           context,
//           'Student, parent, or class information not found',
//         );
//         return;
//       }

//       // Get fee record ID
//       final feeRecordId = feeRecord?.id ?? '';
//       if (feeRecordId.isEmpty) {
//         PaymentService.hidePaymentInitializationDialog(context);
//         _showErrorDialog(context, 'Fee record not found');
//         return;
//       }

//       // Calculate total amount using centralized fee manager
//       final totalAmount = FeeManager.calculateSelectedTotal(
//         selectedFees,
//         partialPaymentAmounts,
//         feeDetails,
//         feeRecord,
//       );

//       // Prepare detailed fee breakdown for payment
//       final feeBreakdown = _buildFeeBreakdownForPayment(
//         selectedFees,
//         feeDetails,
//       );

//       // Create payment data
//       final paymentData = PaymentService.createPaymentData(
//         studentId: studentId,
//         parentId: parentId,
//         classId: classId,
//         academicYear: "2025/2026", // You can make this dynamic
//         term: "First", // You can make this dynamic
//         paymentType: "Tuition",
//         amount: totalAmount,
//         callbackUrl:
//             "https://your-callback-url.com", // Update with your actual callback URL
//         metadata: "School fees payment",
//         description: "First term tuition payment",
//         feeRecordId: feeRecordId,
//         feeBreakdown: feeBreakdown,
//         transactionDetails: {
//           "transactionId": "TXN${DateTime.now().millisecondsSinceEpoch}",
//           "bankName": "Stripe",
//           "accountNumber": "N/A",
//           "referenceNumber": "REF${DateTime.now().millisecondsSinceEpoch}",
//         },
//       );

//       // Initialize payment
//       final success = await PaymentService.initializeStripePayment(
//         paymentData: paymentData,
//         onSuccess: () {
//           PaymentService.hidePaymentInitializationDialog(context);
//           onSuccess?.call();
//           // Schedule refresh after 25 seconds to fetch updated data
//           _scheduleDataRefresh();
//         },
//         onError: (error) {
//           PaymentService.hidePaymentInitializationDialog(context);
//           _showErrorDialog(context, error);
//         },
//         onClose: () {
//           PaymentService.hidePaymentInitializationDialog(context);
//         },
//       );

//       // If payment service doesn't handle the dialog, hide it
//       if (!success) {
//         PaymentService.hidePaymentInitializationDialog(context);
//       }
//     } catch (e) {
//       PaymentService.hidePaymentInitializationDialog(context);
//       _showErrorDialog(context, 'Payment initialization error: $e');
//     }
//   }

//   /// Build detailed fee breakdown for payment
//   static Map<String, dynamic> _buildFeeBreakdownForPayment(
//     Map<String, bool> selectedFees,
//     FeeDetails? feeDetails,
//   ) {
//     final feeBreakdown = <String, dynamic>{};
//     final hasExistingPayments = false; // You can check this if needed

//     feeBreakdown['selectedFees'] = selectedFees;
//     feeBreakdown['hasExistingPayments'] = hasExistingPayments;

//     if (feeDetails != null) {
//       feeBreakdown['feeDetails'] = {
//         'baseFee': feeDetails.baseFee,
//         'totalFee': feeDetails.totalFee,
//         'addOns': feeDetails.addOns ?? [],
//       };
//     }

//     return feeBreakdown;
//   }

//   /// Schedule data refresh after payment
//   static void _scheduleDataRefresh() {
//     // Schedule refresh after 25 seconds to fetch updated data
//     Future.delayed(const Duration(seconds: 25), () {
//       // You can call refresh methods here
//       print('Scheduling data refresh after payment...');
//     });
//   }

//   /// Show error dialog
//   static void _showErrorDialog(BuildContext context, String message) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             title: const Text('Payment Error'),
//             content: Text(message),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.of(context).pop(),
//                 child: const Text('OK'),
//               ),
//             ],
//           ),
//     );
//   }
// }
