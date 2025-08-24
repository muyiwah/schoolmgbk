import 'package:schmgtsystem/utils/http.dart';

class HTTPResponseModel {
  HTTPResponseModel();

  static bool isApiCallSuccess(HTTPResponseModel data) {
    if (data.code >= StatusMultipleChoices) {
      return false;
    }
    return true;
  }

  int? _code;
  String? _message;
  dynamic _error;
  String? _errorMessage;
  dynamic _data;
  dynamic _meta;
  dynamic _rawResponse;

  int get code => _code!;
  String? get message => _message;
  dynamic get error => _error;
  String get errorMessage => _errorMessage ?? 'An error occurred';
  dynamic get data => _data;
  dynamic get meta => _meta;
  dynamic get rawResponse => _rawResponse;

  set setSuccess(int code) => _code = code;
  set setErrorMessage(String message) => _message = message;
  set setError(error) => _error = error;
  set setData(data) => _data = data;
  set setMeta(meta) => _meta = meta;
  set setRawResponse(rawResponse) => _rawResponse = rawResponse;

  HTTPResponseModel.jsonToMap(
    Map<dynamic, dynamic> parsedJson,
    int statusCode, {
    String? errorMessage,
    bool? success,
  }) {
    _code = statusCode;
    _message = parsedJson['message'].toString();
    _error = parsedJson['error'];
    _errorMessage = errorMessage;
    // _data = parsedJson['data'];
    _data = parsedJson;
    _meta = parsedJson['meta'];
    _rawResponse = parsedJson;
  }
}

class ErrorResponseModel {
  ErrorResponseModel({
    this.success = false,
    this.code = StatusBadRequest,
    required this.error,
  });
  final bool success;
  final int code;
  final String error;
}
