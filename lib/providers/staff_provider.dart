import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/staff_model.dart';
import 'package:schmgtsystem/repository/staff_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

// Staff state class
class StaffState {
  final List<Staff> staff;
  final Pagination? pagination;
  final bool isLoading;
  final String? errorMessage;

  StaffState({
    this.staff = const [],
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
  });

  StaffState copyWith({
    List<Staff>? staff,
    Pagination? pagination,
    bool? isLoading,
    String? errorMessage,
  }) {
    return StaffState(
      staff: staff ?? this.staff,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Staff notifier class
class StaffNotifier extends StateNotifier<StaffState> {
  final _staffRepo = locator<StaffRepo>();

  StaffNotifier() : super(StaffState());

  // Setter for staff data
  void setStaffData(List<Staff> staff, Pagination? pagination) {
    state = state.copyWith(
      staff: staff,
      pagination: pagination,
      errorMessage: null,
    );
  }

  // Setter for loading state
  void setLoading(bool loading) {
    state = state.copyWith(isLoading: loading);
  }

  // Setter for error state
  void setError(String? error) {
    state = state.copyWith(errorMessage: error, isLoading: false);
  }

  createStaff(BuildContext context, body) async {
    EasyLoading.show(status: 'creating staff...');

    HTTPResponseModel res = await _staffRepo.createStaff(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(
        res.message ?? 'Staff created successfully',
        type: ToastType.success,
      );

      return res.data;
    } else {
      CustomToastNotification.show(
        res.message ?? 'Failed to create staff',
        type: ToastType.error,
      );
      return null;
    }
  }

  // Method to fetch all staff
  Future<void> getAllStaff({Map<String, dynamic>? queryParams}) async {
    try {
      setLoading(true);
      setError(null);

      final response = await _staffRepo.getAllStaff(queryParams ?? {});

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final staffData = Data.fromJson(data);

        setStaffData(staffData.staff ?? [], staffData.pagination);
      } else {
        setError(response.message ?? 'Failed to fetch staff');
      }
    } catch (e) {
      setError('Error fetching staff: $e');
    } finally {
      setLoading(false);
    }
  }
}

// Provider definition
final staffNotifierProvider = StateNotifierProvider<StaffNotifier, StaffState>((
  ref,
) {
  return StaffNotifier();
});
