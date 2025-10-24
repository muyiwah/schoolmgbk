import 'package:schmgtsystem/models/uniform_model.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class UniformRepository {
  final HttpService _httpService = HttpService();

  // Get all uniforms for a class
  Future<UniformResponse> getUniforms(String classId) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: '/classes/$classId/uniforms',
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return UniformResponse.fromJson(response.data);
      } else {
        return UniformResponse(
          success: false,
          message: response.message ?? 'Failed to fetch uniforms',
        );
      }
    } catch (e) {
      return UniformResponse(
        success: false,
        message: 'Error fetching uniforms: $e',
      );
    }
  }

  // Get uniform for a specific day
  Future<UniformSingleResponse> getUniformByDay(
    String classId,
    String day,
  ) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: '/classes/$classId/uniforms/$day',
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return UniformSingleResponse.fromJson(response.data);
      } else {
        return UniformSingleResponse(
          success: false,
          message: response.message ?? 'Failed to fetch uniform for $day',
        );
      }
    } catch (e) {
      return UniformSingleResponse(
        success: false,
        message: 'Error fetching uniform for $day: $e',
      );
    }
  }

  // Add or update uniform for a day
  Future<UniformResponse> addUniform(
    String classId,
    String day,
    String uniform,
  ) async {
    try {
      final body = {'day': day, 'uniform': uniform};

      final response = await _httpService.runApi(
        type: ApiRequestType.post,
        url: '/classes/$classId/uniforms',
        body: body,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return UniformResponse.fromJson(response.data);
      } else {
        return UniformResponse(
          success: false,
          message: response.message ?? 'Failed to add uniform',
        );
      }
    } catch (e) {
      return UniformResponse(
        success: false,
        message: 'Error adding uniform: $e',
      );
    }
  }

  // Update uniform for a specific day
  Future<UniformSingleResponse> updateUniform(
    String classId,
    String day,
    String uniform,
  ) async {
    try {
      final body = {'uniform': uniform};

      final response = await _httpService.runApi(
        type: ApiRequestType.put,
        url: '/classes/$classId/uniforms/$day',
        body: body,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return UniformSingleResponse.fromJson(response.data);
      } else {
        return UniformSingleResponse(
          success: false,
          message: response.message ?? 'Failed to update uniform',
        );
      }
    } catch (e) {
      return UniformSingleResponse(
        success: false,
        message: 'Error updating uniform: $e',
      );
    }
  }

  // Delete uniform for a specific day
  Future<UniformResponse> deleteUniform(String classId, String day) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.delete,
        url: '/classes/$classId/uniforms/$day',
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return UniformResponse.fromJson(response.data);
      } else {
        return UniformResponse(
          success: false,
          message: response.message ?? 'Failed to delete uniform',
        );
      }
    } catch (e) {
      return UniformResponse(
        success: false,
        message: 'Error deleting uniform: $e',
      );
    }
  }

  // Get all classes with their uniforms
  Future<AllClassesUniformsResponse> getAllClassesUniforms() async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: '/classes/uniforms/all',
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return AllClassesUniformsResponse.fromJson(response.data);
      } else {
        return AllClassesUniformsResponse(
          success: false,
          message: response.message ?? 'Failed to fetch classes uniforms',
          count: 0,
        );
      }
    } catch (e) {
      return AllClassesUniformsResponse(
        success: false,
        message: 'Error fetching classes uniforms: $e',
        count: 0,
      );
    }
  }
}
