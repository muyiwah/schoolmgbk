/// Payment Integration Guide
/// 
/// This guide explains how to integrate Stripe payments with the new response format.
/// 
/// ## Stripe Payment Response Format
/// 
/// The Stripe endpoint returns the following response structure:
/// ```json
/// {
///   "success": true,
///   "message": "Payment initialization successful",
///   "data": {
///     "checkout_url": "https://checkout.stripe.com/c/pay/cs_test_..."
///   }
/// }
/// ```
/// 
/// ## Implementation Options
/// 
/// ### Option 1: Direct Implementation (Current)
/// 
/// In the parent dashboard, the payment initialization is handled directly:
/// 
/// ```dart
/// // Initialize payment with current data
/// final paymentData = {
///   "studentId": studentId,
///   "parentId": parentId,
///   "academicYear": "2025/2026",
///   "term": "First",
///   "paymentType": "Tuition",
///   "amount": totalAmount,
///   "callbackUrl": "https://your-callback-url.com",
///   "metadata": "School fees payment",
///   "description": "First term tuition payment",
///   "feeRecordId": feeRecordId,
///   "feeBreakdown": feeBreakdown,
///   "transactionDetails": transactionDetails,
/// };
/// 
/// final response = await _paymentRepo.initializePayment(paymentData);
/// 
/// if (HTTPResponseModel.isApiCallSuccess(response) && response.data != null) {
///   // Parse the response using the model
///   final paymentResponse = PaymentInitializationResponse.fromJson(response.data);
///   
///   if (paymentResponse.success && paymentResponse.data.checkoutUrl.isNotEmpty) {
///     // Launch the Stripe checkout URL
///     await _launchPaymentUrl(paymentResponse.data.checkoutUrl);
///     
///     // Show success message and handle callbacks
///     showSnackbar(context, 'Payment initialized successfully! Redirecting to Stripe checkout...');
///     Navigator.of(context).pop(); // Close payment dialog
///   } else {
///     _showErrorDialog('Payment initialization failed: ${paymentResponse.message}');
///   }
/// }
/// ```
/// 
/// ### Option 2: Using PaymentService (Recommended for new implementations)
/// 
/// ```dart
/// final success = await PaymentService.initializeStripePayment(
///   paymentData: paymentData,
///   onSuccess: () {
///     // Handle success
///     print('Payment initialized successfully');
///   },
///   onError: (error) {
///     // Handle error
///     print('Payment error: $error');
///   },
///   onClose: () {
///     // Handle close
///     print('Payment dialog closed');
///   },
/// );
/// ```
/// 
/// ### Option 3: Using PaymentProvider (For state management)
/// 
/// ```dart
/// class MyPaymentWidget extends ConsumerWidget {
///   @override
///   Widget build(BuildContext context, WidgetRef ref) {
///     final paymentState = ref.watch(paymentProvider);
///     
///     return ElevatedButton(
///       onPressed: paymentState.isInitializing ? null : () async {
///         await ref.read(paymentProvider.notifier).initializePayment(
///           context: context,
///           paymentData: paymentData,
///           onSuccess: () {
///             // Handle success
///           },
///           onClose: () {
///             // Handle close
///           },
///         );
///       },
///       child: paymentState.isInitializing
///           ? CircularProgressIndicator()
///           : Text('Pay Now'),
///     );
///   }
/// }
/// ```
/// 
/// ### Option 4: Using StripePaymentHelper (For fee payments)
/// 
/// ```dart
/// await StripePaymentHelper.initializePaymentWithCurrentData(
///   context: context,
///   selectedFees: selectedFees,
///   partialPaymentAmounts: partialPaymentAmounts,
///   feeDetails: feeDetails,
///   feeRecord: feeRecord,
///   ref: ref,
///   onSuccess: () {
///     // Handle success
///   },
/// );
/// ```
/// 
/// ## Models Added
/// 
/// ### PaymentInitializationResponse
/// ```dart
/// class PaymentInitializationResponse {
///   final bool success;
///   final String message;
///   final PaymentData data;
///   // ... with fromJson/toJson methods
/// }
/// 
/// class PaymentData {
///   final String checkoutUrl;
///   // ... with fromJson/toJson methods
/// }
/// ```
/// 
/// ## Services Added
/// 
/// ### PaymentService
/// - `initializeStripePayment()` - Main payment initialization method
/// - `createPaymentData()` - Helper to create payment data structure
/// - `showPaymentInitializationDialog()` - Show loading dialog
/// - `showPaymentSuccess()` / `showPaymentError()` - Show notifications
/// 
/// ### StripePaymentHelper
/// - `initializePaymentWithCurrentData()` - Initialize payment with current fee data
/// - Helper methods for fee breakdown and error handling
/// 
/// ## Providers Added
/// 
/// ### PaymentProvider
/// - State management for payment operations
/// - Loading states and error handling
/// - Riverpod integration
/// 
/// ## Dependencies Updated
/// 
/// - Added PaymentRepo to locator.dart
/// - All necessary imports added to relevant files
/// 
/// ## Usage Notes
/// 
/// 1. The current parent dashboard implementation has been updated to use the new response format
/// 2. The `checkout_url` field is now properly parsed and used for redirection
/// 3. Error handling includes response message from the API
/// 4. The payment initialization dialog is properly managed
/// 5. URL launching uses `LaunchMode.externalApplication` for better security
/// 
/// ## Testing
/// 
/// To test the integration:
/// 1. Ensure the backend returns the correct response format
/// 2. Verify the checkout URL is valid and accessible
/// 3. Test error scenarios (network issues, invalid data, etc.)
/// 4. Confirm the external browser launch works on the target platform

