import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/all_parents.dart' as all_parents;
import 'package:schmgtsystem/models/single_parent_fulldetails_model.dart'
    as single_parent;
import 'package:schmgtsystem/repository/parent_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class ParentState {
  final List<all_parents.Parent> parents;
  final all_parents.Pagination? pagination;
  final bool isLoading;
  final String? errorMessage;
  final single_parent.SingleParentFullDetailsModel singleParent;

  ParentState({
    this.parents = const [],
    this.pagination,
    this.isLoading = false,
    this.errorMessage,
    single_parent.SingleParentFullDetailsModel? singleParent,
  }) : singleParent =
           singleParent ?? single_parent.SingleParentFullDetailsModel();

  ParentState copyWith({
    List<all_parents.Parent>? parents,
    all_parents.Pagination? pagination,
    bool? isLoading,
    String? errorMessage,
    single_parent.SingleParentFullDetailsModel? singleParent,
  }) {
    return ParentState(
      parents: parents ?? this.parents,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      singleParent: singleParent ?? this.singleParent,
    );
  }
}

class ParentProvider extends StateNotifier<ParentState> {
  final _parentRepo = locator<ParentRepo>();

  ParentProvider() : super(ParentState());

  // Setter for parents data
  void setParentsData(
    List<all_parents.Parent> parents,
    all_parents.Pagination? pagination,
  ) {
    state = state.copyWith(
      parents: parents,
      pagination: pagination,
      errorMessage: null,
      isLoading: false,
    );
  }

  void setSingleParentData(single_parent.SingleParentFullDetailsModel parent) {
    state = state.copyWith(
      singleParent: parent,
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

  getAllParents(
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
      final response = await _parentRepo.getAllParents();

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        try {
          final parentResponse = all_parents.AllParentsModel.fromJson(
            response.data,
          );
          setParentsData(
            parentResponse.data?.parents ?? [],
            parentResponse.data?.pagination,
          );
        } catch (parseError) {
          setError('Error parsing parent data: $parseError');
        }
      } else {
        setError(response.message ?? 'Failed to load parents');
      }
    } catch (e) {
      setError('Error loading parents: $e');
    }
  }

  getSingleParent(
    BuildContext context,
    String parentId, {
    int page = 1,
    int limit = 10,
    String? search,
    String sortBy = "personalInfo.firstName",
    String sortOrder = "asc",
  }) async {
    setLoading(true);
    setError(null);

    try {
      // Debug: Print the parentId being used for API call
      print('ParentProvider: Making API call for parentId: $parentId');
      print('ParentProvider: ParentId type: ${parentId.runtimeType}');

      final response = await _parentRepo.getSingleParentDetails(parentId);

      // Debug: Print the API response
      print('ParentProvider: API response status: ${response.code}');
      print('ParentProvider: API response message: ${response.message}');
      print(
        'ParentProvider: API response data type: ${response.data.runtimeType}',
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        try {
          print('ParentProvider: Starting JSON parsing...');
          print(
            'ParentProvider: Response data type: ${response.data.runtimeType}',
          );
          print(
            'ParentProvider: Response data keys: ${response.data.keys.toList()}',
          );

          // Log the structure of the data to help identify issues
          if (response.data is Map<String, dynamic>) {
            final dataMap = response.data as Map<String, dynamic>;
            print('ParentProvider: Data structure:');
            dataMap.forEach((key, value) {
              print('  $key: ${value.runtimeType}');
              if (value is Map<String, dynamic>) {
                print('    Sub-keys: ${value.keys.toList()}');
              }
            });
          }

          final parentResponse = single_parent
              .SingleParentFullDetailsModel.fromJson(response.data);
          print('ParentProvider: JSON parsing successful');
          setSingleParentData(parentResponse);
          print('ParentProvider: Data set successfully');
        } catch (parseError, stackTrace) {
          print('ParentProvider: JSON parsing error: $parseError');
          print('ParentProvider: Stack trace: $stackTrace');
          setError('Error parsing parent details: $parseError');
        }
      } else {
        print('ParentProvider: API call failed - ${response.message}');
        setError(response.message ?? 'Failed to load parent details');
      }
    } catch (e) {
      print('ParentProvider: Exception occurred: $e');
      setError('Error loading parent details: $e');
    } finally {
      setLoading(false);
    }
  }

  // createStudent(BuildContext context, body) async {
  //   EasyLoading.show(status: 'creating student...');

  //   HTTPResponseModel res = await _parentRepo.createStudent(body);
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     CustomToastNotification.show(
  //       res.message ?? 'Student created successfully',
  //       type: ToastType.success,
  //     );
  //     // Refresh the students list after successful creation
  //     await getAllStudents(context);
  //     return res.data;
  //   } else {
  //     CustomToastNotification.show(
  //       res.message ?? 'Failed to create student',
  //       type: ToastType.error,
  //     );
  //     return null;
  //   }
  // }

  // deleteParent(BuildContext context, String studentId) async {
  //   EasyLoading.show(status: 'deleting student...');

  //   HTTPResponseModel res = await _parentRepo.deleteStudent(studentId);
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     CustomToastNotification.show(
  //       res.message ?? 'Student deleted successfully',
  //       type: ToastType.success,
  //     );
  //     // Refresh the students list after successful deletion
  //     await getAllStudents(context);
  //   } else {
  //     CustomToastNotification.show(
  //       res.message ?? 'Failed to delete student',
  //       type: ToastType.error,
  //     );
  //   }
  // }

  // Clear single parent data to ensure fresh data on navigation
  void clearSingleParentData() {
    state = state.copyWith(
      singleParent: single_parent.SingleParentFullDetailsModel(),
      errorMessage: null,
    );
  }
}
