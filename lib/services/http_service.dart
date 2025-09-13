import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:schmgtsystem/network/error_handler.dart';
import 'package:schmgtsystem/services/navigator_service.dart';
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/http.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HttpService {
  final Dio _dio;

  static const httpTimeoutDuration = 25;

  final kTimeoutResponse = Response(
    data: {"success": false, "message": "Connection Timeout"},
    statusCode: StatusRequestTimeout,
    requestOptions: RequestOptions(
      path: 'Error occurred while connecting to server',
    ),
  );

  final _navigatorService = locator<NavigatorService>();

  HttpService() : _dio = Dio() {
    _dio.options.baseUrl = AppConstants.kBaseUrl;

    // Add interceptor only once during initialization
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final prefs = await SharedPreferences.getInstance();
          final token = prefs.getString("token");
          print('saved as $token');

          if (token != null && token.isNotEmpty) {
            options.headers["Authorization"] = "Bearer $token";
          }
          return handler.next(options);
        },
        onError: (DioError e, handler) {
          // Handle expired token or 401 here
          return handler.next(e);
        },
      ),
    );
  }

  Future<HTTPResponseModel> runApi({
    required ApiRequestType type,
    required String url,
    Map<String, dynamic>? body,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    bool showError = true,
  }) async {
    // log('header: ${headers ?? _dio.options.headers}');
    // log('url: ${_dio.options.baseUrl + url}');
    // log('request: $body');
    // log('params: $params');

    Response res;

    try {
      switch (type) {
        case ApiRequestType.get:
          res = await _get(url: url, params: params);
          break;
        case ApiRequestType.post:
          res = await _post(url: url, body: body);
          break;
        case ApiRequestType.put:
          res = await _put(url: url, body: body);
          break;
        case ApiRequestType.patch:
          res = await _patch(url: url, body: body);
          break;
        case ApiRequestType.delete:
          res = await _delete(url: url, body: body);
          break;
        case ApiRequestType.formData:
          res = await _formData(url: url, body: body);
          break;
      }

      // log('res: $res');

      if (res.statusCode == StatusRequestTimeout) {
        DioErrorHandler().handleStringError(
          res.data['message'] ?? 'Connection Timeout',
        );
      }

      if (res.data is String) {
        return HTTPResponseModel.jsonToMap({
          "status": false,
          "message": "",
        }, res.statusCode!);
      }

      return HTTPResponseModel.jsonToMap(
        _normalizeResponse(res.data),
        res.statusCode!,
      );
    } on DioException catch (error) {
      if (EasyLoading.isShow) EasyLoading.dismiss();

      final int statusCode = error.response?.statusCode ?? 400;
      // log('Status code: $statusCode');
      // log('#Dio error.response.data: ${error.response?.data}');
      // log('#Dio error: ${error.toString()}');

      String errorMessage = DioErrorHandler().getErrorMessage(error);

      if (error.response?.statusCode == StatusUnauthorized &&
          error.response?.data['message'] ==
              'Please check your login credentials.') {
        DioErrorHandler().handleStringError(
          'Session expired. Kindly login again',
        );

        // clear token
        // _navigatorService.pushAndRemoveUntil(LoginScreen());
      } else if (showError) {
        DioErrorHandler().handleError(error);
      }

      // log('DioError [$statusCode]: $errorMessage');

      Map parsedJson = error.response?.data is Map ? error.response?.data : {};

      return HTTPResponseModel.jsonToMap(
        parsedJson,
        statusCode,
        errorMessage: errorMessage,
        success: false,
      );
    } catch (e) {
      if (EasyLoading.isShow) EasyLoading.dismiss();
      // log('error: ${e.toString()}');

      rethrow;
    }
  }

  Future<Response> _get({required String url, params}) async {
    return await _dio
        .get(url, queryParameters: params)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Future<Response> _post({required String url, body}) async {
    return await _dio
        .post(url, data: body)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Future<Response> _patch({required String url, body}) async {
    return await _dio
        .patch(url, data: body)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Future<Response> _put({required String url, body}) async {
    return await _dio
        .put(url, data: body)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Future<Response> _delete({required String url, body}) async {
    return await _dio
        .delete(url, data: body)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Future<Response> _formData({required String url, body}) async {
    FormData formData = FormData.fromMap(body);
    return await _dio
        .post(url, data: formData)
        .timeout(
          Duration(seconds: httpTimeoutDuration),
          onTimeout: () => kTimeoutResponse,
        );
  }

  Map<String, dynamic> _normalizeResponse(dynamic raw) {
    if (raw is Map<String, dynamic>) {
      // If API response has "data" key, unwrap it
      if (raw.containsKey('data') && raw['data'] is Map<String, dynamic>) {
        return {
          ...raw, // keep success/message
          ...raw['data'], // merge user, token, etc directly
        };
      }
      return raw;
    }
    return {"success": false, "message": "Invalid response"};
  }
}
