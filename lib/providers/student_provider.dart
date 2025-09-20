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

  StudentState({
    this.students = const [],
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
    StudentFullModel? studentFullModel,
  }) : studentFullModel = studentFullModel ?? StudentFullModel();

  StudentState copyWith({
    List<StudentModel>? students,
    PaginationInfo? pagination,
    bool? isLoading,
    String? errorMessage,
    StudentFullModel? studentFullModel,
  }) {
    return StudentState(
      students: students ?? this.students,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      studentFullModel: studentFullModel ?? this.studentFullModel,
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
  }) async {
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
        setStudentsData(
          studentsResponse.data.students,
          studentsResponse.data.pagination,
        );
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
      // Refresh the students list after successful creation
      await getAllStudents(context);
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
      // Refresh the students list after successful deletion
      await getAllStudents(context);
    } else {
      CustomToastNotification.show(
        res.message ?? 'Failed to delete student',
        type: ToastType.error,
      );
    }
  }

  assignStudentToClass(BuildContext context, body) async {
    EasyLoading.show(status: 'creating classes...');

    HTTPResponseModel res = await _studentsRepo.assignStudentToClass('', body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(res.message ?? '', type: ToastType.success);
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.success,
      );
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
}

// Riverpod provider
final studentProvider = StateNotifierProvider<StudentNotifier, StudentState>((
  ref,
) {
  return StudentNotifier();
});
