import '../models/academic_settings_model.dart';
import '../services/http_service.dart';
import '../utils/enums.dart';
import '../utils/locator.dart';
import '../utils/response_model.dart';

class AcademicSettingsRepository {
  final _httpService = locator<HttpService>();

  // Create academic settings
  Future<HTTPResponseModel> createAcademicSettings({
    required String academicYear,
    required String currentTerm,
    required DateTime startDate,
    required DateTime endDate,
    List<TermModel>? terms,
    String? description,
  }) async {
    return await _httpService.runApi(
      type: ApiRequestType.post,
      url: '/classes/academic-settings',
      body: {
        'academicYear': academicYear,
        'currentTerm': currentTerm,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'terms': terms?.map((term) => term.toJson()).toList(),
        'description': description,
      },
    );
  }

  // Get all academic settings
  Future<HTTPResponseModel> getAllAcademicSettings({
    int page = 1,
    int limit = 10,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: '/classes/academic-settings',
      params: {
        'page': page.toString(),
        'limit': limit.toString(),
        'sortBy': sortBy,
        'sortOrder': sortOrder,
      },
    );
  }

  // Get current academic year
  Future<HTTPResponseModel> getCurrentAcademicYear() async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: '/classes/academic-settings/current',
    );
  }

  // Get academic settings by ID
  Future<HTTPResponseModel> getAcademicSettingsById(String id) async {
    return await _httpService.runApi(
      type: ApiRequestType.get,
      url: '/classes/academic-settings/$id',
    );
  }

  // Update academic settings
  Future<HTTPResponseModel> updateAcademicSettings({
    required String id,
    String? academicYear,
    String? currentTerm,
    DateTime? startDate,
    DateTime? endDate,
    List<TermModel>? terms,
    String? description,
  }) async {
    final data = <String, dynamic>{};
    if (academicYear != null) data['academicYear'] = academicYear;
    if (currentTerm != null) data['currentTerm'] = currentTerm;
    if (startDate != null) data['startDate'] = startDate.toIso8601String();
    if (endDate != null) data['endDate'] = endDate.toIso8601String();
    if (terms != null)
      data['terms'] = terms.map((term) => term.toJson()).toList();
    if (description != null) data['description'] = description;

    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: '/classes/academic-settings/$id',
      body: data,
    );
  }

  // Delete academic settings
  Future<HTTPResponseModel> deleteAcademicSettings({required String id}) async {
    return await _httpService.runApi(
      type: ApiRequestType.delete,
      url: '/classes/academic-settings/$id',
    );
  }

  // Set active academic year
  Future<HTTPResponseModel> setActiveAcademicYear({required String id}) async {
    return await _httpService.runApi(
      type: ApiRequestType.put,
      url: '/classes/academic-settings/$id/activate',
    );
  }
}
