import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/providers/communication_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class CommunicationDialog extends ConsumerStatefulWidget {
  final String classId;
  final String? studentId;
  final CommunicationType communicationType;
  final List<String>? parentIds;
  final String? threadId; // Add threadId for thread-based communication

  const CommunicationDialog({
    Key? key,
    required this.classId,
    this.studentId,
    required this.communicationType,
    this.parentIds,
    this.threadId,
  }) : super(key: key);

  @override
  ConsumerState<CommunicationDialog> createState() =>
      _CommunicationDialogState();
}

class _CommunicationDialogState extends ConsumerState<CommunicationDialog> {
  final _titleController = TextEditingController();
  final _messageController = TextEditingController();
  final _replyController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadCommunications();
  }

  Future<void> _loadCommunications() async {
    if (widget.threadId != null) {
      // Load thread if threadId is provided
      await ref
          .read(RiverpodProvider.communicationProvider.notifier)
          .getCommunicationThread(threadId: widget.threadId!);
    } else {
      // Load class communications for new thread
      await ref
          .read(RiverpodProvider.communicationProvider.notifier)
          .getClassCommunications(classId: widget.classId);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _messageController.dispose();
    _replyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final communicationProvider = ref.watch(
      RiverpodProvider.communicationProvider,
    );
    final profileProvider = ref.watch(RiverpodProvider.profileProvider);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildHeader(),
            const SizedBox(height: 16),
            Expanded(
              child:
                  communicationProvider.hasCommunications
                      ? _buildCommunicationsList(communicationProvider)
                      : _buildEmptyState(),
            ),
            const SizedBox(height: 16),
            _buildNewMessageSection(profileProvider.user?.id ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(Icons.message, color: Colors.blue[700], size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Communication',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue[700],
                ),
              ),
              Text(
                widget.communicationType.displayName,
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.close),
        ),
      ],
    );
  }

  Widget _buildCommunicationsList(CommunicationProvider communicationProvider) {
    // Reverse the list to show most recent communications at the bottom
    final reversedCommunications =
        communicationProvider.communications.reversed.toList();

    return ListView.builder(
      itemCount: reversedCommunications.length,
      itemBuilder: (context, index) {
        final communication = reversedCommunications[index];
        return _buildWhatsAppStyleMessage(communication);
      },
    );
  }

  Widget _buildCommunicationCard(CommunicationModel communication) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    communication.sender.firstName.isNotEmpty
                        ? communication.sender.firstName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: Colors.blue[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        communication.sender.fullName,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        DateFormat(
                          'MMM dd, yyyy • HH:mm',
                        ).format(DateTime.parse(communication.createdAt)),
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getTypeColor(
                      communication.communicationType,
                    ).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getTypeDisplayName(communication.communicationType),
                    style: TextStyle(
                      color: _getTypeColor(communication.communicationType),
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            if (communication.title.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                communication.title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(communication.message, style: const TextStyle(fontSize: 14)),
            if (communication.replies.isNotEmpty) ...[
              const SizedBox(height: 12),
              _buildRepliesSection(communication),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildWhatsAppStyleMessage(CommunicationModel communication) {
    final profileProvider = ref.read(RiverpodProvider.profileProvider);
    final currentUserId = profileProvider.user?.id;

    // Determine if this message is from the current user
    final isFromCurrentUser = communication.sender.id == currentUserId;

    // Check if message is seen by all recipients (for outgoing messages)
    final isSeen = _isMessageSeen(communication, currentUserId);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      child: Row(
        mainAxisAlignment:
            isFromCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar for incoming messages (left side)
          if (!isFromCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: _getSenderColor(communication.sender),
              child: Text(
                communication.sender.firstName.isNotEmpty
                    ? communication.sender.firstName[0].toUpperCase()
                    : 'U',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],

          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color:
                    isFromCurrentUser
                        ? const Color(
                          0xFFDCF8C6,
                        ) // WhatsApp green for sent messages
                        : Colors.white, // White for received messages
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isFromCurrentUser ? 18 : 4),
                  bottomRight: Radius.circular(isFromCurrentUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Sender name for incoming messages
                  if (!isFromCurrentUser) ...[
                    Text(
                      '${communication.sender.firstName} ${communication.sender.lastName}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey[700],
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Subject if available
                  if (communication.title.isNotEmpty) ...[
                    Text(
                      communication.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],

                  // Message content
                  Text(
                    communication.message,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),

                  const SizedBox(height: 4),

                  // Timestamp and read status
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        DateFormat(
                          'HH:mm',
                        ).format(DateTime.parse(communication.createdAt)),
                        style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                      ),
                      if (isFromCurrentUser) ...[
                        const SizedBox(width: 4),
                        Icon(
                          isSeen ? Icons.done_all : Icons.done,
                          size: 14,
                          color: isSeen ? Colors.blue[600] : Colors.grey[600],
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // Avatar for outgoing messages (right side)
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: Colors.green[600],
              child: Text(
                profileProvider.user?.firstName?.isNotEmpty == true
                    ? profileProvider.user!.firstName![0].toUpperCase()
                    : 'M',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Check if message is seen by all recipients
  bool _isMessageSeen(CommunicationModel communication, String? currentUserId) {
    if (currentUserId == null) return false;

    // For outgoing messages, check if all recipients have read it
    if (communication.sender.id == currentUserId) {
      // Get all recipient IDs
      final recipientIds = communication.recipients.map((r) => r.id).toSet();

      // Get all read user IDs
      final readUserIds = communication.readBy.map((r) => r.userId).toSet();

      // Message is seen if all recipients have read it
      return recipientIds.every(
        (recipientId) => readUserIds.contains(recipientId),
      );
    }

    return false;
  }

  // Get color for sender avatar
  Color _getSenderColor(SenderInfo sender) {
    // Generate consistent color based on sender ID
    final hash = sender.id.hashCode;
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.teal,
      Colors.red,
      Colors.indigo,
      Colors.pink,
    ];
    return colors[hash.abs() % colors.length];
  }

  Color _getCommunicationTypeColor(String communicationType) {
    switch (communicationType) {
      case 'ADMIN_TEACHER':
        return Colors.blue;
      case 'ADMIN_PARENT':
        return Colors.green;
      case 'TEACHER_ADMIN':
        return Colors.orange;
      case 'PARENT_TEACHER':
        return Colors.purple;
      case 'TEACHER_PARENT':
        return Colors.teal;
      default:
        return Colors.grey;
    }
  }

  String _getCommunicationTypeLabel(String communicationType) {
    switch (communicationType) {
      case 'ADMIN_TEACHER':
        return 'Admin → Teacher';
      case 'ADMIN_PARENT':
        return 'Admin → Parent';
      case 'TEACHER_ADMIN':
        return 'Teacher → Admin';
      case 'PARENT_TEACHER':
        return 'Parent → Teacher';
      case 'TEACHER_PARENT':
        return 'Teacher → Parent';
      default:
        return communicationType.replaceAll('_', ' → ');
    }
  }

  Widget _buildRepliesSection(CommunicationModel communication) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Replies (${communication.replies.length})',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.grey[700],
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 8),
          // TODO: Implement replies when backend provides reply content
          // ...communication.replies.map((reply) => _buildReplyItem(reply)),
        ],
      ),
    );
  }

  Widget _buildReplyItem(ReplyInfo reply) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 12,
            backgroundColor: Colors.grey[200],
            child: const Icon(Icons.person, size: 16, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(reply.message, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  DateFormat(
                    'MMM dd, HH:mm',
                  ).format(DateTime.parse(reply.createdAt)),
                  style: TextStyle(color: Colors.grey[600], fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.message_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Communications Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with ${_getRecipientName()}',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildNewMessageSection(String senderId) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              labelText: 'Subject (Optional)',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _messageController,
            maxLines: 3,
            decoration: InputDecoration(
              labelText: 'Message',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isSending ? null : () => _sendMessage(senderId),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSending
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text('Send Message'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _sendMessage(String senderId) async {
    if (_messageController.text.trim().isEmpty) {
      CustomToastNotification.show(
        'Please enter a message',
        type: ToastType.error,
      );
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      final request = CreateCommunicationRequest(
        title:
            _titleController.text.trim().isNotEmpty
                ? _titleController.text.trim()
                : null,
        message: _messageController.text.trim(),
        recipients: widget.parentIds ?? [],
        communicationType: widget.communicationType.value,
        classId: widget.classId,
        attachments: const [],
        isAnnouncement: false,
      );

      final success = await ref
          .read(RiverpodProvider.communicationProvider.notifier)
          .createCommunication(request: request);

      if (success) {
        CustomToastNotification.show(
          'Message sent successfully!',
          type: ToastType.success,
        );

        // Clear form
        _titleController.clear();
        _messageController.clear();

        // Refresh communications
        await ref
            .read(RiverpodProvider.communicationProvider.notifier)
            .getClassCommunications(classId: widget.classId, refresh: true);
      } else {
        CustomToastNotification.show(
          'Failed to send message',
          type: ToastType.error,
        );
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error sending message: $e',
        type: ToastType.error,
      );
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  Color _getTypeColor(String type) {
    switch (type) {
      case 'PARENT_TEACHER':
        return Colors.green;
      case 'TEACHER_PARENT':
        return Colors.blue;
      case 'ADMIN_TEACHER':
        return Colors.purple;
      case 'ADMIN_PARENT':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  String _getTypeDisplayName(String type) {
    switch (type) {
      case 'PARENT_TEACHER':
        return 'Parent → Teacher';
      case 'TEACHER_PARENT':
        return 'Teacher → Parent';
      case 'ADMIN_TEACHER':
        return 'Admin → Teacher';
      case 'ADMIN_PARENT':
        return 'Admin → Parent';
      default:
        return type;
    }
  }

  String _getRecipientName() {
    switch (widget.communicationType) {
      case CommunicationType.teacherParent:
        return 'parents';
      case CommunicationType.parentTeacher:
        return 'teachers';
      case CommunicationType.adminTeacher:
        return 'teachers';
      case CommunicationType.adminParent:
        return 'parents';
      default:
        return 'recipients';
    }
  }
}
