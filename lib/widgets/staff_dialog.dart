import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class StaffDialog extends StatefulWidget {
  final Map<String, dynamic>? staffData;
  final bool isEditMode;

  const StaffDialog({Key? key, this.staffData, this.isEditMode = false})
    : super(key: key);

  @override
  State<StaffDialog> createState() => _StaffDialogState();
}

class _StaffDialogState extends State<StaffDialog>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  late TabController _tabController;
  bool _isEditing = false;

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _addressController = TextEditingController();
  final _qualificationsController = TextEditingController();

  // Dropdown values
  String? selectedGender;
  String? selectedRole;
  String? selectedMaritalStatus;
  DateTime? dateOfBirth;
  DateTime? dateOfJoining;

  // Dropdown options
  final List<String> genderOptions = ['Male', 'Female', 'Other'];
  final List<String> roleOptions = [
    'Principal',
    'Vice Principal',
    'Head Teacher',
    'Senior Teacher',
    'Teacher',
    'Assistant Teacher',
    'Administrator',
    'Librarian',
    'Lab Assistant',
    'Sports Teacher',
    'Counselor',
    'Security',
    'Cleaner',
    'Driver',
  ];
  final List<String> maritalStatusOptions = [
    'Single',
    'Married',
    'Divorced',
    'Widowed',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _isEditing = widget.isEditMode;
    _loadStaffData();
  }

  void _loadStaffData() {
    if (widget.staffData != null) {
      final data = widget.staffData!;
      _nameController.text = data['name'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _emailController.text = data['email'] ?? '';
      _addressController.text = data['address'] ?? '';
      _qualificationsController.text = data['qualifications'] ?? '';
      selectedGender = data['gender'];
      selectedRole = data['role'];
      selectedMaritalStatus = data['maritalStatus'];
      dateOfBirth = data['dateOfBirth'];
      dateOfJoining = data['dateOfJoining'];
    } else {
      // Load dummy data for demonstration
      _loadDummyData();
    }
  }

  void _loadDummyData() {
    _nameController.text = 'Dr. Sarah Johnson';
    _phoneController.text = '08123456789';
    _emailController.text = 'sarah.johnson@school.edu';
    _addressController.text =
        '15 Victoria Street, GRA Phase 2, Port Harcourt, Rivers State, Nigeria';
    _qualificationsController.text =
        'Ph.D in Mathematics Education - University of Lagos (2018)\nM.Sc in Mathematics - University of Ibadan (2014)\nB.Sc in Mathematics - Obafemi Awolowo University (2012)\nTeaching Certificate - National Teachers Institute (2013)\nCertified Mathematics Teacher - TRCN (2014)';
    selectedGender = 'Female';
    selectedRole = 'Senior Teacher';
    selectedMaritalStatus = 'Married';
    dateOfBirth = DateTime(1988, 5, 15);
    dateOfJoining = DateTime(2019, 9, 1);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _addressController.dispose();
    _qualificationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(color: Colors.white,
        width: MediaQuery.of(context).size.width * 0.95,
        height: MediaQuery.of(context).size.height * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 800),
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildPersonalInfoTab(),
                  _buildProfessionalInfoTab(),
                ],
              ),
            ),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue.shade600,
            child: Icon(Icons.person, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.staffData != null
                      ? 'Staff Information'
                      : 'Staff',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  _isEditing ? 'Edit staff details' : 'View staff information',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          if (widget.staffData != null && !_isEditing)
            IconButton(
              onPressed: () => setState(() => _isEditing = true),
              icon: const Icon(Icons.edit),
              style: IconButton.styleFrom(
                backgroundColor: Colors.blue.shade100,
                foregroundColor: Colors.blue.shade700,
              ),
            ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close),
            style: IconButton.styleFrom(
              backgroundColor: Colors.grey.shade100,
              foregroundColor: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.grey.shade50,
      child: TabBar(
        controller: _tabController,
        labelColor: Colors.blue.shade700,
        unselectedLabelColor: Colors.grey.shade600,
        indicatorColor: Colors.blue.shade600,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.person_outline), text: 'Personal Info'),
          Tab(icon: Icon(Icons.work_outline), text: 'Professional Info'),
        ],
      ),
    );
  }

  Widget _buildPersonalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Basic Information'),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _nameController,
              label: 'Full Name',
              icon: Icons.person,
              enabled: _isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Please enter full name';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDropdownField(
                    label: 'Gender',
                    value: selectedGender,
                    items: genderOptions,
                    icon: Icons.wc,
                    enabled: _isEditing,
                    onChanged:
                        (value) => setState(() => selectedGender = value),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDateField(
                    label: 'Date of Birth',
                    value: dateOfBirth,
                    icon: Icons.cake,
                    enabled: _isEditing,
                    onTap: () => _selectDate(context, true),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Marital Status',
              value: selectedMaritalStatus,
              items: maritalStatusOptions,
              icon: Icons.favorite,
              enabled: _isEditing,
              onChanged:
                  (value) => setState(() => selectedMaritalStatus = value),
            ),
            const SizedBox(height: 24),
            _buildSectionTitle('Contact Information'),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _phoneController,
              label: 'Phone Number',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
              enabled: _isEditing,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Please enter phone number';
                }
                if (_isEditing && value!.length < 10) {
                  return 'Enter valid phone number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _emailController,
              label: 'Email Address',
              icon: Icons.email,
              keyboardType: TextInputType.emailAddress,
              enabled: _isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Please enter email address';
                }
                if (_isEditing &&
                    !RegExp(
                      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                    ).hasMatch(value!)) {
                  return 'Enter valid email address';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildTextFormField(
              controller: _addressController,
              label: 'Address',
              icon: Icons.home,
              maxLines: 3,
              enabled: _isEditing,
              validator: (value) {
                if (_isEditing && (value == null || value.isEmpty)) {
                  return 'Please enter address';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfessionalInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Job Information'),
          const SizedBox(height: 16),
          _buildDropdownField(
            label: 'Role/Position',
            value: selectedRole,
            items: roleOptions,
            icon: Icons.work,
            enabled: _isEditing,
            onChanged: (value) => setState(() => selectedRole = value),
          ),
          const SizedBox(height: 16),
          _buildDateField(
            label: 'Date of Joining',
            value: dateOfJoining,
            icon: Icons.calendar_today,
            enabled: _isEditing,
            onTap: () => _selectDate(context, false),
          ),
          const SizedBox(height: 24),
          _buildSectionTitle('Academic Information'),
          const SizedBox(height: 16),
          _buildTextFormField(
            controller: _qualificationsController,
            label: 'Academic Qualifications',
            icon: Icons.school,
            maxLines: 4,
            enabled: _isEditing,
            hintText: 'Enter qualifications, degrees, certifications etc.',
            validator: (value) {
              if (_isEditing && (value == null || value.isEmpty)) {
                return 'Please enter academic qualifications';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          if (!_isEditing) _buildInfoCard(),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Staff Summary',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildSummaryRow('Years of Service', _calculateYearsOfService()),
          _buildSummaryRow('Department', selectedRole ?? 'Not specified'),
          _buildSummaryRow('Status', 'Active'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _calculateYearsOfService() {
    if (dateOfJoining == null) return 'Not specified';
    final now = DateTime.now();
    final difference = now.difference(dateOfJoining!);
    final years = (difference.inDays / 365).floor();
    final months = ((difference.inDays % 365) / 30).floor();
    return years > 0 ? '$years years, $months months' : '$months months';
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  Widget _buildTextFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool enabled = true,
    List<TextInputFormatter>? inputFormatters,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          enabled: enabled,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            hintText: hintText ?? 'Enter $label',
            hintStyle: TextStyle(color: Colors.grey.shade600),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(
              icon,
              color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
              size: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.blue.shade400, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            filled: true,
            fillColor: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          hint: Text(
            'Select $label',
            style: TextStyle(color: Colors.grey.shade600),
          ),
          items:
              enabled
                  ? items.map((String item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList()
                  : [],
          onChanged: enabled ? onChanged : null,
          validator: (value) {
            if (enabled && _isEditing && (value == null || value.isEmpty)) {
              return 'Please select $label';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? value,
    required IconData icon,
    required VoidCallback onTap,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: enabled ? onTap : null,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(12),
              color: enabled ? Colors.grey.shade50 : Colors.grey.shade100,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  color: enabled ? Colors.grey.shade600 : Colors.grey.shade400,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    value != null
                        ? '${value!.day}/${value!.month}/${value!.year}'
                        : 'Select $label',
                    style: TextStyle(
                      color:
                          value != null
                              ? Colors.grey.shade800
                              : Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ),
                if (enabled)
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey.shade400,
                    size: 16,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        children: [
          if (_isEditing) ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () {
                  if (widget.staffData != null) {
                    setState(() => _isEditing = false);
                    _loadStaffData(); // Reset data
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Cancel',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: ElevatedButton(
                onPressed: _saveStaffData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade600,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.save, size: 20),
                    SizedBox(width: 8),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.grey.shade300),
                ),
                child: const Text(
                  'Close',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, bool isDateOfBirth) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate:
          isDateOfBirth
              ? (dateOfBirth ?? DateTime(1990))
              : (dateOfJoining ?? DateTime.now()),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Colors.blue.shade600,
              onPrimary: Colors.white,
              surface: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isDateOfBirth) {
          dateOfBirth = picked;
        } else {
          dateOfJoining = picked;
        }
      });
    }
  }

  void _saveStaffData() {
    if (_formKey.currentState!.validate()) {
      final staffData = {
        'name': _nameController.text,
        'phone': _phoneController.text,
        'email': _emailController.text,
        'address': _addressController.text,
        'gender': selectedGender,
        'dateOfBirth': dateOfBirth,
        'role': selectedRole,
        'maritalStatus': selectedMaritalStatus,
        'dateOfJoining': dateOfJoining,
        'qualifications': _qualificationsController.text,
        'lastModified': DateTime.now(),
      };

      // TODO: Save to database or state management
      print('Staff Data: $staffData');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Staff information saved successfully!'),
            ],
          ),
          backgroundColor: Colors.green.shade600,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      if (widget.staffData == null) {
        Navigator.of(context).pop(staffData);
      } else {
        setState(() => _isEditing = false);
      }
    }
  }
}

// Usage examples with dummy data:
void showAddStaffDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return const StaffDialog(isEditMode: true);
    },
  );
}

void showViewStaffDialog(
  BuildContext context, [
  Map<String, dynamic>? staffData,
]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StaffDialog(staffData: staffData ?? _getSampleStaffData());
    },
  );
}

void showEditStaffDialog(
  BuildContext context, [
  Map<String, dynamic>? staffData,
]) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return StaffDialog(
        staffData: staffData ?? _getSampleStaffData(),
        isEditMode: true,
      );
    },
  );
}

