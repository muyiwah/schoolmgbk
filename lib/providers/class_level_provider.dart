import 'package:flutter/material.dart';
import 'package:schmgtsystem/repository/class_level_repo.dart';
import 'package:schmgtsystem/models/class_level_model.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/utils/locator.dart';

class ClassLevelProvider extends ChangeNotifier {
  final ClassLevelRepo _classLevelRepo = locator<ClassLevelRepo>();

  // State variables
  List<ClassLevelModel> _classLevels = [];
  ClassLevelsResponseModel? _classLevelsResponse;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  List<ClassLevelModel> get classLevels => _classLevels;
  ClassLevelsResponseModel? get classLevelsResponse => _classLevelsResponse;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Setters
  void setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void setClassLevels(List<ClassLevelModel> classLevels) {
    _classLevels = classLevels;
    notifyListeners();
  }

  void setClassLevelsResponse(ClassLevelsResponseModel response) {
    _classLevelsResponse = response;
    notifyListeners();
  }

  // Get all class levels
  Future<List<ClassLevelModel>?> getAllClassLevels(
    BuildContext context, {
    String? category,
    bool? isActive,
  }) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _classLevelRepo.getAllClassLevels(
        category: category,
        isActive: isActive,
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        // Debug: Print response structure
        print('ClassLevel API Response: ${res.data}');

        // Backend response format: { "success": true, "count": 5, "data": [...] }
        if (res.data.containsKey('data') && res.data['data'] is List) {
          List<ClassLevelModel> levels =
              (res.data['data'] as List)
                  .map((e) => ClassLevelModel.fromJson(e))
                  .toList();
          setClassLevels(levels);

          // Set response data with statistics
          setClassLevelsResponse(ClassLevelsResponseModel.fromJson(res.data));
          print('Parsed ${levels.length} class levels successfully');
          return levels;
        } else {
          // Fallback: Handle case where data is directly a list
          List<ClassLevelModel> levels =
              (res.data as List)
                  .map((e) => ClassLevelModel.fromJson(e))
                  .toList();
          setClassLevels(levels);
          print('Parsed ${levels.length} class levels from direct list');
          return levels;
        }
      } else {
        setError(res.message ?? 'Failed to fetch class levels');
        CustomToastNotification.show(
          res.message ?? 'Failed to fetch class levels',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      setError('Error fetching class levels: $e');
      CustomToastNotification.show(
        'Error fetching class levels: $e',
        type: ToastType.error,
      );
      return null;
    } finally {
      setLoading(false);
    }
  }

  // Create class level
  Future<bool> createClassLevel(
    BuildContext context,
    Map<String, dynamic> data,
  ) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _classLevelRepo.createClassLevel(data);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class level created successfully',
          type: ToastType.success,
        );

        // Refresh the list
        await getAllClassLevels(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to create class level');
        CustomToastNotification.show(
          res.message ?? 'Failed to create class level',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error creating class level: $e');
      CustomToastNotification.show(
        'Error creating class level: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Update class level
  Future<bool> updateClassLevel(
    BuildContext context,
    String id,
    Map<String, dynamic> data,
  ) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _classLevelRepo.updateClassLevel(id, data);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class level updated successfully',
          type: ToastType.success,
        );

        // Refresh the list
        await getAllClassLevels(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to update class level');
        CustomToastNotification.show(
          res.message ?? 'Failed to update class level',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error updating class level: $e');
      CustomToastNotification.show(
        'Error updating class level: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Delete class level
  Future<bool> deleteClassLevel(BuildContext context, String id) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _classLevelRepo.deleteClassLevel(id);

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class level deleted successfully',
          type: ToastType.success,
        );

        // Remove from local list
        _classLevels.removeWhere((level) => level.id == id);
        notifyListeners();

        return true;
      } else {
        setError(res.message ?? 'Failed to delete class level');
        CustomToastNotification.show(
          res.message ?? 'Failed to delete class level',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error deleting class level: $e');
      CustomToastNotification.show(
        'Error deleting class level: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Reorder class levels
  Future<bool> reorderClassLevels(
    BuildContext context,
    ReorderClassLevelsModel reorderData,
  ) async {
    try {
      setLoading(true);
      setError(null);

      HTTPResponseModel res = await _classLevelRepo.reorderClassLevels(
        reorderData,
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class levels reordered successfully',
          type: ToastType.success,
        );

        // Refresh the list
        await getAllClassLevels(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to reorder class levels');
        CustomToastNotification.show(
          res.message ?? 'Failed to reorder class levels',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error reordering class levels: $e');
      CustomToastNotification.show(
        'Error reordering class levels: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Bulk create class levels
  Future<bool> bulkCreateClassLevels(
    BuildContext context,
    BulkCreateClassLevelsModel bulkData,
  ) async {
    try {
      setLoading(true);
      setError(null);

      // Validate data before sending
      if (!bulkData.isValid()) {
        List<String> errors = bulkData.getValidationErrors();
        String errorMessage = errors.join('\n');
        setError(errorMessage);
        CustomToastNotification.show(errorMessage, type: ToastType.error);
        return false;
      }

      // Debug: Print the data being sent
      print('Bulk create data: ${bulkData.toJson()}');
      print('Number of levels: ${bulkData.levels.length}');

      HTTPResponseModel res = await _classLevelRepo.bulkCreateClassLevels(
        bulkData,
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class levels created successfully',
          type: ToastType.success,
        );

        // Refresh the list
        await getAllClassLevels(context);
        return true;
      } else {
        setError(res.message ?? 'Failed to create class levels');
        CustomToastNotification.show(
          res.message ?? 'Failed to create class levels',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      setError('Error creating class levels: $e');
      CustomToastNotification.show(
        'Error creating class levels: $e',
        type: ToastType.error,
      );
      return false;
    } finally {
      setLoading(false);
    }
  }

  // Get class levels by category
  List<ClassLevelModel> getClassLevelsByCategory(String category) {
    return _classLevels.where((level) => level.category == category).toList();
  }

  // Get active class levels
  List<ClassLevelModel> getActiveClassLevels() {
    return _classLevels.where((level) => level.isActive).toList();
  }

  // Get available categories
  List<String> getAvailableCategories() {
    return _classLevels.map((level) => level.category).toSet().toList();
  }
}
