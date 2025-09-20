import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:schmgtsystem/models/subject_model.dart';
import 'package:schmgtsystem/repository/subject_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class SubjectProvider extends ChangeNotifier {
  final _subjectRepo = locator<SubjectRepo>();

  // Subject list data
  List<Subject> _subjects = [];
  List<Subject> get subjects => _subjects;

  // Loading and error states
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  // Set subjects list
  void setSubjects(List<Subject> subjects) {
    _subjects = subjects;
    notifyListeners();
  }

  // Set loading state
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Set error message
  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // ✅ Get all subjects
  Future<void> getAllSubjects(
    BuildContext context, {
    Map<String, dynamic>? queryParams,
  }) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _subjectRepo.getAllSubjects(
        queryParams ?? {},
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        if (res.data != null && res.data['data'] != null) {
          List<dynamic> subjectsData = res.data['data'] as List<dynamic>;
          List<Subject> subjectsList =
              subjectsData
                  .map((subjectJson) => Subject.fromJson(subjectJson))
                  .toList();

          setSubjects(subjectsList);

          CustomToastNotification.show(
            res.message ?? 'Subjects loaded successfully',
            type: ToastType.success,
          );
        } else {
          setSubjects([]);
          CustomToastNotification.show(
            'No subjects found',
            type: ToastType.success,
          );
        }
      } else {
        setError(res.message ?? 'Failed to fetch subjects');
        CustomToastNotification.show(
          res.message ?? 'Failed to fetch subjects',
          type: ToastType.error,
        );
      }
    } catch (e) {
      setError('Error fetching subjects: $e');
      CustomToastNotification.show(
        'Error fetching subjects: $e',
        type: ToastType.error,
      );
    } finally {
      setLoading(false);
    }
  }

  // ✅ Get single subject
  Future<Subject?> getSingleSubject(
    BuildContext context,
    String subjectId,
  ) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _subjectRepo.getSingleSubject(subjectId);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        if (res.data != null && res.data['data'] != null) {
          Subject subject = Subject.fromJson(res.data['data']);

          CustomToastNotification.show(
            res.message ?? 'Subject loaded successfully',
            type: ToastType.success,
          );

          return subject;
        } else {
          setError('Subject not found');
          CustomToastNotification.show(
            'Subject not found',
            type: ToastType.error,
          );
          return null;
        }
      } else {
        setError(res.message ?? 'Failed to fetch subject');
        CustomToastNotification.show(
          res.message ?? 'Failed to fetch subject',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      setError('Error fetching subject: $e');
      CustomToastNotification.show(
        'Error fetching subject: $e',
        type: ToastType.error,
      );
      return null;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Create subject
  Future<bool> createSubject(
    BuildContext context,
    Map<String, dynamic> subjectData,
  ) async {
    try {
      print('SubjectProvider.createSubject called with data: $subjectData');
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _subjectRepo.createSubject(subjectData);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Subject created successfully',
          type: ToastType.success,
        );

        // Refresh the subjects list
        await getAllSubjects(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to create subject');
        CustomToastNotification.show(
          res.message ?? 'Failed to create subject',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error creating subject: $e');
      CustomToastNotification.show(
        'Error creating subject: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Update subject
  Future<bool> updateSubject(
    BuildContext context,
    String subjectId,
    Map<String, dynamic> subjectData,
  ) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _subjectRepo.updateSubject(
        subjectId,
        subjectData,
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Subject updated successfully',
          type: ToastType.success,
        );

        // Refresh the subjects list
        await getAllSubjects(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to update subject');
        CustomToastNotification.show(
          res.message ?? 'Failed to update subject',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error updating subject: $e');
      CustomToastNotification.show(
        'Error updating subject: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // ✅ Delete subject
  Future<bool> deleteSubject(BuildContext context, String subjectId) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _subjectRepo.deleteSubject(subjectId);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Subject deleted successfully',
          type: ToastType.success,
        );

        // Remove from local list
        _subjects.removeWhere((subject) => subject.id == subjectId);
        notifyListeners();

        return true;
      } else {
        setError(res.message ?? 'Failed to delete subject');
        CustomToastNotification.show(
          res.message ?? 'Failed to delete subject',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error deleting subject: $e');
      CustomToastNotification.show(
        'Error deleting subject: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Helper method to find subject by ID
  Subject? getSubjectById(String subjectId) {
    try {
      return _subjects.firstWhere((subject) => subject.id == subjectId);
    } catch (e) {
      return null;
    }
  }

  // Helper method to get subjects by category
  List<Subject> getSubjectsByCategory(String category) {
    return _subjects.where((subject) => subject.category == category).toList();
  }

  // Helper method to get active subjects
  List<Subject> getActiveSubjects() {
    return _subjects.where((subject) => subject.isActive).toList();
  }

  // Clear all data
  void clearData() {
    _subjects.clear();
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}
