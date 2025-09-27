import 'package:flutter/foundation.dart';
import 'package:schmgtsystem/repository/communication_repo.dart';
import 'package:schmgtsystem/utils/response_model.dart';
import 'package:schmgtsystem/models/communication_model.dart';

class CommunicationProvider extends ChangeNotifier {
  final CommunicationRepo _communicationRepo = CommunicationRepo();

  // State variables
  bool _isLoading = false;
  String? _errorMessage;
  List<CommunicationModel> _communications = [];
  List<CommunicationModel> _teacherToParentCommunications = [];
  List<CommunicationModel> _adminToTeacherCommunications = [];
  CommunicationModel? _selectedCommunication;
  PaginationInfo? _pagination;
  DateTime? _lastUpdated;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CommunicationModel> get communications => _communications;
  List<CommunicationModel> get teacherToParentCommunications =>
      _teacherToParentCommunications;
  List<CommunicationModel> get adminToTeacherCommunications =>
      _adminToTeacherCommunications;
  CommunicationModel? get selectedCommunication => _selectedCommunication;
  PaginationInfo? get pagination => _pagination;
  DateTime? get lastUpdated => _lastUpdated;

  // Helper getters
  bool get hasCommunications => _communications.isNotEmpty;
  bool get hasMorePages => _pagination?.hasNext ?? false;

