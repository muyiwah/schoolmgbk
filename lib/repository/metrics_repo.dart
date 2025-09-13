import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class MetricsRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> dashboard(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/metrics/dashboard",
      body: body,
    );
  }
  Future<HTTPResponseModel> students(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/metrics/students",
      body: body,
    );
  }
  Future<HTTPResponseModel> financial(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/metrics/financial",
      body: body,
    );
  }
  Future<HTTPResponseModel> attendance(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/metrics/attendance",
      body: body,
    );
  }
  Future<HTTPResponseModel> performance(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/metrics/performance",
      body: body,
    );
  }
}
