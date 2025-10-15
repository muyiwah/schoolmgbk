import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class PaymentRepository {
  Future<HTTPResponseModel> getFeesPaidReport({
    int? page,
    String? paymentStatus,
    String? academicYear,
    String? term,
    String? sortBy,
    String? sortOrder,
    String? classId,
    String? search,
  }) async {
    try {
      final queryParams = <String, String>{};
      if (page != null) queryParams['page'] = page.toString();
      if (paymentStatus != null) queryParams['paymentStatus'] = paymentStatus;
      if (academicYear != null) queryParams['academicYear'] = academicYear;
      if (term != null) queryParams['term'] = term;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;
      if (classId != null) queryParams['classId'] = classId;
      if (search != null) queryParams['search'] = search;

      final uri = Uri.parse(
        '${AppConstants.kBaseUrl}/payments/fees-paid-report',
      ).replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
          // 'Authorization': 'Bearer $token',
        },
      );

      final model = HTTPResponseModel();
      model.setSuccess = response.statusCode;
      model.setData = json.decode(response.body);
      model.setErrorMessage =
          response.statusCode == 200
              ? 'Success'
              : 'Failed to load fees paid report';
      return model;
    } catch (e) {
      final model = HTTPResponseModel();
      model.setSuccess = 500;
      model.setData = null;
      model.setErrorMessage = 'Error fetching fees paid report: $e';
      return model;
    }
  }

  Future<HTTPResponseModel> initializePayment(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.kBaseUrl}/payments/stripe/initialize'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(paymentData),
      );
      print(response.body);
      final model = HTTPResponseModel();
      model.setSuccess = response.statusCode;
      model.setData = json.decode(response.body);
      model.setErrorMessage = response.body;
      return model;
    } catch (e) {
      final model = HTTPResponseModel();
      model.setSuccess = 500;
      model.setData = null;
      model.setErrorMessage = 'Error initializing payment: $e';
      return model;
    }
  }

  Future<HTTPResponseModel> getClassFeeBreakdown({
    required String classId,
    required String term,
  }) async {
    try {
      final queryParams = <String, String>{'term': term};

      final uri = Uri.parse(
        '${AppConstants.kBaseUrl}/payments/class-fee-breakdown/$classId',
      ).replace(queryParameters: queryParams);
      print(uri);
      print(queryParams);
      print('how are you');
      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
          // 'Authorization': 'Bearer $token',
        },
      );

      final model = HTTPResponseModel();
      model.setSuccess = response.statusCode;
      model.setData = json.decode(response.body);
      model.setErrorMessage =
          response.statusCode == 200
              ? 'Success'
              : 'Failed to load class fee breakdown';
      return model;
    } catch (e) {
      final model = HTTPResponseModel();
      model.setSuccess = 500;
      model.setData = null;
      model.setErrorMessage = 'Error fetching class fee breakdown: $e';
      return model;
    }
  }

  Future<HTTPResponseModel> updateManualPaymentStatu(
    Map<String, dynamic> paymentData,
  ) async {
    try {
      print('Updating manual payment status');
      print(paymentData);

      final response = await http.put(
        Uri.parse('${AppConstants.kBaseUrl}/payments/admin/manual-update'),
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
          // 'Authorization': 'Bearer $token',
        },
        body: json.encode(paymentData),
      );
      print(response.body);
      final model = HTTPResponseModel();
      model.setSuccess = response.statusCode;
      model.setData = json.decode(response.body);
      return model;
    } catch (e) {
      final model = HTTPResponseModel();
      model.setSuccess = 500;
      model.setData = null;
      model.setErrorMessage = 'Error updating manual payment status: $e';
      return model;
    }
  }
}
