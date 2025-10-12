class AdminUsersResponseModel {
  final bool success;
  final AdminUsersData? data;

  AdminUsersResponseModel({required this.success, this.data});

  factory AdminUsersResponseModel.fromJson(Map<String, dynamic> json) {
    return AdminUsersResponseModel(
      success: json['success'] ?? false,
      data: json['data'] != null ? AdminUsersData.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data?.toJson()};
  }
}

class AdminUsersData {
  final List<AdminUser> users;
  final PaginationInfo pagination;

  AdminUsersData({required this.users, required this.pagination});

  factory AdminUsersData.fromJson(Map<String, dynamic> json) {
    return AdminUsersData(
      users:
          (json['users'] as List<dynamic>?)
              ?.map((user) => AdminUser.fromJson(user))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'users': users.map((user) => user.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class AdminUser {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final String status;
  final bool isActive;
  final DateTime createdAt;

  AdminUser({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.status,
    required this.isActive,
    required this.createdAt,
  });

  factory AdminUser.fromJson(Map<String, dynamic> json) {
    return AdminUser(
      id: json['_id'] ?? json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      role: json['role'] ?? '',
      status: json['status'] ?? 'active',
      isActive: json['isActive'] ?? true,
      createdAt:
          json['createdAt'] != null
              ? DateTime.parse(json['createdAt'])
              : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'role': role,
      'status': status,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  String get fullName => '$firstName $lastName';
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalUsers;
  final int currentPageUsers;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalUsers,
    required this.currentPageUsers,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      totalUsers: json['totalUsers'] ?? 0,
      currentPageUsers: json['currentPageUsers'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'totalUsers': totalUsers,
      'currentPageUsers': currentPageUsers,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}
