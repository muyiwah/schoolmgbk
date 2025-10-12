import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/fees_paid_report_model.dart';
import 'package:schmgtsystem/repository/payment_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

final feesPaidReportProvider =
    StateNotifierProvider<FeesPaidReportNotifier, FeesPaidReportState>((ref) {
      return FeesPaidReportNotifier();
    });

class FeesPaidReportState {
  final FeesPaidReportModel? feesPaidReport;
  final bool isLoading;
  final String? error;
  final int currentPage;
  final String paymentStatus;
  final String? academicYear;
  final String? sortBy;
  final String sortOrder;
  final String? classId;
  final String? search;

  FeesPaidReportState({
    this.feesPaidReport,
    this.isLoading = false,
    this.error,
    this.currentPage = 1,
    this.paymentStatus = 'all',
    this.academicYear,
    this.sortBy,
    this.sortOrder = 'desc',
    this.classId,
    this.search,
  });

  FeesPaidReportState copyWith({
    FeesPaidReportModel? feesPaidReport,
    bool? isLoading,
    String? error,
    int? currentPage,
    String? paymentStatus,
    String? academicYear,
    String? sortBy,
    String? sortOrder,
    String? classId,
    String? search,
  }) {
    return FeesPaidReportState(
      feesPaidReport: feesPaidReport ?? this.feesPaidReport,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      currentPage: currentPage ?? this.currentPage,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      academicYear: academicYear ?? this.academicYear,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      classId: classId ?? this.classId,
      search: search ?? this.search,
    );
  }
}

class FeesPaidReportNotifier extends StateNotifier<FeesPaidReportState> {
  final PaymentRepository _paymentRepo = locator<PaymentRepository>();

  FeesPaidReportNotifier() : super(FeesPaidReportState());

  Future<void> loadFeesPaidReport({
    int? page,
    String? paymentStatus,
    String? academicYear,
    String? sortBy,
    String? sortOrder,
    String? classId,
    String? search,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      final response = await _paymentRepo.getFeesPaidReport(
        page: page ?? state.currentPage,
        paymentStatus: paymentStatus ?? state.paymentStatus,
        academicYear: academicYear ?? state.academicYear,
        sortBy: sortBy ?? state.sortBy,
        sortOrder: sortOrder ?? state.sortOrder,
        classId: classId ?? state.classId,
        search: search ?? state.search,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final feesPaidReport = FeesPaidReportModel.fromJson(response.data);
        state = state.copyWith(
          feesPaidReport: feesPaidReport,
          isLoading: false,
          currentPage: page ?? state.currentPage,
          paymentStatus: paymentStatus ?? state.paymentStatus,
          academicYear: academicYear ?? state.academicYear,
          sortBy: sortBy ?? state.sortBy,
          sortOrder: sortOrder ?? state.sortOrder,
          classId: classId ?? state.classId,
          search: search ?? state.search,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: response.message ?? 'Failed to load fees paid report',
        );
        CustomToastNotification.show(
          response.message ?? 'Failed to load fees paid report',
          type: ToastType.error,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      CustomToastNotification.show(
        'Error loading fees paid report: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> refreshData() async {
    await loadFeesPaidReport();
  }

  Future<void> changePage(int page) async {
    await loadFeesPaidReport(page: page);
  }

  Future<void> updateFilters({
    String? paymentStatus,
    String? academicYear,
    String? sortBy,
    String? sortOrder,
    String? classId,
    String? search,
  }) async {
    await loadFeesPaidReport(
      page: 1, // Reset to first page when filters change
      paymentStatus: paymentStatus,
      academicYear: academicYear,
      sortBy: sortBy,
      sortOrder: sortOrder,
      classId: classId,
      search: search,
    );
  }

  void clearFilters() {
    state = state.copyWith(
      paymentStatus: 'all',
      academicYear: null,
      sortBy: null,
      sortOrder: 'desc',
      classId: null,
      search: null,
      currentPage: 1,
    );
  }
}
