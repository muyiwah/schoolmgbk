class CommunicationModel {
  final String id;
  final String title;
  final String message;
  final SenderInfo sender;
  final List<RecipientInfo> recipients;
  final String communicationType;
  final String? classId;
  final List<ReplyInfo> replies;
  final List<AttachmentInfo> attachments;
  final bool isAnnouncement;
  final String createdAt;
  final String updatedAt;

  CommunicationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.sender,
    required this.recipients,
    required this.communicationType,
    this.classId,
    required this.replies,
    required this.attachments,
    required this.isAnnouncement,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunicationModel.fromJson(Map<String, dynamic> json) {
    return CommunicationModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      sender: SenderInfo.fromJson(json['sender'] ?? {}),
      recipients:
          (json['recipients'] as List<dynamic>?)
              ?.map((recipient) => RecipientInfo.fromJson(recipient))
              .toList() ??
          [],
      communicationType: json['communicationType'] ?? '',
      classId: json['classId'],
      replies:
          (json['replies'] as List<dynamic>?)
              ?.map((reply) => ReplyInfo.fromJson(reply))
              .toList() ??
          [],
      attachments:
          (json['attachments'] as List<dynamic>?)
              ?.map((attachment) => AttachmentInfo.fromJson(attachment))
              .toList() ??
          [],
      isAnnouncement: json['isAnnouncement'] ?? false,
      createdAt: json['createdAt'] ?? '',
      updatedAt: json['updatedAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'title': title,
      'message': message,
      'sender': sender.toJson(),
      'recipients': recipients.map((recipient) => recipient.toJson()).toList(),
      'communicationType': communicationType,
      'classId': classId,
      'replies': replies.map((reply) => reply.toJson()).toList(),
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
      'isAnnouncement': isAnnouncement,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }
}

class SenderInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  SenderInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory SenderInfo.fromJson(Map<String, dynamic> json) {
    return SenderInfo(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
}

class RecipientInfo {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  RecipientInfo({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  factory RecipientInfo.fromJson(Map<String, dynamic> json) {
    return RecipientInfo(
      id: json['_id'] ?? json['id'] ?? '',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'role': role,
    };
  }

  String get fullName => '$firstName $lastName';
}

class ReplyInfo {
  final String sender;
  final String message;
  final String createdAt;

  ReplyInfo({
    required this.sender,
    required this.message,
    required this.createdAt,
  });

  factory ReplyInfo.fromJson(Map<String, dynamic> json) {
    return ReplyInfo(
      sender: json['sender'] ?? '',
      message: json['message'] ?? '',
      createdAt: json['createdAt'] ?? json['timestamp'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'sender': sender, 'message': message, 'createdAt': createdAt};
  }
}

class AttachmentInfo {
  final String fileUrl;
  final String fileType;

  AttachmentInfo({required this.fileUrl, required this.fileType});

  factory AttachmentInfo.fromJson(Map<String, dynamic> json) {
    return AttachmentInfo(
      fileUrl: json['fileUrl'] ?? '',
      fileType: json['fileType'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'fileUrl': fileUrl, 'fileType': fileType};
  }
}

class CommunicationListResponse {
  final bool success;
  final CommunicationListData data;

  CommunicationListResponse({required this.success, required this.data});

  factory CommunicationListResponse.fromJson(Map<String, dynamic> json) {
    return CommunicationListResponse(
      success: json['success'] ?? false,
      data: CommunicationListData.fromJson(json['data'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {'success': success, 'data': data.toJson()};
  }
}

class CommunicationListData {
  final List<CommunicationModel> communications;
  final PaginationInfo pagination;

  CommunicationListData({
    required this.communications,
    required this.pagination,
  });

  factory CommunicationListData.fromJson(Map<String, dynamic> json) {
    return CommunicationListData(
      communications:
          (json['communications'] as List<dynamic>?)
              ?.map((comm) => CommunicationModel.fromJson(comm))
              .toList() ??
          [],
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'communications': communications.map((comm) => comm.toJson()).toList(),
      'pagination': pagination.toJson(),
    };
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int total;
  final bool hasNext;
  final bool hasPrev;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.total,
    required this.hasNext,
    required this.hasPrev,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: json['currentPage'] ?? 1,
      totalPages: json['totalPages'] ?? 1,
      total: json['total'] ?? 0,
      hasNext: json['hasNext'] ?? false,
      hasPrev: json['hasPrev'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'currentPage': currentPage,
      'totalPages': totalPages,
      'total': total,
      'hasNext': hasNext,
      'hasPrev': hasPrev,
    };
  }
}

class CreateCommunicationRequest {
  final String? subject;
  final String message;
  final List<String> recipients;
  final String communicationType;
  final String? classId;
  final String senderId;

  CreateCommunicationRequest({
    this.subject,
    required this.message,
    required this.recipients,
    required this.communicationType,
    this.classId,
    required this.senderId,
  });

  Map<String, dynamic> toJson() {
    return {
      'subject': subject,
      'message': message,
      'recipients': recipients,
      'communicationType': communicationType,
      'classId': classId,
      'senderId': senderId,
    };
  }
}

class ReplyCommunicationRequest {
  final String message;
  final String senderId;

  ReplyCommunicationRequest({required this.message, required this.senderId});

  Map<String, dynamic> toJson() {
    return {'message': message, 'senderId': senderId};
  }
}

// Communication types enum
enum CommunicationType {
  parentTeacher('PARENT_TEACHER'),
  teacherParent('TEACHER_PARENT'),
  teacherStudent('TEACHER_STUDENT'),
  teacherAdmin('TEACHER_ADMIN'),
  adminTeacher('ADMIN_TEACHER'),
  adminStaff('ADMIN_STAFF'),
  adminParent('ADMIN_PARENT'),
  adminAll('ADMIN_ALL');

  const CommunicationType(this.value);
  final String value;

  String get displayName {
    switch (this) {
      case CommunicationType.parentTeacher:
        return 'Parent to Teacher';
      case CommunicationType.teacherParent:
        return 'Teacher to Parent';
      case CommunicationType.teacherStudent:
        return 'Teacher to Student';
      case CommunicationType.teacherAdmin:
        return 'Teacher to Admin';
      case CommunicationType.adminTeacher:
        return 'Admin to Teacher';
      case CommunicationType.adminStaff:
        return 'Admin to Staff';
      case CommunicationType.adminParent:
        return 'Admin to Parent';
      case CommunicationType.adminAll:
        return 'Admin to All';
    }
  }
}
