import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/repository/parent_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

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
  bool _isEditMode = false;

  // Controllers for editable fields
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _middleNameController;
  late TextEditingController _titleController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;
  late TextEditingController _streetController;
  late TextEditingController _cityController;
  late TextEditingController _stateController;
  late TextEditingController _countryController;
  late TextEditingController _occupationController;
  late TextEditingController _employerController;
  late TextEditingController _annualIncomeController;
  late TextEditingController _idTypeController;
  late TextEditingController _idNumberController;
  late TextEditingController _relationshipController;

  // Dropdown values
  String? _selectedGender;
  String? _selectedMaritalStatus;
  String? _selectedParentType;
  String? _selectedPreferredContact;

  // Boolean values
  bool _parentalResponsibility = false;
  bool _legalGuardianship = false;
  bool _authorisedToCollectChild = false;
  bool _receiveNewsletters = false;
  bool _receiveEventNotifications = false;

  // Date
  DateTime? _selectedDateOfBirth;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
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

  void _initializeControllers() {
    _firstNameController = TextEditingController();
    _lastNameController = TextEditingController();
    _middleNameController = TextEditingController();
    _titleController = TextEditingController();
    _phoneController = TextEditingController();
    _emailController = TextEditingController();
    _streetController = TextEditingController();
    _cityController = TextEditingController();
    _stateController = TextEditingController();
    _countryController = TextEditingController();
    _occupationController = TextEditingController();
    _employerController = TextEditingController();
    _annualIncomeController = TextEditingController();
    _idTypeController = TextEditingController();
    _idNumberController = TextEditingController();
    _relationshipController = TextEditingController();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _titleController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _occupationController.dispose();
    _employerController.dispose();
    _annualIncomeController.dispose();
    _idTypeController.dispose();
    _idNumberController.dispose();
    _relationshipController.dispose();
    super.dispose();
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
      builder:
          (context) => MessagePopup(
            title: title,
            classId: '',
            communicationType: CommunicationType.adminParent,
          ),
    );
  }

  void _populateControllersWithCurrentData(dynamic parent) {
    if (parent == null) return;

    // Personal Info
    _firstNameController.text = parent.personalInfo?.firstName ?? '';
    _lastNameController.text = parent.personalInfo?.lastName ?? '';
    _middleNameController.text = parent.personalInfo?.middleName ?? '';
    _titleController.text = parent.personalInfo?.title ?? '';
    _selectedGender = parent.personalInfo?.gender;
    _selectedMaritalStatus = parent.personalInfo?.maritalStatus;
    _selectedDateOfBirth = parent.personalInfo?.dateOfBirth;

    // Contact Info
    _phoneController.text = parent.contactInfo?.primaryPhone ?? '';
    _emailController.text = parent.contactInfo?.email ?? '';
    _streetController.text = parent.contactInfo?.address?.street ?? '';
    _cityController.text = parent.contactInfo?.address?.city ?? '';
    _stateController.text = parent.contactInfo?.address?.state ?? '';
    _countryController.text = parent.contactInfo?.address?.country ?? '';

    // Professional Info
    _occupationController.text = parent.professionalInfo?.occupation ?? '';
    _employerController.text = parent.professionalInfo?.employer ?? '';
    _annualIncomeController.text =
        parent.professionalInfo?.annualIncome?.toString() ?? '';

    // Identification
    _idTypeController.text = parent.identification?.idType ?? '';
    _idNumberController.text = parent.identification?.idNumber ?? '';

    // Legal Info
    _relationshipController.text = parent.legalInfo?.relationshipToChild ?? '';
    _parentalResponsibility = parent.legalInfo?.parentalResponsibility ?? false;
    _legalGuardianship = parent.legalInfo?.legalGuardianship ?? false;
    _authorisedToCollectChild =
        parent.legalInfo?.authorisedToCollectChild ?? false;

    // Preferences
    _selectedPreferredContact = parent.preferences?.preferredContactMethod;
    _receiveNewsletters = parent.preferences?.receiveNewsletters ?? false;
    _receiveEventNotifications =
        parent.preferences?.receiveEventNotifications ?? false;

    // Parent Type
    _selectedParentType = parent.parentType;
  }

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
      if (_isEditMode) {
        // Populate controllers when entering edit mode
        final parentData =
            ref.read(RiverpodProvider.parentProvider).singleParent.data;
        if (parentData?.parent != null) {
          _populateControllersWithCurrentData(parentData!.parent!);
        }
      }
    });
  }

  Future<void> _saveParentData() async {
    try {
      final parentData =
          ref.read(RiverpodProvider.parentProvider).singleParent.data;
      if (parentData?.parent == null) return;

      final updateData = {
        'parentType': _selectedParentType,
        'personalInfo': {
          'title': _titleController.text,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'middleName': _middleNameController.text,
          'dateOfBirth': _selectedDateOfBirth?.toIso8601String(),
          'gender': _selectedGender,
          'maritalStatus': _selectedMaritalStatus,
        },
        'contactInfo': {
          'primaryPhone': _phoneController.text,
          'email': _emailController.text,
          'address': {
            'street': _streetController.text,
            'city': _cityController.text,
            'state': _stateController.text,
            'country': _countryController.text,
          },
        },
        'professionalInfo': {
          'occupation': _occupationController.text,
          'employer': _employerController.text,
          'annualIncome': int.tryParse(_annualIncomeController.text),
        },
        'identification': {
          'idType': _idTypeController.text,
          'idNumber': _idNumberController.text,
        },
        'legalInfo': {
          'parentalResponsibility': _parentalResponsibility,
          'legalGuardianship': _legalGuardianship,
          'authorisedToCollectChild': _authorisedToCollectChild,
          'relationshipToChild': _relationshipController.text,
        },
        'preferences': {
          'preferredContactMethod': _selectedPreferredContact,
          'receiveNewsletters': _receiveNewsletters,
          'receiveEventNotifications': _receiveEventNotifications,
        },
      };

      // Remove null values
      updateData.removeWhere((key, value) => value == null);

      // Call API to update parent
      final success = await _updateParentAPI(updateData);

      if (success) {
        setState(() {
          _isEditMode = false;
        });
        // Refresh parent data
        final provider = ref.read(RiverpodProvider.parentProvider.notifier);
        provider.getSingleParent(context, widget.parentId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Parent information updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating parent: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<bool> _updateParentAPI(Map<String, dynamic> updateData) async {
    try {
      final parentRepo = locator<ParentRepo>();
      final response = await parentRepo.updateParent(
        widget.parentId,
        updateData,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        return true;
      } else {
        print('Error updating parent: ${response.message}');
        return false;
      }
    } catch (e) {
      print('Exception updating parent: $e');
      return false;
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditMode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            widget.navigateTo();
          },
        ),
        title: Text(
          'Parent Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
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
                              // Edit/Save/Cancel buttons
                              if (_isEditMode) ...[
                                ElevatedButton.icon(
                                  onPressed: _saveParentData,
                                  icon: const Icon(Icons.save, size: 16),
                                  label: const Text('Save Changes'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
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
                                  onPressed: _cancelEdit,
                                  icon: const Icon(Icons.cancel, size: 16),
                                  label: const Text('Cancel'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: Colors.red,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                ),
                              ] else ...[
                                ElevatedButton.icon(
                                  onPressed: _toggleEditMode,
                                  icon: const Icon(Icons.edit, size: 16),
                                  label: const Text('Edit Parent'),
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
                                ElevatedButton.icon(
                                  onPressed: () {
                                    _showMessagePopup(context, 'Message');
                                    showSnackbar(context, 'Message sent');
                                  },
                                  icon: const Icon(Icons.send, size: 16),
                                  label: const Text('Send Message'),
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
                                  icon: const Icon(
                                    Icons.receipt_long,
                                    size: 16,
                                  ),
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
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),

                // Enhanced Tab Navigation
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      _buildTab('Parent Details', 0),
                      _buildTab('Children', 1),
                      _buildTab('Payments', 2),
                      _buildTab('Communications', 3),
                      _buildTab('Documents', 4),
                      _buildTab('Notes', 5),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Enhanced Tab Content Container
                Container(
                  constraints: const BoxConstraints(minHeight: 500),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 25,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: _buildTabContent(),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(
    IconData icon,
    String text, {
    Color? color,
    Color? iconColor,
  }) {
    return Row(
      children: [
        Icon(icon, size: 18, color: iconColor ?? Colors.grey[600]),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 15,
              color: color ?? Colors.grey[700],
              fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
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

  Widget _buildParentDetailsSection() {
    final parentData =
        ref.watch(RiverpodProvider.parentProvider).singleParent.data;

    if (parentData == null) {
      return Container(
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
        child: const Center(
          child: Text(
            'No parent data available',
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ),
      );
    }

    return Container(
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
            'Parent Details',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),

          // Personal Information
          _buildDetailSection('Personal Information', Icons.person, [
            _buildDetailRow(
              'Full Name',
              '${parentData.parent?.personalInfo?.firstName ?? ''} ${parentData.parent?.personalInfo?.lastName ?? ''}',
            ),
            _buildDetailRow('Title', parentData.parent?.personalInfo?.title),
            _buildDetailRow(
              'First Name',
              parentData.parent?.personalInfo?.firstName,
            ),
            _buildDetailRow(
              'Last Name',
              parentData.parent?.personalInfo?.lastName,
            ),
            _buildDetailRow(
              'Middle Name',
              parentData.parent?.personalInfo?.middleName,
            ),
            _buildDetailRow(
              'Date of Birth',
              parentData.parent?.personalInfo?.dateOfBirth?.toString(),
            ),
            _buildDetailRow('Gender', parentData.parent?.personalInfo?.gender),
            _buildDetailRow(
              'Marital Status',
              parentData.parent?.personalInfo?.maritalStatus,
            ),
          ]),

          const SizedBox(height: 24),

          // Contact Information
          _buildDetailSection('Contact Information', Icons.contact_phone, [
            _buildDetailRow(
              'Primary Phone',
              parentData.parent?.contactInfo?.primaryPhone,
            ),
            _buildDetailRow('Email', parentData.parent?.contactInfo?.email),
            _buildDetailRow(
              'Street Address',
              parentData.parent?.contactInfo?.address?.street,
            ),
            _buildDetailRow(
              'City',
              parentData.parent?.contactInfo?.address?.city,
            ),
            _buildDetailRow(
                'Locality',
              parentData.parent?.contactInfo?.address?.state,
            ),
            _buildDetailRow(
              'Country',
              parentData.parent?.contactInfo?.address?.country,
            ),
          ]),

          const SizedBox(height: 24),

          // Professional Information
          _buildDetailSection('Professional Information', Icons.work, [
            _buildDetailRow(
              'Occupation',
              parentData.parent?.professionalInfo?.occupation,
            ),
            _buildDetailRow(
              'Employer',
              parentData.parent?.professionalInfo?.employer,
            ),
            _buildDetailRow(
              'Annual Income',
              parentData.parent?.professionalInfo?.annualIncome?.toString(),
            ),
          ]),

          const SizedBox(height: 24),

          // Family Information
          _buildDetailSection('Family Information', Icons.family_restroom, [
            _buildDetailRow(
              'Number of Children',
              parentData.children?.length.toString(),
            ),
          ]),

          const SizedBox(height: 24),

          // Financial Information
          _buildDetailSection(
            'Financial Information',
            Icons.account_balance_wallet,
            [
              _buildDetailRow(
                'Total Fees',
                parentData.financialSummary?.totalFees?.toString(),
              ),
              _buildDetailRow(
                'Total Amount Paid',
                parentData.financialSummary?.totalAmountPaid?.toString(),
              ),
              _buildDetailRow(
                'Total Amount Owed',
                parentData.financialSummary?.totalAmountOwed?.toString(),
              ),
              _buildDetailRow(
                'Number of Children',
                parentData.financialSummary?.numberOfChildren?.toString(),
              ),
              _buildDetailRow(
                'Children with Outstanding Fees',
                parentData.financialSummary?.childrenWithOutstandingFees
                    ?.toString(),
              ),
              _buildDetailRow(
                'Payment Completion',
                '${parentData.financialSummary?.paymentCompletion?.toStringAsFixed(1)}%',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // System Information
          _buildDetailSection('System Information', Icons.info, [
            _buildDetailRow('Parent ID', parentData.parent?.id),
            _buildDetailRow(
              'Current Academic Year',
              parentData.currentTerm?.academicYear,
            ),
            _buildDetailRow('Current Term', parentData.currentTerm?.term),
          ]),

          const SizedBox(height: 24),

          // Children Information
          if (parentData.children != null && parentData.children!.isNotEmpty)
            _buildDetailSection(
              'Children Information',
              Icons.child_care,
              parentData.children!
                  .map((child) => _buildChildDetailRow(child))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildDetailSection(
    String title,
    IconData icon,
    List<Widget> children,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: Colors.blue[600]),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.blue[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 160,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value ?? 'Not specified',
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildDetailRow(dynamic child) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${child.student?.personalInfo?.firstName ?? ''} ${child.student?.personalInfo?.lastName ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
          const SizedBox(height: 4),
          _buildDetailRow('Student ID', child.student?.id),
          _buildDetailRow('Admission Number', child.student?.admissionNumber),
          _buildDetailRow(
            'Class',
            child.student?.academicInfo?.currentClass?.name,
          ),
          _buildDetailRow('Academic Year', child.currentTerm?.academicYear),
          _buildDetailRow('Term', child.currentTerm?.term),
          _buildDetailRow('Status', child.currentTerm?.status),
          _buildDetailRow(
            'Amount Owed',
            child.currentTerm?.amountOwed?.toString(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildParentDetailsContent();
      case 1:
        return _buildChildrenContent();
      case 2:
        return _buildPaymentHistoryContent();
      case 3:
        return _buildCommunicationContent();
      case 4:
        return _buildDocumentsContent();
      case 5:
        return _buildNotesContent();
      default:
        return _buildParentDetailsContent();
    }
  }

  Widget _buildParentDetailsContent() {
    final parentData =
        ref.watch(RiverpodProvider.parentProvider).singleParent.data;
    final parent = parentData?.parent;
    final financialSummary = parentData?.financialSummary;

    if (parent == null) {
      return const Center(
        child: Text(
          'No parent data available',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Personal Information Section
        _buildSectionHeader('Personal Information', Icons.person),
        const SizedBox(height: 20),
        _buildParentDetailsSection(),

        const SizedBox(height: 40),

        // Contact Information Section
        _buildSectionHeader('Contact Information', Icons.contact_phone),
        const SizedBox(height: 20),
        _buildContactInfoSection(parent),

        const SizedBox(height: 40),

        // Professional Information Section
        _buildSectionHeader('Professional Information', Icons.work),
        const SizedBox(height: 20),
        _buildProfessionalInfoSection(parent),

        const SizedBox(height: 40),

        // Financial Summary Section
        _buildSectionHeader('Financial Summary', Icons.account_balance_wallet),
        const SizedBox(height: 20),
        _buildFinancialSummarySection(financialSummary),

        const SizedBox(height: 40),

        // Identification Information Section
        _buildSectionHeader('Identification Information', Icons.badge),
        const SizedBox(height: 20),
        _buildIdentificationSection(parent),

        const SizedBox(height: 40),

        // Legal Information Section
        _buildSectionHeader('Legal Information', Icons.gavel),
        const SizedBox(height: 20),
        _buildLegalInfoSection(parent),

        const SizedBox(height: 40),

        // Computed Fields Section
        _buildSectionHeader('Account Information', Icons.info),
        const SizedBox(height: 20),
        _buildComputedFieldsSection(parent),

        const SizedBox(height: 40),

        // Metadata Section
        _buildSectionHeader('Additional Information', Icons.more_horiz),
        const SizedBox(height: 20),
        _buildMetadataSection(parent),
      ],
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.secondary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: AppColors.secondary, size: 24),
        ),
        const SizedBox(width: 16),
        Text(
          title,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  Widget _buildContactInfoSection(dynamic parent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditMode) ...[
                      _buildEditableTextField(
                        'Phone Number',
                        _phoneController,
                        Icons.phone,
                        TextInputType.phone,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableTextField(
                        'Email Address',
                        _emailController,
                        Icons.email,
                        TextInputType.emailAddress,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.phone,
                        parent.contactInfo?.primaryPhone ?? 'No phone',
                        iconColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.email,
                        parent.contactInfo?.email ?? 'No email',
                        iconColor: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditMode) ...[
                      _buildEditableTextField(
                        'Street Address',
                        _streetController,
                        Icons.location_on,
                        TextInputType.streetAddress,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _buildEditableTextField(
                              'City',
                              _cityController,
                              Icons.location_city,
                              TextInputType.text,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _buildEditableTextField(
                              'State',
                              _stateController,
                              Icons.map,
                              TextInputType.text,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildEditableTextField(
                        'Country',
                        _countryController,
                        Icons.public,
                        TextInputType.text,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.location_on,
                        '${parent.contactInfo?.address?.street ?? ''}, ${parent.contactInfo?.address?.city ?? ''}',
                        iconColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_city,
                        '${parent.contactInfo?.address?.state ?? ''}, ${parent.contactInfo?.address?.country ?? ''}',
                        iconColor: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEditableTextField(
    String label,
    TextEditingController controller,
    IconData icon,
    TextInputType keyboardType,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppColors.secondary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.secondary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProfessionalInfoSection(dynamic parent) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditMode) ...[
                      _buildEditableTextField(
                        'Occupation',
                        _occupationController,
                        Icons.work,
                        TextInputType.text,
                      ),
                      const SizedBox(height: 16),
                      _buildEditableTextField(
                        'Employer',
                        _employerController,
                        Icons.business,
                        TextInputType.text,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.work,
                        parent.professionalInfo?.occupation ?? 'Not specified',
                        iconColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.business,
                        parent.professionalInfo?.employer ?? 'Not specified',
                        iconColor: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_isEditMode) ...[
                      _buildEditableTextField(
                        'Annual Income',
                        _annualIncomeController,
                        Icons.attach_money,
                        TextInputType.number,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        'Work Address: ${parent.professionalInfo?.workAddress != null ? 'Available' : 'Not provided'}',
                        iconColor: AppColors.secondary,
                      ),
                    ] else ...[
                      _buildInfoRow(
                        Icons.attach_money,
                        'Annual Income: £${parent.professionalInfo?.annualIncome ?? 'Not specified'}',
                        iconColor: AppColors.secondary,
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(
                        Icons.location_on,
                        'Work Address: ${parent.professionalInfo?.workAddress != null ? 'Available' : 'Not provided'}',
                        iconColor: AppColors.secondary,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialSummarySection(dynamic financialSummary) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  'Total Fees',
                  '£${financialSummary?.totalFees ?? 0}',
                  Colors.blue,
                  Icons.receipt,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialCard(
                  'Total Paid',
                  '£${financialSummary?.totalAmountPaid ?? 0}',
                  Colors.green,
                  Icons.check_circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildFinancialCard(
                  'Total Owed',
                  '£${financialSummary?.totalAmountOwed ?? 0}',
                  Colors.red,
                  Icons.warning,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildFinancialCard(
                  'Payment Completion',
                  '${(financialSummary?.paymentCompletion ?? 0).toStringAsFixed(1)}%',
                  Colors.purple,
                  Icons.percent,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenContent() {
    final parentData =
        ref.watch(RiverpodProvider.parentProvider).singleParent.data;
    final children = parentData?.children ?? [];

    if (children.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.child_care_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'No Children Enrolled',
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'This parent has no children enrolled yet',
                    style: TextStyle(fontSize: 16, color: Colors.grey[500]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Children Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.child_care,
                    color: AppColors.secondary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Children Information',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    Text(
                      '${children.length} child${children.length == 1 ? '' : 'ren'} enrolled',
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // Children Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 1.2,
            crossAxisSpacing: 20,
            mainAxisSpacing: 20,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) {
            final child = children[index];
            final student = child.student;
            final currentTerm = child.currentTerm;

            return Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color:
                      currentTerm?.status == 'active'
                          ? Colors.green.withOpacity(0.3)
                          : Colors.grey.withOpacity(0.2),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Child Avatar and Status
                  Row(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(25),
                          image: const DecorationImage(
                            image: NetworkImage(
                              'https://images.unsplash.com/photo-1544005313-94ddf0286df2?w=100&h=100&fit=crop&crop=face',
                            ),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color:
                              currentTerm?.status == 'active'
                                  ? Colors.green.withOpacity(0.1)
                                  : Colors.orange.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentTerm?.status == 'active'
                              ? 'Active'
                              : 'Inactive',
                          style: TextStyle(
                            color:
                                currentTerm?.status == 'active'
                                    ? Colors.green[700]
                                    : Colors.orange[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Child Name
                  Text(
                    '${student?.personalInfo?.firstName ?? ''} ${student?.personalInfo?.lastName ?? ''}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 8),

                  // Class and Admission Number
                  Text(
                    '${student?.academicInfo?.currentClass?.name ?? 'No class'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const SizedBox(height: 4),

                  Text(
                    'Admission: ${student?.admissionNumber ?? 'N/A'}',
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),

                  const Spacer(),

                  // Action Button
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        // Navigate to child details
                      },
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.secondary,
                        side: BorderSide(color: AppColors.secondary),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('View', style: TextStyle(fontSize: 12)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
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
          '£625.00',
          'November 2024',
          'Paid',
          Colors.green,
          'Nov 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '£625.00',
          'October 2024',
          'Paid',
          Colors.green,
          'Oct 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '£625.00',
          'September 2024',
          'Overdue',
          Colors.red,
          'Sep 15, 2024',
          'Tuition Fee',
        ),
        const SizedBox(height: 12),
        _buildPaymentCard(
          '£125.00',
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
                '£1,250.00',
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
          'Friendly reminder about the outstanding balance of £625. Please contact us if you need...',
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

  // New section builder methods for enhanced parent data
  Widget _buildIdentificationSection(dynamic parent) {
    // Safe access to identification data
    final identification = parent.identification;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.badge, color: AppColors.secondary),
              const SizedBox(width: 12),
              const Text(
                'Identification Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isEditMode) ...[
            Row(
              children: [
                Expanded(
                  child: _buildEditableTextField(
                    'ID Type',
                    _idTypeController,
                    Icons.credit_card,
                    TextInputType.text,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildEditableTextField(
                    'ID Number',
                    _idNumberController,
                    Icons.numbers,
                    TextInputType.text,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (identification?.idPhotoUrl != null &&
                identification!.idPhotoUrl!.isNotEmpty)
              _buildInfoRow(
                Icons.photo,
                'ID Photo: Available',
                color: Colors.green,
              ),
          ] else ...[
            _buildInfoRow(
              Icons.credit_card,
              'ID Type: ${identification?.idType ?? 'N/A'}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.numbers,
              'ID Number: ${identification?.idNumber ?? 'N/A'}',
            ),
            const SizedBox(height: 12),
            if (identification?.idPhotoUrl != null &&
                identification!.idPhotoUrl!.isNotEmpty)
              _buildInfoRow(
                Icons.photo,
                'ID Photo: Available',
                color: Colors.green,
              ),
          ],
        ],
      ),
    );
  }

  Widget _buildLegalInfoSection(dynamic parent) {
    // Safe access to legal info data
    final legalInfo = parent.legalInfo;

    return Container(
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
          Row(
            children: [
              Icon(Icons.gavel, color: AppColors.secondary),
              const SizedBox(width: 12),
              const Text(
                'Legal Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          if (_isEditMode) ...[
            _buildEditableTextField(
              'Relationship to Child',
              _relationshipController,
              Icons.family_restroom,
              TextInputType.text,
            ),
            const SizedBox(height: 20),
            _buildCheckboxField(
              'Parental Responsibility',
              _parentalResponsibility,
              (value) => setState(() => _parentalResponsibility = value!),
            ),
            const SizedBox(height: 16),
            _buildCheckboxField(
              'Legal Guardianship',
              _legalGuardianship,
              (value) => setState(() => _legalGuardianship = value!),
            ),
            const SizedBox(height: 16),
            _buildCheckboxField(
              'Authorized to Collect Child',
              _authorisedToCollectChild,
              (value) => setState(() => _authorisedToCollectChild = value!),
            ),
          ] else ...[
            _buildInfoRow(
              Icons.family_restroom,
              'Relationship to Child: ${legalInfo?.relationshipToChild ?? 'N/A'}',
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.check_circle,
              'Parental Responsibility: ${legalInfo?.parentalResponsibility == true ? 'Yes' : 'No'}',
              color:
                  legalInfo?.parentalResponsibility == true
                      ? Colors.green
                      : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.shield,
              'Legal Guardianship: ${legalInfo?.legalGuardianship == true ? 'Yes' : 'No'}',
              color:
                  legalInfo?.legalGuardianship == true
                      ? Colors.green
                      : Colors.red,
            ),
            const SizedBox(height: 12),
            _buildInfoRow(
              Icons.person_pin,
              'Authorized to Collect Child: ${legalInfo?.authorisedToCollectChild == true ? 'Yes' : 'No'}',
              color:
                  legalInfo?.authorisedToCollectChild == true
                      ? Colors.green
                      : Colors.red,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCheckboxField(
    String label,
    bool value,
    ValueChanged<bool?> onChanged,
  ) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.secondary,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildComputedFieldsSection(dynamic parent) {
    // Safe access to computed fields data
    final computedFields = parent.computedFields;

    return Container(
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
          Row(
            children: [
              Icon(Icons.analytics, color: AppColors.secondary),
              const SizedBox(width: 12),
              const Text(
                'Computed Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.person,
            'Full Name: ${computedFields?.fullName ?? parent.fullName ?? 'N/A'}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.family_restroom,
            'Parent Type: ${computedFields?.parentTypeDisplay ?? parent.parentTypeDisplay ?? 'N/A'}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.child_care,
            'Children Count: ${computedFields?.childrenCount ?? parent.children?.length ?? 0}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.group,
            'Has Multiple Children: ${computedFields?.hasMultipleChildren == true ? 'Yes' : 'No'}',
            color:
                computedFields?.hasMultipleChildren == true
                    ? Colors.orange
                    : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.check_circle,
            'Account Status: ${computedFields?.isActive == true ? 'Active' : 'Inactive'}',
            color: computedFields?.isActive == true ? Colors.green : Colors.red,
          ),
          const SizedBox(height: 12),
          if (computedFields?.createdAtFormatted != null)
            _buildInfoRow(
              Icons.calendar_today,
              'Created: ${computedFields!.createdAtFormatted}',
            ),
          const SizedBox(height: 12),
          if (computedFields?.updatedAtFormatted != null)
            _buildInfoRow(
              Icons.update,
              'Last Updated: ${computedFields!.updatedAtFormatted}',
            ),
        ],
      ),
    );
  }

  Widget _buildMetadataSection(dynamic parent) {
    // Safe access to metadata and preferences data
    final metadata = parent.metadata;
    final preferences = parent.preferences;

    return Container(
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
          Row(
            children: [
              Icon(Icons.info, color: AppColors.secondary),
              const SizedBox(width: 12),
              const Text(
                'Additional Information',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildInfoRow(
            Icons.child_care,
            'Total Children: ${metadata?.totalChildren ?? parent.children?.length ?? 0}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.emergency,
            'Has Emergency Contacts: ${metadata?.hasEmergencyContacts == true ? 'Yes' : 'No'}',
            color:
                metadata?.hasEmergencyContacts == true
                    ? Colors.green
                    : Colors.red,
          ),
          const SizedBox(height: 12),
          if (metadata?.emergencyContactsCount != null)
            _buildInfoRow(
              Icons.contacts,
              'Emergency Contacts Count: ${metadata!.emergencyContactsCount}',
            ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.work,
            'Has Work Address: ${metadata?.hasWorkAddress?.isNotEmpty == true ? 'Yes' : 'No'}',
            color:
                metadata?.hasWorkAddress?.isNotEmpty == true
                    ? Colors.green
                    : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.photo_camera,
            'Has ID Photo: ${metadata?.hasIdPhoto?.isNotEmpty == true ? 'Yes' : 'No'}',
            color:
                metadata?.hasIdPhoto?.isNotEmpty == true
                    ? Colors.green
                    : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.contact_phone,
            'Preferred Contact: ${metadata?.preferredContactMethod ?? preferences?.preferredContactMethod ?? 'N/A'}',
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.email,
            'Receives Newsletters: ${metadata?.receivesNewsletters == true ? 'Yes' : 'No'}',
            color:
                metadata?.receivesNewsletters == true
                    ? Colors.green
                    : Colors.grey,
          ),
          const SizedBox(height: 12),
          _buildInfoRow(
            Icons.event,
            'Receives Event Notifications: ${metadata?.receivesEventNotifications == true ? 'Yes' : 'No'}',
            color:
                metadata?.receivesEventNotifications == true
                    ? Colors.green
                    : Colors.grey,
          ),
        ],
      ),
    );
  }
}
