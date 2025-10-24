import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/admin_payment_update_model.dart';
import 'package:schmgtsystem/services/admin_payment_service.dart';

/// State for admin payment management
class AdminPaymentState {
  final bool isLoading;
  final String? error;
  final Map<String, dynamic>? paymentHistory;
  final Map<String, dynamic>? paymentBreakdown;
  final List<AdminPaymentUpdateModel> recentUpdates;
  final Map<String, dynamic>? lastApiResponse; // Store raw backend response

  AdminPaymentState({
    this.isLoading = false,
    this.error,
    this.paymentHistory,
    this.paymentBreakdown,
    this.recentUpdates = const [],
    this.lastApiResponse,
  });

  AdminPaymentState copyWith({
    bool? isLoading,
    String? error,
    Map<String, dynamic>? paymentHistory,
    Map<String, dynamic>? paymentBreakdown,
    List<AdminPaymentUpdateModel>? recentUpdates,
    Map<String, dynamic>? lastApiResponse,
  }) {
    return AdminPaymentState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      paymentHistory: paymentHistory ?? this.paymentHistory,
      paymentBreakdown: paymentBreakdown ?? this.paymentBreakdown,
      recentUpdates: recentUpdates ?? this.recentUpdates,
      lastApiResponse: lastApiResponse ?? this.lastApiResponse,
    );
  }
}

/// Provider for admin payment management
class AdminPaymentNotifier extends StateNotifier<AdminPaymentState> {
  AdminPaymentNotifier() : super(AdminPaymentState());

  /// Create new payment entry and return raw backend response
  Future<Map<String, dynamic>?> createPaymentEntry({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final response = await AdminPaymentService.createPaymentEntryWithResponse(
        studentId: studentId,
        academicYear: academicYear,
        term: term,
        amount: amount,
        method: method,
        paymentStatus: paymentStatus,
        reference: reference,
        description: description,
        remarks: remarks,
        receiptUrl: receiptUrl,
        feeBreakdown: feeBreakdown,
        paymentBreakdown: paymentBreakdown,
        context: context,
      );

      // Store the raw response
      state = state.copyWith(isLoading: false, lastApiResponse: response);

      return response;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return null;
    }
  }

  /// Update existing payment entry
  Future<bool> updatePaymentEntry({
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
    state = state.copyWith(isLoading: true, error: null);

    try {
      final success = await AdminPaymentService.updatePaymentEntry(
        studentId: studentId,
        academicYear: academicYear,
        term: term,
        paymentStatus: paymentStatus,
        reference: reference,
        remarks: remarks,
        description: description,
        receiptUrl: receiptUrl,
        feeBreakdown: feeBreakdown,
        paymentBreakdown: paymentBreakdown,
        context: context,
      );

      if (success) {
        // Add to recent updates
        final updateModel = AdminPaymentUpdateModel(
          studentId: studentId,
          academicYear: academicYear,
          term: term,
          paymentStatus: paymentStatus,
          reference: reference,
          remarks: remarks,
          description: description,
          receiptUrl: receiptUrl,
          feeBreakdown: feeBreakdown,
          paymentBreakdown: paymentBreakdown,
        );

        state = state.copyWith(
          isLoading: false,
          recentUpdates: [updateModel, ...state.recentUpdates],
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Failed to update payment entry',
        );
      }

      return success;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  /// Get student payment history
  Future<void> getStudentPaymentHistory({
    required String studentId,
    String? academicYear,
    String? term,
    int page = 1,
    int limit = 20,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final history = await AdminPaymentService.getStudentPaymentHistory(
        studentId: studentId,
        academicYear: academicYear,
        term: term,
        page: page,
        limit: limit,
        context: context,
      );

      state = state.copyWith(isLoading: false, paymentHistory: history);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Get student payment breakdown
  Future<void> getStudentPaymentBreakdown({
    required String studentId,
    required String academicYear,
    required String term,
    required BuildContext context,
  }) async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final breakdown = await AdminPaymentService.getStudentPaymentBreakdown(
        studentId: studentId,
        academicYear: academicYear,
        term: term,
        context: context,
      );

      state = state.copyWith(isLoading: false, paymentBreakdown: breakdown);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  /// Clear error state
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Clear all data
  void clear() {
    state = AdminPaymentState();
  }

  /// Validate fee breakdown
  bool validateFeeBreakdown(Map<String, dynamic> feeBreakdown) {
    return AdminPaymentService.validateFeeBreakdown(feeBreakdown);
  }

  /// Calculate total from fee breakdown
  int calculateTotalFromBreakdown(Map<String, dynamic> feeBreakdown) {
    return AdminPaymentService.calculateTotalFromBreakdown(feeBreakdown);
  }

  /// Generate default fee breakdown
  Map<String, dynamic> generateDefaultFeeBreakdown({
    required int baseFee,
    List<Map<String, dynamic>>? addOns,
  }) {
    return AdminPaymentService.generateDefaultFeeBreakdown(
      baseFee: baseFee,
      addOns: addOns,
    );
  }
}

/// Provider instance
final adminPaymentProvider =
    StateNotifierProvider<AdminPaymentNotifier, AdminPaymentState>((ref) {
      return AdminPaymentNotifier();
    });

/// Provider for payment status options
final paymentStatusOptionsProvider = Provider<List<String>>((ref) {
  return ['Pending', 'Completed', 'Failed', 'Refunded'];
});

/// Provider for payment method options
final paymentMethodOptionsProvider = Provider<List<String>>((ref) {
  return [
    'Cash',
    'Bank Transfer',
    'Cheque',
    'Card Payment',
    'Online Transfer',
    'Manual Entry',
  ];
});

/// Provider for term options
final termOptionsProvider = Provider<List<String>>((ref) {
  return ['First', 'Second', 'Third'];
});
