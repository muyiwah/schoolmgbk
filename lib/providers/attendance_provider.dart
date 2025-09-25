import 'package:flutter/foundation.dart';
import 'package:schmgtsystem/repository/attendance_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceRepo _attendanceRepo = AttendanceRepo();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  AttendanceByDate? _attendanceByDate;
  AttendanceSummaryData? _attendanceSummary;
  DateTime? _lastUpdated;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AttendanceByDate? get attendanceByDate => _attendanceByDate;
  AttendanceSummaryData? get attendanceSummary => _attendanceSummary;
  DateTime? get lastUpdated => _lastUpdated;

  // Helper getters
  bool get hasAttendanceData => _attendanceByDate != null;
  bool get hasSummaryData => _attendanceSummary != null;
  bool get isAttendanceSubmitted => _attendanceByDate?.isSubmitted ?? false;
  bool get isAttendanceLocked => _attendanceByDate?.isLocked ?? false;

  // Mark attendance for a class
  Future<bool> markAttendance({
    required String classId,
    required MarkAttendanceRequest request,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceRepo.markAttendance(
        classId: classId,
        request: request,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _clearError();
        if (kDebugMode) {
          print('Attendance marked successfully');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to mark attendance');
        return false;
      }
    } catch (e) {
      _setError('Error marking attendance: ${e.toString()}');
      if (kDebugMode) {
        print('Error in markAttendance: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get attendance by date
  Future<bool> getAttendanceByDate({
    required String classId,
    required String date,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceRepo.getAttendanceByDate(
        classId: classId,
        date: date,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Parse the response data properly - handle actual backend format
        final responseData = response.data as Map<String, dynamic>;

        // The backend returns: { "success": true, "data": { "attendance": {...} } }
        if (responseData['success'] == true && responseData['data'] != null) {
          final data = responseData['data'] as Map<String, dynamic>;
          final attendanceData = data['attendance'] as Map<String, dynamic>?;

          if (attendanceData != null) {
            _attendanceByDate = AttendanceByDate.fromJson(attendanceData);
            _lastUpdated = DateTime.now();
            _clearError();

            if (kDebugMode) {
              print('Attendance by date loaded successfully');
              print('Date: ${_attendanceByDate?.date}');
              print('Records count: ${_attendanceByDate?.records.length}');
            }
            return true;
          } else {
            _setError('No attendance data found in response');
            return false;
          }
        } else {
          _setError('Invalid response format from server');
          return false;
        }
      } else {
        _setError(response.message ?? 'Failed to get attendance by date');
        return false;
      }
    } catch (e) {
      _setError('Error getting attendance by date: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getAttendanceByDate: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get attendance summary
  Future<bool> getAttendanceSummary({required String classId}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceRepo.getClassAttendanceSummary(
        classId: classId,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        // Parse the response data properly
        final responseData = response.data as Map<String, dynamic>;
        _attendanceSummary =
            AttendanceSummaryResponse.fromJson(responseData).data;
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Attendance summary loaded successfully');
          print('Class: ${_attendanceSummary?.classInfo.name}');
          print('Students count: ${_attendanceSummary?.summary.length}');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to get attendance summary');
        return false;
      }
    } catch (e) {
      _setError('Error getting attendance summary: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getAttendanceSummary: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Update attendance record
  Future<bool> updateAttendanceRecord({
    required String classId,
    required String date,
    required String studentId,
    required String status,
    required String remarks,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceRepo.updateAttendanceRecord(
        classId: classId,
        date: date,
        studentId: studentId,
        status: status,
        remarks: remarks,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _clearError();
        if (kDebugMode) {
          print('Attendance record updated successfully');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to update attendance record');
        return false;
      }
    } catch (e) {
      _setError('Error updating attendance record: ${e.toString()}');
      if (kDebugMode) {
        print('Error in updateAttendanceRecord: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Submit attendance
  Future<bool> submitAttendance({
    required String classId,
    required String date,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _attendanceRepo.submitAttendance(
        classId: classId,
        date: date,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _clearError();
        if (kDebugMode) {
          print('Attendance submitted successfully');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to submit attendance');
        return false;
      }
    } catch (e) {
      _setError('Error submitting attendance: ${e.toString()}');
      if (kDebugMode) {
        print('Error in submitAttendance: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Refresh attendance data
  Future<void> refreshAttendanceData({
    required String classId,
    String? date,
  }) async {
    if (date != null) {
      await getAttendanceByDate(classId: classId, date: date);
    }
    await getAttendanceSummary(classId: classId);
  }

  // Clear all data
  void clearData() {
    _attendanceByDate = null;
    _attendanceSummary = null;
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

  // Utility methods for accessing specific data
  List<AttendanceRecordDetail> get attendanceRecords =>
      _attendanceByDate?.records ?? [];
  List<StudentAttendanceSummary> get studentSummaries =>
      _attendanceSummary?.summary ?? [];
  ClassInfo? get classInfo => _attendanceSummary?.classInfo;
  int get totalAttendanceDays => _attendanceSummary?.totalAttendanceDays ?? 0;

  // Get attendance statistics
  Map<String, int> get attendanceStats {
    if (_attendanceByDate == null) return {};

    int present = 0;
    int absent = 0;
    int late = 0;

    for (var record in _attendanceByDate!.records) {
      switch (record.status.toLowerCase()) {
        case 'present':
          present++;
          break;
        case 'absent':
          absent++;
          break;
        case 'late':
          late++;
          break;
      }
    }

    return {
      'present': present,
      'absent': absent,
      'late': late,
      'total': _attendanceByDate!.records.length,
    };
  }

  // Get overall attendance rate
  double get overallAttendanceRate {
    final stats = attendanceStats;
    if (stats['total'] == 0) return 0.0;
    return ((stats['present']! + stats['late']!) / stats['total']!) * 100;
  }
}
