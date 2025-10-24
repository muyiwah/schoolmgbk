import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/single_class_model.dart' as single_class;
import 'package:schmgtsystem/models/students_with_fees_model.dart';
import 'package:schmgtsystem/models/class_statistics_model.dart' as old_model;
import 'package:schmgtsystem/models/all_terms_class_statistics_model.dart'
    as new_model;
import 'package:schmgtsystem/models/imagekit_model.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class ClassProvider extends ChangeNotifier {
  final _classRepo = locator<ClassRepo>();

  getAllClasses(BuildContext context) async {
    EasyLoading.show(status: 'getting classes...');

    await _classRepo.getAllClasses();
    EasyLoading.dismiss();
  }

  single_class.SingleClass _singlgeClassData = single_class.SingleClass();
  single_class.SingleClass get singlgeClassData => _singlgeClassData;

  ClassMetricModel _classData = ClassMetricModel();
  ClassMetricModel get classData => _classData;
  setClassData(data) {
    _classData = data;
    notifyListeners();
  }

  // Method to clear cached class data
  void clearClassDataCache() {
    _classData = ClassMetricModel();
    notifyListeners();
  }

  // Students with fees data
  StudentsWithFeesModel _studentsWithFeesData = StudentsWithFeesModel(
    students: [],
    pagination: PaginationInfo(
      currentPage: 1,
      totalPages: 1,
      totalStudents: 0,
      limit: 50,
    ),
    metrics: FeeMetrics(
      totalStudents: 0,
      maleStudents: 0,
      femaleStudents: 0,
      paidStudents: 0,
      partialStudents: 0,
      unpaidStudents: 0,
      totalFeesCollected: 0,
      totalFeesOutstanding: 0,
      totalClasses: 0,
      averagePerClass: 0,
      totalFeesExpected: 0,
    ),
  );
  StudentsWithFeesModel get studentsWithFeesData => _studentsWithFeesData;

  // Class statistics data
  old_model.ClassStatisticsModel _classStatisticsData =
      old_model.ClassStatisticsModel();
  old_model.ClassStatisticsModel get classStatisticsData =>
      _classStatisticsData;
  setClassStatisticsData(data) {
    _classStatisticsData = data;
    notifyListeners();
  }

  new_model.AllTermsClassStatisticsModel _allTermsClassStatisticsData =
      new_model.AllTermsClassStatisticsModel(
        classes: [],
        groupedByTerm: [],
        overallStats: new_model.OverallStats(),
        availableTerms: [],
        availableAcademicYears: [],
        filters: new_model.Filters(),
      );
  new_model.AllTermsClassStatisticsModel get allTermsClassStatisticsData =>
      _allTermsClassStatisticsData;
  setAllTermsClassStatisticsData(data) {
    _allTermsClassStatisticsData = data;
    notifyListeners();
  }

  bool _isLoadingStudentsWithFees = false;
  bool get isLoadingStudentsWithFees => _isLoadingStudentsWithFees;

  String? _studentsWithFeesError;
  String? get studentsWithFeesError => _studentsWithFeesError;

  setStudentsWithFeesData(data) {
    _studentsWithFeesData = data;
    notifyListeners();
  }

  setLoadingStudentsWithFees(bool loading) {
    _isLoadingStudentsWithFees = loading;
    notifyListeners();
  }

  setStudentsWithFeesError(String? error) {
    _studentsWithFeesError = error;
    notifyListeners();
  }

  setSingleClassData(data) {
    _singlgeClassData = data;
    notifyListeners();
  }

  // Get students with fees
  Future<StudentsWithFeesModel?> getStudentsWithFees(
    BuildContext context, {
    String? search,
    String? searchBy,
    String? classId,
    String? feeStatus,
    String? term,
    String? academicYear,
    String? sortBy,
    String? sortOrder,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      setLoadingStudentsWithFees(true);
      setStudentsWithFeesError(null);

      HTTPResponseModel res = await _classRepo.getStudentsWithFees(
        search: search,
        searchBy: searchBy,
        classId: classId,
        feeStatus: feeStatus,
        term: term,
        academicYear: academicYear,
        sortBy: sortBy,
        sortOrder: sortOrder,
        page: page,
        limit: limit,
      );

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        // Handle both possible response structures
        Map<String, dynamic> responseData;
        if (res.data.containsKey('data')) {
          responseData = res.data['data'];
        } else {
          responseData = res.data;
        }

        StudentsWithFeesModel studentsWithFees = StudentsWithFeesModel.fromJson(
          responseData,
        );
        setStudentsWithFeesData(studentsWithFees);
        return studentsWithFees;
      } else {
        setStudentsWithFeesError(
          res.message ?? 'Failed to fetch students with fees',
        );
        CustomToastNotification.show(
          res.message ?? 'Failed to fetch students with fees',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      setStudentsWithFeesError('Error fetching students with fees: $e');
      CustomToastNotification.show(
        'Error fetching students with fees: $e',
        type: ToastType.error,
      );
      return null;
    } finally {
      setLoadingStudentsWithFees(false);
    }
  }

  getAllClassesWithMetric(
    BuildContext context, {
    bool forceRefresh = false,
  }) async {
    // Check if we already have cached data and not forcing refresh
    if (!forceRefresh &&
        _classData.classes != null &&
        _classData.classes!.isNotEmpty) {
      return _classData;
    }

    EasyLoading.show(status: 'getting classes...');

    HTTPResponseModel res = await _classRepo.getAllClasses();
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      // print(res.data);
      _classData = ClassMetricModel.fromJson(res.data['data']);
      setClassData(_classData);
      // CustomToastNotification.show(
      //   res.message ?? '',
      //   type: ToastType.success,
      // );
      return _classData;
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.error,
      );
      return ClassMetricModel();
    }
  }

  getSingleClass(BuildContext context, String classId) async {
    EasyLoading.show(status: 'getting class...');

    HTTPResponseModel res = await _classRepo.getSingleClass(classId);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      print('API Response: ${res.data}');
      print('Response data type: ${res.data.runtimeType}');
      print('Response data keys: ${res.data.keys.toList()}');
      if (res.data['data'] != null) {
        print('Response data[\'data\']: ${res.data['data']}');
        print('Response data[\'data\'] type: ${res.data['data'].runtimeType}');
        if (res.data['data'] is Map) {
          print(
            'Response data[\'data\'] keys: ${(res.data['data'] as Map).keys.toList()}',
          );
        }
      }

      // Check if res.data is null or empty
      if (res.data == null) {
        print('API Response data is null');
        _singlgeClassData = single_class.SingleClass();
        setSingleClassData(_singlgeClassData);
        return _singlgeClassData;
      }

      // Try different parsing approaches based on response structure
      try {
        // First try: res.data is the direct response
        _singlgeClassData = single_class.SingleClass.fromJson(res.data);
        print('Successfully parsed as SingleClass.fromJson(res.data)');
        print('Parsed SingleClass: ${_singlgeClassData.toJson()}');
      } catch (e) {
        print('Error parsing as SingleClass.fromJson(res.data): $e');
        try {
          // Second try: res.data['data'] contains the response
          _singlgeClassData = single_class.SingleClass.fromJson(
            res.data['data'],
          );
          print(
            'Successfully parsed as SingleClass.fromJson(res.data[\'data\'])',
          );
          print('Parsed SingleClass: ${_singlgeClassData.toJson()}');

          // Check if the parsed data is null and try alternative approach
          if (_singlgeClassData.data == null) {
            print('Parsed data is null, trying alternative approach...');
            // Try creating SingleClass with the raw data
            _singlgeClassData = single_class.SingleClass(
              success: true,
              data: single_class.Data.fromJson(res.data['data']),
            );
            print(
              'Alternative parsing successful: ${_singlgeClassData.toJson()}',
            );
          }
        } catch (e2) {
          print(
            'Error parsing as SingleClass.fromJson(res.data[\'data\']): $e2',
          );
          // Third try: Create a mock response structure
          try {
            _singlgeClassData = single_class.SingleClass(
              success: true,
              data: single_class.Data.fromJson(res.data),
            );
            print(
              'Successfully parsed as SingleClass with Data.fromJson(res.data)',
            );
            print('Parsed SingleClass: ${_singlgeClassData.toJson()}');
          } catch (e3) {
            print(
              'Error parsing as SingleClass with Data.fromJson(res.data): $e3',
            );
            // Fourth try: Create a minimal response structure
            _singlgeClassData = single_class.SingleClass(
              success: true,
              data: single_class.Data(
                dataClass: single_class.Class(
                  id: classId,
                  name: 'Test Class',
                  level: 'Primary 1',
                  section: 'A',
                ),
                students: [],
                metrics: single_class.Metrics(),
                academicInfo: single_class.AcademicInfo(),
                recentCommunications: [],
              ),
            );
            print('Created minimal SingleClass response');
          }
        }
      }

      setSingleClassData(_singlgeClassData);
      // CustomToastNotification.show(
      //   res.message ?? '',
      //   type: ToastType.success,
      // );
      return _singlgeClassData;
    } else {
      print('API call failed. Response: ${res.data}');
      print('Error message: ${res.message}');
      print('Response code: ${res.code}');
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.error,
      );
      return single_class.SingleClass();
    }
  }

  createClass(BuildContext context, body) async {
    EasyLoading.show(status: 'creating classes...');

    HTTPResponseModel res = await _classRepo.createClass(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(res.message ?? '', type: ToastType.success);
      // Clear cache and refresh class data
      clearClassDataCache();
      await getAllClassesWithMetric(context, forceRefresh: true);
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.success,
      );
    }
  }

  assignClassTeacherToClass(
    BuildContext context,
    body,
    String teacherId,
  ) async {
    EasyLoading.show(status: 'adding class teacher...');

    HTTPResponseModel res = await _classRepo.assignClassTeacherToClass(
      teacherId,
      body,
    );
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(res.message ?? '', type: ToastType.success);
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to add class teacher',
        type: ToastType.success,
      );
    }
  }

  removeTeacherFromClass(
    BuildContext context,
    String classId,
    String teacherId, {
    String? role,
  }) async {
    EasyLoading.show(status: 'Removing teacher...');

    HTTPResponseModel res = await _classRepo.removeTeacherFromClass(
      classId,
      teacherId,
      role ?? '',
    );
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      CustomToastNotification.show(res.message ?? '', type: ToastType.success);
    } else {
      CustomToastNotification.show(
        res.message ?? 'Unable to remove teacher',
        type: ToastType.error,
      );
    }
  }

  // ✅ Bulk assign subjects to classes
  Future<bool> bulkAssignSubjects(
    BuildContext context,
    Map<String, dynamic> body,
  ) async {
    try {
      EasyLoading.show(status: 'Updating subject assignments...');

      HTTPResponseModel res = await _classRepo.bulkAssignSubjects(body);
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Subject assignments updated successfully',
          type: ToastType.success,
        );

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to update subject assignments',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error updating subject assignments: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Add fee structure to class
  Future<bool> addFeeStructureToClass(
    BuildContext context,
    String classId,
    Map<String, dynamic> feeStructureData,
  ) async {
    try {
      EasyLoading.show(status: 'Adding fee structure...');

      HTTPResponseModel res = await _classRepo.addFeeStructureToClass(
        classId,
        feeStructureData,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Fee structure added successfully',
          type: ToastType.success,
        );

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to add fee structure',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error adding fee structure: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Update fee structure
  Future<bool> updateFeeStructure(
    BuildContext context,
    String feeStructureId,
    Map<String, dynamic> feeStructureData,
  ) async {
    try {
      EasyLoading.show(status: 'Updating fee structure...');

      HTTPResponseModel res = await _classRepo.updateFeeStructure(
        feeStructureId,
        feeStructureData,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Fee structure updated successfully',
          type: ToastType.success,
        );

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to update fee structure',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error updating fee structure: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Delete fee structure
  Future<bool> deleteFeeStructure(
    BuildContext context,
    String feeStructureId,
  ) async {
    try {
      EasyLoading.show(status: 'Deleting fee structure...');

      HTTPResponseModel res = await _classRepo.deleteFeeStructure(
        feeStructureId,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Fee structure deleted successfully',
          type: ToastType.success,
        );

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to delete fee structure',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error deleting fee structure: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Set active fee structure for class
  Future<bool> setActiveFeeStructure(
    BuildContext context,
    String classId,
    Map<String, dynamic> feeStructureData,
  ) async {
    try {
      EasyLoading.show(status: 'Setting active fee structure...');

      HTTPResponseModel res = await _classRepo.setActiveFeeStructure(
        classId,
        feeStructureData,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Active fee structure set successfully',
          type: ToastType.success,
        );

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to set active fee structure',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error setting active fee structure: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Get fee structures for a class
  Future<Map<String, dynamic>?> getClassFeeStructures(
    BuildContext context,
    String classId,
  ) async {
    try {
      EasyLoading.show(status: 'Loading fee structures...');

      HTTPResponseModel res = await _classRepo.getClassFeeStructure(classId);
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        return res.data;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to load fee structures',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error loading fee structures: $e',
        type: ToastType.error,
      );
      return null;
    }
  }

  // ✅ Get class statistics
  Future<bool> getClassStatistics(
    BuildContext context, {
    String? term,
    String? academicYear,
  }) async {
    try {
      EasyLoading.show(status: 'Loading statistics...');

      HTTPResponseModel res = await _classRepo.getClassStatistics(
        term: term,
        academicYear: academicYear,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final statisticsData = old_model.ClassStatisticsModel.fromJson(
          res.data,
        );
        setClassStatisticsData(statisticsData);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to load statistics',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error loading statistics: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  Future<bool> getAllTermsClassStatistics(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Loading all terms statistics...');

      HTTPResponseModel res = await _classRepo.getAllTermsClassStatistics(
        includeAllClasses: true,
      );
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        final allTermsData = new_model.AllTermsClassStatisticsModel.fromJson(
          res.data,
        );
        setAllTermsClassStatisticsData(allTermsData);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to load all terms statistics',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error loading all terms statistics: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // ✅ Delete class level
  Future<bool> deleteClassLevel(BuildContext context, String classId) async {
    try {
      EasyLoading.show(status: 'Deleting class...');

      HTTPResponseModel res = await _classRepo.deleteClassLevel(classId);
      EasyLoading.dismiss();

      if (HTTPResponseModel.isApiCallSuccess(res)) {
        CustomToastNotification.show(
          res.message ?? 'Class deleted successfully',
          type: ToastType.success,
        );

        // Clear cache and refresh class data to reflect changes
        clearClassDataCache();
        await getAllClassesWithMetric(context, forceRefresh: true);
        return true;
      } else {
        CustomToastNotification.show(
          res.message ?? 'Failed to delete class',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error deleting class: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Update class
  Future<bool> updateClass(
    BuildContext context,
    String classId,
    Map<String, dynamic> updateData,
  ) async {
    try {
      EasyLoading.show(status: 'Updating class...');

      final response = await _classRepo.updateClass(classId, updateData);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          'Class updated successfully',
          type: ToastType.success,
        );

        // Clear cache and refresh the class data
        clearClassDataCache();
        await getAllClassesWithMetric(context, forceRefresh: true);

        return true;
      } else {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          response.message ?? 'Failed to update class',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error updating class: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Add curriculum to class
  Future<bool> addCurriculum(
    BuildContext context,
    String classId,
    String curriculumUrl,
  ) async {
    try {
      EasyLoading.show(status: 'Adding curriculum...');

      final response = await _classRepo.addCurriculum(classId, {
        'curriculumUrl': curriculumUrl,
      });

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          'Curriculum added successfully',
          type: ToastType.success,
        );

        // Refresh the class data
        await getAllClassesWithMetric(context);

        return true;
      } else {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          response.message ?? 'Failed to add curriculum',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error adding curriculum: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Delete curriculum from class
  Future<bool> deleteCurriculum(BuildContext context, String classId) async {
    try {
      EasyLoading.show(status: 'Deleting curriculum...');

      final response = await _classRepo.deleteCurriculum(classId);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          'Curriculum deleted successfully',
          type: ToastType.success,
        );

        // Refresh the class data
        await getAllClassesWithMetric(context);

        return true;
      } else {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          response.message ?? 'Failed to delete curriculum',
          type: ToastType.error,
        );
        return false;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error deleting curriculum: $e',
        type: ToastType.error,
      );
      return false;
    }
  }

  // Get ImageKit authentication parameters
  Future<ImageKitAuthData?> getImageKitAuth(BuildContext context) async {
    try {
      EasyLoading.show(status: 'Getting authentication...');

      final response = await _classRepo.getImageKitAuth();

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        EasyLoading.dismiss();
        final authData = ImageKitAuthModel.fromJson(response.data!);

        if (authData.success && authData.data != null) {
          CustomToastNotification.show(
            'Authentication successful',
            type: ToastType.success,
          );
          return authData.data!;
        } else {
          CustomToastNotification.show(
            authData.message ?? 'Invalid authentication response',
            type: ToastType.error,
          );
          return null;
        }
      } else {
        EasyLoading.dismiss();
        CustomToastNotification.show(
          response.message ?? 'Failed to get authentication',
          type: ToastType.error,
        );
        return null;
      }
    } catch (e) {
      EasyLoading.dismiss();
      CustomToastNotification.show(
        'Error getting authentication: $e',
        type: ToastType.error,
      );
      return null;
    }
  }
}
