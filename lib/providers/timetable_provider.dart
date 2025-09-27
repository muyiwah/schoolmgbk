import 'package:flutter/foundation.dart';
import 'package:schmgtsystem/repository/time_table_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/timetable_model.dart';

class TimetableProvider extends ChangeNotifier {
  final TimeTableRepo _timetableRepo = TimeTableRepo();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<TimetableModel> _timetables = [];
  TimetableModel? _currentTimetable;
  TimetableDetailsResponse? _timetableDetails;
  PaginationInfo? _pagination;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<TimetableModel> get timetables => _timetables;
  TimetableModel? get currentTimetable => _currentTimetable;
  TimetableDetailsResponse? get timetableDetails => _timetableDetails;
  PaginationInfo? get pagination => _pagination;

  // Helper getters
  bool get hasTimetables => _timetables.isNotEmpty;
  bool get hasCurrentTimetable => _currentTimetable != null;
  bool get hasTimetableDetails => _timetableDetails != null;

  // Create timetable
  Future<bool> createTimetable(CreateTimetableRequest request) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.createTimetable(request);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final timetableData =
            responseData['data']['timetable'] as Map<String, dynamic>;
        final newTimetable = TimetableModel.fromJson(timetableData);

        _timetables.insert(0, newTimetable);
        _currentTimetable = newTimetable;

        if (kDebugMode) {
          print('Timetable created successfully: ${newTimetable.id}');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to create timetable');
        return false;
      }
    } catch (e) {
      _setError('Error creating timetable: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get all timetables with filtering
  Future<bool> getTimetables({
    int page = 1,
    int limit = 10,
    String? classId,
    String? academicYear,
    String? term,
    String? type,
    bool? isActive,
    String sortBy = "createdAt",
    String sortOrder = "desc",
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.getTimetables(
        page: page,
        limit: limit,
        classId: classId,
        academicYear: academicYear,
        term: term,
        type: type,
        isActive: isActive,
        sortBy: sortBy,
        sortOrder: sortOrder,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        final timetablesList =
            (data['timetables'] as List<dynamic>)
                .map((timetable) => TimetableModel.fromJson(timetable))
                .toList();

        final paginationData = data['pagination'] as Map<String, dynamic>;
        final pagination = PaginationInfo.fromJson(paginationData);

        if (refresh || page == 1) {
          _timetables = timetablesList;
        } else {
          _timetables.addAll(timetablesList);
        }

        _pagination = pagination;

        if (kDebugMode) {
          print('Loaded ${timetablesList.length} timetables (page $page)');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to get timetables');
        return false;
      }
    } catch (e) {
      _setError('Error getting timetables: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get timetable details
  Future<bool> getTimetableDetails(String timetableId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.getTimetableDetails(timetableId);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        _timetableDetails = TimetableDetailsResponse.fromJson(data);
        _currentTimetable = _timetableDetails!.timetable;

        if (kDebugMode) {
          print('Loaded timetable details: ${_currentTimetable!.id}');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to get timetable details');
        return false;
      }
    } catch (e) {
      _setError('Error getting timetable details: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update timetable
  Future<bool> updateTimetable(
    String timetableId,
    UpdateTimetableRequest request,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.updateTimetable(
        timetableId,
        request,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final timetableData =
            responseData['data']['timetable'] as Map<String, dynamic>;
        final updatedTimetable = TimetableModel.fromJson(timetableData);

        // Update in the list
        final index = _timetables.indexWhere((t) => t.id == timetableId);
        if (index != -1) {
          _timetables[index] = updatedTimetable;
        }

        // Update current timetable if it's the same
        if (_currentTimetable?.id == timetableId) {
          _currentTimetable = updatedTimetable;
        }

        if (kDebugMode) {
          print('Timetable updated successfully: ${updatedTimetable.id}');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to update timetable');
        return false;
      }
    } catch (e) {
      _setError('Error updating timetable: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Delete timetable
  Future<bool> deleteTimetable(String timetableId) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.deleteTimetable(timetableId);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Remove from the list
        _timetables.removeWhere((t) => t.id == timetableId);

        // Clear current timetable if it's the same
        if (_currentTimetable?.id == timetableId) {
          _currentTimetable = null;
          _timetableDetails = null;
        }

        if (kDebugMode) {
          print('Timetable deleted successfully: $timetableId');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to delete timetable');
        return false;
      }
    } catch (e) {
      _setError('Error deleting timetable: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get class timetable
  Future<bool> getClassTimetable({
    required String classId,
    String? academicYear,
    String? term,
    String type = "regular",
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _timetableRepo.getClassTimetable(
        classId: classId,
        academicYear: academicYear,
        term: term,
        type: type,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final data = responseData['data'] as Map<String, dynamic>;

        // Parse the formatted schedule back to TimetableModel
        final formattedSchedule = data['schedule'] as List<dynamic>;
        final schedule =
            formattedSchedule.map((day) {
              final periods =
                  (day['periods'] as List<dynamic>).map((period) {
                    return Period(
                      startTime: period['time'].toString().split(' - ')[0],
                      endTime: period['time'].toString().split(' - ')[1],
                      subject: period['subject'],
                      teacher:
                          period['teacher'] != 'TBA' ? period['teacher'] : null,
                      room: period['room'] != 'TBA' ? period['room'] : null,
                      notes:
                          period['notes'].isNotEmpty ? period['notes'] : null,
                    );
                  }).toList();

              return DaySchedule(day: day['day'], periods: periods);
            }).toList();

        _currentTimetable = TimetableModel(
          id: 'temp_${classId}_${type}',
          classId: classId,
          academicYear: data['academicYear'],
          term: data['term'],
          type: data['type'],
          schedule: schedule,
          isActive: true,
          createdBy: '',
          createdAt: DateTime.tryParse(data['lastUpdated']) ?? DateTime.now(),
          updatedAt: DateTime.tryParse(data['lastUpdated']) ?? DateTime.now(),
        );

        if (kDebugMode) {
          print('Loaded class timetable for class: $classId');
        }

        notifyListeners();
        return true;
      } else {
        _setError(response.message ?? 'Failed to get class timetable');
        return false;
      }
    } catch (e) {
      _setError('Error getting class timetable: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Set current timetable
  void setCurrentTimetable(TimetableModel timetable) {
    _currentTimetable = timetable;
    notifyListeners();
  }

  // Clear current timetable
  void clearCurrentTimetable() {
    _currentTimetable = null;
    _timetableDetails = null;
    notifyListeners();
  }

  // Clear all data
  void clearData() {
    _timetables.clear();
    _currentTimetable = null;
    _timetableDetails = null;
    _pagination = null;
    _clearError();
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}
