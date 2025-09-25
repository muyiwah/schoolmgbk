import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class MetricsRepo {
  final _httpService = locator<HttpService>();

  // Get comprehensive metrics for dashboard
  Future<HTTPResponseModel> getComprehensiveMetrics({
    String? academicYear,
    String? term,
    Map<String, dynamic>? filters,
  }) async {
    try {
      final queryParams = <String, dynamic>{};

      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (term != null) queryParams['term'] = term;
      if (filters != null) queryParams.addAll(filters);

      String url = "/metrics/get-comprehensive-metrics";
      if (queryParams.isNotEmpty) {
        final queryString = queryParams.entries
            .map((e) => '${e.key}=${e.value}')
            .join('&');
        url += '?$queryString';
      }

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: url,
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch comprehensive metrics: ${e.toString()}',
      }, 500);
    }
  }

  // Get metrics by date range
  Future<HTTPResponseModel> getMetricsByDateRange({
    required DateTime startDate,
    required DateTime endDate,
    String? academicYear,
    String? term,
  }) async {
    try {
      final queryParams = <String, dynamic>{
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
      };

      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (term != null) queryParams['term'] = term;

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/metrics/get-comprehensive-metrics?$queryString",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch metrics by date range: ${e.toString()}',
      }, 500);
    }
  }

  // Get real-time metrics
  Future<HTTPResponseModel> getRealTimeMetrics() async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/metrics/get-comprehensive-metrics?realTime=true",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to fetch real-time metrics: ${e.toString()}',
      }, 500);
    }
  }
}
