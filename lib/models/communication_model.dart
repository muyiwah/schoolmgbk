class CommunicationModel {
  final String id;
  final String threadId;
  final String title;
  final String message;
  final SenderInfo sender;
  final List<RecipientInfo> recipients;
  final String communicationType;
  final String? classId;
  final List<String> replies;
  final String? parentMessage;
  final bool isThreadStarter;
  final int threadDepth;
  final List<AttachmentInfo> attachments;
  final bool isAnnouncement;
  final List<ReadByInfo> readBy;
  final String createdAt;
  final String updatedAt;

  CommunicationModel({
    required this.id,
    required this.threadId,
    required this.title,
    required this.message,
    required this.sender,
    required this.recipients,
    required this.communicationType,
    this.classId,
    required this.replies,
    this.parentMessage,
    required this.isThreadStarter,
    required this.threadDepth,
    required this.attachments,
    required this.isAnnouncement,
    required this.readBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory CommunicationModel.fromJson(Map<String, dynamic> json) {
    try {
      return CommunicationModel(
        id: json['_id'] ?? '',
        threadId: json['threadId'] ?? '',
        title: json['title'] ?? '',
        message: json['message'] ?? '',
        sender: SenderInfo.fromJson(json['sender'] ?? {}),
        recipients:
            (json['recipients'] as List<dynamic>?)
                ?.map((recipient) => RecipientInfo.fromJson(recipient))
                .toList() ??
            [],
        communicationType: json['communicationType'] ?? '',
        classId:
            json['classId'] is String
                ? json['classId']
                : json['classId']?['_id'] ?? json['classId']?['id'] ?? null,
        replies:
            (json['replies'] as List<dynamic>?)
                ?.map((reply) => reply.toString())
                .toList() ??
            [],
        parentMessage: json['parentMessage'],
        isThreadStarter: json['isThreadStarter'] ?? false,
        threadDepth: json['threadDepth'] ?? 0,
        attachments:
            (json['attachments'] as List<dynamic>?)
                ?.map((attachment) => AttachmentInfo.fromJson(attachment))
                .toList() ??
            [],
        isAnnouncement: json['isAnnouncement'] ?? false,
        readBy:
            (json['readBy'] as List<dynamic>?)
                ?.map((readBy) => ReadByInfo.fromJson(readBy))
                .toList() ??
            [],
        createdAt: json['createdAt'] ?? '',
        updatedAt: json['updatedAt'] ?? '',
      );
    } catch (e) {
      print('Error parsing CommunicationModel: $e');
      print('JSON data: $json');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'threadId': threadId,
      'title': title,
      'message': message,
      'sender': sender.toJson(),
      'recipients': recipients.map((recipient) => recipient.toJson()).toList(),
      'communicationType': communicationType,
      'classId': classId,
      'replies': replies,
      'parentMessage': parentMessage,
      'isThreadStarter': isThreadStarter,
      'threadDepth': threadDepth,
      'attachments':
          attachments.map((attachment) => attachment.toJson()).toList(),
      'isAnnouncement': isAnnouncement,
      'readBy': readBy.map((readBy) => readBy.toJson()).toList(),
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

class ReadByInfo {
  final String userId;
  final String readAt;

  ReadByInfo({required this.userId, required this.readAt});

  factory ReadByInfo.fromJson(Map<String, dynamic> json) {
    return ReadByInfo(
      userId: json['userId'] ?? '',
      readAt: json['readAt'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'userId': userId, 'readAt': readAt};
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
  final String? title;
  final String message;
  final List<String> recipients;
  final String communicationType;
  final String? classId;
  final List<Map<String, String>> attachments;
  final bool isAnnouncement;

  CreateCommunicationRequest({
    this.title,
    required this.message,
    required this.recipients,
    required this.communicationType,
    this.classId,
    this.attachments = const [],
    this.isAnnouncement = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'message': message,
      'recipients': recipients,
      'communicationType': communicationType,
      'classId': classId,
      'attachments': attachments,
      'isAnnouncement': isAnnouncement,
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
