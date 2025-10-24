import 'package:flutter/foundation.dart';
import 'package:schmgtsystem/repository/metrics_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/comprehensive_metrics_model.dart';

class MetricsProvider extends ChangeNotifier {
  final MetricsRepo _metricsRepo = MetricsRepo();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  ComprehensiveMetricsModel? _comprehensiveMetrics;
  DateTime? _lastUpdated;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  ComprehensiveMetricsModel? get comprehensiveMetrics => _comprehensiveMetrics;
  DateTime? get lastUpdated => _lastUpdated;

  // Helper getters for easy access to specific data
  int get totalStudents =>
      _comprehensiveMetrics?.data.overview.totalStudents ?? 0;
  int get totalStaff => _comprehensiveMetrics?.data.overview.totalStaff ?? 0;
  int get totalClasses =>
      _comprehensiveMetrics?.data.overview.totalClasses ?? 0;
  int get totalParents =>
      _comprehensiveMetrics?.data.overview.totalParents ?? 0;

  int get totalOutstandingFees =>
      _comprehensiveMetrics?.data.finances.outstanding.total ?? 0;
  int get recentPaymentsAmount =>
      _comprehensiveMetrics?.data.finances.recentPayments.amount ?? 0;
  int get recentPaymentsCount =>
      _comprehensiveMetrics?.data.finances.recentPayments.transactions ?? 0;

  double get enrollmentRate =>
      double.tryParse(
        _comprehensiveMetrics?.data.academics.classes.enrollment.rate ?? '0',
      ) ??
      0.0;
  double get capacityUtilization =>
      double.tryParse(
        _comprehensiveMetrics?.data.academics.classes.enrollment.utilization ??
            '0',
      ) ??
      0.0;

  List<FeeStatus> get feeStatusList =>
      _comprehensiveMetrics?.data.finances.feeStatus ?? [];
  List<OutstandingByClass> get outstandingByClass =>
      _comprehensiveMetrics?.data.finances.outstanding.byClass ?? [];
  List<EnrollmentByClass> get enrollmentByClass =>
      _comprehensiveMetrics?.data.academics.classes.enrollment.byClass ?? [];
  List<StaffByDepartment> get staffByDepartment =>
      _comprehensiveMetrics?.data.staff.byDepartment ?? [];
  List<GeographicDistribution> get geographicDistribution =>
      _comprehensiveMetrics?.data.students.geographicDistribution ?? [];

  // Get comprehensive metrics
  Future<void> getComprehensiveMetrics({
    String? academicYear,
    String? term,
    Map<String, dynamic>? filters,
    bool forceRefresh = false,
  }) async {
    // Don't fetch if already loading and not forcing refresh
    if (_isLoading && !forceRefresh) return;

    _setLoading(true);
    _clearError();

    try {
      final response = await _metricsRepo.getComprehensiveMetrics(
        academicYear: academicYear,
        term: term,
        filters: filters,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _comprehensiveMetrics = ComprehensiveMetricsModel.fromJson(
          response.data,
        );
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Comprehensive metrics loaded successfully');
          print(
            'Total Students: ${_comprehensiveMetrics?.data.overview.totalStudents}',
          );
          print(
            'Total Staff: ${_comprehensiveMetrics?.data.overview.totalStaff}',
          );
          print(
            'Total Classes: ${_comprehensiveMetrics?.data.overview.totalClasses}',
          );
        }
      } else {
        _setError(response.message ?? 'Failed to load comprehensive metrics');
      }
    } catch (e) {
      _setError('Error loading comprehensive metrics: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getComprehensiveMetrics: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Get metrics by date range
  Future<void> getMetricsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? academicYear,
    String? term,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _metricsRepo.getMetricsByDateRange(
        startDate: startDate,
        endDate: endDate,
        academicYear: academicYear,
        term: term,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _comprehensiveMetrics = ComprehensiveMetricsModel.fromJson(
          response.data,
        );
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Metrics by date range loaded successfully');
        }
      } else {
        _setError(response.message ?? 'Failed to load metrics by date range');
      }
    } catch (e) {
      _setError('Error loading metrics by date range: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getMetricsByDateRange: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Get real-time metrics
  Future<void> getRealTimeMetrics() async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _metricsRepo.getRealTimeMetrics();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _comprehensiveMetrics = ComprehensiveMetricsModel.fromJson(
          response.data,
        );
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Real-time metrics loaded successfully');
        }
      } else {
        _setError(response.message ?? 'Failed to load real-time metrics');
      }
    } catch (e) {
      _setError('Error loading real-time metrics: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getRealTimeMetrics: $e');
      }
    } finally {
      _setLoading(false);
    }
  }

  // Refresh metrics
  Future<void> refreshMetrics({
    String? academicYear,
    String? term,
    Map<String, dynamic>? filters,
  }) async {
    await getComprehensiveMetrics(
      academicYear: academicYear,
      term: term,
      filters: filters,
      forceRefresh: true,
    );
  }

  // Clear all data
  void clearData() {
    _comprehensiveMetrics = null;
    _lastUpdated = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
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

  // Utility methods for accessing specific metrics
  StudentsData? getStudentMetrics() {
    return _comprehensiveMetrics?.data.students;
  }

  FinancesData? getFinancialMetrics() {
    return _comprehensiveMetrics?.data.finances;
  }

  AcademicsData? getAcademicMetrics() {
    return _comprehensiveMetrics?.data.academics;
  }

  StaffData? getStaffMetrics() {
    return _comprehensiveMetrics?.data.staff;
  }

  OverviewData? getOverviewMetrics() {
    return _comprehensiveMetrics?.data.overview;
  }
}
