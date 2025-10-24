class AdminUpdateStatusRequestModel {
  final String userId;
  final String status;
  final String? reason;

  AdminUpdateStatusRequestModel({
    required this.userId,
    required this.status,
    this.reason,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'status': status,
      if (reason != null) 'reason': reason,
    };
  }

  factory AdminUpdateStatusRequestModel.fromJson(Map<String, dynamic> json) {
    return AdminUpdateStatusRequestModel(
      userId: json['userId'] ?? '',
      status: json['status'] ?? '',
      reason: json['reason'],
    );
  }
}

class AdminUpdateStatusResponseModel {
  final bool success;
  final String message;
  final AdminUpdateStatusData? data;

  AdminUpdateStatusResponseModel({
    required this.success,
    required this.message,
    this.data,
  });

  factory AdminUpdateStatusResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminUpdateStatusResponseModel(
      success: json['success'] ?? false,
      message: json['message'] ?? '',
      data:
          json['data'] != null
              ? AdminUpdateStatusData.fromJson(json['data'])
              : null,
    );
  }
}

class AdminUpdateStatusData {
  final String userId;
  final String userEmail;
  final String userRole;
  final String oldStatus;
  final String newStatus;
  final bool isActive;
  final String changedBy;
  final String changedAt;
  final String? reason;

  AdminUpdateStatusData({
    required this.userId,
    required this.userEmail,
    required this.userRole,
    required this.oldStatus,
    required this.newStatus,
    required this.isActive,
    required this.changedBy,
    required this.changedAt,
    this.reason,
  });

  factory AdminUpdateStatusData.fromJson(Map<String, dynamic> json) {
    return AdminUpdateStatusData(
      userId: json['userId'] ?? '',
      userEmail: json['userEmail'] ?? '',
      userRole: json['userRole'] ?? '',
      oldStatus: json['oldStatus'] ?? '',
      newStatus: json['newStatus'] ?? '',
      isActive: json['isActive'] ?? false,
      changedBy: json['changedBy'] ?? '',
      changedAt: json['changedAt'] ?? '',
      reason: json['reason'],
    );
  }
}

enum UserStatus {
  active('active', 'Active', 'User can log in normally', 0xFF10B981),
  inactive('inactive', 'Inactive', 'User account is deactivated', 0xFF6B7280),
  suspended(
    'suspended',
    'Suspended',
    'User account is temporarily suspended',
    0xFFF59E0B,
  ),
  terminated(
    'terminated',
    'Terminated',
    'User account is permanently terminated',
    0xFFEF4444,
  );

  const UserStatus(this.value, this.displayName, this.description, this.color);

  final String value;
  final String displayName;
  final String description;
  final int color;

  static UserStatus fromString(String status) {
    return UserStatus.values.firstWhere(
      (s) => s.value == status,
      orElse: () => UserStatus.active,
    );
  }
}
