// ImageKit Authentication Models
class ImageKitAuthModel {
  final bool success;
  final ImageKitAuthData? data;
  final String? message;

  ImageKitAuthModel({required this.success, this.data, this.message});

  factory ImageKitAuthModel.fromJson(Map<String, dynamic> json) {
    return ImageKitAuthModel(
      success: json['success'] ?? false,
      data:
          json['data'] != null ? ImageKitAuthData.fromJson(json['data']) : null,
      message: json['message'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson(), 'message': message};
  }
}

class ImageKitAuthData {
  final String token;
  final int expire;
  final String signature;

  ImageKitAuthData({
    required this.token,
    required this.expire,
    required this.signature,
  });

  factory ImageKitAuthData.fromJson(Map<String, dynamic> json) {
    return ImageKitAuthData(
      token: json['token'] ?? '',
      expire: json['expire'] ?? 0,
      signature: json['signature'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'token': token, 'expire': expire, 'signature': signature};
  }
}
