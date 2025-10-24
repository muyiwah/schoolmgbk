import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/academic_settings_model.dart';
import '../repository/academic_settings_repository.dart';
import '../utils/locator.dart';
import '../utils/response_model.dart';
import '../widgets/custom_toast_notification.dart';
import '../services/global_academic_year_service.dart';

class AcademicSettingsState {
  final List<AcademicSettingsModel> academicSettings;
  final AcademicSettingsModel? currentAcademicYear;
  final Statistics? statistics;
  final PaginationInfo? pagination;
  final UpdateResult? updateResult;
  final bool isLoading;
  final String? errorMessage;
  final String? lastRequestHash;

  AcademicSettingsState({
    this.academicSettings = const [],
    this.currentAcademicYear,
    this.statistics,
    this.pagination,
    this.updateResult,
    this.isLoading = false,
    this.errorMessage,
    this.lastRequestHash,
  });

  AcademicSettingsState copyWith({
    List<AcademicSettingsModel>? academicSettings,
    AcademicSettingsModel? currentAcademicYear,
    Statistics? statistics,
    PaginationInfo? pagination,
    UpdateResult? updateResult,
    bool? isLoading,
    String? errorMessage,
    String? lastRequestHash,
  }) {
    return AcademicSettingsState(
      academicSettings: academicSettings ?? this.academicSettings,
      currentAcademicYear: currentAcademicYear ?? this.currentAcademicYear,
      statistics: statistics ?? this.statistics,
      pagination: pagination ?? this.pagination,
      updateResult: updateResult ?? this.updateResult,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      lastRequestHash: lastRequestHash ?? this.lastRequestHash,
    );
  }
}

class AcademicSettingsNotifier extends StateNotifier<AcademicSettingsState> {
  final _academicSettingsRepo = locator<AcademicSettingsRepository>();

  AcademicSettingsNotifier() : super(AcademicSettingsState());

