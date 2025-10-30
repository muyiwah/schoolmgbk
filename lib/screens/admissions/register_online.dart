import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/models/admission_model.dart';
import 'package:schmgtsystem/providers/admission_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:schmgtsystem/utils/academic_year_helper.dart';

class StudentAdmissionForm extends ConsumerStatefulWidget {
  @override
  ConsumerState<StudentAdmissionForm> createState() =>
      _StudentAdmissionFormState();
}

class _StudentAdmissionFormState extends ConsumerState<StudentAdmissionForm> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  // Image upload variables
  XFile? _selectedImageFile;
  String? _imageUrl;
  final ImagePicker _imagePicker = ImagePicker();

  // Form controllers
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _dateController = TextEditingController();
  final _previousSchoolController = TextEditingController();

  // Guardian/Parent controllers
  final _guardianNameController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianOccupationController = TextEditingController();
  final _guardianAddressController = TextEditingController();

  // Academic controllers
  final _selectedClassController = TextEditingController();
  final _academicYearController = TextEditingController();
  final _admissionDateController = TextEditingController();

  // Selected values
  String _selectedGender = '';
  String _admissionNumber = 'ADM-2025-001'; // Will be updated in initState
  String? _selectedClassId;
  DateTime? _selectedDOB;
  DateTime? _selectedAdmissionDate;

  // Class data
  List<Map<String, dynamic>> _classes = [];
  bool _isLoadingClasses = false;

  @override
  void initState() {
    super.initState();
    _academicYearController.text = AcademicYearHelper.getCurrentAcademicYear(
      ref,
    );
    _generateAdmissionNumber();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      final classProvider = ref.read(RiverpodProvider.classProvider);
      await classProvider.getAllClassesWithMetric(context);

      if (classProvider.classData.classes != null) {
        setState(() {
          _classes =
              classProvider.classData.classes!
                  .map(
                    (classItem) => {
                      'id': classItem.id,
                      'name': classItem.name,
                      'level': classItem.level,
                      'section': classItem.section,
                    },
                  )
                  .toList();
        });
      }
    } catch (e) {
      showSnackbar(context, 'Failed to load classes: $e');
    } finally {
      setState(() {
        _isLoadingClasses = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _previousSchoolController.dispose();
    _guardianNameController.dispose();
    _guardianPhoneController.dispose();
    _guardianEmailController.dispose();
    _guardianOccupationController.dispose();
    _guardianAddressController.dispose();
    _selectedClassController.dispose();
    _academicYearController.dispose();
    _admissionDateController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _generateAdmissionNumber() {
    setState(() {
      _admissionNumber = AcademicYearHelper.generateAdmissionNumber(ref);
    });
  }

  void _nextStep() {
    if (_currentStep < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.ease,
      );
    }
  }

  void _goToStep(int step) {
    _pageController.animateToPage(
      step,
      duration: const Duration(milliseconds: 300),
      curve: Curves.ease,
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Student Info
        if (_firstNameController.text.isEmpty ||
            _lastNameController.text.isEmpty ||
            _selectedGender.isEmpty ||
            _selectedDOB == null) {
          showSnackbar(context, 'Please fill in all required fields');
          return false;
        }
        break;
      case 1: // Guardian Info
        if (_guardianNameController.text.isEmpty ||
            _guardianPhoneController.text.isEmpty) {
          showSnackbar(
            context,
            'Please fill in guardian name and phone number',
          );
          return false;
        }
        break;
      case 2: // Class Placement
        if (_selectedClassId == null || _selectedAdmissionDate == null) {
          showSnackbar(context, 'Please select class and admission date');
          return false;
        }
        break;
      case 3: // Documents
        // Documents are optional, so always valid
        break;
    }
    return true;
  }

  Future<void> _loadData() async {
    final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
    await Future.wait([
      admissionProvider.getAllAdmissionIntents(context),
      admissionProvider.getAdmissionStatistics(context),
    ]);
  }

  void _saveDraft() {
    // Here you would save form data to local storage or backend
    // For now, just show a success message
    showSnackbar(context, 'Draft saved successfully!');
  }

  void _submitForm() async {
    if (!_validateCurrentStep()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare submission data
      final personalInfo = PersonalInfo(
        firstName: _firstNameController.text.trim(),
        middleName:
            _middleNameController.text.trim().isEmpty
                ? null
                : _middleNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        dateOfBirth: _selectedDOB!,
        gender: _selectedGender.toLowerCase(),
        profileImage: _imageUrl,
        previousSchool:
            _previousSchoolController.text.trim().isEmpty
                ? null
                : _previousSchoolController.text.trim(),
      );

      final parentInfo = ParentInfo(
        legacy: Legacy(
          name: _guardianNameController.text.trim(),
          phone: _guardianPhoneController.text.trim(),
          email: _guardianEmailController.text.trim(),
          occupation: _guardianOccupationController.text.trim(),
          address: _guardianAddressController.text.trim(),
        ),
      );

      final academicInfo = AcademicInfo(
        desiredClass: _selectedClassController.text,
        academicYear: _academicYearController.text.trim(),
      );

      final contactInfo = ContactInfo(
        address: Address(
          streetName: _guardianAddressController.text.trim(),
          city: '',
          state: '',
          country: '',
        ),
        phone: _guardianPhoneController.text.trim(),
        email: _guardianEmailController.text.trim(),
      );

      final submission = AdmissionSubmissionModel(
        personalInfo: personalInfo,
        contactInfo: contactInfo,
        parentInfo: parentInfo,
        academicInfo: academicInfo,
        additionalInfo: null,
      );

      // Submit to backend
      final admissionProvider = ref.read(RiverpodProvider.admissionProvider);
      final success = await admissionProvider.submitAdmissionIntent(
        context,
        submission,
      );
      _loadData();
      if (success) {
        showSnackbar(context, 'Student admission submitted successfully!');
        context.go('/admissions'); // Navigate back to admissions list
      } else {
        showSnackbar(context, 'Failed to submit admission. Please try again.');
      }
    } catch (e) {
      showSnackbar(context, 'Error submitting form: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      showSnackbar(context, 'Error picking image: $e');
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImageFile = image;
        });
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      showSnackbar(context, 'Error taking photo: $e');
    }
  }

  void _showImagePickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImage();
                },
              ),
              if (!kIsWeb)
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takePhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      final compressedImageBytes = await _compressImage(_selectedImageFile!);
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
        });
        showSnackbar(context, 'Image uploaded successfully!');
      }
    } catch (e) {
      showSnackbar(context, 'Error uploading image: $e');
    } finally {
      setState(() {
        _isUploadingImage = false;
      });
    }
  }

  Future<Uint8List> _compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) throw Exception('Could not decode image');

      final resizedImage = img.copyResize(image, width: 400, height: 400);
      final compressedBytes = img.encodeJpg(resizedImage, quality: 90);

      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
    }
  }

  Future<String?> _robustCloudinaryUpload(Uint8List imageBytes) async {
    try {
      final base64Image = base64Encode(imageBytes);

      final response = await http.post(
        Uri.parse('https://api.cloudinary.com/v1_1/demo/image/upload'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'file': 'data:image/jpeg;base64,$base64Image',
          'upload_preset': 'ml_default',
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['secure_url'];
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
    }
    return null;
  }

  Future<void> _selectDate(BuildContext context, bool isAdmissionDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isAdmissionDate ? DateTime.now() : DateTime(2010),
      firstDate: isAdmissionDate ? DateTime(2020) : DateTime(1990),
      lastDate: isAdmissionDate ? DateTime(2030) : DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (isAdmissionDate) {
          _selectedAdmissionDate = picked;
          _admissionDateController.text =
              '${picked.day}/${picked.month}/${picked.year}';
        } else {
          _selectedDOB = picked;
          _dateController.text = '${picked.day}/${picked.month}/${picked.year}';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFF4285F4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.school, color: Colors.white, size: 20),
        ),
        title: Row(
          children: [
            Icon(Icons.home, color: Colors.grey[600], size: 20),
            const SizedBox(width: 8),
            const Text(
              'New Student Admission',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => context.go('/admissions'),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Steps
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              children: [
                _buildStep(
                  0,
                  'Student Info',
                  'Basic details',
                  _currentStep >= 0,
                ),
                Expanded(child: _buildStepConnector(_currentStep > 0)),
                _buildStep(
                  1,
                  'Guardian Info',
                  'Contact details',
                  _currentStep >= 1,
                ),
                Expanded(child: _buildStepConnector(_currentStep > 1)),
                _buildStep(
                  2,
                  'Class Placement',
                  'Academic info',
                  _currentStep >= 2,
                ),
                Expanded(child: _buildStepConnector(_currentStep > 2)),
                _buildStep(
                  3,
                  'Documents',
                  'Upload & confirm',
                  _currentStep >= 3,
                ),
              ],
            ),
          ),

          // Progress Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 4,
                    backgroundColor: Colors.grey[300],
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF4285F4),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  'Step ${_currentStep + 1} of 4',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF4285F4),
                  ),
                ),
              ],
            ),
          ),

          // Form Content
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildStudentInfoStep(),
                _buildGuardianInfoStep(),
                _buildClassPlacementStep(),
                _buildDocumentsStep(),
              ],
            ),
          ),

          // Bottom Navigation
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                if (_currentStep > 0)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _previousStep,
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Previous'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.grey[600],
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                // if (_currentStep > 0) const SizedBox(width: 16),
                // Expanded(
                //   child: TextButton.icon(
                //     onPressed: _saveDraft,
                //     icon: const Icon(Icons.save, size: 18),
                //     label: const Text('Save Draft'),
                //     style: TextButton.styleFrom(
                //       foregroundColor: Colors.grey[600],
                //       padding: const EdgeInsets.symmetric(
                //         horizontal: 16,
                //         vertical: 12,
                //       ),
                //     ),
                //   ),
                // ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed:
                        _isLoading
                            ? null
                            : (_currentStep == 3 ? _submitForm : _nextStep),
                    label: Text(_currentStep == 3 ? 'Submit' : 'Next'),
                    icon:
                        _isLoading
                            ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                            : Icon(
                              _currentStep == 3
                                  ? Icons.check
                                  : Icons.arrow_forward,
                              size: 18,
                            ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF4285F4),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(int number, String title, String subtitle, bool isActive) {
    return GestureDetector(
      onTap: () => _goToStep(number),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: isActive ? const Color(0xFF4285F4) : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                '${number + 1}',
                style: TextStyle(
                  color: isActive ? Colors.white : Colors.grey[600],
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: isActive ? Colors.black87 : Colors.grey[600],
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(fontSize: 10, color: Colors.grey[500]),
          ),
        ],
      ),
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      height: 2,
      margin: const EdgeInsets.only(bottom: 40),
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF4285F4) : Colors.grey[300],
      ),
    );
  }

  Widget _buildStudentInfoStep() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Student Information',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please provide the basic details about the student',
                style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
              const SizedBox(height: 32),

              // Photo Upload Section
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPhotoUpload(),
                  const SizedBox(width: 24),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Student Profile Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a clear photo of the student (passport size preferred)',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed:
                              _isUploadingImage ? null : _showImagePickerDialog,
                          icon:
                              _isUploadingImage
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.upload_file, size: 18),
                          label: Text(
                            _isUploadingImage ? 'Uploading...' : 'Choose File',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4285F4),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(6),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Name Fields
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      'First Name',
                      'Enter first name',
                      _firstNameController,
                      required: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Middle Name',
                      'Enter middle name',
                      _middleNameController,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildTextField(
                      'Last Name',
                      'Enter last name',
                      _lastNameController,
                      required: true,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Date and Gender Row
              Row(
                children: [
                  Expanded(child: _buildDateField()),
                  const SizedBox(width: 32),
                  Expanded(child: _buildGenderField()),
                ],
              ),

              const SizedBox(height: 24),

              // Admission Number
              // _buildAdmissionNumberField(),

              // const SizedBox(height: 24),

              // Previous School
              _buildTextField(
                'Previous School',
                'Enter previous school name',
                _previousSchoolController,
                optional: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGuardianInfoStep() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
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
              'Guardian Information',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide the guardian/parent contact details',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildTextField(
              'Guardian Name',
              'Enter full name',
              _guardianNameController,
              required: true,
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _buildTextField(
                    'Phone Number',
                    'Enter phone number',
                    _guardianPhoneController,
                    required: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildTextField(
                    'Email Address',
                    'Enter email address',
                    _guardianEmailController,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            _buildTextField(
              'Occupation',
              'Enter occupation',
              _guardianOccupationController,
            ),

            const SizedBox(height: 24),

            _buildTextField(
              'Address',
              'Enter full address',
              _guardianAddressController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassPlacementStep() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
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
              'Class Placement',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the class and admission details',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildClassDropdown(),

            const SizedBox(height: 24),

            _buildTextField(
              'Academic Year',
              'Academic year',
              _academicYearController,
              readOnly: true,
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentsStep() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(32),
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
              'Documents & Confirmation',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Review all information before submitting',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            _buildSummaryCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoUpload() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
      ),
      child:
          _imageUrl != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  _imageUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.grey,
                    );
                  },
                ),
              )
              : _selectedImageFile != null
              ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child:
                    kIsWeb
                        ? Image.network(
                          _selectedImageFile!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        )
                        : Image.network(
                          _selectedImageFile!.path,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.person,
                              size: 40,
                              color: Colors.grey,
                            );
                          },
                        ),
              )
              : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt_outlined,
                    size: 32,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload Photo',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'JPG, PNG',
                    style: TextStyle(fontSize: 10, color: Colors.grey[500]),
                  ),
                ],
              ),
    );
  }

  Widget _buildTextField(
    String label,
    String hint,
    TextEditingController controller, {
    bool required = false,
    bool optional = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (required)
              const Text(
                ' *',
                style: TextStyle(color: Colors.red, fontSize: 14),
              ),
            if (optional)
              Text(
                ' (Optional)',
                style: TextStyle(color: Colors.grey[500], fontSize: 12),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Date of Birth',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _dateController,
          readOnly: true,
          onTap: () => _selectDate(context, false),
          decoration: InputDecoration(
            hintText: 'mm/dd/yyyy',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            suffixIcon: Icon(
              Icons.calendar_today,
              color: Colors.grey[500],
              size: 18,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Age will be calculated automatically',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildGenderField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Gender',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _buildRadioOption('Male'),
            const SizedBox(width: 24),
            _buildRadioOption('Female'),
          ],
        ),
      ],
    );
  }

  Widget _buildRadioOption(String value) {
    return Row(
      children: [
        Radio<String>(
          value: value,
          groupValue: _selectedGender,
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue!;
            });
          },
          activeColor: const Color(0xFF4285F4),
        ),
        Text(
          value,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ],
    );
  }

  Widget _buildAdmissionNumberField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Admission Number',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  _admissionNumber,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Auto-generated admission number',
          style: TextStyle(fontSize: 11, color: Colors.grey[500]),
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Text(
              'Desired Class',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            Text(' *', style: TextStyle(color: Colors.red, fontSize: 14)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedClassId,
          decoration: InputDecoration(
            hintText: _isLoadingClasses ? 'Loading classes...' : 'Select class',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(6),
              borderSide: const BorderSide(color: Color(0xFF4285F4)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          items:
              _classes.map((classItem) {
                return DropdownMenuItem<String>(
                  value: classItem['id'],
                  child: Text('${classItem['name']} (${classItem['level']})'),
                );
              }).toList(),
          onChanged:
              _isLoadingClasses
                  ? null
                  : (String? newValue) {
                    setState(() {
                      _selectedClassId = newValue;
                    });
                  },
        ),
        if (_isLoadingClasses)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 8),
                Text(
                  'Loading classes...',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildSummaryCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Admission Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildSummaryRow(
            'Student Name',
            '${_firstNameController.text} ${_lastNameController.text}',
          ),
          _buildSummaryRow('Gender', _selectedGender),
          _buildSummaryRow('Date of Birth', _dateController.text),
          _buildSummaryRow('Admission Number', _admissionNumber),
          _buildSummaryRow('Guardian Name', _guardianNameController.text),
          _buildSummaryRow('Guardian Phone', _guardianPhoneController.text),
          _buildSummaryRow('Class', _getSelectedClassName()),
          _buildSummaryRow('Admission Date', _admissionDateController.text),
          if (_imageUrl != null) _buildSummaryRow('Profile Photo', 'Uploaded'),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not provided' : value,
              style: const TextStyle(fontSize: 14, color: Colors.black87),
            ),
          ),
        ],
      ),
    );
  }

  String _getSelectedClassName() {
    if (_selectedClassId == null) return 'Not selected';

    try {
      final selectedClass = _classes.firstWhere(
        (classItem) => classItem['id'] == _selectedClassId,
      );
      return selectedClass['name'] ?? 'Unknown Class';
    } catch (e) {
      return 'Unknown Class';
    }
  }
}
