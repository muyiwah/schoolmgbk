import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/parent_login_model.dart';
import 'package:schmgtsystem/services/fee_manager.dart';

/// State class for fee management
class FeeState {
  final Map<String, bool> selectedFees;
  final Map<String, int> partialPaymentAmounts;
  final FeeDetails? feeDetails;
  final FeeRecord? feeRecord;
  final bool isLoading;
  final String? errorMessage;

  FeeState({
    this.selectedFees = const {},
    this.partialPaymentAmounts = const {},
    this.feeDetails,
    this.feeRecord,
    this.isLoading = false,
    this.errorMessage,
  });

  FeeState copyWith({
    Map<String, bool>? selectedFees,
    Map<String, int>? partialPaymentAmounts,
    FeeDetails? feeDetails,
    FeeRecord? feeRecord,
    bool? isLoading,
    String? errorMessage,
  }) {
    return FeeState(
      selectedFees: selectedFees ?? this.selectedFees,
      partialPaymentAmounts:
          partialPaymentAmounts ?? this.partialPaymentAmounts,
      feeDetails: feeDetails ?? this.feeDetails,
      feeRecord: feeRecord ?? this.feeRecord,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Get total amount for selected fees
  int get selectedTotal => FeeManager.calculateSelectedTotal(
    selectedFees,
    partialPaymentAmounts,
    feeDetails,
    feeRecord,
  );

  /// Get available fee names
  List<String> get availableFeeNames =>
      FeeManager.getAvailableFeeNames(feeDetails);

  /// Check if all required fees are selected
  bool get allRequiredFeesSelected {
    if (feeDetails == null) return false;

    final requiredFees =
        availableFeeNames
            .where((name) => FeeManager.isRequiredFee(name, feeDetails))
            .toList();

    return requiredFees.every((fee) => selectedFees[fee] == true);
  }

  /// Get fee amount display for a specific fee
  String getFeeAmountDisplay(String feeName) {
    return FeeManager.getFeeAmountDisplay(feeName, feeDetails, feeRecord);
  }

  /// Get fee status for a specific fee
  String getFeeStatus(String feeName) {
    return FeeManager.getFeeStatus(feeName, feeRecord);
  }

  /// Check if fee can be unselected
  bool canUnselectFee(String feeName) {
    return FeeManager.canUnselectFee(feeName, feeDetails, feeRecord);
  }
}

/// Provider for fee state management
class FeeProvider extends StateNotifier<FeeState> {
  FeeProvider() : super(FeeState());

  /// Initialize fee data
  void initializeFees(FeeDetails feeDetails, FeeRecord? feeRecord) {
    final selectedFees = FeeManager.preSelectRequiredFees(
      feeDetails,
      feeRecord,
    );

    state = state.copyWith(
      feeDetails: feeDetails,
      feeRecord: feeRecord,
      selectedFees: selectedFees,
      partialPaymentAmounts: {},
      isLoading: false,
      errorMessage: null,
    );
  }

  /// Update fee selection
  void updateFeeSelection(String feeName, bool isSelected) {
    if (!isSelected &&
        !FeeManager.canUnselectFee(
          feeName,
          state.feeDetails,
          state.feeRecord,
        )) {
      return; // Don't allow unchecking required fees
    }

    final newSelectedFees = Map<String, bool>.from(state.selectedFees);
    newSelectedFees[feeName] = isSelected;

    state = state.copyWith(selectedFees: newSelectedFees);
  }

  /// Update partial payment amount
  void updatePartialPaymentAmount(String feeName, int amount) {
    final newPartialAmounts = Map<String, int>.from(
      state.partialPaymentAmounts,
    );
    newPartialAmounts[feeName] = amount;

    state = state.copyWith(partialPaymentAmounts: newPartialAmounts);
  }

  /// Clear all selections
  void clearSelections() {
    state = state.copyWith(selectedFees: {}, partialPaymentAmounts: {});
  }

  /// Set loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  /// Set error message
  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  /// Refresh fee data
  void refreshFees(FeeDetails feeDetails, FeeRecord? feeRecord) {
    initializeFees(feeDetails, feeRecord);
  }
}

/// Provider instance
final feeProvider = StateNotifierProvider<FeeProvider, FeeState>((ref) {
  return FeeProvider();
});