  String _generateRequestHash({
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) {
    return '$page-$limit-$sortBy-$sortOrder';
  }

  // Setter for academic settings data
  void setAcademicSettingsData(
    List<AcademicSettingsModel> academicSettings,
    PaginationInfo? pagination,
  ) {
    state = state.copyWith(
      academicSettings: academicSettings,
      pagination: pagination,
      errorMessage: null,
      isLoading: false,
    );
  }

  // Setter for current academic year
  void setCurrentAcademicYear(
    AcademicSettingsModel? currentAcademicYear,
    Statistics? statistics,
  ) {
    state = state.copyWith(
      currentAcademicYear: currentAcademicYear,
      statistics: statistics,
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

  void clearAcademicSettingsCache() {
    state = AcademicSettingsState();
  }

  Future<void> getAllAcademicSettings({
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
    bool forceRefresh = false,
  }) async {
    final currentRequestHash = _generateRequestHash(
      page: page,
      limit: limit,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    if (!forceRefresh &&
        state.lastRequestHash == currentRequestHash &&
        state.academicSettings.isNotEmpty) {
      return; // Use cached data
    }

    setLoading(true);

    try {
      final response = await _academicSettingsRepo.getAllAcademicSettings(
        page: page,
        limit: limit,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final academicSettingsData = AcademicSettingsData.fromJson(
          response.data['data'],
        );
        setAcademicSettingsData(
          academicSettingsData.academicSettings,
          academicSettingsData.pagination,
        );
        state = state.copyWith(lastRequestHash: currentRequestHash);
      } else {
        setError(response.message ?? 'Failed to load academic settings');
        CustomToastNotification.show(
          response.message ?? 'Failed to load academic settings',
          type: ToastType.error,
        );
      }
    } catch (e) {
      setError('Failed to load academic settings: $e');
      CustomToastNotification.show(
        'Failed to load academic settings: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> getCurrentAcademicYear({bool forceRefresh = false}) async {
    if (!forceRefresh && state.currentAcademicYear != null) {
      return; // Use cached data
    }

    setLoading(true);

    try {
      final response = await _academicSettingsRepo.getCurrentAcademicYear();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final academicSettingsData = AcademicSettingsData.fromJson(
          response.data['data'],
        );

        setCurrentAcademicYear(
          academicSettingsData.academicSettingsSingle,
          academicSettingsData.statistics,
        );
      } else {
        setError(response.message ?? 'Failed to load current academic year');
        CustomToastNotification.show(
          response.message ?? 'Failed to load current academic year',
          type: ToastType.error,
        );
      }
    } catch (e) {
      setError('Failed to load current academic year: $e');
      CustomToastNotification.show(
        'Failed to load current academic year: $e',
        type: ToastType.error,
      );
    }
  }

  Future<bool> createAcademicSettings({
    required String academicYear,
    required String currentTerm,
    required DateTime startDate,
    required DateTime endDate,
    List<TermModel>? terms,
    String? description,
  }) async {
    EasyLoading.show(status: 'Creating academic year...');

    try {
      final response = await _academicSettingsRepo.createAcademicSettings(
        academicYear: academicYear,
        currentTerm: currentTerm,
        startDate: startDate,
        endDate: endDate,
        terms: terms,
        description: description,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        CustomToastNotification.show(
          response.message ?? 'Academic year created successfully',
          type: ToastType.success,
        );
        // Refresh the list
        await getAllAcademicSettings(forceRefresh: true);
        // Update global academic year service
        await GlobalAcademicYearService().forceRefresh();
        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to create academic year',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Failed to create academic year: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  Future<bool> updateAcademicSettings({
    required String id,
    String? academicYear,
    String? currentTerm,
    DateTime? startDate,
    DateTime? endDate,
    List<TermModel>? terms,
    String? description,
  }) async {
    EasyLoading.show(status: 'Updating academic year...');

    try {
      final response = await _academicSettingsRepo.updateAcademicSettings(
        id: id,
        academicYear: academicYear,
        currentTerm: currentTerm,
        startDate: startDate,
        endDate: endDate,
        terms: terms,
        description: description,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        CustomToastNotification.show(
          response.message ?? 'Academic year updated successfully',
          type: ToastType.success,
        );
        // Refresh the list
        await getAllAcademicSettings(forceRefresh: true);
        // Update global academic year service
        await GlobalAcademicYearService().forceRefresh();
        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to update academic year',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Failed to update academic year: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  Future<bool> deleteAcademicSettings(String id) async {
    EasyLoading.show(status: 'Deleting academic year...');

    try {
      final response = await _academicSettingsRepo.deleteAcademicSettings(
        id: id,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        CustomToastNotification.show(
          response.message ?? 'Academic year deleted successfully',
          type: ToastType.success,
        );
        // Refresh the list
        await getAllAcademicSettings(forceRefresh: true);
        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to delete academic year',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Failed to delete academic year: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  Future<bool> setActiveAcademicYear(String id) async {
    EasyLoading.show(status: 'Setting active academic year...');

    try {
      final response = await _academicSettingsRepo.setActiveAcademicYear(
        id: id,
      );

      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        print('Response data: ${response.data}');
        if (response.data?['data']?['updateResult'] != null) {
          final updateResult = UpdateResult.fromJson(
            response.data!['data']['updateResult'],
          );
          print('Update result: ${updateResult.modifiedCount} classes updated');
        }

        CustomToastNotification.show(
          response.message ?? 'Academic year activated successfully',
          type: ToastType.success,
        );

        // Refresh both current academic year and the list
        await Future.wait([
          getCurrentAcademicYear(forceRefresh: true),
          getAllAcademicSettings(forceRefresh: true),
        ]);

        // Update global academic year service
        await GlobalAcademicYearService().forceRefresh();

        // Store update result if available
        if (response.data?['data']?['updateResult'] != null) {
          final updateResult = UpdateResult.fromJson(
            response.data!['data']['updateResult'],
          );
          state = state.copyWith(updateResult: updateResult);
        }

        return true;
      } else {
        CustomToastNotification.show(
          response.message ?? 'Failed to activate academic year',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Failed to activate academic year: $e',
        type: ToastType.error,
      );
      return false;
    }
  }
}

final academicSettingsProvider =
    StateNotifierProvider<AcademicSettingsNotifier, AcademicSettingsState>((
      ref,
    ) {
      return AcademicSettingsNotifier();
    });
