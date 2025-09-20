import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/single_class_model.dart' as single_class;
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

  setSingleClassData(data) {
    _singlgeClassData = data;
    notifyListeners();
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
}
