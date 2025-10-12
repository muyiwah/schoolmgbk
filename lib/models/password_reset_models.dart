class PasswordResetRequestModel {
  final String email;

  PasswordResetRequestModel({required this.email});

  Map<String, dynamic> toJson() {
    return {'email': email};
  }

  factory PasswordResetRequestModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetRequestModel(email: json['email'] ?? '');
  }
}

class PasswordResetResponseModel {
  final bool success;
  final String message;
  final int? expiresIn;

  PasswordResetResponseModel({
    required this.success,
    required this.message,
    this.expiresIn,
  });

  factory PasswordResetResponseModel.fromJson(Map<String, dynamic> json) {
    return PasswordResetResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'],
    );
  }
}

class ResetPasswordRequestModel {
  final String email;
  final String otp;
  final String newPassword;

  ResetPasswordRequestModel({
    required this.email,
    required this.otp,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp, 'newPassword': newPassword};
  }

  factory ResetPasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordRequestModel(
      email: json['email'] ?? '',
      otp: json['otp'] ?? '',
      newPassword: json['newPassword'] ?? '',
    );
  }
}

class ResetPasswordResponseModel {
  final bool success;
  final String message;

  ResetPasswordResponseModel({required this.success, required this.message});

  factory ResetPasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return ResetPasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
    );
  }
}

class VerifyOTPRequestModel {
  final String email;
  final String otp;

  VerifyOTPRequestModel({required this.email, required this.otp});

  Map<String, dynamic> toJson() {
    return {'email': email, 'otp': otp};
  }

  factory VerifyOTPRequestModel.fromJson(Map<String, dynamic> json) {
    return VerifyOTPRequestModel(
      email: json['email'] ?? '',
      otp: json['otp'] ?? '',
    );
  }
}

class VerifyOTPResponseModel {
  final bool success;
  final String message;
  final int? expiresAt;
  final int? attemptsRemaining;

  VerifyOTPResponseModel({
    required this.success,
    required this.message,
    this.expiresAt,
    this.attemptsRemaining,
  });

  factory VerifyOTPResponseModel.fromJson(Map<String, dynamic> json) {
    return VerifyOTPResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      expiresAt: json['expiresAt'],
      attemptsRemaining: json['attemptsRemaining'],
    );
  }
}

class OTPStatusResponseModel {
  final bool success;
  final bool hasOTP;
  final String message;
  final int? expiresIn;
  final int? attemptsRemaining;
  final int? createdAt;

  OTPStatusResponseModel({
    required this.success,
    required this.hasOTP,
    required this.message,
    this.expiresIn,
    this.attemptsRemaining,
    this.createdAt,
  });

  factory OTPStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return OTPStatusResponseModel(
      success: json['success'] ?? false,
      hasOTP: json['hasOTP'] ?? false,
      message: json['message'] ?? '',
      expiresIn: json['expiresIn'],
      attemptsRemaining: json['attemptsRemaining'],
      createdAt: json['createdAt'],
    );
  }
}