  // Create new communication
  Future<bool> createCommunication({
    required CreateCommunicationRequest request,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.createCommunication(
        request: request,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _clearError();
        if (kDebugMode) {
          print('Communication created successfully');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to create communication');
        return false;
      }
    } catch (e) {
      _setError('Error creating communication: ${e.toString()}');
      if (kDebugMode) {
        print('Error in createCommunication: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Reply to communication
  Future<bool> replyToCommunication({
    required String communicationId,
    required ReplyCommunicationRequest request,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.replyToCommunication(
        communicationId: communicationId,
        request: request,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        _clearError();
        if (kDebugMode) {
          print('Reply sent successfully');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to send reply');
        return false;
      }
    } catch (e) {
      _setError('Error sending reply: ${e.toString()}');
      if (kDebugMode) {
        print('Error in replyToCommunication: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get communications for a class
  Future<bool> getClassCommunications({
    required String classId,
    String? communicationType,
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getClasscommunication(
        classId: classId,
        communicationType: communicationType,
        page: page,
        limit: limit,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;

        // Parse the new backend response format
        final communicationsData = responseData['data'] as Map<String, dynamic>;
        final communicationsList =
            (communicationsData['communications'] as List<dynamic>).map((comm) {
              if (kDebugMode) {
                print('Parsing communication: $comm');
              }
              return CommunicationModel.fromJson(comm);
            }).toList();

        final paginationData =
            communicationsData['pagination'] as Map<String, dynamic>;
        final pagination = PaginationInfo.fromJson(paginationData);

        if (refresh || page == 1) {
          _communications = communicationsList;

          // Store communications in specific lists based on type
          if (communicationType == CommunicationType.teacherParent.value) {
            _teacherToParentCommunications = communicationsList;
          } else if (communicationType ==
              CommunicationType.adminTeacher.value) {
            _adminToTeacherCommunications = communicationsList;
          }
        } else {
          _communications.addAll(communicationsList);

          // Add to specific lists based on type
          if (communicationType == CommunicationType.teacherParent.value) {
            _teacherToParentCommunications.addAll(communicationsList);
          } else if (communicationType ==
              CommunicationType.adminTeacher.value) {
            _adminToTeacherCommunications.addAll(communicationsList);
          }
        }

        _pagination = pagination;
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Class communications loaded successfully');
          print('Communications count: ${_communications.length}');
          print('Communication type filter: $communicationType');
          print('Raw response data: ${response.data}');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to get class communications');
        return false;
      }
    } catch (e) {
      _setError('Error getting class communications: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getClassCommunications: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get user communications (inbox)
  Future<bool> getUserCommunications({
    int page = 1,
    int limit = 10,
    String? communicationType,
    bool unreadOnly = false,
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getUsercommunication(
        page: page,
        limit: limit,
        communicationType: communicationType,
        unreadOnly: unreadOnly,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final communicationListResponse = CommunicationListResponse.fromJson(
          responseData,
        );

        if (refresh || page == 1) {
          _communications = communicationListResponse.data.communications;
        } else {
          _communications.addAll(communicationListResponse.data.communications);
        }

        _pagination = communicationListResponse.data.pagination;
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('User communications loaded successfully');
          print('Communications count: ${_communications.length}');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to get user communications');
        return false;
      }
    } catch (e) {
      _setError('Error getting user communications: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getUserCommunications: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Get single communication by ID
  Future<bool> getCommunicationById({required String communicationId}) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getCommunicationById(
        communicationId: communicationId,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        _selectedCommunication = CommunicationModel.fromJson(responseData);
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Communication loaded successfully');
          print('Communication ID: ${_selectedCommunication?.id}');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to get communication');
        return false;
      }
    } catch (e) {
      _setError('Error getting communication: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getCommunicationById: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Load more communications (pagination)
  Future<bool> loadMoreCommunications({required String classId}) async {
    if (!hasMorePages || _isLoading) return false;

    final nextPage = (_pagination?.currentPage ?? 1) + 1;
    return await getClassCommunications(classId: classId, page: nextPage);
  }

  // Refresh communications
  Future<bool> refreshCommunications({required String classId}) async {
    return await getClassCommunications(
      classId: classId,
      page: 1,
      refresh: true,
    );
  }

  // Set selected communication
  void setSelectedCommunication(CommunicationModel? communication) {
    _selectedCommunication = communication;
    notifyListeners();
  }

  // Get communication thread with all replies
  Future<bool> getCommunicationThread({
    required String threadId,
    int page = 1,
    int limit = 20,
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getCommunicationThread(
        threadId: threadId,
        page: page,
        limit: limit,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        final responseData = response.data as Map<String, dynamic>;
        final threadData = responseData['data'] as Map<String, dynamic>;
        final messagesList =
            (threadData['messages'] as List<dynamic>)
                .map((message) => CommunicationModel.fromJson(message))
                .toList();

        if (refresh || page == 1) {
          _communications = messagesList;
        } else {
          _communications.addAll(messagesList);
        }

        _pagination = PaginationInfo.fromJson(threadData['pagination']);
        _lastUpdated = DateTime.now();
        _clearError();

        if (kDebugMode) {
          print('Communication thread loaded successfully');
          print('Messages count: ${_communications.length}');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to get communication thread');
        return false;
      }
    } catch (e) {
      _setError('Error getting communication thread: ${e.toString()}');
      if (kDebugMode) {
        print('Error in getCommunicationThread: $e');
      }
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Mark communication as read
  Future<bool> markAsRead({required String communicationId}) async {
    try {
      final response = await _communicationRepo.markAsRead(
        communicationId: communicationId,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        if (kDebugMode) {
          print('Communication marked as read');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to mark communication as read');
        return false;
      }
    } catch (e) {
      _setError('Error marking communication as read: ${e.toString()}');
      if (kDebugMode) {
        print('Error in markAsRead: $e');
      }
      return false;
    }
  }

  // Mark entire thread as read
  Future<bool> markThreadAsRead({required String threadId}) async {
    try {
      final response = await _communicationRepo.markThreadAsRead(
        threadId: threadId,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        if (kDebugMode) {
          print('Thread marked as read');
        }
        return true;
      } else {
        _setError(response.message ?? 'Failed to mark thread as read');
        return false;
      }
    } catch (e) {
      _setError('Error marking thread as read: ${e.toString()}');
      if (kDebugMode) {
        print('Error in markThreadAsRead: $e');
      }
      return false;
    }
  }

  // Clear all data
  void clearData() {
    _communications.clear();
    _teacherToParentCommunications.clear();
    _adminToTeacherCommunications.clear();
    _selectedCommunication = null;
    _pagination = null;
    _lastUpdated = null;
    _clearError();
    notifyListeners();
  }

  // Helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  // Utility methods for filtering communications
  List<CommunicationModel> getCommunicationsByType(CommunicationType type) {
    return _communications
        .where((comm) => comm.communicationType == type.value)
        .toList();
  }

  List<CommunicationModel> getUnreadCommunications() {
    // This would need to be implemented based on your read/unread logic
    return _communications;
  }

  // Get teacher-to-parent communications specifically
  List<CommunicationModel> getTeacherToParentCommunications() {
    return _teacherToParentCommunications;
  }

  // Get admin-to-teacher communications specifically
  List<CommunicationModel> getAdminToTeacherCommunications() {
    return _adminToTeacherCommunications;
  }

  // Get communication statistics
  Map<String, int> getCommunicationStats() {
    final stats = <String, int>{};
    for (final type in CommunicationType.values) {
      stats[type.displayName] = getCommunicationsByType(type).length;
    }
    return stats;
  }
}
