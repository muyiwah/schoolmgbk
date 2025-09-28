import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/single_class_model.dart' as single_class;
import 'package:schmgtsystem/models/students_with_fees_model.dart';
import 'package:schmgtsystem/models/class_statistics_model.dart';
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
  ClassStatisticsModel _classStatisticsData = ClassStatisticsModel();
  ClassStatisticsModel get classStatisticsData => _classStatisticsData;
  setClassStatisticsData(data) {
    _classStatisticsData = data;
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

  getAllClassesWithMetric(BuildContext context) async {
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
        final statisticsData = ClassStatisticsModel.fromJson(res.data);
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

        // Refresh class data to reflect changes
        await getAllClassesWithMetric(context);
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

        // Refresh the class data
        await getAllClassesWithMetric(context);

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
}
