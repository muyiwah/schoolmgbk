import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class TimeTableRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> createClassTimeTable(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/timetables",
      body: body,
    );
  }
  Future<HTTPResponseModel> getAllClassesTimeTable(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables",
      body: body,
    );
  }

  Future<HTTPResponseModel> getDetailsOfSingeTimeTable(
   String classId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables/$classId",
  
    );
  }
  Future<HTTPResponseModel> getClassTimeTable(
   String classId,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/timetables/$classId",
  
    );
  }
  Future<HTTPResponseModel> updateClassTimeTble(
   String classId,
   Map<String, dynamic> body
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: "/timetables/$classId",
      body: body,
  
    );
  }


}