// Sample staff data for demonstration
Map<String, dynamic> _getSampleStaffData() {
  return {
    'name': 'Prof. Michael Adebayo',
    'phone': '08098765432',
    'email': 'michael.adebayo@school.edu.ng',
    'address': '42 Independence Layout, Enugu East, Enugu State, Nigeria',
    'gender': 'Male',
    'dateOfBirth': DateTime(1975, 8, 22),
    'role': 'Principal',
    'maritalStatus': 'Married',
    'dateOfJoining': DateTime(2015, 1, 5),
    'qualifications':
        'Ph.D in Educational Administration - University of Nigeria, Nsukka (2010)\nM.Ed in Educational Management - Ahmadu Bello University (2005)\nB.Ed in English Language - University of Ilorin (2001)\nNigerian Certificate in Education - Federal College of Education, Zaria (1999)\nFellow, Nigerian Academy of Education (FNAE) - 2020',
  };
}

// Additional sample staff data for testing
List<Map<String, dynamic>> getSampleStaffList() {
  return [
    {
      'name': 'Mrs. Funmi Okafor',
      'phone': '08076543210',
      'email': 'funmi.okafor@school.edu.ng',
      'address': '23 Ahmadu Bello Way, Kaduna North, Kaduna State, Nigeria',
      'gender': 'Female',
      'dateOfBirth': DateTime(1982, 3, 10),
      'role': 'Vice Principal',
      'maritalStatus': 'Married',
      'dateOfJoining': DateTime(2017, 3, 15),
      'qualifications':
          'M.Ed in Curriculum Studies - University of Jos (2012)\nB.Sc in Biology - Bayero University, Kano (2008)\nNigerian Certificate in Education - Federal College of Education, Kano (2006)',
    },
    {
      'name': 'Mr. Chinedu Eze',
      'phone': '08054321098',
      'email': 'chinedu.eze@school.edu.ng',
      'address': '18 New Haven Extension, Enugu South, Enugu State, Nigeria',
      'gender': 'Male',
      'dateOfBirth': DateTime(1990, 11, 5),
      'role': 'Teacher',
      'maritalStatus': 'Single',
      'dateOfJoining': DateTime(2020, 9, 7),
      'qualifications':
          'B.Sc in Computer Science - University of Nigeria, Nsukka (2015)\nProfessional Diploma in Education - National Open University (2018)\nCertified ICT Teacher - 2019',
    },
    {
      'name': 'Dr. Amina Hassan',
      'phone': '08087654321',
      'email': 'amina.hassan@school.edu.ng',
      'address': '67 Maitama District, Abuja, FCT, Nigeria',
      'gender': 'Female',
      'dateOfBirth': DateTime(1979, 1, 28),
      'role': 'Head Teacher',
      'maritalStatus': 'Divorced',
      'dateOfJoining': DateTime(2016, 8, 20),
      'qualifications':
          'Ph.D in Physics Education - Ahmadu Bello University (2014)\nM.Sc in Physics - University of Abuja (2009)\nB.Sc in Physics - Usmanu Danfodiyo University (2005)\nNigerian Certificate in Education - Federal College of Education, Zaria (2003)',
    },
    {
      'name': 'Mr. Ibrahim Yusuf',
      'phone': '08065432109',
      'email': 'ibrahim.yusuf@school.edu.ng',
      'address': '12 Sabon Gari, Zaria, Kaduna State, Nigeria',
      'gender': 'Male',
      'dateOfBirth': DateTime(1985, 12, 3),
      'role': 'Sports Teacher',
      'maritalStatus': 'Married',
      'dateOfJoining': DateTime(2018, 4, 10),
      'qualifications':
          'B.Sc in Human Kinetics - University of Ilorin (2011)\nDiploma in Sports Management - National Institute of Sports (2013)\nCertified Athletic Coach - 2014',
    },
  ];
}
