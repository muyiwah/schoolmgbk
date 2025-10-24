import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/enums.dart';

class TeacherRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> getAllTeachers(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/teachers",
      body: body,
    );
  }

  Future<HTTPResponseModel> getSingleTeacher(String teacherId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/teachers/$teacherId",
   
    );
  }
}
