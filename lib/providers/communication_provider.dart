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
  CommunicationModel? _selectedCommunication;
  PaginationInfo? _pagination;
  DateTime? _lastUpdated;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<CommunicationModel> get communications => _communications;
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
    int page = 1,
    int limit = 10,
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getClasscommunication(
        classId: classId,
        page: page,
        limit: limit,
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
          print('Class communications loaded successfully');
          print('Communications count: ${_communications.length}');
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
    bool refresh = false,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _communicationRepo.getUsercommunication(
        page: page,
        limit: limit,
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

  // Clear all data
  void clearData() {
    _communications.clear();
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

  // Get communication statistics
  Map<String, int> getCommunicationStats() {
    final stats = <String, int>{};
    for (final type in CommunicationType.values) {
      stats[type.displayName] = getCommunicationsByType(type).length;
    }
    return stats;
  }
}
