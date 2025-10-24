class AdminChangePasswordRequestModel {
  final String userId;
  final String newPassword;
  final String? reason;

  AdminChangePasswordRequestModel({
    required this.userId,
    required this.newPassword,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'newPassword': newPassword,
      if (reason != null) 'reason': reason,
    };
  }

  factory AdminChangePasswordRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminChangePasswordRequestModel(
      userId: json['userId'] ?? '',
      newPassword: json['newPassword'] ?? '',
      reason: json['reason'],
    );
  }
}

class AdminChangePasswordResponseModel {
  final bool success;
  final String message;
  final AdminChangePasswordData? data;

  AdminChangePasswordResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminChangePasswordResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminChangePasswordResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? AdminChangePasswordData.fromJson(json['data'])
              : null,
    );
  }
}

class AdminChangePasswordData {
  final String userId;
  final String userEmail;
  final String userRole;
  final String changedBy;
  final String changedAt;
  final String? reason;

  AdminChangePasswordData({
    required this.userId,
    required this.userEmail,
    required this.userRole,
    required this.changedBy,
    required this.changedAt,
    this.reason,
  });

  factory AdminChangePasswordData.fromJson(Map<String, dynamic> json) {
    return AdminChangePasswordData(
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userRole: json['userRole'] ?? '',
      changedBy: json['changedBy'] ?? '',
      changedAt: json['changedAt'] ?? '',
      reason: json['reason'],
    );
  }
}
