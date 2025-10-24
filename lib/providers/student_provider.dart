import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/student_full_model.dart';
import 'package:schmgtsystem/models/student_model.dart';
import 'package:schmgtsystem/repository/students_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

// Student state class
class StudentState {
  final List<StudentModel> students;
  final PaginationInfo? pagination;
  final bool isLoading;
  final String? errorMessage;
  final StudentFullModel studentFullModel;
  final String? lastRequestHash; // Cache key for request parameters

  StudentState({
    this.students = const [],
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
    StudentFullModel? studentFullModel,
    this.lastRequestHash,
  }) : studentFullModel = studentFullModel ?? StudentFullModel();

  StudentState copyWith({
    List<StudentModel>? students,
    PaginationInfo? pagination,
    bool? isLoading,
    String? errorMessage,
    StudentFullModel? studentFullModel,
    String? lastRequestHash,
  }) {
    return StudentState(
      students: students ?? this.students,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      studentFullModel: studentFullModel ?? this.studentFullModel,
      lastRequestHash: lastRequestHash ?? this.lastRequestHash,
    );
  }
}

// Student notifier class
class StudentNotifier extends StateNotifier<StudentState> {
  final _studentsRepo = locator<StudentsRepo>();

  StudentNotifier() : super(StudentState());

  // Setter for students data
  void setStudentsData(
    List<StudentModel> students,
    PaginationInfo? pagination,
  ) {
    state = state.copyWith(
      students: students,
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

  // Method to clear cached student data
  void clearStudentDataCache() {
    state = state.copyWith(
      students: const [],
      pagination: null,
      lastRequestHash: null,
      errorMessage: null,
    );
  }

  // Generate hash for request parameters to check cache validity
  String _generateRequestHash({
    int page = 1,
    int limit = 10,
    String? classId,
    String? gender,
    String? feeStatus,
    String? status,
    String? academicYear,
    String? search,
    String sortBy = "personalInfo.firstName",
    String sortOrder = "asc",
  }) {
    return '$page-$limit-$classId-$gender-$feeStatus-$status-$academicYear-$search-$sortBy-$sortOrder';
  }

  getAllStudents(
    BuildContext context, {
    int page = 1,
    int limit = 10,
    String? classId,
    String? gender,
    String? feeStatus,
    String? status,
    String? academicYear,
    String? search,
    String sortBy = "personalInfo.firstName",
    String sortOrder = "asc",
    bool forceRefresh = false,
    bool loadMore = false,
  }) async {
    // Generate hash for current request parameters
    final currentRequestHash = _generateRequestHash(
      page: page,
      limit: limit,
      classId: classId,
      gender: gender,
      feeStatus: feeStatus,
      status: status,
      academicYear: academicYear,
      search: search,
      sortBy: sortBy,
      sortOrder: sortOrder,
    );

    // Check if we already have cached data for the same request (but not for load more)
    if (!forceRefresh &&
        !loadMore &&
        state.lastRequestHash == currentRequestHash &&
        state.students.isNotEmpty) {
      return; // Use cached data
    }

    setLoading(true);
    setError(null);

    try {
      final response = await _studentsRepo.getAllStudents(
        page: page,
        limit: limit,
        classId: classId,
        gender: gender,
        feeStatus: feeStatus,
        status: status,
        academicYear: academicYear,
        search: search,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final studentsResponse = StudentsResponse.fromJson(response.data);

        if (loadMore) {
          // Append new students to existing list
          final updatedStudents = [
            ...state.students,
            ...studentsResponse.data.students,
          ];
          state = state.copyWith(
            students: updatedStudents,
            pagination: studentsResponse.data.pagination,
            lastRequestHash: currentRequestHash,
            errorMessage: null,
            isLoading: false,
          );
        } else {
          // Replace students list (initial load or refresh)
          state = state.copyWith(
            students: studentsResponse.data.students,
            pagination: studentsResponse.data.pagination,
            lastRequestHash: currentRequestHash,
            errorMessage: null,
            isLoading: false,
          );
        }
      } else {
        setError(response.message ?? 'Failed to load students');
      }
    } catch (e) {
      setError('Error loading students: $e');
    }
  }

  createStudent(BuildContext context, body) async {
    EasyLoading.show(status: 'creating student...');

    HTTPResponseModel res = await _studentsRepo.createStudent(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(
        res.message ?? 'Student created successfully',
        type: ToastType.success,
      );
      // Clear cache and refresh the students list after successful creation
      clearStudentDataCache();
      await getAllStudents(context, forceRefresh: true);
      return res.data;
    } else {
      CustomToastNotification.show(
        res.message ?? 'Failed to create student',
        type: ToastType.error,
      );
      return null;
    }
  }

  deleteStudent(BuildContext context, String studentId) async {
    EasyLoading.show(status: 'deleting student...');

    HTTPResponseModel res = await _studentsRepo.deleteStudent(studentId);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(
        res.message ?? 'Student deleted successfully',
        type: ToastType.success,
      );
      // Clear cache and refresh the students list after successful deletion
      clearStudentDataCache();
      await getAllStudents(context, forceRefresh: true);
    } else {
      CustomToastNotification.show(
        res.message ?? 'Failed to delete student',
        type: ToastType.error,
      );
    }
  }

  assignStudentToClass(
    BuildContext context,
    String studentId,
    Map<String, dynamic> body,
  ) async {
    EasyLoading.show(status: 'Assigning student to class...');

    HTTPResponseModel res = await _studentsRepo.assignStudentToClass(
      studentId,
      body,
    );
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(
        res.message ?? 'Student assigned to class successfully',
        type: ToastType.success,
      );
      // Clear cache and refresh the students list after successful assignment
      clearStudentDataCache();
      await getAllStudents(context, forceRefresh: true);
      return true;
    } else {
      CustomToastNotification.show(
        res.message ?? 'Failed to assign student to class',
        type: ToastType.error,
      );
      return false;
    }
  }

  getStudentById(BuildContext context, String studentId) async {
    EasyLoading.show(status: 'Getting student...');
    setLoading(true);
    setError(null);

    try {
      HTTPResponseModel res = await _studentsRepo.getStudentById(studentId);
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final studentFullModel = StudentFullModel.fromJson(res.data);
        state = state.copyWith(
          studentFullModel: studentFullModel,
          isLoading: false,
        );
        CustomToastNotification.show(
          res.message ?? '',
          type: ToastType.success,
        );
      } else {
        EasyLoading.dismiss();
        setError(res.message ?? 'Unable to get student data');
        CustomToastNotification.show(
          res.message ?? 'Unable to get student data',
          type: ToastType.error,
        );
      }
    } catch (e) {
      EasyLoading.dismiss();
      setError('Error loading student: $e');
      CustomToastNotification.show(
        'Error loading student: $e',
        type: ToastType.error,
      );
    }
  }

  Future<bool> updateStudent(
    BuildContext context,
    String studentId,
    Map<String, dynamic> updates,
  ) async {
    EasyLoading.show(status: 'Updating student...');

    try {
      HTTPResponseModel res = await _studentsRepo.updateStudent(
        studentId,
        updates,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Student updated successfully',
          type: ToastType.success,
        );
        // Clear cache and refresh student data after successful update
        clearStudentDataCache();
        await getStudentById(context, studentId);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to update student',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error updating student: $e',
        type: ToastType.error,
      );
      return false;
    }
  }
}

// Riverpod provider
final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
  ref,
) {
  return StudentNotifier();
});
