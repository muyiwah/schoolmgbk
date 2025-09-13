import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class StudentsRepo {
  final _httpService = locator<HttpService>();

  Future<HTTPResponseModel> getAllStudents(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/students",
      body: body,
    );
  }

  Future<HTTPResponseModel> createStudent(Map<String, dynamic> body) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/students",
      body: body,
    );
  }

Future<HTTPResponseModel> assignStudentToClass(
  // body takes "classId": "68a386c5fc888b6066cff7e0"
    String studentId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: "/students/$studentId/assign-class", // <-- studentId goes here
      body: body,
    );
  }


  Future<HTTPResponseModel> getStudentById(String studentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: "/students/$studentId",
    );
  }

  Future<HTTPResponseModel> updateStudent(
    //eample {"personalInfo.lastName": "Tolani", }
    String studentId,
    Map<String, dynamic> body,
  ) async {
    return await _httpService.runApi(
      type: ApiRequestType.put, // or patch, depending on your backend
      url: "/students/$studentId",
      body: body,
    );
  }

  Future<HTTPResponseModel> deleteStudent(String studentId) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: "/students/$studentId",
    );
  }

}
