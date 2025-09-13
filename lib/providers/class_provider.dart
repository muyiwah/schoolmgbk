import 'package:flutter/widgets.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/class_model.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class ClassProvider extends ChangeNotifier {
  final _classRepo = locator<ClassRepo>();

  getAllClasses(BuildContext context) async {
    EasyLoading.show(status: 'getting classes...');

    HTTPResponseModel res = await _classRepo.getAllClasses();
    EasyLoading.dismiss();

    // if (HTTPResponseModel.isApiCallSuccess(res)) {
    //   // print(res.data);
    //   ClassModel classData = ClassModel.fromJson(res.data['data']);
    //   print(classData.classes?[0].classId);
    //   // CustomToastNotification.show(
    //   //   res.message ?? '',
    //   //   type: ToastType.success,
    //   // );
    //   return classData;
    // } else {
    //   CustomToastNotification.show(
    //     res.message ?? 'unable to get class data',
    //     type: ToastType.success,
    //   );
    // }

  }
  getAllClassesWithMetric(BuildContext context) async {
    EasyLoading.show(status: 'getting classes...');

    HTTPResponseModel res = await _classRepo.getAllClasses();
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      // print(res.data);
      ClassMetricModel classData = ClassMetricModel.fromJson(res.data['data']);
      // CustomToastNotification.show(
      //   res.message ?? '',
      //   type: ToastType.success,
      // );
      return classData;
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.success,
      );
    }

  }
  createClass(BuildContext context,body) async {
    EasyLoading.show(status: 'creating classes...');

    HTTPResponseModel res = await _classRepo.createClass(body);
    EasyLoading.dismiss();

    if (HTTPResponseModel.isApiCallSuccess(res)) {
      print(res.data);
      CustomToastNotification.show(
        res.message ?? '', 
        type: ToastType.success,
      );
    } else {
      CustomToastNotification.show(
        res.message ?? 'unable to get class data',
        type: ToastType.success,
      );
    }

  }
}
