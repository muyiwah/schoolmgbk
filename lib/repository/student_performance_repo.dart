import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class StudentPerformanceRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> recordStudentPerformance(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/performance",
      body: body,
    );
  }
  Future<HTTPResponseModel> getFilteredPerformance(
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/performance",
      body: body,
    );
  }
}
