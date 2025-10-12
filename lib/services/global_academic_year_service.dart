import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/academic_settings_model.dart';
import '../utils/response_model.dart';
import '../utils/locator.dart';
import '../utils/enums.dart';
import 'http_service.dart';

class GlobalAcademicYearService extends ChangeNotifier {
  static final GlobalAcademicYearService _instance =
      GlobalAcademicYearService._internal();
  factory GlobalAcademicYearService() => _instance;
  GlobalAcademicYearService._internal();

  AcademicSettingsModel? _currentAcademicYear;
  Statistics? _statistics;
  bool _isInitialized = false;

  // Getters
  AcademicSettingsModel? get currentAcademicYear => _currentAcademicYear;
  Statistics? get statistics => _statistics;
  bool get isInitialized => _isInitialized;

  String get currentAcademicYearString =>
      _currentAcademicYear?.academicYear ?? '2025/2026';
  String get currentTermString => _currentAcademicYear?.currentTerm ?? 'First';

  /// Initialize the service by fetching current academic year from backend
  Future<bool> initialize() async {
    try {
      print('🔄 GlobalAcademicYearService: Initializing...');
      final response = await _fetchCurrentAcademicYear();

      if (response != null) {
        print('📡 GlobalAcademicYearService: Response received');
        print(
          '📊 GlobalAcademicYearService: academicSettings data: ${response['academicSettings']}',
        );

        _currentAcademicYear = AcademicSettingsModel.fromJson(
          response['academicSettings'],
        );
        _statistics = Statistics.fromJson(response['statistics']);
        _isInitialized = true;

        print(
          '✅ GlobalAcademicYearService: Parsed academic year: ${_currentAcademicYear?.academicYear}',
        );
        print(
          '✅ GlobalAcademicYearService: Parsed term: ${_currentAcademicYear?.currentTerm}',
        );

        // Cache the data locally
        await _cacheAcademicYearData();

        // Notify listeners of the update
        notifyListeners();

        return true;
      } else {
        print('❌ GlobalAcademicYearService: No response received');
        return false;
      }
    } catch (e) {
      print('❌ GlobalAcademicYearService: Error during initialization: $e');
      return false;
    }
  }

