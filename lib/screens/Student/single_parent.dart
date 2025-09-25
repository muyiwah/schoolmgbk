import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class SingleParent extends ConsumerStatefulWidget {
  final Function navigateTo;
  final Function navigateTo2;
  final String parentId;

  SingleParent({
    Key? key,
    required this.navigateTo,
    required this.navigateTo2,
    required this.parentId,
  }) : super(key: key);

  @override
  ConsumerState<SingleParent> createState() => _SingleParentState();
}

class _SingleParentState extends ConsumerState<SingleParent> {
  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    // Clear any previous data and load fresh single parent data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = ref.read(RiverpodProvider.parentProvider.notifier);
      // Clear previous single parent data to ensure fresh data
      provider.clearSingleParentData();
      // Clear any previous errors
      provider.setError(null);
      // Fetch new data
      provider.getSingleParent(context, widget.parentId);
    });
  }

  @override
  void didUpdateWidget(SingleParent oldWidget) {
    super.didUpdateWidget(oldWidget);
    // If parentId changed, fetch new data
    if (oldWidget.parentId != widget.parentId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final provider = ref.read(RiverpodProvider.parentProvider.notifier);
        provider.clearSingleParentData();
        provider.setError(null);
        provider.getSingleParent(context, widget.parentId);
      });
    }
  }

  void _showMessagePopup(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      builder: (context) => MessagePopup(title: title,classId: '',communicationType: CommunicationType.adminParent),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer(
        builder: (context, ref, child) {
          final parentState = ref.watch(RiverpodProvider.parentProvider);

          if (parentState.isLoading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  Text(
                    'Loading parent details...',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          if (parentState.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading parent details',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.red[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      parentState.errorMessage!,
                      style: TextStyle(fontSize: 14, color: Colors.red[600]),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final provider = ref.read(
                        RiverpodProvider.parentProvider.notifier,
                      );
                      provider.setError(null);
                      provider.getSingleParent(context, widget.parentId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final parentData = parentState.singleParent.data;
          if (parentData?.parent == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_outline, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Parent not found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Parent ID: ${widget.parentId}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      final provider = ref.read(
                        RiverpodProvider.parentProvider.notifier,
                      );
                      provider.setError(null);
                      provider.getSingleParent(context, widget.parentId);
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final parent = parentData!.parent!;
          final children = parentData.children ?? [];
          final financialSummary = parentData.financialSummary;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 24,
                    horizontal: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      IconButton(
                        onPressed: () {
                          widget.navigateTo();
                        },
                        icon: Icon(Icons.arrow_back_ios_new),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Parent Profile Overview',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Full insight into guardian activity, payment records, and child enrollment',
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              ElevatedButton.icon(
                                onPressed: () {
                                  _showMessagePopup(context, 'Message');
                                  showSnackbar(context, 'Message sent');
                                },
                                icon: const Icon(Icons.send, size: 16),
                                label: Text('Send Message'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.secondary,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              OutlinedButton.icon(
                                onPressed: () {
                                  _showMessagePopup(
                                    context,
                                    'Push Notification',
                                  );
                                },
                                icon: const Icon(Icons.note_add, size: 16),
                                label: const Text('Push Notification'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: Colors.grey[700],
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              ElevatedButton.icon(
                                onPressed: () {
                                  widget.navigateTo2();
                                },
                                icon: const Icon(Icons.receipt_long, size: 16),
                                label: const Text('View All Transactions'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF06B6D4),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column - Parent Details & Children
                    Expanded(
                      flex: 2,
                      child: Column(
                        children: [
                          // Parent Details Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Row(
                              children: [
                                // Profile Image
                                Container(
                                  width: 80,
                                  height: 80,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(40),
                                    image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://images.unsplash.com/photo-1494790108755-2616b332c912?w=150&h=150&fit=crop&crop=face',
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                // Details
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(
                                            '${parent.personalInfo?.firstName ?? ''} ${parent.personalInfo?.lastName ?? ''}',
                                            style: const TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(width: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDCFCE7),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'VIP',
                                              style: TextStyle(
                                                color: Color(0xFF16A34A),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 4,
                                            ),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFDBEAFE),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: const Text(
                                              'Responsive',
                                              style: TextStyle(
                                                color: Color(0xFF2563EB),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 12),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildInfoRow(
                                                  Icons.phone,
                                                  parent
                                                          .contactInfo
                                                          ?.primaryPhone ??
                                                      'No phone',
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.email,
                                                  parent.contactInfo?.email ??
                                                      'No email',
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.location_on,
                                                  '${parent.contactInfo?.address?.street ?? ''}, ${parent.contactInfo?.address?.city ?? ''}',
                                                ),
                                              ],
                                            ),
                                          ),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                _buildInfoRow(
                                                  Icons.work,
                                                  parent
                                                          .professionalInfo
                                                          ?.occupation ??
                                                      'Not specified',
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.email_outlined,
                                                  'Email Preferred',
                                                ),
                                                const SizedBox(height: 8),
                                                _buildInfoRow(
                                                  Icons.people,
                                                  '${children.length} Children Enrolled',
                                                  color: const Color(
                                                    0xFF6366F1,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Tabbed Content Section
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Tab Bar
                                Row(
                                  children: [
                                    _buildTab('Children Enrolled', 0),
                                    _buildTab('Payment History', 1),
                                    _buildTab('Communication', 2),
                                    _buildTab('Documents', 3),
                                    _buildTab('Notes', 4),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Tab Content
                                _buildTabContent(),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(width: 24),

                    // Right Column - Quick Summary & Recent Activity
                    Expanded(
                      flex: 1,
                      child: Column(
                        children: [
                          // Quick Summary Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Quick Summary',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildSummaryRow(
                                  'Total Owed',
                                  '\$${financialSummary?.totalAmountOwed ?? 0}',
                                  Colors.red,
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  'Children',
                                  '${financialSummary?.numberOfChildren ?? 0}',
                                  Colors.black,
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  'Payment Completion',
                                  '${(financialSummary?.paymentCompletion ?? 0).toStringAsFixed(1)}%',
                                  Colors.black,
                                ),
                                const SizedBox(height: 16),
                                _buildSummaryRow(
                                  'Total Fees',
                                  '\$${financialSummary?.totalFees ?? 0}',
                                  Colors.black,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Recent Activity Card
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Recent Activity',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                _buildActivityItem(
                                  Colors.green,
                                  'Payment received',
                                  '2 hours ago',
                                ),
                                const SizedBox(height: 16),
                                _buildActivityItem(
                                  Colors.blue,
                                  'Profile updated',
                                  '1 day ago',
                                ),
                                const SizedBox(height: 16),
                                _buildActivityItem(
                                  Colors.purple,
                                  'Message sent',
                                  '3 days ago',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text, {Color? color}) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 14,
              color: color ?? Colors.grey[700],
              fontWeight: color != null ? FontWeight.w500 : FontWeight.normal,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTab(String text, int index) {
    bool isActive = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTabIndex = index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(right: 24),
        child: Column(
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 14,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? const Color(0xFF6366F1) : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            if (isActive)
              Container(height: 2, width: 60, color: const Color(0xFF6366F1)),
          ],
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildChildrenContent();
      case 1:
        return _buildPaymentHistoryContent();
      case 2:
        return _buildCommunicationContent();
      case 3:
        return _buildDocumentsContent();
      case 4:
        return _buildNotesContent();
      default:
        return _buildChildrenContent();
    }
  }

  Widget _buildChildrenContent() {
    final parentData =
        ref.watch(RiverpodProvider.parentProvider).singleParent.data;
    final children = parentData?.children ?? [];

    if (children.isEmpty) {
      return const Center(
        child: Column(
          children: [
            Icon(Icons.child_care_outlined, size: 48, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No children enrolled',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'This parent has no children enrolled yet',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Column(
      children:
          children.map((child) {
            final student = child.student;
            final currentTerm = child.currentTerm;

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildChildCard(
                'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
                '${student?.personalInfo?.firstName ?? ''} ${student?.personalInfo?.lastName ?? ''}',
                '${student?.academicInfo?.currentClass?.name ?? 'No class'} • ${student?.admissionNumber ?? 'No admission number'}',
                currentTerm?.status == 'active',
              ),
            );
          }).toList(),
    );
  }

  Widget _buildPaymentHistoryContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Payment History',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            TextButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export'),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildPaymentCard(
          '\$625.00',
          'November 2024',
          'Paid',
          Colors.green,
          'Nov 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '\$625.00',
          'October 2024',
          'Paid',
          Colors.green,
          'Oct 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '\$625.00',
          'September 2024',
          'Overdue',
          Colors.red,
          'Sep 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '\$125.00',
          'August 2024',
          'Paid',
          Colors.green,
          'Aug 20, 2024',
          'Activity Fee',
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Total Outstanding:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const Text(
                '\$1,250.00',
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCommunicationContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Communication Log',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: () {
                _showMessagePopup(context, 'New Message');
              },
              icon: const Icon(Icons.add, size: 16),
              label: const Text('New Message'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildCommunicationCard(
          'Email',
          'Monthly Progress Report',
          'Dec 10, 2024 - 9:30 AM',
          'Sent progress reports for both Emma and Michael. Emma is excelling in Mathematics...',
          Icons.email,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildCommunicationCard(
          'Phone Call',
          'Parent Conference Scheduled',
          'Dec 8, 2024 - 2:15 PM',
          'Discussed Michael\'s improvement in reading comprehension. Scheduled follow-up meeting...',
          Icons.phone,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildCommunicationCard(
          'SMS',
          'Pickup Reminder',
          'Dec 5, 2024 - 3:45 PM',
          'Reminder: Early pickup today at 2:30 PM for Emma\'s dental appointment.',
          Icons.sms,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildCommunicationCard(
          'Email',
          'Payment Overdue Notice',
          'Dec 1, 2024 - 10:00 AM',
          'Friendly reminder about the outstanding balance of \$625. Please contact us if you need...',
          Icons.email,
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildDocumentsContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Documents & Files',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.upload_file, size: 16),
              label: const Text('Upload'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildDocumentCard(
          'Enrollment Agreement 2024.pdf',
          'PDF Document',
          '2.4 MB',
          'Nov 28, 2024',
          Icons.picture_as_pdf,
          Colors.red,
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          'Emma_ProgressReport_Q2.pdf',
          'Progress Report',
          '1.8 MB',
          'Dec 10, 2024',
          Icons.description,
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          'Michael_MedicalRecords.pdf',
          'Medical Records',
          '3.2 MB',
          'Oct 15, 2024',
          Icons.medical_information,
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          'Emergency_Contacts.docx',
          'Emergency Information',
          '0.5 MB',
          'Sep 20, 2024',
          Icons.contact_emergency,
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildDocumentCard(
          'PhotoPermission_Form.jpg',
          'Permission Form',
          '2.1 MB',
          'Aug 30, 2024',
          Icons.image,
          Colors.purple,
        ),
      ],
    );
  }

  Widget _buildNotesContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Internal Notes',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.add_comment, size: 16),
              label: const Text('Add Note'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _buildNoteCard(
          'Parent Conference Follow-up',
          'Dec 10, 2024',
          'Ms. Rodriguez',
          'Discussed Emma\'s exceptional performance in mathematics. Parents requested additional challenges. Recommended advanced math workbooks and considering grade acceleration for next year.',
          Colors.blue,
        ),
        const SizedBox(height: 12),
        _buildNoteCard(
          'Payment Plan Discussion',
          'Dec 5, 2024',
          'Finance Office',
          'Parent called regarding payment difficulties due to recent job change. Agreed to split outstanding balance into 3 monthly installments. Very cooperative and appreciative.',
          Colors.orange,
        ),
        const SizedBox(height: 12),
        _buildNoteCard(
          'Behavioral Observation',
          'Nov 28, 2024',
          'Mr. Thompson',
          'Michael has shown significant improvement in social interactions during lunch break. Less withdrawn, actively participating in group activities. Continue positive reinforcement.',
          Colors.green,
        ),
        const SizedBox(height: 12),
        _buildNoteCard(
          'Allergy Alert Update',
          'Nov 15, 2024',
          'School Nurse',
          'Emma\'s peanut allergy severity updated to moderate. EpiPen location confirmed in classroom and nurse office. All teachers notified of new protocol.',
          Colors.red,
        ),
      ],
    );
  }

  Widget _buildChildCard(
    String imageUrl,
    String name,
    String details,
    bool isActive,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              image: DecorationImage(
                image: NetworkImage(imageUrl),
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  details,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Active',
                    style: TextStyle(
                      color: Color(0xFF16A34A),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.secondary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            child: const Text('View Progress', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(
    String amount,
    String period,
    String status,
    Color statusColor,
    String date,
    String type,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              status == 'Paid' ? Icons.check_circle : Icons.warning,
              color: statusColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      amount,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  type,
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                Text(
                  '$period • Due: $date',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommunicationCard(
    String type,
    String subject,
    String datetime,
    String preview,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(icon, color: color, size: 16),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          subject,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            type,
                            style: TextStyle(
                              color: color,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      datetime,
                      style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            preview,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard(
    String filename,
    String type,
    String size,
    String date,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  filename,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      type,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Text(' • ', style: TextStyle(color: Colors.grey)),
                    Text(
                      size,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
                Text(
                  'Uploaded: $date',
                  style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: Icon(Icons.more_vert, color: Colors.grey[600]),
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'download',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 16),
                        SizedBox(width: 8),
                        Text('Download'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'share',
                    child: Row(
                      children: [
                        Icon(Icons.share, size: 16),
                        SizedBox(width: 8),
                        Text('Share'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 16, color: Colors.red),
                        SizedBox(width: 8),
                        Text('Delete', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                  ),
                ],
          ),
        ],
      ),
    );
  }

  Widget _buildNoteCard(
    String title,
    String date,
    String author,
    String content,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          'By $author',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const Text(' • ', style: TextStyle(color: Colors.grey)),
                        Text(
                          date,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton(
                icon: Icon(Icons.more_vert, color: Colors.grey[600]),
                itemBuilder:
                    (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 16),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 16, color: Colors.red),
                            SizedBox(width: 8),
                            Text('Delete', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[700])),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildActivityItem(Color color, String title, String time) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                time,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
