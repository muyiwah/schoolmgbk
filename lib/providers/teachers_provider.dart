import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/class_model.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/repository/teacher_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class TeachersProvider extends ChangeNotifier {
  final _teacherRepo = locator<TeacherRepo>();
  TeacherListModel _teacherListData = TeacherListModel();
  TeacherListModel get teacherListData => _teacherListData;
  setTeacherList(data) {
    _teacherListData = data;
  }

  getAllTeachers(BuildContext context) async {
    EasyLoading.show(status: 'getting classes...');

    HTTPResponseModel res = await _teacherRepo.getAllTeachers({});
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      // print(res.data);
      TeacherListModel teacherData = TeacherListModel.fromJson(
        res.data['data'],
      );
      setTeacherList(teacherData);
      // CustomToastNotification.show(
      //   res.message ?? '',
      //   type: ToastType.success,
      // );
      return teacherData;
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.success,
      );
    }
  }

  // getAllClassesWithMetric(BuildContext context) async {
  //   EasyLoading.show(status: 'getting classes...');

  //   HTTPResponseModel res = await _classRepo.getAllClasses();
  //   EasyLoading.dismiss();

  //   if (HTTPResponseModel.isApiCallSuccess(res)) {
  //     // print(res.data);
  //     ClassMetricModel classData = ClassMetricModel.fromJson(res.data['data']);
  //     // CustomToastNotification.show(
  //     //   res.message ?? '',
  //     //   type: ToastType.success,
  //     // );
  //     return classData;
  //   } else {
  //     CustomToastNotification.show(
  //       res.message ?? 'unable to get class data',
  //       type: ToastType.success,
  //     );
  //   }
  // }
}