  /// Fetch current academic year from backend
  Future<Map<String, dynamic>?> _fetchCurrentAcademicYear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        print('❌ GlobalAcademicYearService: No token found');
        return null;
      }

      print(
        '🔗 GlobalAcademicYearService: Making API call to /classes/academic-settings/current',
      );
      final httpService = locator<HttpService>();
      final response = await httpService.runApi(
        type: ApiRequestType.get,
        url: '/classes/academic-settings/current',
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print(
        '📡 GlobalAcademicYearService: API Response Code: ${response.code}',
      );
      print(
        '📡 GlobalAcademicYearService: API Response Data: ${response.data}',
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final data = response.data['data'];
        print('✅ GlobalAcademicYearService: API call successful, data: $data');
        return data;
      } else {
        print(
          '❌ GlobalAcademicYearService: API call failed: ${response.message}',
        );
        return null;
      }
    } catch (e) {
      print('❌ GlobalAcademicYearService: Exception during API call: $e');
      return null;
    }
  }

  /// Cache academic year data locally
  Future<void> _cacheAcademicYearData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      if (_currentAcademicYear != null) {
        final academicYearJson = jsonEncode(_currentAcademicYear!.toJson());
        await prefs.setString('cached_academic_year', academicYearJson);
      }

      if (_statistics != null) {
        // Convert statistics to JSON manually since it doesn't have toJson method
        final statisticsMap = {
          'totalClasses': _statistics!.totalClasses,
          'totalStudents': _statistics!.totalStudents,
          'currentAcademicYear': _statistics!.currentAcademicYear,
          'currentTerm': _statistics!.currentTerm,
        };
        final statisticsJson = jsonEncode(statisticsMap);
        await prefs.setString('cached_academic_statistics', statisticsJson);
      }

      await prefs.setBool('academic_year_initialized', true);
    } catch (e) {
      // Handle caching error silently
    }
  }

  /// Load cached academic year data
  Future<void> loadCachedData() async {
    try {
      print('🔄 GlobalAcademicYearService: Loading cached data...');
      final prefs = await SharedPreferences.getInstance();

      final academicYearJson = prefs.getString('cached_academic_year');
      final statisticsJson = prefs.getString('cached_academic_statistics');
      final isInitialized = prefs.getBool('academic_year_initialized') ?? false;

      print(
        '📊 GlobalAcademicYearService: Cached academic year JSON: $academicYearJson',
      );
      print(
        '📊 GlobalAcademicYearService: Cached statistics JSON: $statisticsJson',
      );
      print(
        '📊 GlobalAcademicYearService: Cached initialized flag: $isInitialized',
      );

      if (academicYearJson != null) {
        final academicYearMap =
            jsonDecode(academicYearJson) as Map<String, dynamic>;
        _currentAcademicYear = AcademicSettingsModel.fromJson(academicYearMap);
        print(
          '✅ GlobalAcademicYearService: Loaded cached academic year: ${_currentAcademicYear?.academicYear}',
        );
      } else {
        print('❌ GlobalAcademicYearService: No cached academic year found');
      }

      if (statisticsJson != null) {
        final statisticsMap =
            jsonDecode(statisticsJson) as Map<String, dynamic>;
        _statistics = Statistics.fromJson(statisticsMap);
        print('✅ GlobalAcademicYearService: Loaded cached statistics');
      } else {
        print('❌ GlobalAcademicYearService: No cached statistics found');
      }

      _isInitialized = isInitialized;
      print(
        '📊 GlobalAcademicYearService: Final state - initialized: $_isInitialized, academic year: ${_currentAcademicYear?.academicYear}',
      );
    } catch (e) {
      print('❌ GlobalAcademicYearService: Error loading cached data: $e');
    }
  }

  /// Refresh current academic year from backend
  Future<bool> refresh() async {
    try {
      final response = await _fetchCurrentAcademicYear();

      if (response != null) {
        _currentAcademicYear = AcademicSettingsModel.fromJson(
          response['academicSettings'],
        );
        _statistics = Statistics.fromJson(response['statistics']);

        // Update cache
        await _cacheAcademicYearData();

        // Notify listeners of the update
        notifyListeners();

        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Clear all data (useful for logout)
  Future<void> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('cached_academic_year');
      await prefs.remove('cached_academic_statistics');
      await prefs.remove('academic_year_initialized');

      _currentAcademicYear = null;
      _statistics = null;
      _isInitialized = false;
    } catch (e) {
      // Handle clearing error silently
    }
  }

  /// Check if academic year is available
  bool get isAcademicYearAvailable => _currentAcademicYear != null;

  /// Get academic year with fallback
  String getAcademicYearWithFallback([String fallback = '2025/2026']) {
    return _currentAcademicYear?.academicYear ?? fallback;
  }

  /// Get current term with fallback
  String getCurrentTermWithFallback([String fallback = 'First']) {
    return _currentAcademicYear?.currentTerm ?? fallback;
  }

  /// Force refresh the academic year data from backend
  /// This should be called after any academic year operations (create, update, setActive)
  Future<bool> forceRefresh() async {
    print(
      '🔄 GlobalAcademicYearService: Force refreshing academic year data...',
    );
    return await initialize();
  }

  /// Update academic year data directly (for immediate UI updates)
  void updateAcademicYearData(
    AcademicSettingsModel academicYear,
    Statistics statistics,
  ) {
    _currentAcademicYear = academicYear;
    _statistics = statistics;
    _isInitialized = true;

    // Cache the updated data
    _cacheAcademicYearData();

    // Notify all listeners
    notifyListeners();

    print('✅ GlobalAcademicYearService: Academic year data updated directly');
    print(
      '📊 GlobalAcademicYearService: New academic year: ${academicYear.academicYear}',
    );
    print(
      '📊 GlobalAcademicYearService: New term: ${academicYear.currentTerm}',
    );
  }
}
