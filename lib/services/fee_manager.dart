import 'package:schmgtsystem/models/parent_login_model.dart';

/// Centralized fee management service that serves as the single source of truth
/// for all fee calculations, selections, and payment amounts
class FeeManager {
  static final FeeManager _instance = FeeManager._internal();
  factory FeeManager() => _instance;
  FeeManager._internal();

  /// Calculate total fee amount from fee details
  static int calculateTotalFee(FeeDetails? feeDetails) {
    if (feeDetails == null) return 0;

    int total = feeDetails.baseFee ?? 0;

    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final amount = addOnMap['amount'] ?? 0;
        total += amount is int ? amount : (amount as num).toInt();
      }
    }

    return total;
  }

  /// Get fee amount for a specific fee name
  static int getFeeAmount(String feeName, FeeDetails? feeDetails) {
    if (feeDetails == null) return 0;

    if (feeName == 'Base Fee') {
      return feeDetails.baseFee ?? 0;
    }

    // Check add-ons
    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final addOnName = addOnMap['name'] ?? 'Additional Fee';
        if (addOnName == feeName) {
          final amount = addOnMap['amount'] ?? 0;
          return amount is int ? amount : (amount as num).toInt();
        }
      }
    }

    return 0;
  }

  /// Get outstanding balance for a specific fee name
  static int getOutstandingBalance(String feeName, FeeRecord? feeRecord) {
    if (feeRecord == null) return 0;

    if (feeName == 'Base Fee') {
      return feeRecord.baseFeeBalance ?? 0;
    }

    // Check add-on balances
    final addOnBalances = feeRecord.addOnBalances ?? [];
    for (final addOnBalance in addOnBalances) {
      final addOnMap = addOnBalance as Map<String, dynamic>;
      final balanceFeeName = addOnMap['name'] ?? 'Additional Fee';
      if (balanceFeeName == feeName) {
        return addOnMap['balance'] ?? 0;
      }
    }

    return 0;
  }

  /// Check if a fee is required/compulsory
  static bool isRequiredFee(String feeName, FeeDetails? feeDetails) {
    if (feeDetails == null) return false;

    if (feeName == 'Base Fee') return true;

    // Check add-ons
    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final addOnName = addOnMap['name'] ?? 'Additional Fee';
        final isRequired = addOnMap['compulsory'] ?? false;
        if (addOnName == feeName) {
          return isRequired;
        }
      }
    }

    return false;
  }

  /// Get all available fee names from fee details
  static List<String> getAvailableFeeNames(FeeDetails? feeDetails) {
    if (feeDetails == null) return ['Base Fee'];

    List<String> feeNames = ['Base Fee'];

    if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
      for (final addOn in feeDetails.addOns!) {
        final addOnMap = addOn as Map<String, dynamic>;
        final addOnName = addOnMap['name'] ?? 'Additional Fee';
        feeNames.add(addOnName);
      }
    }

    return feeNames;
  }

  /// Calculate total amount for selected fees
  static int calculateSelectedTotal(
    Map<String, bool> selectedFees,
    Map<String, int> partialPaymentAmounts,
    FeeDetails? feeDetails,
    FeeRecord? feeRecord,
  ) {
    int total = 0;
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    selectedFees.forEach((feeName, isSelected) {
      if (isSelected) {
        if (hasExistingPayments) {
          // Use outstanding balance
          total += getOutstandingBalance(feeName, feeRecord);
        } else {
          // Use full fee amount
          total += getFeeAmount(feeName, feeDetails);
        }
      }
    });

    return total;
  }

  /// Get fee status (Paid, Outstanding, Pending)
  static String getFeeStatus(String feeName, FeeRecord? feeRecord) {
    if (feeRecord == null) return 'Pending';

    final hasExistingPayments =
        feeRecord.amountPaid != null && feeRecord.amountPaid! > 0;

    if (hasExistingPayments) {
      final outstandingAmount = getOutstandingBalance(feeName, feeRecord);
      if (outstandingAmount > 0) {
        return 'Outstanding';
      } else {
        return 'Paid';
      }
    } else {
      return 'Pending';
    }
  }

  /// Get fee amount display string with formatting
  static String getFeeAmountDisplay(
    String feeName,
    FeeDetails? feeDetails,
    FeeRecord? feeRecord,
  ) {
    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    int amount;
    if (hasExistingPayments) {
      amount = getOutstandingBalance(feeName, feeRecord);
    } else {
      amount = getFeeAmount(feeName, feeDetails);
    }

    return '₦${amount.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}';
  }

  /// Pre-select required fees
  static Map<String, bool> preSelectRequiredFees(
    FeeDetails? feeDetails,
    FeeRecord? feeRecord,
  ) {
    Map<String, bool> selectedFees = {};

    if (feeDetails == null) return selectedFees;

    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, only select outstanding balances
      final baseFeeBalance = feeRecord.baseFeeBalance ?? 0;
      if (baseFeeBalance > 0) {
        selectedFees['Base Fee'] = true;
      }

      final addOnBalances = feeRecord.addOnBalances ?? [];
      for (final addOnBalance in addOnBalances) {
        final addOnMap = addOnBalance as Map<String, dynamic>;
        final feeName = addOnMap['name'] ?? 'Additional Fee';
        final balance = addOnMap['balance'] ?? 0;

        if (balance > 0) {
          selectedFees[feeName] = true;
        }
      }
    } else {
      // If no payments, select required fields
      selectedFees['Base Fee'] = true;

      if (feeDetails.addOns != null && feeDetails.addOns!.isNotEmpty) {
        for (final addOn in feeDetails.addOns!) {
          final addOnMap = addOn as Map<String, dynamic>;
          final feeName = addOnMap['name'] ?? 'Additional Fee';
          final isRequired = addOnMap['compulsory'] ?? false;

          if (isRequired) {
            selectedFees[feeName] = true;
          }
        }
      }
    }

    return selectedFees;
  }

  /// Validate fee selection (prevent unchecking required fees)
  static bool canUnselectFee(
    String feeName,
    FeeDetails? feeDetails,
    FeeRecord? feeRecord,
  ) {
    if (feeDetails == null) return false;

    final hasExistingPayments =
        feeRecord?.amountPaid != null && feeRecord!.amountPaid! > 0;

    if (hasExistingPayments) {
      // If there are existing payments, don't allow unchecking outstanding balances
      return false;
    } else {
      // If no payments, prevent unchecking required fields
      return !isRequiredFee(feeName, feeDetails);
    }
  }
}
