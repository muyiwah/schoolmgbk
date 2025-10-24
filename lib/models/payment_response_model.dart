class PaymentInitializationResponse {
  final bool success;
  final String message;
  final PaymentData data;

  PaymentInitializationResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory PaymentInitializationResponse.fromJson(Map<String, dynamic> json) {
    return PaymentInitializationResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data: PaymentData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'message': message, 'data': data.toJson()};
  }
}

class PaymentData {
  final String checkoutUrl;

  PaymentData({required this.checkoutUrl});

  factory PaymentData.fromJson(Map<String, dynamic> json) {
    return PaymentData(checkoutUrl: json['checkout_url'] ?? '');
  }

  Map<String, dynamic> toJson() {
    return {'checkout_url': checkoutUrl};
  }
}
