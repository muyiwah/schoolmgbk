import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/models/communication_model.dart';

class CommunicationRepo {
  final _httpService = locator<HttpService>();

  // Create new communication thread
  Future<HTTPResponseModel> createCommunication({
    required CreateCommunicationRequest request,
  }) async {
    try {
      print(request.toJson());
      print("--------------------------------");
      final response = await _httpService.runApi(
        type: ApiRequestType.post,
        url: "/communication",
        body: request.toJson(),
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to create communication: ${e.toString()}',
      }, 500);
    }
  }

  // Reply to a communication thread
  Future<HTTPResponseModel> replyToCommunication({
    required String communicationId,
    required ReplyCommunicationRequest request,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.post,
        url: "/communication/$communicationId/reply",
        body: request.toJson(),
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to reply to communication: ${e.toString()}',
      }, 500);
    }
  }

  // Get communication for a class
  Future<HTTPResponseModel> getClasscommunication({
    required String classId,
    String? communicationType,
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      if (communicationType != null) {
        queryParams['communicationType'] = communicationType;
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/communication/class/$classId?$queryString",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get class communication: ${e.toString()}',
      }, 500);
    }
  }

  // Get user communication (inbox)
  Future<HTTPResponseModel> getUsercommunication({
    int page = 1,
    int limit = 10,
    String? communicationType,
    bool unreadOnly = false,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      if (communicationType != null) {
        queryParams['communicationType'] = communicationType;
      }

      if (unreadOnly) {
        queryParams['unreadOnly'] = 'true';
      }

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/communication?$queryString",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get user communication: ${e.toString()}',
      }, 500);
    }
  }

  // Get communication thread with all replies
  Future<HTTPResponseModel> getCommunicationThread({
    required String threadId,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = {'page': page.toString(), 'limit': limit.toString()};

      final queryString = queryParams.entries
          .map((e) => '${e.key}=${e.value}')
          .join('&');

      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/communication/thread/$threadId?$queryString",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get communication thread: ${e.toString()}',
      }, 500);
    }
  }

  // Mark communication as read
  Future<HTTPResponseModel> markAsRead({
    required String communicationId,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.put,
        url: "/communication/$communicationId/read",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to mark communication as read: ${e.toString()}',
      }, 500);
    }
  }

  // Mark entire thread as read
  Future<HTTPResponseModel> markThreadAsRead({required String threadId}) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.put,
        url: "/communication/thread/$threadId/read",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to mark thread as read: ${e.toString()}',
      }, 500);
    }
  }

  // Get single communication by ID
  Future<HTTPResponseModel> getCommunicationById({
    required String communicationId,
  }) async {
    try {
      final response = await _httpService.runApi(
        type: ApiRequestType.get,
        url: "/communication/$communicationId",
      );

      return response;
    } catch (e) {
      return HTTPResponseModel.jsonToMap({
        "success": false,
        "message": 'Failed to get communication: ${e.toString()}',
      }, 500);
    }
  }
}
