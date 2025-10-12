import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/payment_response_model.dart';
import 'package:schmgtsystem/services/payment_service.dart';

/// Payment state
class PaymentState {
  final bool isInitializing;
  final PaymentInitializationResponse? paymentResponse;
  final String? errorMessage;

  PaymentState({
    this.isInitializing = false,
    this.paymentResponse,
    this.errorMessage,
  });

  PaymentState copyWith({
    bool? isInitializing,
    PaymentInitializationResponse? paymentResponse,
    String? errorMessage,
  }) {
    return PaymentState(
      isInitializing: isInitializing ?? this.isInitializing,
      paymentResponse: paymentResponse ?? this.paymentResponse,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

/// Payment provider
class PaymentProvider extends StateNotifier<PaymentState> {
  PaymentProvider() : super(PaymentState());

  /// Initialize Stripe payment
  Future<bool> initializePayment({
    required BuildContext context,
    required Map<String, dynamic> paymentData,
    required VoidCallback? onSuccess,
    required VoidCallback? onClose,
  }) async {
    state = state.copyWith(isInitializing: true, errorMessage: null);

    try {
      final success = await PaymentService.initializeStripePayment(
        paymentData: paymentData,
        onSuccess: () {
          PaymentService.showPaymentSuccess(
            context,
            'Payment initialized successfully! Redirecting to Stripe checkout...',
          );
          onSuccess?.call();
          state = state.copyWith(isInitializing: false, errorMessage: null);
        },
        onError: (error) {
          PaymentService.showPaymentError(context, error);
          state = state.copyWith(isInitializing: false, errorMessage: error);
        },
        onClose: onClose,
      );

      return success;
    } catch (e) {
      final errorMessage = 'Payment initialization error: $e';
      PaymentService.showPaymentError(context, errorMessage);
      state = state.copyWith(isInitializing: false, errorMessage: errorMessage);
      return false;
    }
  }

  /// Clear payment state
  void clearState() {
    state = PaymentState();
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isInitializing: loading);
  }

  /// Set error message
  void setError(String? error) {
    state = state.copyWith(errorMessage: error);
  }
}

/// Provider instance
final paymentProvider = StateNotifierProvider<PaymentProvider, PaymentState>(
  (ref) => PaymentProvider(),
);
