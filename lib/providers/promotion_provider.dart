import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/promotion_model.dart';
import 'package:schmgtsystem/repository/promotion_repository.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

// State classes
class PromotionEligibleState {
  final List<PromotionEligibleStudent> students;
  final List<AvailableClass> availableClasses;
  final CurrentClass? currentClass;
  final PromotionSummary? summary;
  final bool isLoading;
  final String? errorMessage;

  PromotionEligibleState({
    this.students = const [],
    this.availableClasses = const [],
    this.currentClass,
    this.summary,
    this.isLoading = false,
    this.errorMessage,
  });

  PromotionEligibleState copyWith({
    List<PromotionEligibleStudent>? students,
    List<AvailableClass>? availableClasses,
    CurrentClass? currentClass,
    PromotionSummary? summary,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PromotionEligibleState(
      students: students ?? this.students,
      availableClasses: availableClasses ?? this.availableClasses,
      currentClass: currentClass ?? this.currentClass,
      summary: summary ?? this.summary,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class PromotionHistoryState {
  final List<PromotionModel> promotions;
  final PaginationInfo? pagination;
  final bool isLoading;
  final String? errorMessage;

  PromotionHistoryState({
    this.promotions = const [],
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
  });

  PromotionHistoryState copyWith({
    List<PromotionModel>? promotions,
    PaginationInfo? pagination,
    bool? isLoading,
    String? errorMessage,
  }) {
    return PromotionHistoryState(
      promotions: promotions ?? this.promotions,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

// Providers
final promotionEligibleProvider =
    StateNotifierProvider<PromotionEligibleNotifier, PromotionEligibleState>((
      ref,
    ) {
      return PromotionEligibleNotifier();
    });

final promotionHistoryProvider =
    StateNotifierProvider<PromotionHistoryNotifier, PromotionHistoryState>((
      ref,
    ) {
      return PromotionHistoryNotifier();
    });

// Notifier classes
class PromotionEligibleNotifier extends StateNotifier<PromotionEligibleState> {
  final _promotionRepo = locator<PromotionRepository>();

  PromotionEligibleNotifier() : super(PromotionEligibleState());

  // Setter for eligible students data
  void setEligibleStudentsData(
    List<PromotionEligibleStudent> students,
    List<AvailableClass> availableClasses,
    CurrentClass currentClass,
    PromotionSummary summary,
  ) {
    state = state.copyWith(
      students: students,
      availableClasses: availableClasses,
      currentClass: currentClass,
      summary: summary,
      errorMessage: null,
      isLoading: false,
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

  // Get promotion eligible students
  Future<void> getPromotionEligibleStudents({
    required String classId,
    String? academicYear,
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _promotionRepo.getPromotionEligibleStudents(
        classId: classId,
        academicYear: academicYear,
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final eligibleResponse = PromotionEligibleResponse.fromJson(
          response.data,
        );
        setEligibleStudentsData(
          eligibleResponse.data.eligibleStudents,
          eligibleResponse.data.availableClasses,
          eligibleResponse.data.currentClass,
          eligibleResponse.data.summary,
        );
      } else {
        setError(response.message ?? 'Failed to load eligible students');
      }
    } catch (e) {
      setError('Error loading eligible students: $e');
    }
  }

  // Promote students
  Future<bool> promoteStudents({
    required String fromClassId,
    String? toClassId,
    required String academicYear,
    String? processedBy,
    List<String>? studentIds,
    String promotionType = 'promoted',
    String term = 'First Term',
  }) async {
    EasyLoading.show(status: 'Processing promotion...');

    try {
      final response = await _promotionRepo.promoteStudents(
        fromClassId: fromClassId,
        toClassId: toClassId,
        academicYear: academicYear,
        processedBy: processedBy,
        studentIds: studentIds,
        promotionType: promotionType,
        term: term,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        CustomToastNotification.show(
          response.message ?? 'Students promoted successfully',
          type: ToastType.success,
        );
        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to promote students',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error promoting students: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Promote individual student
  Future<bool> promoteIndividualStudent({
    required String studentId,
    String? toClassId,
    required String academicYear,
    String promotionType = 'promoted',
    String? remarks,
  }) async {
    EasyLoading.show(status: 'Processing promotion...');

    try {
      final response = await _promotionRepo.promoteIndividualStudent(
        studentId: studentId,
        toClassId: toClassId,
        academicYear: academicYear,
        promotionType: promotionType,
        remarks: remarks,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        CustomToastNotification.show(
          response.message ?? 'Student promoted successfully',
          type: ToastType.success,
        );
        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to promote student',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error promoting student: $e',
        type: ToastType.error,
      );
      return false;
    }
  }
}

class PromotionHistoryNotifier extends StateNotifier<PromotionHistoryState> {
  final _promotionRepo = locator<PromotionRepository>();

  PromotionHistoryNotifier() : super(PromotionHistoryState());

  // Setter for promotion history data
  void setPromotionHistoryData(
    List<PromotionModel> promotions,
    PaginationInfo pagination,
  ) {
    state = state.copyWith(
      promotions: promotions,
      pagination: pagination,
      errorMessage: null,
      isLoading: false,
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

  // Get promotion history
  Future<void> getPromotionHistory({
    int page = 1,
    int limit = 10,
    String? academicYear,
    String sortBy = 'promotionDate',
    String sortOrder = 'desc',
  }) async {
    setLoading(true);
    setError(null);

    try {
      final response = await _promotionRepo.getPromotionHistory(
        page: page,
        limit: limit,
        academicYear: academicYear,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final historyResponse = PromotionHistoryResponse.fromJson(
          response.data,
        );
        setPromotionHistoryData(
          historyResponse.data.promotions,
          historyResponse.data.pagination,
        );
      } else {
        setError(response.message ?? 'Failed to load promotion history');
      }
    } catch (e) {
      setError('Error loading promotion history: $e');
    }
  }
}
