import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/models/single_class_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';

class MessagePopup extends ConsumerStatefulWidget {
  final String title;
  final String classId;
  final Data? classData;
  final List<String>? parentIds;
  final CommunicationType communicationType;

  const MessagePopup({
    super.key,
    required this.title,
    required this.classId,
    this.classData,
    this.parentIds,
    required this.communicationType,
  });

  @override
  ConsumerState<MessagePopup> createState() => _MessagePopupState();
}

class _MessagePopupState extends ConsumerState<MessagePopup>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();

  late AnimationController _animationController;
  late AnimationController _scaleController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = false;
  bool _emailFocused = false;
  bool _subjectFocused = false;
  bool _messageFocused = false;
  bool _parentDropdownFocused = false;

  // List of parents from the class data
  List<Map<String, String>> get _parentsList {
    if (widget.classData?.students == null) return [];

    return widget.classData!.students!.map((student) {
      return {
        'name': student.parentName ?? 'Unknown Parent',
        'email':
            '${student.name?.toLowerCase().replaceAll(' ', '.')}@parent.com', // Placeholder email
        'studentId': student.id ?? '',
      };
    }).toList();
  }

  String? _selectedParent;
  String? _selectedParentEmail;
  String? _selectedStudentId;
  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scaleController.dispose();
    _emailController.dispose();
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: Dialog(
                backgroundColor: Colors.transparent,
                elevation: 0,
                insetPadding: const EdgeInsets.all(20),
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 500,
                    maxHeight: 700,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 40,
                        offset: const Offset(0, 20),
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [_buildHeader(), Flexible(child: _buildBody())],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [const Color(0xFF6366F1), const Color(0xFF8B5CF6)],
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.send_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Send ${widget.title}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Compose and send your message',
                  style: TextStyle(fontSize: 14, color: Colors.white70),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(
              Icons.close_rounded,
              color: Colors.white,
              size: 24,
            ),
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildParentDropdown(),
            const SizedBox(height: 20),
            // _buildEmailField(),
            // const SizedBox(height: 20),
            _buildSubjectField(),
            const SizedBox(height: 20),
            _buildMessageField(),
            const SizedBox(height: 32),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildParentDropdown() {
    // Handle different communication types
    if (widget.communicationType == CommunicationType.adminTeacher) {
      // For class teacher communication, show class teacher info
      return _buildClassTeacherRecipient();
    } else if (widget.communicationType == CommunicationType.adminParent) {
      if (widget.parentIds != null && widget.parentIds!.isNotEmpty) {
        // For "all parents" communication
        return _buildAllParentsRecipient();
      } else {
        // For single parent communication
        return _buildSingleParentDropdown();
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildClassTeacherRecipient() {
    final classTeacher = widget.classData?.dataClass?.classTeacher;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.person, color: Colors.blue[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      classTeacher?.name ?? 'Class Teacher',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'Class Teacher',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAllParentsRecipient() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipients',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.people, color: Colors.green[700]),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'All Parents (${_parentsList.length})',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      'All parents in this class will receive this message',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSingleParentDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          alignment: Alignment.center,
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _parentDropdownFocused
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
              width: _parentDropdownFocused ? 2 : 1,
            ),
            boxShadow:
                _parentDropdownFocused
                    ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: DropdownButtonFormField<String>(
            dropdownColor: Colors.white,
            value: _selectedParent,
            hint: const Text('Select a parent'),
            icon: Icon(
              Icons.arrow_drop_down,
              color:
                  _parentDropdownFocused
                      ? const Color(0xFF6366F1)
                      : const Color(0xFF9CA3AF),
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                Icons.person_outline,
                color:
                    _parentDropdownFocused
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              isDense: true,
            ),
            items:
                _parentsList.map((parent) {
                  return DropdownMenuItem<String>(
                    value: parent['name'],
                    child: Text(parent['name']!),
                    onTap: () {
                      _selectedParentEmail = parent['email'];
                      _selectedStudentId = parent['studentId'];
                    },
                  );
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedParent = value;
              });
            },
            onTap: () {
              setState(() => _parentDropdownFocused = true);
            },
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select a parent';
              }
              return null;
            },
          ),
        ),
        if (_selectedParentEmail != null) ...[
          const SizedBox(height: 8),
          Text(
            'Email: $_selectedParentEmail',
            style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
          ),
        ],
      ],
    );
  }

  Widget _buildEmailField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recipient Email',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _emailFocused
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
              width: _emailFocused ? 2 : 1,
            ),
            boxShadow:
                _emailFocused
                    ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onTap: () => setState(() => _emailFocused = true),
            onTapOutside: (_) => setState(() => _emailFocused = false),
            decoration: InputDecoration(
              hintText: 'Enter recipient email address',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(
                Icons.email_outlined,
                color:
                    _emailFocused
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter an email address';
              }
              if (!RegExp(
                r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
              ).hasMatch(value)) {
                return 'Please enter a valid email address';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSubjectField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Subject',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _subjectFocused
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
              width: _subjectFocused ? 2 : 1,
            ),
            boxShadow:
                _subjectFocused
                    ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: _subjectController,
            textInputAction: TextInputAction.next,
            onTap: () => setState(() => _subjectFocused = true),
            onTapOutside: (_) => setState(() => _subjectFocused = false),
            decoration: InputDecoration(
              hintText: 'Enter message subject',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              prefixIcon: Icon(
                Icons.subject_outlined,
                color:
                    _subjectFocused
                        ? const Color(0xFF6366F1)
                        : const Color(0xFF9CA3AF),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
              isDense: true,
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a subject';
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Message',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF374151),
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color:
                  _messageFocused
                      ? const Color(0xFF6366F1)
                      : const Color(0xFFE5E7EB),
              width: _messageFocused ? 2 : 1,
            ),
            boxShadow:
                _messageFocused
                    ? [
                      BoxShadow(
                        color: const Color(0xFF6366F1).withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ]
                    : null,
          ),
          child: TextFormField(
            controller: _messageController,
            maxLines: 6,
            textInputAction: TextInputAction.newline,
            onTap: () => setState(() => _messageFocused = true),
            onTapOutside: (_) => setState(() => _messageFocused = false),
            decoration: InputDecoration(
              hintText:
                  'Type your message here...\n\nMake it personal and engaging!',
              hintStyle: const TextStyle(color: Color(0xFF9CA3AF)),
              alignLabelWithHint: true,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(16),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a message';
              }
              if (value.length < 10) {
                return 'Message should be at least 10 characters long';
              }
              return null;
            },
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${_messageController.text.length}/1000 characters',
          style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: const BorderSide(color: Color(0xFFE5E7EB)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Cancel',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _sendMessage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
              shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
            ),
            child:
                _isLoading
                    ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                    : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.send_rounded, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Send Message',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
          ),
        ),
      ],
    );
  }

  Future<void> _sendMessage() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Get current user (admin) from profile provider
      final profileProvider = ref.read(RiverpodProvider.profileProvider);
      final currentUser = profileProvider.user;

      if (currentUser == null) {
        CustomToastNotification.show(
          'User not found. Please login again.',
          type: ToastType.error,
        );
        return;
      }

      // Prepare recipients based on communication type
      List<String> recipients = [];

      if (widget.communicationType == CommunicationType.adminTeacher) {
   
        // For class teacher communication - use class teacher's staffId
        final classTeacher = widget.classData?.dataClass?.classTeacher;
        if (classTeacher?.id != null) {
          recipients = [classTeacher!.id!];
        }
      } else if (widget.communicationType == CommunicationType.adminParent) {
        if (widget.parentIds != null && widget.parentIds!.isNotEmpty) {
          // For "all parents" communication - use provided parent IDs
          recipients = widget.parentIds!;
        } else if (_selectedStudentId != null) {
          // For single parent communication - use selected student ID
          recipients = [_selectedStudentId!];
        }
      }

      if (recipients.isEmpty) {
        CustomToastNotification.show(
          'No recipients selected',
          type: ToastType.error,
        );
        return;
      }

      // Create communication request
      final request = CreateCommunicationRequest(
        subject:
            _subjectController.text.trim().isNotEmpty
                ? _subjectController.text.trim()
                : null,
        message: _messageController.text.trim(),
        recipients: recipients,
        communicationType: widget.communicationType.value,
        classId: widget.classId,
        senderId: currentUser.id ?? '',
      );
print(request.toJson());
      // Send communication
      final success = await ref
          .read(RiverpodProvider.communicationProvider.notifier)
          .createCommunication(request: request);

      if (success) {
        CustomToastNotification.show(
          'Message sent successfully!',
          type: ToastType.success,
        );

        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        CustomToastNotification.show(
          'Failed to send message. Please try again.',
          type: ToastType.error,
        );
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error sending message: $e',
        type: ToastType.error,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
}
