import 'package:flutter/material.dart';
import 'package:schmgtsystem/models/admission_model.dart';
import 'package:schmgtsystem/repository/admission_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class AdmissionProvider extends ChangeNotifier {
  List<AdmissionModel> _admissions = [];
  AdmissionStatistics? _statistics;
  bool _isLoading = false;
  String? _error;
  PaginationInfo? _pagination;

  // Filters
  String? _statusFilter;
  String? _academicYearFilter;
  String? _classFilter;
  int _currentPage = 1;
  int _limit = 10;
  String _sortBy = 'submittedAt';
  String _sortOrder = 'desc';

  // Getters
  List<AdmissionModel> get admissions => _admissions;
  AdmissionStatistics? get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  PaginationInfo? get pagination => _pagination;
  String? get statusFilter => _statusFilter;
  String? get academicYearFilter => _academicYearFilter;
  String? get classFilter => _classFilter;
  int get currentPage => _currentPage;
  int get limit => _limit;
  String get sortBy => _sortBy;
  String get sortOrder => _sortOrder;
  // Submit admission intent
  Future<bool> submitAdmissionIntent(
    BuildContext context,
    AdmissionSubmissionModel submission,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AdmissionRepo.submitAdmissionIntent(submission);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to submit admission: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get all admission intents
  Future<void> getAllAdmissionIntents(BuildContext context) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AdmissionRepo.getAllAdmissionIntents(
        status: _statusFilter,
        academicYear: _academicYearFilter,
        desiredClass: _classFilter,
        page: _currentPage,
        limit: _limit,
        sortBy: _sortBy,
        sortOrder: _sortOrder,
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        try {
          // Try the expected structure first
          final admissionResponse = AdmissionListResponse.fromJson(
            response.data,
          );
          _admissions = admissionResponse.admissions;
          _pagination = admissionResponse.pagination;
        } catch (e) {
          print('Error parsing admission response: $e');
          print('Trying alternative parsing...');

          // Try alternative parsing if the structure is different
          try {
            if (response.data['admissions'] != null) {
              _admissions =
                  (response.data['admissions'] as List)
                      .map((item) => AdmissionModel.fromJson(item))
                      .toList();
              _pagination = PaginationInfo.fromJson(
                response.data['pagination'] ?? {},
              );
            } else {
              throw Exception('No admissions data found');
            }
          } catch (e2) {
            print('Alternative parsing also failed: $e2');
            _setError('Failed to parse admission data: $e');
            _admissions = [];
            _pagination = null;
          }
        }
      } else {
        _setError(response.message ?? 'Unknown error');
        _admissions = [];
        _pagination = null;
      }
    } catch (e) {
      _setError('Failed to fetch admissions: $e');
      _admissions = [];
      _pagination = null;
    } finally {
      _setLoading(false);
    }
  }

  // Get single admission intent
  Future<AdmissionModel?> getAdmissionIntent(
    BuildContext context,
    String id,
  ) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AdmissionRepo.getAdmissionIntent(id);

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        final admission = AdmissionModel.fromJson(response.data['admission']);
        _setLoading(false);
        return admission;
      } else {
        _setError(response.message ?? 'Unknown error');
        _setLoading(false);
        return null;
      }
    } catch (e) {
      _setError('Failed to fetch admission: $e');
      _setLoading(false);
      return null;
    }
  }

  // Update admission status
  Future<bool> updateAdmissionStatus(
    String userId,
    BuildContext context,
    String id,
    String status, {
    String? reviewNotes,
    String? rejectionReason,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await AdmissionRepo.updateAdmissionStatus(
        userId.toString(),
        id,
        status,
        reviewNotes: reviewNotes,
        rejectionReason: rejectionReason,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Refresh the admissions list
        await getAllAdmissionIntents(context);
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to update admission status: $e');
      _setLoading(false);
      return false;
    }
  }

  // Admit student
  Future<bool> admitStudent(
    String userId,
    BuildContext context,
    String id, {
    Map<String, dynamic>? additionalStudentData,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AdmissionRepo.admitStudent(
        userId.toString(),
        id,
        additionalStudentData: additionalStudentData,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Refresh the admissions list
        await getAllAdmissionIntents(context);
        _setLoading(false);
        return true;
      } else {
        _setError(response.message ?? 'Unknown error');
        _setLoading(false);
        return false;
      }
    } catch (e) {
      _setError('Failed to admit student: $e');
      _setLoading(false);
      return false;
    }
  }

  // Get admission statistics
  Future<void> getAdmissionStatistics(
    BuildContext context, {
    String? academicYear,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await AdmissionRepo.getAdmissionStatistics(
        academicYear: academicYear,
      );

      if (HTTPResponseModel.isApiCallSuccess(response) &&
          response.data != null) {
        _statistics = AdmissionStatistics.fromJson(response.data);
      } else {
        _setError(response.message ?? 'Unknown error');
        _statistics = null;
      }
    } catch (e) {
      _setError('Failed to fetch admission statistics: $e');
      _statistics = null;
    } finally {
      _setLoading(false);
    }
  }

  // Filter methods
  void setStatusFilter(String? status) {
    _statusFilter = status;
    _currentPage = 1; // Reset to first page when filtering
    notifyListeners();
  }

  void setAcademicYearFilter(String? academicYear) {
    _academicYearFilter = academicYear;
    _currentPage = 1;
    notifyListeners();
  }

  void setClassFilter(String? classId) {
    _classFilter = classId;
    _currentPage = 1;
    notifyListeners();
  }

  void setSorting(String sortBy, String sortOrder) {
    _sortBy = sortBy;
    _sortOrder = sortOrder;
    _currentPage = 1;
    notifyListeners();
  }

  void setPage(int page) {
    _currentPage = page;
    notifyListeners();
  }

  void setLimit(int limit) {
    _limit = limit;
    _currentPage = 1;
    notifyListeners();
  }

  void clearFilters() {
    _statusFilter = null;
    _academicYearFilter = null;
    _classFilter = null;
    _currentPage = 1;
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  // Get admissions by status
  List<AdmissionModel> getAdmissionsByStatus(String status) {
    return _admissions
        .where((admission) => admission.status == status)
        .toList();
  }

  // Get admission count by status
  int getAdmissionCountByStatus(String status) {
    return _admissions.where((admission) => admission.status == status).length;
  }

  // Get total admissions count
  int get totalAdmissions => _admissions.length;

  // Get pending admissions count
  int get pendingAdmissions => getAdmissionCountByStatus('pending');

  // Get approved admissions count
  int get approvedAdmissions => getAdmissionCountByStatus('approved');

  // Get rejected admissions count
  int get rejectedAdmissions => getAdmissionCountByStatus('rejected');

  // Get admitted students count
  int get admittedStudents => getAdmissionCountByStatus('admitted');
}
