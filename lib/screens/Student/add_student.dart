import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/student_provider.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/utils/constants.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'dart:typed_data';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:country_picker/country_picker.dart';

class StudentRegistrationPage extends ConsumerStatefulWidget {
  const StudentRegistrationPage({super.key});

  @override
  ConsumerState<StudentRegistrationPage> createState() =>
      _StudentRegistrationPageState();
}

class _StudentRegistrationPageState
    extends ConsumerState<StudentRegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final PageController _pageController = PageController();

  int _currentStep = 0;
  bool _isLoading = false;
  bool _isLoadingClasses = false;
  List<Class> _classes = [];
  String? _selectedClassId;

  // Image upload variables
  XFile? _selectedImageFile; // Use XFile instead of File for web compatibility
  Uint8List? _selectedImageBytes;
  String? _imageUrl;
  bool _isUploadingImage = false;
  final ImagePicker _imagePicker = ImagePicker();

  // ID Photo upload variables
  XFile? _selectedIdPhotoFile;
  Uint8List? _selectedIdPhotoBytes;
  String? _idPhotoUrl;
  bool _isUploadingIdPhoto = false;

  // Form controllers - Student Personal Info
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _dobController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _allergiesController = TextEditingController();
  final _medicationsController = TextEditingController();
  final _medicalConditionsController = TextEditingController();
  final _emergencyContactNameController = TextEditingController();
  final _emergencyContactPhoneController = TextEditingController();
  final _emergencyContactRelationshipController = TextEditingController();

  // Additional Personal Info Controllers
  final _profileImageController = TextEditingController();
  final _passportPhotoController = TextEditingController();
  final _languagesSpokenController = TextEditingController();
  final _ethnicBackgroundController = TextEditingController();
  final _formOfIdentificationController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _localGovernmentController = TextEditingController();

  // Contact Info Controllers
  final _streetNumberController = TextEditingController();
  final _streetNameController = TextEditingController();
  final _postalCodeController = TextEditingController();

  // Medical Info Controllers
  final _generalPractitionerNameController = TextEditingController();
  final _generalPractitionerAddressController = TextEditingController();
  final _generalPractitionerPhoneController = TextEditingController();
  final _medicalHistoryController = TextEditingController();
  final _ongoingMedicalConditionsController = TextEditingController();
  final _specialNeedsController = TextEditingController();
  final _currentMedicationController = TextEditingController();
  final _immunisationRecordController = TextEditingController();
  final _dietaryRequirementsController = TextEditingController();

  // Emergency Contact Additional Controllers
  final _emergencyContactEmailController = TextEditingController();
  final _emergencyContactStreetNumberController = TextEditingController();
  final _emergencyContactStreetNameController = TextEditingController();
  final _emergencyContactCityController = TextEditingController();
  final _emergencyContactStateController = TextEditingController();
  final _emergencyContactCountryController = TextEditingController();
  final _emergencyContactPostalCodeController = TextEditingController();

  // SEN Info Controllers
  final _supportDetailsController = TextEditingController();
  final _ehcpDetailsController = TextEditingController();

  // Background Info Controllers
  final _previousChildcareProviderController = TextEditingController();
  final _interestsController = TextEditingController();
  final _toiletTrainingStatusController = TextEditingController();
  final _comfortItemsController = TextEditingController();
  final _sleepRoutineController = TextEditingController();
  final _behaviouralConcernsController = TextEditingController();

  // Legal Info Controllers
  final _legalResponsibilityController = TextEditingController();
  final _courtOrdersController = TextEditingController();
  final _safeguardingDisclosureController = TextEditingController();
  final _parentSignatureController = TextEditingController();

  // Funding Info Controllers
  final _fundingAgreementController = TextEditingController();

  // Session Info Controllers
  final _daysOfAttendanceController = TextEditingController();
  final _fundedHoursController = TextEditingController();
  final _additionalPaidSessionsController = TextEditingController();
  final _preferredSettlingInSessionsController = TextEditingController();

  // Parent controllers - Father (expanded to match new schema)
  final _fatherTitleController = TextEditingController();
  final _fatherFirstNameController = TextEditingController();
  final _fatherLastNameController = TextEditingController();
  final _fatherMiddleNameController = TextEditingController();
  final _fatherStreetNumberController = TextEditingController();
  final _fatherStreetNameController = TextEditingController();
  final _fatherCityController = TextEditingController();
  final _fatherStateController = TextEditingController();
  final _fatherCountryController = TextEditingController();
  final _fatherPostalCodeController = TextEditingController();
  final _fatherPhoneController = TextEditingController();
  final _fatherEmailController = TextEditingController();
  final _fatherOccupationController = TextEditingController();
  final _fatherEmployerController = TextEditingController();
  final _fatherFormOfIdentificationController = TextEditingController();
  final _fatherIdNumberController = TextEditingController();

  // Parent controllers - Mother (expanded to match new schema)
  final _motherTitleController = TextEditingController();
  final _motherFirstNameController = TextEditingController();
  final _motherLastNameController = TextEditingController();
  final _motherMiddleNameController = TextEditingController();
  final _motherStreetNumberController = TextEditingController();
  final _motherStreetNameController = TextEditingController();
  final _motherCityController = TextEditingController();
  final _motherStateController = TextEditingController();
  final _motherCountryController = TextEditingController();
  final _motherPostalCodeController = TextEditingController();
  final _motherPhoneController = TextEditingController();
  final _motherEmailController = TextEditingController();
  final _motherOccupationController = TextEditingController();
  final _motherEmployerController = TextEditingController();
  final _motherFormOfIdentificationController = TextEditingController();
  final _motherIdNumberController = TextEditingController();

  // Parent controllers - Guardian (expanded to match new schema)
  final _guardianTitleController = TextEditingController();
  final _guardianFirstNameController = TextEditingController();
  final _guardianLastNameController = TextEditingController();
  final _guardianMiddleNameController = TextEditingController();
  final _guardianStreetNumberController = TextEditingController();
  final _guardianStreetNameController = TextEditingController();
  final _guardianCityController = TextEditingController();
  final _guardianStateController = TextEditingController();
  final _guardianCountryController = TextEditingController();
  final _guardianPostalCodeController = TextEditingController();
  final _guardianPhoneController = TextEditingController();
  final _guardianEmailController = TextEditingController();
  final _guardianOccupationController = TextEditingController();
  final _guardianEmployerController = TextEditingController();
  final _guardianFormOfIdentificationController = TextEditingController();
  final _guardianIdNumberController = TextEditingController();

  // Selected values
  String? _selectedGender;
  String? _selectedNationality;
  String? _selectedAcademicYear;
  String? _selectedStudentType = 'day';
  late GlobalAcademicYearService _academicYearService;
  String? _selectedReligion;
  String? _selectedBloodGroup;
  String? _selectedStateOfOrigin;
  String? _selectedCountry;
  String? _selectedState;
  String? _selectedFatherWorkCountry;
  String? _selectedFatherWorkState;

  // Additional selected values
  String? _selectedFormOfIdentification;
  bool _hasSiblings = false;
  bool _hasSpecialNeeds = false;
  bool _receivingAdditionalSupport = false;
  bool _hasEHCP = false;
  bool _emergencyMedicalTreatment = false;
  bool _administrationOfMedication = false;
  bool _firstAidConsent = false;
  bool _outingsAndTrips = false;
  bool _transportConsent = false;
  bool _useOfPhotosVideos = false;
  bool _suncreamApplication = false;
  bool _observationAndAssessment = false;
  bool _agreementToPayFees = false;
  bool _authorisedToCollectChild = false;

  // Parent boolean fields
  bool _fatherParentalResponsibility = true;
  bool _fatherLegalGuardianship = true;
  bool _fatherAuthorisedToCollectChild = true;
  bool _motherParentalResponsibility = true;
  bool _motherLegalGuardianship = true;
  bool _motherAuthorisedToCollectChild = true;
  bool _guardianParentalResponsibility = true;
  bool _guardianLegalGuardianship = true;
  bool _guardianAuthorisedToCollectChild = true;

  // Country picker selections for personal info
  String? _selectedPersonalCountry;
  DateTime? _selectedDOB;
  DateTime? _selectedAdmissionDate;

  final List<String> _genders = ['male', 'female'];
  final List<String> _religions = [
    'Christian',
    'Muslim',
    'Traditional',
    'Other',
  ];
  final List<String> _bloodGroups = [
    'A+',
    'A-',
    'B+',
    'B-',
    'AB+',
    'AB-',
    'O+',
    'O-',
  ];
  final List<String> _formOfIdentificationOptions = [
    'NHS',
    'Passport',
    'Citizen Card',
    'Driving License',
    'Birth Certificate',
    'Other',
  ];

  // Comprehensive country and state data
  final Map<String, List<String>> _countriesWithStates = {
    'Nigeria': [
      'Abia',
      'Adamawa',
      'Akwa Ibom',
      'Anambra',
      'Bauchi',
      'Bayelsa',
      'Benue',
      'Borno',
      'Cross River',
      'Delta',
      'Ebonyi',
      'Edo',
      'Ekiti',
      'Enugu',
      'FCT',
      'Gombe',
      'Imo',
      'Jigawa',
      'Kaduna',
      'Kano',
      'Katsina',
      'Kebbi',
      'Kogi',
      'Kwara',
      'Lagos',
      'Nasarawa',
      'Niger',
      'Ogun',
      'Ondo',
      'Osun',
      'Oyo',
      'Plateau',
      'Rivers',
      'Sokoto',
      'Taraba',
      'Yobe',
      'Zamfara',
    ],
    'United States': [
      'Alabama',
      'Alaska',
      'Arizona',
      'Arkansas',
      'California',
      'Colorado',
      'Connecticut',
      'Delaware',
      'Florida',
      'Georgia',
      'Hawaii',
      'Idaho',
      'Illinois',
      'Indiana',
      'Iowa',
      'Kansas',
      'Kentucky',
      'Louisiana',
      'Maine',
      'Maryland',
      'Massachusetts',
      'Michigan',
      'Minnesota',
      'Mississippi',
      'Missouri',
      'Montana',
      'Nebraska',
      'Nevada',
      'New Hampshire',
      'New Jersey',
      'New Mexico',
      'New York',
      'North Carolina',
      'North Dakota',
      'Ohio',
      'Oklahoma',
      'Oregon',
      'Pennsylvania',
      'Rhode Island',
      'South Carolina',
      'South Dakota',
      'Tennessee',
      'Texas',
      'Utah',
      'Vermont',
      'Virginia',
      'Washington',
      'West Virginia',
      'Wisconsin',
      'Wyoming',
    ],
    'United Kingdom': ['England', 'Scotland', 'Wales', 'Northern Ireland'],
    'Canada': [
      'Alberta',
      'British Columbia',
      'Manitoba',
      'New Brunswick',
      'Newfoundland and Labrador',
      'Northwest Territories',
      'Nova Scotia',
      'Nunavut',
      'Ontario',
      'Prince Edward Island',
      'Quebec',
      'Saskatchewan',
      'Yukon',
    ],
    'Ghana': [
      'Greater Accra',
      'Ashanti',
      'Western',
      'Central',
      'Volta',
      'Eastern',
      'Northern',
      'Upper East',
      'Upper West',
      'Brong-Ahafo',
    ],
    'Kenya': [
      'Nairobi',
      'Mombasa',
      'Kisumu',
      'Nakuru',
      'Eldoret',
      'Thika',
      'Malindi',
      'Kitale',
      'Garissa',
      'Kakamega',
      'Bungoma',
      'Nyeri',
    ],
    'South Africa': [
      'Eastern Cape',
      'Free State',
      'Gauteng',
      'KwaZulu-Natal',
      'Limpopo',
      'Mpumalanga',
      'Northern Cape',
      'North West',
      'Western Cape',
    ],
    'India': [
      'Andhra Pradesh',
      'Arunachal Pradesh',
      'Assam',
      'Bihar',
      'Chhattisgarh',
      'Goa',
      'Gujarat',
      'Haryana',
      'Himachal Pradesh',
      'Jharkhand',
      'Karnataka',
      'Kerala',
      'Madhya Pradesh',
      'Maharashtra',
      'Manipur',
      'Meghalaya',
      'Mizoram',
      'Nagaland',
      'Odisha',
      'Punjab',
      'Rajasthan',
      'Sikkim',
      'Tamil Nadu',
      'Telangana',
      'Tripura',
      'Uttar Pradesh',
      'Uttarakhand',
      'West Bengal',
    ],
    'China': [
      'Beijing',
      'Shanghai',
      'Tianjin',
      'Chongqing',
      'Hebei',
      'Shanxi',
      'Inner Mongolia',
      'Liaoning',
      'Jilin',
      'Heilongjiang',
      'Jiangsu',
      'Zhejiang',
      'Anhui',
      'Fujian',
      'Jiangxi',
      'Shandong',
      'Henan',
      'Hubei',
      'Hunan',
      'Guangdong',
      'Guangxi',
      'Hainan',
      'Sichuan',
      'Guizhou',
      'Yunnan',
      'Tibet',
      'Shaanxi',
      'Gansu',
      'Qinghai',
      'Ningxia',
      'Xinjiang',
    ],
    'Brazil': [
      'Acre',
      'Alagoas',
      'Amapá',
      'Amazonas',
      'Bahia',
      'Ceará',
      'Distrito Federal',
      'Espírito Santo',
      'Goiás',
      'Maranhão',
      'Mato Grosso',
      'Mato Grosso do Sul',
      'Minas Gerais',
      'Pará',
      'Paraíba',
      'Paraná',
      'Pernambuco',
      'Piauí',
      'Rio de Janeiro',
      'Rio Grande do Norte',
      'Rio Grande do Sul',
      'Rondônia',
      'Roraima',
      'Santa Catarina',
      'São Paulo',
      'Sergipe',
      'Tocantins',
    ],
    'Australia': [
      'New South Wales',
      'Victoria',
      'Queensland',
      'Western Australia',
      'South Australia',
      'Tasmania',
      'Australian Capital Territory',
      'Northern Territory',
    ],
    'Germany': [
      'Baden-Württemberg',
      'Bavaria',
      'Berlin',
      'Brandenburg',
      'Bremen',
      'Hamburg',
      'Hesse',
      'Lower Saxony',
      'Mecklenburg-Vorpommern',
      'North Rhine-Westphalia',
      'Rhineland-Palatinate',
      'Saarland',
      'Saxony',
      'Saxony-Anhalt',
      'Schleswig-Holstein',
      'Thuringia',
    ],
    'France': [
      'Auvergne-Rhône-Alpes',
      'Bourgogne-Franche-Comté',
      'Brittany',
      'Centre-Val de Loire',
      'Corsica',
      'Grand Est',
      'Hauts-de-France',
      'Île-de-France',
      'Normandy',
      'Nouvelle-Aquitaine',
      'Occitanie',
      'Pays de la Loire',
      'Provence-Alpes-Côte d\'Azur',
    ],
    'Japan': [
      'Hokkaido',
      'Tohoku',
      'Kanto',
      'Chubu',
      'Kansai',
      'Chugoku',
      'Shikoku',
      'Kyushu',
      'Okinawa',
    ],
    'Other': [],
  };
  final List<String> _localGovernments = [
    'Ikeja',
    'Victoria Island',
    'Lekki',
    'Surulere',
    'Other',
  ];
  // Academic year is now loaded from backend and displayed as read-only
  final List<String> _studentTypes = ['day', 'boarding'];
  final List<String> _titles = ['Mr', 'Mrs', 'Ms', 'Dr', 'Prof'];
  ClassMetricModel _classData = ClassMetricModel();

  // Helper method to get states for selected country
  List<String> _getStatesForCountry(String? country) {
    if (country == null || country.isEmpty) return [];
    return _countriesWithStates[country] ?? [];
  }

  // Helper method to get local governments for selected state
  List<String> _getLocalGovernmentsForState(String? state) {
    if (state == null || state.isEmpty) return _localGovernments;

    // For Nigeria, provide state-specific LGAs
    if (_selectedPersonalCountry == 'Nigeria') {
      return _getNigerianLGAsForState(state);
    }

    // For other countries, return generic list
    return _localGovernments;
  }

  // Helper method to get Nigerian LGAs for specific state
  List<String> _getNigerianLGAsForState(String state) {
    // This is a simplified mapping - you can expand this with actual LGA data
    switch (state) {
      case 'Lagos':
        return [
          'Ikeja',
          'Victoria Island',
          'Lekki',
          'Surulere',
          'Mushin',
          'Oshodi',
          'Other',
        ];
      case 'Abuja':
        return ['Garki', 'Wuse', 'Asokoro', 'Maitama', 'Gwarinpa', 'Other'];
      case 'Kano':
        return ['Nassarawa', 'Fagge', 'Dala', 'Gwale', 'Municipal', 'Other'];
      case 'Rivers':
        return ['Port Harcourt', 'Obio-Akpor', 'Eleme', 'Okrika', 'Other'];
      case 'Ogun':
        return [
          'Abeokuta North',
          'Abeokuta South',
          'Ijebu Ode',
          'Sagamu',
          'Other',
        ];
      case 'Kaduna':
        return ['Kaduna North', 'Kaduna South', 'Chikun', 'Igabi', 'Other'];
      default:
        return ['Other'];
    }
  }

  // Method to build country dropdown with search
  Widget _buildCountryDropdown({
    required String label,
    required String? value,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () {
            showCountryPicker(
              context: context,
              onSelect: (Country country) {
                onChanged(country.name);
                setState(() {
                  _selectedCountry = country.name;
                  _selectedState = null; // Reset state when country changes
                });
              },
              showPhoneCode: false,
              showWorldWide: true,
              favorite: [
                'NG',
                'US',
                'GB',
                'CA',
                'GH',
                'KE',
                'ZA',
                'IN',
                'CN',
                'BR',
                'AU',
                'DE',
                'FR',
                'JP',
              ],
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
              color: Colors.white,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    value ?? 'Select Country',
                    style: TextStyle(
                      fontSize: 16,
                      color:
                          value == null ? Colors.grey.shade500 : Colors.black87,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down, color: Colors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Method to build state dropdown with dynamic states based on country
  Widget _buildStateDropdown({
    required String label,
    required String? value,
    required String? country,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    final states = _getStatesForCountry(country);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label${isRequired ? ' *' : ''}',
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
            color: Colors.white,
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text(
                states.isEmpty ? 'Select country first' : 'Select State',
                style: TextStyle(fontSize: 16, color: Colors.grey.shade500),
              ),
              isExpanded: true,
              items:
                  states.map((String state) {
                    return DropdownMenuItem<String>(
                      value: state,
                      child: Text(state, style: const TextStyle(fontSize: 16)),
                    );
                  }).toList(),
              onChanged: states.isEmpty ? null : onChanged,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _academicYearService.addListener(_onAcademicYearChanged);
    _countryController.text = 'Nigeria';
    _selectedCountry = 'Nigeria';
    _selectedState = 'Lagos';
    _fatherTitleController.text = 'Mr';
    _motherTitleController.text = 'Mrs';
    _loadAcademicYears();
    _loadClasses();
  }

  void _onAcademicYearChanged() {
    if (mounted) {
      setState(() {
        _selectedAcademicYear = _academicYearService.currentAcademicYearString;
      });
    }
  }

  Future<void> _loadAcademicYears() async {
    try {
      print('🔍 AddStudent: Loading academic years...');

      // Get current academic year from global service
      final academicYearService = GlobalAcademicYearService();

      print(
        '📊 AddStudent: Service initialized: ${academicYearService.isInitialized}',
      );
      print(
        '📊 AddStudent: Current academic year: ${academicYearService.currentAcademicYearString}',
      );

      // If service is not initialized, try to load cached data first
      if (!academicYearService.isInitialized) {
        print('🔄 AddStudent: Service not initialized, loading cached data...');
        await academicYearService.loadCachedData();
      }

      final currentAcademicYear = academicYearService.currentAcademicYearString;

      print('✅ AddStudent: Setting academic year to: $currentAcademicYear');

      setState(() {
        _selectedAcademicYear = currentAcademicYear;
      });
    } catch (e) {
      print('❌ AddStudent: Error loading academic year: $e');
      // Fallback to default academic year if service is not available
      setState(() {
        _selectedAcademicYear = '2025/2026';
      });
    }
  }

  Future<void> _loadClasses() async {
    setState(() {
      _isLoadingClasses = true;
    });

    try {
      _classData = await ref
          .read(RiverpodProvider.classProvider)
          .getAllClassesWithMetric(context);

      if (!mounted) return;

      if (_classData.classes != null && _classData.classes!.isNotEmpty) {
        setState(() {
          _classes = _classData.classes!;
          _isLoadingClasses = false;
        });
      } else {
        setState(() {
          _isLoadingClasses = false;
        });
        if (mounted) {
          showSnackbar(context, 'No classes found');
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingClasses = false;
      });
      if (mounted) {
        showSnackbar(context, 'Error loading classes: $e');
      }
    }
  }

  @override
  void dispose() {
    _academicYearService.removeListener(_onAcademicYearChanged);

    // Student controllers
    _firstNameController.dispose();
    _lastNameController.dispose();
    _middleNameController.dispose();
    _dobController.dispose();
    _streetController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _allergiesController.dispose();
    _medicationsController.dispose();
    _medicalConditionsController.dispose();
    _emergencyContactNameController.dispose();
    _emergencyContactPhoneController.dispose();
    _emergencyContactRelationshipController.dispose();

    // Additional Personal Info Controllers
    _profileImageController.dispose();
    _passportPhotoController.dispose();
    _languagesSpokenController.dispose();
    _ethnicBackgroundController.dispose();
    _formOfIdentificationController.dispose();
    _idNumberController.dispose();
    _localGovernmentController.dispose();

    // Contact Info Controllers
    _streetNumberController.dispose();
    _streetNameController.dispose();
    _postalCodeController.dispose();

    // Medical Info Controllers
    _generalPractitionerNameController.dispose();
    _generalPractitionerAddressController.dispose();
    _generalPractitionerPhoneController.dispose();
    _medicalHistoryController.dispose();
    _ongoingMedicalConditionsController.dispose();
    _specialNeedsController.dispose();
    _currentMedicationController.dispose();
    _immunisationRecordController.dispose();
    _dietaryRequirementsController.dispose();

    // Emergency Contact Additional Controllers
    _emergencyContactEmailController.dispose();
    _emergencyContactStreetNumberController.dispose();
    _emergencyContactStreetNameController.dispose();
    _emergencyContactCityController.dispose();
    _emergencyContactStateController.dispose();
    _emergencyContactCountryController.dispose();
    _emergencyContactPostalCodeController.dispose();

    // SEN Info Controllers
    _supportDetailsController.dispose();
    _ehcpDetailsController.dispose();

    // Background Info Controllers
    _previousChildcareProviderController.dispose();
    _interestsController.dispose();
    _toiletTrainingStatusController.dispose();
    _comfortItemsController.dispose();
    _sleepRoutineController.dispose();
    _behaviouralConcernsController.dispose();

    // Legal Info Controllers
    _legalResponsibilityController.dispose();
    _courtOrdersController.dispose();
    _safeguardingDisclosureController.dispose();
    _parentSignatureController.dispose();

    // Funding Info Controllers
    _fundingAgreementController.dispose();

    // Session Info Controllers
    _daysOfAttendanceController.dispose();
    _fundedHoursController.dispose();
    _additionalPaidSessionsController.dispose();
    _preferredSettlingInSessionsController.dispose();

    // Father controllers
    _fatherTitleController.dispose();
    _fatherFirstNameController.dispose();
    _fatherLastNameController.dispose();
    _fatherMiddleNameController.dispose();
    _fatherStreetNumberController.dispose();
    _fatherStreetNameController.dispose();
    _fatherCityController.dispose();
    _fatherStateController.dispose();
    _fatherCountryController.dispose();
    _fatherPostalCodeController.dispose();
    _fatherPhoneController.dispose();
    _fatherEmailController.dispose();
    _fatherOccupationController.dispose();
    _fatherEmployerController.dispose();
    _fatherFormOfIdentificationController.dispose();
    _fatherIdNumberController.dispose();

    // Mother controllers
    _motherTitleController.dispose();
    _motherFirstNameController.dispose();
    _motherLastNameController.dispose();
    _motherMiddleNameController.dispose();
    _motherStreetNumberController.dispose();
    _motherStreetNameController.dispose();
    _motherCityController.dispose();
    _motherStateController.dispose();
    _motherCountryController.dispose();
    _motherPostalCodeController.dispose();
    _motherPhoneController.dispose();
    _motherEmailController.dispose();
    _motherOccupationController.dispose();
    _motherEmployerController.dispose();
    _motherFormOfIdentificationController.dispose();
    _motherIdNumberController.dispose();

    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Student Registration'),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            // Progress indicator
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: LinearProgressIndicator(
                          value: (_currentStep + 1) / 9,
                          backgroundColor: Colors.grey[300],
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF6366F1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Step ${_currentStep + 1} of 8',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStepTitle(_currentStep),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),

            // Form pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics:
                    const NeverScrollableScrollPhysics(), // Disable manual swiping
                onPageChanged: (index) {
                  setState(() {
                    _currentStep = index;
                  });
                },
                children: [
                  _buildPersonalInfoStep(),
                  _buildContactInfoStep(),
                  _buildAcademicInfoStep(),
                  _buildMedicalInfoStep(),
                  _buildPermissionsStep(),
                  _buildBackgroundInfoStep(),
                  _buildFatherInfoStep(),
                  _buildMotherInfoStep(),
                  _buildGuardianInfoStep(),
                ],
              ),
            ),

            // Navigation buttons
            Container(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousStep,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleNextOrSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF6366F1),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                              : Text(
                                _currentStep == 7 ? 'Submit' : 'Next',
                                style: const TextStyle(color: Colors.white),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s personal details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Profile Image Upload Section
          _buildImageUploadSection(),
          const SizedBox(height: 32),

          // // ID Photo Upload Section
          // _buildIdPhotoUploadSection(),
          // const SizedBox(height: 32),

          // Name fields
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _firstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _middleNameController,
                  label: 'Middle Name',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _lastNameController,
            label: 'Last Name',
            isRequired: true,
          ),
          const SizedBox(height: 16),

          // Date of Birth
          _buildTextField(
            controller: _dobController,
            label: 'Date of Birth',
            isRequired: true,
            readOnly: true,
            onTap: () => _selectDate(context, true),
            suffixIcon: const Icon(Icons.calendar_today),
          ),
          const SizedBox(height: 16),

          // Gender and Nationality
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Gender',
                  value: _selectedGender,
                  items: _genders,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildCountryDropdown(
                  label: 'Nationality of Origin',
                  value: _selectedNationality,
                  onChanged: (value) {
                    setState(() {
                      _selectedNationality = value;
                      _selectedPersonalCountry = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Religion and Blood Group
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Religion',
                  value: _selectedReligion,
                  items: _religions,
                  onChanged: (value) {
                    setState(() {
                      _selectedReligion = value;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Blood Group',
                  value: _selectedBloodGroup,
                  items: _bloodGroups,
                  onChanged: (value) {
                    setState(() {
                      _selectedBloodGroup = value;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // State and LGA
          Row(
            children: [
              Expanded(
                child: _buildStateDropdown(
                  label: 'Locality',
                  value: _selectedStateOfOrigin,
                  country: _selectedPersonalCountry,
                  onChanged: (value) {
                    setState(() {
                      _selectedStateOfOrigin = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _localGovernmentController,
                  label: 'Local Government',
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s contact details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Address fields
          _buildTextField(
            controller: _streetController,
            label: 'Street Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _streetNumberController,
                  label: 'Street Number',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _postalCodeController,
                  label: 'Postal Code',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCountryDropdown(
                  label: 'Country of Residence',
                  value: _selectedCountry,
                  onChanged: (value) {
                    setState(() {
                      _selectedCountry = value;
                      _countryController.text = value ?? '';
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'State',
                  value: _selectedState,
                  items: _getStatesForCountry(_selectedCountry),
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                      _stateController.text = value ?? '';
                    });
                  },
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _cityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),

              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _phoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emailController,
            label: 'Email Address',
            keyboardType: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Academic Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s academic details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // Academic Year and Class
          Row(
            children: [
              Expanded(child: _buildAcademicYearField()),
              const SizedBox(width: 16),
              Expanded(child: _buildClassDropdown()),
            ],
          ),
          const SizedBox(height: 16),

          // Student Type and Admission Date
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Student Type',
                  value: _selectedStudentType,
                  items: _studentTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedStudentType = value;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Admission Date *',
                      style: TextStyle(
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: TextEditingController(
                        text:
                            _selectedAdmissionDate != null
                                ? '${_selectedAdmissionDate!.day}/${_selectedAdmissionDate!.month}/${_selectedAdmissionDate!.year}'
                                : '',
                      ),
                      readOnly: true,
                      onTap: () => _selectDate(context, 'admission'),
                      decoration: InputDecoration(
                        hintText: 'Select admission date',
                        suffixIcon: const Icon(Icons.calendar_today),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(
                            color:
                                _selectedAdmissionDate == null
                                    ? Colors.red
                                    : const Color(0xFF6366F1),
                          ),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                      validator: (value) {
                        if (_selectedAdmissionDate == null) {
                          return 'Admission date is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildFatherInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Father\'s Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the father\'s complete details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Fill with N/A button
          _buildFillNAButton('Father\'s', _fillFatherFieldsWithNA),

          const SizedBox(height: 16),

          // Personal Information Section
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Title and Name
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Title',
                  value:
                      _fatherTitleController.text.isNotEmpty
                          ? _fatherTitleController.text
                          : null,
                  items: _titles,
                  onChanged: (value) {
                    setState(() {
                      _fatherTitleController.text = value!;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherFirstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherMiddleNameController,
                  label: 'Middle Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherLastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Address Information Section
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Street Number and Street Name
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherStreetNumberController,
                  label: 'Street Number',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherStreetNameController,
                  label: 'Street Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // City, State, Country
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherCityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherStateController,
                  label: 'State',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherCountryController,
                  label: 'Country',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherPostalCodeController,
                  label: 'Postal Code',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Contact Information Section
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherPhoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherEmailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Professional Information Section
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherOccupationController,
                  label: 'Occupation',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherEmployerController,
                  label: 'Employer',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Legal Information Section
          const Text(
            'Legal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Parental Responsibility and Legal Guardianship
          _buildCheckboxField(
            'Parental Responsibility',
            _fatherParentalResponsibility,
            (value) => setState(() => _fatherParentalResponsibility = value!),
          ),
          _buildCheckboxField(
            'Legal Guardianship',
            _fatherLegalGuardianship,
            (value) => setState(() => _fatherLegalGuardianship = value!),
          ),
          _buildCheckboxField(
            'Authorised to Collect the Child',
            _fatherAuthorisedToCollectChild,
            (value) => setState(() => _fatherAuthorisedToCollectChild = value!),
          ),
          const SizedBox(height: 16),

          // Form of Identification and ID Number
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _fatherFormOfIdentificationController,
                  label: 'Form of Identification',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _fatherIdNumberController,
                  label: 'ID Number',
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMedicalInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Medical Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the student\'s medical details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          // General Practitioner
          const Text(
            'General Practitioner',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _generalPractitionerNameController,
            label: 'GP Name',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _generalPractitionerAddressController,
            label: 'GP Address',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _generalPractitionerPhoneController,
            label: 'GP Phone',
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
          const SizedBox(height: 24),

          // Medical History
          _buildTextField(
            controller: _medicalHistoryController,
            label: 'Medical History',
            maxLines: 3,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _allergiesController,
            label: 'Allergies (comma separated)',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ongoingMedicalConditionsController,
            label: 'Ongoing Medical Conditions',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _specialNeedsController,
            label: 'Special Needs',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _currentMedicationController,
            label: 'Current Medication (with dosage)',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _immunisationRecordController,
            label: 'Immunisation Record',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _dietaryRequirementsController,
            label: 'Dietary Requirements',
            maxLines: 2,
            isRequired: true,
          ),
          const SizedBox(height: 32),

          // Emergency Contact
          const Text(
            'Emergency Contact',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactNameController,
                  label: 'Emergency Contact Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _emergencyContactRelationshipController,
                  label: 'Relationship',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _emergencyContactPhoneController,
            label: 'Emergency Contact Phone',
            keyboardType: TextInputType.phone,
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Permissions & Consents',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please provide consent for various activities',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          _buildCheckboxField(
            'Emergency Medical Treatment',
            _emergencyMedicalTreatment,
            (value) => setState(() => _emergencyMedicalTreatment = value!),
          ),
          _buildCheckboxField(
            'Administration of Medication',
            _administrationOfMedication,
            (value) => setState(() => _administrationOfMedication = value!),
          ),
          _buildCheckboxField(
            'First Aid Consent',
            _firstAidConsent,
            (value) => setState(() => _firstAidConsent = value!),
          ),
          _buildCheckboxField(
            'Outings and Trips',
            _outingsAndTrips,
            (value) => setState(() => _outingsAndTrips = value!),
          ),
          _buildCheckboxField(
            'Transport Consent',
            _transportConsent,
            (value) => setState(() => _transportConsent = value!),
          ),
          _buildCheckboxField(
            'Use of Photos/Videos',
            _useOfPhotosVideos,
            (value) => setState(() => _useOfPhotosVideos = value!),
          ),
          _buildCheckboxField(
            'Suncream Application',
            _suncreamApplication,
            (value) => setState(() => _suncreamApplication = value!),
          ),
          _buildCheckboxField(
            'Observation and Assessment',
            _observationAndAssessment,
            (value) => setState(() => _observationAndAssessment = value!),
          ),
          _buildCheckboxField(
            'Agreement to Pay Fees',
            _agreementToPayFees,
            (value) => setState(() => _agreementToPayFees = value!),
          ),
        ],
      ),
    );
  }

  Widget _buildBackgroundInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Background & Development Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter additional background information',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 32),

          _buildTextField(
            controller: _previousChildcareProviderController,
            label: 'Previous Childcare Provider',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _interestsController,
            label: 'Child\'s Interests',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _toiletTrainingStatusController,
            label: 'Toilet Training Status',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _comfortItemsController,
            label: 'Comfort Items',
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _sleepRoutineController,
            label: 'Sleep Routine',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _behaviouralConcernsController,
            label: 'Behavioural Concerns',
            maxLines: 2,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _languagesSpokenController,
            label: 'Languages Spoken at Home',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _ethnicBackgroundController,
            label: 'Ethnic Background',
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildDropdown(
            label: 'Form of Identification',
            value: _selectedFormOfIdentification,
            items: _formOfIdentificationOptions,
            onChanged: (value) {
              setState(() {
                _selectedFormOfIdentification = value;
              });
            },
            isRequired: true,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _idNumberController,
            label: 'ID Number',
            isRequired: true,
          ),
        ],
      ),
    );
  }

  Widget _buildMotherInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mother\'s Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the mother\'s complete details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Fill with N/A button
          _buildFillNAButton('Mother\'s', _fillMotherFieldsWithNA),

          const SizedBox(height: 16),

          // Personal Information Section
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Title and Name
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Title',
                  value:
                      _motherTitleController.text.isNotEmpty
                          ? _motherTitleController.text
                          : null,
                  items: _titles,
                  onChanged: (value) {
                    setState(() {
                      _motherTitleController.text = value!;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherFirstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherMiddleNameController,
                  label: 'Middle Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherLastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Address Information Section
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Street Number and Street Name
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherStreetNumberController,
                  label: 'Street Number',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherStreetNameController,
                  label: 'Street Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // City, State, Country
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherCityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherStateController,
                  label: 'State',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherCountryController,
                  label: 'Country',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherPostalCodeController,
                  label: 'Postal Code',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Contact Information Section
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherPhoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherEmailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Professional Information Section
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherOccupationController,
                  label: 'Occupation',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherEmployerController,
                  label: 'Employer',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Legal Information Section
          const Text(
            'Legal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Parental Responsibility and Legal Guardianship
          _buildCheckboxField(
            'Parental Responsibility',
            _motherParentalResponsibility,
            (value) => setState(() => _motherParentalResponsibility = value!),
          ),
          _buildCheckboxField(
            'Legal Guardianship',
            _motherLegalGuardianship,
            (value) => setState(() => _motherLegalGuardianship = value!),
          ),
          _buildCheckboxField(
            'Authorised to Collect the Child',
            _motherAuthorisedToCollectChild,
            (value) => setState(() => _motherAuthorisedToCollectChild = value!),
          ),
          const SizedBox(height: 16),

          // Form of Identification and ID Number
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _motherFormOfIdentificationController,
                  label: 'Form of Identification',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _motherIdNumberController,
                  label: 'ID Number',
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGuardianInfoStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Guardian\'s Information',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the guardian\'s complete details',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Fill with N/A button
          _buildFillNAButton('Guardian\'s', _fillGuardianFieldsWithNA),

          const SizedBox(height: 16),

          // Personal Information Section
          const Text(
            'Personal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Title and Name
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Title',
                  value:
                      _guardianTitleController.text.isNotEmpty
                          ? _guardianTitleController.text
                          : null,
                  items: _titles,
                  onChanged: (value) {
                    setState(() {
                      _guardianTitleController.text = value!;
                    });
                  },
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianFirstNameController,
                  label: 'First Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianMiddleNameController,
                  label: 'Middle Name',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianLastNameController,
                  label: 'Last Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Address Information Section
          const Text(
            'Address Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Street Number and Street Name
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianStreetNumberController,
                  label: 'Street Number',
                  keyboardType: TextInputType.number,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianStreetNameController,
                  label: 'Street Name',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // City, State, Country
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianCityController,
                  label: 'City',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianStateController,
                  label: 'State',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianCountryController,
                  label: 'Country',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianPostalCodeController,
                  label: 'Postal Code',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Contact Information Section
          const Text(
            'Contact Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianPhoneController,
                  label: 'Phone Number',
                  keyboardType: TextInputType.phone,
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianEmailController,
                  label: 'Email Address',
                  keyboardType: TextInputType.emailAddress,
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Professional Information Section
          const Text(
            'Professional Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianOccupationController,
                  label: 'Occupation',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianEmployerController,
                  label: 'Employer',
                  isRequired: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Legal Information Section
          const Text(
            'Legal Information',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          // Parental Responsibility and Legal Guardianship
          _buildCheckboxField(
            'Parental Responsibility',
            _guardianParentalResponsibility,
            (value) => setState(() => _guardianParentalResponsibility = value!),
          ),
          _buildCheckboxField(
            'Legal Guardianship',
            _guardianLegalGuardianship,
            (value) => setState(() => _guardianLegalGuardianship = value!),
          ),
          _buildCheckboxField(
            'Authorised to Collect the Child',
            _guardianAuthorisedToCollectChild,
            (value) =>
                setState(() => _guardianAuthorisedToCollectChild = value!),
          ),
          const SizedBox(height: 16),

          // Form of Identification and ID Number
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  controller: _guardianFormOfIdentificationController,
                  label: 'Form of Identification',
                  isRequired: true,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  controller: _guardianIdNumberController,
                  label: 'ID Number',
                  isRequired: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxField(
    String label,
    bool value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(
        label,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Colors.black87,
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: const Color(0xFF6366F1),
      contentPadding: EdgeInsets.zero,
    );
  }

  Widget _buildFillNAButton(String sectionName, VoidCallback onPressed) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: const Icon(Icons.auto_fix_high, size: 18),
        label: Text('Fill all $sectionName fields with N/A'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.orange[100],
          foregroundColor: Colors.orange[800],
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.orange[300]!),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    bool isRequired = false,
    bool readOnly = false,
    TextInputType? keyboardType,
    int maxLines = 1,
    Widget? suffixIcon,
    VoidCallback? onTap,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: readOnly,
          keyboardType: keyboardType,
          maxLines: maxLines,
          onTap: onTap,
          decoration: InputDecoration(
            hintText: 'Enter $label',
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildAcademicYearField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Academic Year *',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[100], // Make it look disabled
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedAcademicYear ?? 'Loading...',
                  style: TextStyle(
                    fontSize: 16,
                    color:
                        _selectedAcademicYear != null
                            ? Colors.black87
                            : Colors.grey[500],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(Icons.lock, color: Colors.grey[500], size: 20),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label + (isRequired ? ' *' : ''),
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isRequired ? Colors.red : Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              items.map((item) {
                return DropdownMenuItem<String>(value: item, child: Text(item));
              }).toList(),
          onChanged: onChanged,
          validator:
              isRequired
                  ? (value) {
                    if (value == null || value.isEmpty) {
                      return '$label is required';
                    }
                    return null;
                  }
                  : null,
        ),
      ],
    );
  }

  Widget _buildClassDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Assign to Class',
          style: TextStyle(fontWeight: FontWeight.w500, color: Colors.black87),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedClassId,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF6366F1)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          items:
              _isLoadingClasses
                  ? [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Loading classes...'),
                    ),
                  ]
                  : _classes.map((classItem) {
                    return DropdownMenuItem<String>(
                      value: classItem.id,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            classItem.section != null &&
                                    classItem.section!.isNotEmpty
                                ? '${classItem.name} (${classItem.section})'
                                : classItem.name ?? '',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          Text(
                            '${classItem.level} • ${classItem.academicYear}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          if (classItem.availableSlots != null)
                            Text(
                              '${classItem.availableSlots} slots available',
                              style: TextStyle(
                                fontSize: 11,
                                color:
                                    classItem.availableSlots! > 0
                                        ? Colors.green[600]
                                        : Colors.red[600],
                              ),
                            ),
                        ],
                      ),
                    );
                  }).toList(),
          onChanged:
              _isLoadingClasses
                  ? null
                  : (value) {
                    setState(() {
                      _selectedClassId = value;
                    });
                  },
        ),
      ],
    );
  }

  void _nextStep() {
    if (_currentStep < 8) {
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

  Future<void> _selectDate(BuildContext context, dynamic type) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        if (type == true) {
          // Student DOB
          _selectedDOB = picked;
          _dobController.text =
              '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
        } else if (type == 'admission') {
          // Admission date
          _selectedAdmissionDate = picked;
        }
      });
    }
  }

  void _handleNextOrSubmit() {
    if (_currentStep < 8) {
      // Validate current step before proceeding
      if (!_validateCurrentStep()) {
        return;
      }
      _nextStep();
    } else {
      // Validate required fields before submission
      if (_selectedAdmissionDate == null) {
        showSnackbar(context, 'Please select an admission date');
        return;
      }
      _submitForm();
    }
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal Information';
      case 1:
        return 'Contact Information';
      case 2:
        return 'Academic Information';
      case 3:
        return 'Medical Information';
      case 4:
        return 'Permissions & Consents';
      case 5:
        return 'Background Information';
      case 6:
        return 'Father\'s Information';
      case 7:
        return 'Mother\'s Information';
      case 8:
        return 'Guardian\'s Information';
      default:
        return 'Student Registration';
    }
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.orange),
              SizedBox(width: 8),
              Text('Required Fields Missing'),
            ],
          ),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0: // Personal Information
        return _validatePersonalInfoStep();
      case 1: // Contact Information
        return _validateContactInfoStep();
      case 2: // Academic Information
        return _validateAcademicInfoStep();
      case 3: // Medical Information
        return _validateMedicalInfoStep();
      case 4: // Permissions
        return _validatePermissionsStep();
      case 5: // Background Information
        return _validateBackgroundInfoStep();
      case 6: // Father's Information
        return _validateFatherInfoStep();
      case 7: // Mother's Information
        return _validateMotherInfoStep();
      case 8: // Guardian's Information
        return _validateGuardianInfoStep();
      default:
        return true;
    }
  }

  bool _validatePersonalInfoStep() {
    final errors = <String>[];

    if (_firstNameController.text.trim().isEmpty) {
      errors.add('First Name is required');
    }
    if (_lastNameController.text.trim().isEmpty) {
      errors.add('Last Name is required');
    }
    if (_selectedDOB == null) {
      errors.add('Date of Birth is required');
    }
    if (_selectedGender == null) {
      errors.add('Gender is required');
    }
    if (_selectedNationality == null) {
      errors.add('Nationality of Origin is required');
    }
    if (_selectedStateOfOrigin == null) {
      errors.add('Locality is required');
    }
    if (_localGovernmentController.text.trim().isEmpty) {
      errors.add('Local Government is required');
    }
    // if (_idPhotoUrl == null || _idPhotoUrl!.isEmpty) {
    //   errors.add('ID Photo is required');
    // }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateContactInfoStep() {
    final errors = <String>[];

    if (_streetController.text.trim().isEmpty) {
      errors.add('Street Address is required');
    }
    if (_streetNumberController.text.trim().isEmpty) {
      errors.add('Street Number is required');
    }
    if (_postalCodeController.text.trim().isEmpty) {
      errors.add('Postal Code is required');
    }
    if (_cityController.text.trim().isEmpty) {
      errors.add('City is required');
    }
    if (_selectedCountry == null) {
      errors.add('Country of Residence is required');
    }
    if (_selectedState == null) {
      errors.add('State is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateAcademicInfoStep() {
    final errors = <String>[];

    if (_selectedAcademicYear == null) {
      errors.add('Academic Year is required');
    }
    if (_selectedClassId == null) {
      errors.add('Class assignment is required');
    }
    if (_selectedStudentType == null) {
      errors.add('Student Type is required');
    }
    if (_selectedAdmissionDate == null) {
      errors.add('Admission Date is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateMedicalInfoStep() {
    final errors = <String>[];

    // General Practitioner fields
    if (_generalPractitionerNameController.text.trim().isEmpty) {
      errors.add('GP Name is required');
    }
    if (_generalPractitionerAddressController.text.trim().isEmpty) {
      errors.add('GP Address is required');
    }
    if (_generalPractitionerPhoneController.text.trim().isEmpty) {
      errors.add('GP Phone is required');
    }

    // Medical History fields
    if (_medicalHistoryController.text.trim().isEmpty) {
      errors.add('Medical History is required');
    }
    if (_allergiesController.text.trim().isEmpty) {
      errors.add('Allergies is required');
    }
    if (_ongoingMedicalConditionsController.text.trim().isEmpty) {
      errors.add('Ongoing Medical Conditions is required');
    }
    if (_specialNeedsController.text.trim().isEmpty) {
      errors.add('Special Needs is required');
    }
    if (_currentMedicationController.text.trim().isEmpty) {
      errors.add('Current Medication is required');
    }
    if (_immunisationRecordController.text.trim().isEmpty) {
      errors.add('Immunisation Record is required');
    }
    if (_dietaryRequirementsController.text.trim().isEmpty) {
      errors.add('Dietary Requirements is required');
    }

    // Emergency Contact fields
    if (_emergencyContactNameController.text.trim().isEmpty) {
      errors.add('Emergency Contact Name is required');
    }
    if (_emergencyContactRelationshipController.text.trim().isEmpty) {
      errors.add('Emergency Contact Relationship is required');
    }
    if (_emergencyContactPhoneController.text.trim().isEmpty) {
      errors.add('Emergency Contact Phone is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validatePermissionsStep() {
    final errors = <String>[];

    if (!_agreementToPayFees) {
      errors.add('Agreement to Pay Fees is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateBackgroundInfoStep() {
    final errors = <String>[];

    if (_languagesSpokenController.text.trim().isEmpty) {
      errors.add('Languages Spoken at Home is required');
    }
    if (_ethnicBackgroundController.text.trim().isEmpty) {
      errors.add('Ethnic Background is required');
    }
    if (_selectedFormOfIdentification == null) {
      errors.add('Form of Identification is required');
    }
    if (_idNumberController.text.trim().isEmpty) {
      errors.add('ID Number is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateFatherInfoStep() {
    final errors = <String>[];

    // Personal Information
    if (_fatherTitleController.text.trim().isEmpty) {
      errors.add('Father\'s Title is required');
    }
    if (_fatherFirstNameController.text.trim().isEmpty) {
      errors.add('Father\'s First Name is required');
    }
    if (_fatherMiddleNameController.text.trim().isEmpty) {
      errors.add('Father\'s Middle Name is required');
    }
    if (_fatherLastNameController.text.trim().isEmpty) {
      errors.add('Father\'s Last Name is required');
    }

    // Address Information
    if (_fatherStreetNumberController.text.trim().isEmpty) {
      errors.add('Father\'s Street Number is required');
    }
    if (_fatherStreetNameController.text.trim().isEmpty) {
      errors.add('Father\'s Street Name is required');
    }
    if (_fatherCityController.text.trim().isEmpty) {
      errors.add('Father\'s City is required');
    }
    if (_fatherStateController.text.trim().isEmpty) {
      errors.add('Father\'s State is required');
    }
    if (_fatherCountryController.text.trim().isEmpty) {
      errors.add('Father\'s Country is required');
    }
    if (_fatherPostalCodeController.text.trim().isEmpty) {
      errors.add('Father\'s Postal Code is required');
    }

    // Contact Information
    if (_fatherPhoneController.text.trim().isEmpty) {
      errors.add('Father\'s Phone Number is required');
    }
    if (_fatherEmailController.text.trim().isEmpty) {
      errors.add('Father\'s Email Address is required');
    }

    // Professional Information
    if (_fatherOccupationController.text.trim().isEmpty) {
      errors.add('Father\'s Occupation is required');
    }
    if (_fatherEmployerController.text.trim().isEmpty) {
      errors.add('Father\'s Employer is required');
    }

    // Legal Information
    if (_fatherFormOfIdentificationController.text.trim().isEmpty) {
      errors.add('Father\'s Form of Identification is required');
    }
    if (_fatherIdNumberController.text.trim().isEmpty) {
      errors.add('Father\'s ID Number is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateMotherInfoStep() {
    final errors = <String>[];

    // Personal Information
    if (_motherTitleController.text.trim().isEmpty) {
      errors.add('Mother\'s Title is required');
    }
    if (_motherFirstNameController.text.trim().isEmpty) {
      errors.add('Mother\'s First Name is required');
    }
    if (_motherMiddleNameController.text.trim().isEmpty) {
      errors.add('Mother\'s Middle Name is required');
    }
    if (_motherLastNameController.text.trim().isEmpty) {
      errors.add('Mother\'s Last Name is required');
    }

    // Address Information
    if (_motherStreetNumberController.text.trim().isEmpty) {
      errors.add('Mother\'s Street Number is required');
    }
    if (_motherStreetNameController.text.trim().isEmpty) {
      errors.add('Mother\'s Street Name is required');
    }
    if (_motherCityController.text.trim().isEmpty) {
      errors.add('Mother\'s City is required');
    }
    if (_motherStateController.text.trim().isEmpty) {
      errors.add('Mother\'s State is required');
    }
    if (_motherCountryController.text.trim().isEmpty) {
      errors.add('Mother\'s Country is required');
    }
    if (_motherPostalCodeController.text.trim().isEmpty) {
      errors.add('Mother\'s Postal Code is required');
    }

    // Contact Information
    if (_motherPhoneController.text.trim().isEmpty) {
      errors.add('Mother\'s Phone Number is required');
    }
    if (_motherEmailController.text.trim().isEmpty) {
      errors.add('Mother\'s Email Address is required');
    }

    // Professional Information
    if (_motherOccupationController.text.trim().isEmpty) {
      errors.add('Mother\'s Occupation is required');
    }
    if (_motherEmployerController.text.trim().isEmpty) {
      errors.add('Mother\'s Employer is required');
    }

    // Legal Information
    if (_motherFormOfIdentificationController.text.trim().isEmpty) {
      errors.add('Mother\'s Form of Identification is required');
    }
    if (_motherIdNumberController.text.trim().isEmpty) {
      errors.add('Mother\'s ID Number is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  bool _validateGuardianInfoStep() {
    final errors = <String>[];

    // Personal Information
    if (_guardianTitleController.text.trim().isEmpty) {
      errors.add('Guardian\'s Title is required');
    }
    if (_guardianFirstNameController.text.trim().isEmpty) {
      errors.add('Guardian\'s First Name is required');
    }
    if (_guardianMiddleNameController.text.trim().isEmpty) {
      errors.add('Guardian\'s Middle Name is required');
    }
    if (_guardianLastNameController.text.trim().isEmpty) {
      errors.add('Guardian\'s Last Name is required');
    }

    // Address Information
    if (_guardianStreetNumberController.text.trim().isEmpty) {
      errors.add('Guardian\'s Street Number is required');
    }
    if (_guardianStreetNameController.text.trim().isEmpty) {
      errors.add('Guardian\'s Street Name is required');
    }
    if (_guardianCityController.text.trim().isEmpty) {
      errors.add('Guardian\'s City is required');
    }
    if (_guardianStateController.text.trim().isEmpty) {
      errors.add('Guardian\'s State is required');
    }
    if (_guardianCountryController.text.trim().isEmpty) {
      errors.add('Guardian\'s Country is required');
    }
    if (_guardianPostalCodeController.text.trim().isEmpty) {
      errors.add('Guardian\'s Postal Code is required');
    }

    // Contact Information
    if (_guardianPhoneController.text.trim().isEmpty) {
      errors.add('Guardian\'s Phone Number is required');
    }
    if (_guardianEmailController.text.trim().isEmpty) {
      errors.add('Guardian\'s Email Address is required');
    }

    // Professional Information
    if (_guardianOccupationController.text.trim().isEmpty) {
      errors.add('Guardian\'s Occupation is required');
    }
    if (_guardianEmployerController.text.trim().isEmpty) {
      errors.add('Guardian\'s Employer is required');
    }

    // Legal Information
    if (_guardianFormOfIdentificationController.text.trim().isEmpty) {
      errors.add('Guardian\'s Form of Identification is required');
    }
    if (_guardianIdNumberController.text.trim().isEmpty) {
      errors.add('Guardian\'s ID Number is required');
    }

    if (errors.isNotEmpty) {
      _showValidationError(
        'Please fill in all required fields:\n${errors.join('\n')}',
      );
      return false;
    }
    return true;
  }

  void _fillFatherFieldsWithNA() {
    setState(() {
      _fatherTitleController.text = 'Mr'; // Use valid dropdown value
      _fatherFirstNameController.text = 'N/A';
      _fatherMiddleNameController.text = 'N/A';
      _fatherLastNameController.text = 'N/A';
      _fatherStreetNumberController.text = 'N/A';
      _fatherStreetNameController.text = 'N/A';
      _fatherCityController.text = 'N/A';
      _fatherStateController.text = 'N/A';
      _fatherCountryController.text = 'N/A';
      _fatherPostalCodeController.text = 'N/A';
      _fatherPhoneController.text = 'N/A';
      _fatherEmailController.text = 'N/A';
      _fatherOccupationController.text = 'N/A';
      _fatherEmployerController.text = 'N/A';
      _fatherFormOfIdentificationController.text = 'N/A';
      _fatherIdNumberController.text = 'N/A';
    });
  }

  void _fillMotherFieldsWithNA() {
    setState(() {
      _motherTitleController.text = 'Mrs'; // Use valid dropdown value
      _motherFirstNameController.text = 'N/A';
      _motherMiddleNameController.text = 'N/A';
      _motherLastNameController.text = 'N/A';
      _motherStreetNumberController.text = 'N/A';
      _motherStreetNameController.text = 'N/A';
      _motherCityController.text = 'N/A';
      _motherStateController.text = 'N/A';
      _motherCountryController.text = 'N/A';
      _motherPostalCodeController.text = 'N/A';
      _motherPhoneController.text = 'N/A';
      _motherEmailController.text = 'N/A';
      _motherOccupationController.text = 'N/A';
      _motherEmployerController.text = 'N/A';
      _motherFormOfIdentificationController.text = 'N/A';
      _motherIdNumberController.text = 'N/A';
    });
  }

  void _fillGuardianFieldsWithNA() {
    setState(() {
      _guardianTitleController.text = 'Mr'; // Use valid dropdown value
      _guardianFirstNameController.text = 'N/A';
      _guardianMiddleNameController.text = 'N/A';
      _guardianLastNameController.text = 'N/A';
      _guardianStreetNumberController.text = 'N/A';
      _guardianStreetNameController.text = 'N/A';
      _guardianCityController.text = 'N/A';
      _guardianStateController.text = 'N/A';
      _guardianCountryController.text = 'N/A';
      _guardianPostalCodeController.text = 'N/A';
      _guardianPhoneController.text = 'N/A';
      _guardianEmailController.text = 'N/A';
      _guardianOccupationController.text = 'N/A';
      _guardianEmployerController.text = 'N/A';
      _guardianFormOfIdentificationController.text = 'N/A';
      _guardianIdNumberController.text = 'N/A';
    });
  }

  bool _isSectionFilledWithNA(
    String title,
    String firstName,
    String middleName,
    String lastName,
    String streetNumber,
    String streetName,
    String city,
    String state,
    String country,
    String postalCode,
    String phone,
    String email,
    String occupation,
    String employer,
    String formOfId,
    String idNumber,
  ) {
    return title.isNotEmpty &&
        firstName == 'N/A' &&
        middleName == 'N/A' &&
        lastName == 'N/A' &&
        streetNumber == 'N/A' &&
        streetName == 'N/A' &&
        city == 'N/A' &&
        state == 'N/A' &&
        country == 'N/A' &&
        postalCode == 'N/A' &&
        phone == 'N/A' &&
        email == 'N/A' &&
        occupation == 'N/A' &&
        employer == 'N/A' &&
        formOfId == 'N/A' &&
        idNumber == 'N/A';
  }

  bool _validateAtLeastOneParentInfo() {
    // Check if Father's info is filled with N/A
    bool fatherIsNA = _isSectionFilledWithNA(
      _fatherTitleController.text,
      _fatherFirstNameController.text,
      _fatherMiddleNameController.text,
      _fatherLastNameController.text,
      _fatherStreetNumberController.text,
      _fatherStreetNameController.text,
      _fatherCityController.text,
      _fatherStateController.text,
      _fatherCountryController.text,
      _fatherPostalCodeController.text,
      _fatherPhoneController.text,
      _fatherEmailController.text,
      _fatherOccupationController.text,
      _fatherEmployerController.text,
      _fatherFormOfIdentificationController.text,
      _fatherIdNumberController.text,
    );

    // Check if Mother's info is filled with N/A
    bool motherIsNA = _isSectionFilledWithNA(
      _motherTitleController.text,
      _motherFirstNameController.text,
      _motherMiddleNameController.text,
      _motherLastNameController.text,
      _motherStreetNumberController.text,
      _motherStreetNameController.text,
      _motherCityController.text,
      _motherStateController.text,
      _motherCountryController.text,
      _motherPostalCodeController.text,
      _motherPhoneController.text,
      _motherEmailController.text,
      _motherOccupationController.text,
      _motherEmployerController.text,
      _motherFormOfIdentificationController.text,
      _motherIdNumberController.text,
    );

    // Check if Guardian's info is filled with N/A
    bool guardianIsNA = _isSectionFilledWithNA(
      _guardianTitleController.text,
      _guardianFirstNameController.text,
      _guardianMiddleNameController.text,
      _guardianLastNameController.text,
      _guardianStreetNumberController.text,
      _guardianStreetNameController.text,
      _guardianCityController.text,
      _guardianStateController.text,
      _guardianCountryController.text,
      _guardianPostalCodeController.text,
      _guardianPhoneController.text,
      _guardianEmailController.text,
      _guardianOccupationController.text,
      _guardianEmployerController.text,
      _guardianFormOfIdentificationController.text,
      _guardianIdNumberController.text,
    );

    // At least one section must not be filled with N/A
    if (fatherIsNA && motherIsNA && guardianIsNA) {
      _showValidationError(
        'At least one parent or guardian information must be properly filled.\n\n'
        'You cannot submit the form if all three sections (Father, Mother, and Guardian) are filled with "N/A".\n\n'
        'Please provide real information for at least one parent or guardian.',
      );
      return false;
    }

    return true;
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate that at least one parent/guardian info is properly filled
    if (!_validateAtLeastOneParentInfo()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the data according to the refactored API structure
      final studentData = {
        'personalInfo': {
          'firstName': _firstNameController.text.trim(),
          'middleName': _middleNameController.text.trim(),
          'lastName': _lastNameController.text.trim(),
          'dateOfBirth': _selectedDOB?.toIso8601String().split('T')[0],
          'gender': _selectedGender,
          'nationality': _selectedNationality,
          'stateOfOrigin': _selectedStateOfOrigin,
          'localGovernment': _localGovernmentController.text.trim(),
          'religion': _selectedReligion,
          'bloodGroup': _selectedBloodGroup,
          'languagesSpokenAtHome': _languagesSpokenController.text.trim(),
          'ethnicBackground': _ethnicBackgroundController.text.trim(),
          'formOfIdentification': _selectedFormOfIdentification,
          'idNumber': _idNumberController.text.trim(),
          'idPhoto': _idPhotoUrl,
          'hasSiblings': _hasSiblings,
          'siblingDetails': [], // TODO: Add sibling details collection
          'profileImage': _imageUrl,
          'passportPhoto': _idPhotoUrl,
          'previousSchool': '', // TODO: Add previous school field
        },
        'contactInfo': {
          'address': {
            'streetNumber': _streetNumberController.text.trim(),
            'streetName': _streetController.text.trim(),
            'city': _cityController.text.trim(),
            'state': _stateController.text.trim(),
            'country': _countryController.text.trim(),
            'postalCode': _postalCodeController.text.trim(),
          },
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
        },
        'academicInfo': {
          'currentClass': _selectedClassId,
          'academicYear': _selectedAcademicYear,
          'admissionDate':
              _selectedAdmissionDate?.toIso8601String().split('T')[0],
          'studentType': 'day',
        },
        'parentInfo': {
          'fatherData': {
            'personalInfo': {
              'title': _fatherTitleController.text.trim(),
              'firstName': _fatherFirstNameController.text.trim(),
              'middleName': _fatherMiddleNameController.text.trim(),
              'lastName': _fatherLastNameController.text.trim(),
              'dateOfBirth': null, // TODO: Add father DOB field
              'gender': 'male', // TODO: Add father gender field
              'maritalStatus':
                  'married', // TODO: Add father marital status field
            },
            'contactInfo': {
              'primaryPhone': _fatherPhoneController.text.trim(),
              'secondaryPhone': '', // TODO: Add father secondary phone field
              'email': _fatherEmailController.text.trim(),
              'address': {
                'streetNumber': _fatherStreetNumberController.text.trim(),
                'streetName': _fatherStreetNameController.text.trim(),
                'city': _fatherCityController.text.trim(),
                'state': _fatherStateController.text.trim(),
                'country': _fatherCountryController.text.trim(),
                'postalCode': _fatherPostalCodeController.text.trim(),
              },
            },
            'professionalInfo': {
              'occupation': _fatherOccupationController.text.trim(),
              'employer': _fatherEmployerController.text.trim(),
              'workAddress': {
                'streetNumber': '',
                'streetName': '',
                'city': '',
                'state': '',
                'country': '',
                'postalCode': '',
              },
              'workPhone': '',
              'annualIncome': 0,
            },
            'identification': {
              'idType': _fatherFormOfIdentificationController.text.trim(),
              'idNumber': _fatherIdNumberController.text.trim(),
              'idPhotoUrl': '',
            },
            'legalInfo': {
              'parentalResponsibility': true,
              'legalGuardianship': true,
              'authorisedToCollectChild': true,
              'relationshipToChild': 'Father',
            },
            'emergencyContacts': [],
            'preferences': {
              'preferredContactMethod': 'email',
              'receiveNewsletters': true,
              'receiveEventNotifications': true,
            },
          },
          'motherData': {
            'personalInfo': {
              'title': _motherTitleController.text.trim(),
              'firstName': _motherFirstNameController.text.trim(),
              'middleName': _motherMiddleNameController.text.trim(),
              'lastName': _motherLastNameController.text.trim(),
              'dateOfBirth': null, // TODO: Add mother DOB field
              'gender': 'female', // TODO: Add mother gender field
              'maritalStatus':
                  'married', // TODO: Add mother marital status field
            },
            'contactInfo': {
              'primaryPhone': _motherPhoneController.text.trim(),
              'secondaryPhone': '', // TODO: Add mother secondary phone field
              'email': _motherEmailController.text.trim(),
              'address': {
                'streetNumber': _motherStreetNumberController.text.trim(),
                'streetName': _motherStreetNameController.text.trim(),
                'city': _motherCityController.text.trim(),
                'state': _motherStateController.text.trim(),
                'country': _motherCountryController.text.trim(),
                'postalCode': _motherPostalCodeController.text.trim(),
              },
            },
            'professionalInfo': {
              'occupation': _motherOccupationController.text.trim(),
              'employer': _motherEmployerController.text.trim(),
              'workAddress': {
                'streetNumber': '',
                'streetName': '',
                'city': '',
                'state': '',
                'country': '',
                'postalCode': '',
              },
              'workPhone': '',
              'annualIncome': 0,
            },
            'identification': {
              'idType': _motherFormOfIdentificationController.text.trim(),
              'idNumber': _motherIdNumberController.text.trim(),
              'idPhotoUrl': '',
            },
            'legalInfo': {
              'parentalResponsibility': true,
              'legalGuardianship': true,
              'authorisedToCollectChild': true,
              'relationshipToChild': 'Mother',
            },
            'emergencyContacts': [],
            'preferences': {
              'preferredContactMethod': 'email',
              'receiveNewsletters': true,
              'receiveEventNotifications': true,
            },
          },
          'guardianData': {
            'personalInfo': {
              'title': _guardianTitleController.text.trim(),
              'firstName': _guardianFirstNameController.text.trim(),
              'middleName': _guardianMiddleNameController.text.trim(),
              'lastName': _guardianLastNameController.text.trim(),
              'dateOfBirth': null, // TODO: Add guardian DOB field
              'gender': 'other', // TODO: Add guardian gender field
              'maritalStatus':
                  'single', // TODO: Add guardian marital status field
            },
            'contactInfo': {
              'primaryPhone': _guardianPhoneController.text.trim(),
              'secondaryPhone': '', // TODO: Add guardian secondary phone field
              'email': _guardianEmailController.text.trim(),
              'address': {
                'streetNumber': _guardianStreetNumberController.text.trim(),
                'streetName': _guardianStreetNameController.text.trim(),
                'city': _guardianCityController.text.trim(),
                'state': _guardianStateController.text.trim(),
                'country': _guardianCountryController.text.trim(),
                'postalCode': _guardianPostalCodeController.text.trim(),
              },
            },
            'professionalInfo': {
              'occupation': _guardianOccupationController.text.trim(),
              'employer': _guardianEmployerController.text.trim(),
              'workAddress': {
                'streetNumber': '',
                'streetName': '',
                'city': '',
                'state': '',
                'country': '',
                'postalCode': '',
              },
              'workPhone': '',
              'annualIncome': 0,
            },
            'identification': {
              'idType': _guardianFormOfIdentificationController.text.trim(),
              'idNumber': _guardianIdNumberController.text.trim(),
              'idPhotoUrl': '',
            },
            'legalInfo': {
              'parentalResponsibility': _guardianParentalResponsibility,
              'legalGuardianship': _guardianLegalGuardianship,
              'authorisedToCollectChild': _guardianAuthorisedToCollectChild,
              'relationshipToChild': 'Guardian',
            },
            'emergencyContacts': [],
            'preferences': {
              'preferredContactMethod': 'email',
              'receiveNewsletters': true,
              'receiveEventNotifications': true,
            },
          },
        },
        'medicalInfo': {
          'generalPractitioner': {
            'name': _generalPractitionerNameController.text.trim(),
            'address': _generalPractitionerAddressController.text.trim(),
            'telephoneNumber': _generalPractitionerPhoneController.text.trim(),
          },
          'medicalHistory': _medicalHistoryController.text.trim(),
          'allergies':
              _allergiesController.text
                  .trim()
                  .split(',')
                  .map((e) => e.trim())
                  .where((e) => e.isNotEmpty)
                  .toList(),
          'ongoingMedicalConditions':
              _ongoingMedicalConditionsController.text.trim(),
          'specialNeeds': _specialNeedsController.text.trim(),
          'currentMedication': _currentMedicationController.text.trim(),
          'immunisationRecord': _immunisationRecordController.text.trim(),
          'dietaryRequirements': _dietaryRequirementsController.text.trim(),
          'emergencyContact': {
            'name': _emergencyContactNameController.text.trim(),
            'relationship': _emergencyContactRelationshipController.text.trim(),
            'phone': _emergencyContactPhoneController.text.trim(),
            'email': _emergencyContactEmailController.text.trim(),
            'address': {
              'streetNumber':
                  _emergencyContactStreetNumberController.text.trim(),
              'streetName': _emergencyContactStreetNameController.text.trim(),
              'city': _emergencyContactCityController.text.trim(),
              'state': _emergencyContactStateController.text.trim(),
              'country': _emergencyContactCountryController.text.trim(),
              'postalCode': _emergencyContactPostalCodeController.text.trim(),
            },
            'authorisedToCollectChild': true, // TODO: Add field for this
          },
        },
        'senInfo': {
          'hasSpecialNeeds': _hasSpecialNeeds,
          'receivingAdditionalSupport': _receivingAdditionalSupport,
          'supportDetails': _supportDetailsController.text.trim(),
          'hasEHCP': _hasEHCP,
          'ehcpDetails': _ehcpDetailsController.text.trim(),
        },
        'permissions': {
          'emergencyMedicalTreatment': _emergencyMedicalTreatment,
          'administrationOfMedication': _administrationOfMedication,
          'firstAidConsent': _firstAidConsent,
          'outingsAndTrips': _outingsAndTrips,
          'transportConsent': _transportConsent,
          'useOfPhotosVideos': _useOfPhotosVideos,
          'suncreamApplication': _suncreamApplication,
          'observationAndAssessment': _observationAndAssessment,
        },
        'sessionInfo': {
          'requestedStartDate':
              _selectedAdmissionDate?.toIso8601String().split('T')[0],
          'daysOfAttendance': _daysOfAttendanceController.text.trim(),
          'fundedHours': _fundedHoursController.text.trim(),
          'additionalPaidSessions':
              _additionalPaidSessionsController.text.trim(),
          'preferredSettlingInSessions':
              _preferredSettlingInSessionsController.text.trim(),
        },
        'backgroundInfo': {
          'previousChildcareProvider':
              _previousChildcareProviderController.text.trim(),
          'siblings': [], // TODO: Add sibling details collection
          'interests': _interestsController.text.trim(),
          'toiletTrainingStatus': _toiletTrainingStatusController.text.trim(),
          'comfortItems': _comfortItemsController.text.trim(),
          'sleepRoutine': _sleepRoutineController.text.trim(),
          'behaviouralConcerns': _behaviouralConcernsController.text.trim(),
          'languagesSpokenAtHome': _languagesSpokenController.text.trim(),
        },
        'legalInfo': {
          'legalResponsibility': _legalResponsibilityController.text.trim(),
          'courtOrders': _courtOrdersController.text.trim(),
          'safeguardingDisclosure':
              _safeguardingDisclosureController.text.trim(),
          'parentSignature': _parentSignatureController.text.trim(),
          'signatureDate': DateTime.now().toIso8601String().split('T')[0],
        },
        'fundingInfo': {
          'agreementToPayFees': _agreementToPayFees,
          'fundingAgreement': _fundingAgreementController.text.trim(),
        },
        'financialInfo': {
          'feeStatus': 'unpaid',
          'totalFees': 0,
          'paidAmount': 0,
          'outstandingBalance': 0,
        },
        'additionalInfo': '', // TODO: Add additional info field
      };

      // Debug logging
      print('Creating student with data structure:');
      print('Personal Info: ${studentData['personalInfo']}');
      print('Contact Info: ${studentData['contactInfo']}');
      print('Academic Info: ${studentData['academicInfo']}');
      print('Parent Info: ${studentData['parentInfo']}');
      print('Medical Info: ${studentData['medicalInfo']}');
      print('Funding Info: ${studentData['fundingInfo']}');

      final response = await ref
          .read(studentProvider.notifier)
          .createStudent(context, studentData);

      if (!mounted) return;

      if (response != null) {
        // Refresh the students list to show updated data
        await ref.read(studentProvider.notifier).getAllStudents(context);

        if (!mounted) return;

        // Show credentials dialog if they exist
        if (response['data']?['loginCredentials'] != null ||
            (response['data']?['parentCredentials'] != null &&
                (response['data']['parentCredentials'] as List).isNotEmpty)) {
          _showCredentialsDialog(context, response);
        } else {
          // Navigate back to students list
          context.go('/students');
        }
      }
    } catch (e) {
      if (!mounted) return;
      showSnackbar(context, 'Error creating student: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  // Image upload methods
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

        // Automatically upload the image
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Error picking image: $e');
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      // Check if camera is available (not available on web)
      if (kIsWeb) {
        showSnackbar(
          context,
          'Camera not available on web. Please use gallery instead.',
        );
        return;
      }

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

        // Automatically upload the image
        await _uploadImageToCloudinary();
      }
    } catch (e) {
      if (mounted) {
        showSnackbar(context, 'Error taking photo: $e');
      }
    }
  }

  // Test Cloudinary configuration
  // Removed _testCloudinaryConnection method - no longer needed

  // Removed _verifyCredentials method - no longer needed

  Future<void> _uploadImageToCloudinary() async {
    if (_selectedImageFile == null) return;

    setState(() {
      _isUploadingImage = true;
    });

    try {
      // Compress the image
      final compressedImageBytes = await _compressImage(_selectedImageFile!);
      debugPrint(
        '📸 Compressed image size: ${compressedImageBytes.length} bytes',
      );

      // Use the new robust upload method
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        setState(() {
          _imageUrl = uploadedUrl;
          debugPrint('✅ Image URL set: $_imageUrl');
        });

        if (mounted) {
          showSnackbar(context, 'Image uploaded successfully!');
        }
      } else {
        throw Exception(
          'All upload strategies failed. Please check your Cloudinary configuration.',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error uploading image';
        if (e.toString().contains('Upload failed')) {
          errorMessage = e.toString();
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Upload timeout. Please try again.';
        } else if (e.toString().contains('All upload presets failed')) {
          errorMessage = 'Upload configuration error. Please contact support.';
        } else {
          errorMessage = 'Error uploading image: ${e.toString()}';
        }

        showSnackbar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImage = false;
        });
      }
    }
  }

  // New robust upload method with multiple strategies
  Future<String?> _robustCloudinaryUpload(Uint8List imageBytes) async {
    debugPrint('🚀 Starting robust Cloudinary upload...');

    // Strategy 1: Direct upload with your preset
    try {
      debugPrint(
        '📤 Strategy 1: Direct upload with preset "${AppConstants.cloudinaryPreset}"',
      );
      final result = await _directUpload(
        imageBytes,
        AppConstants.cloudinaryPreset,
      );
      if (result != null) {
        debugPrint('✅ Strategy 1 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 1 failed: $e');
    }

    // Strategy 2: Upload with base64 encoding
    try {
      debugPrint('📤 Strategy 2: Base64 upload');
      final result = await _base64Upload(imageBytes);
      if (result != null) {
        debugPrint('✅ Strategy 2 successful!');
        return result;
      }
    } catch (e) {
      debugPrint('❌ Strategy 2 failed: $e');
    }

    // Strategy 3: Upload with different presets
    final fallbackPresets = ['unsigned_preset', 'ml_default', 'default'];
    for (String preset in fallbackPresets) {
      try {
        debugPrint('📤 Strategy 3: Trying preset "$preset"');
        final result = await _directUpload(imageBytes, preset);
        if (result != null) {
          debugPrint('✅ Strategy 3 successful with preset "$preset"!');
          return result;
        }
      } catch (e) {
        debugPrint('❌ Strategy 3 failed with preset "$preset": $e');
      }
    }

    debugPrint('❌ All upload strategies failed');
    return null;
  }

  // Direct upload method
  Future<String?> _directUpload(Uint8List imageBytes, String preset) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse(
        'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
      ),
    );

    request.fields['upload_preset'] = preset;
    request.fields['folder'] = 'students';
    request.fields['public_id'] =
        'student_${DateTime.now().millisecondsSinceEpoch}';

    // Note: Transformation parameters are not allowed with unsigned uploads
    // The preset should handle transformations if needed

    request.files.add(
      http.MultipartFile.fromBytes(
        'file',
        imageBytes,
        filename: 'student_image.jpg',
      ),
    );

    final response = await request.send().timeout(const Duration(seconds: 30));
    final responseBody = await response.stream.bytesToString();

    debugPrint('📊 Upload response status: ${response.statusCode}');
    debugPrint('📊 Upload response body: $responseBody');

    if (response.statusCode == 200) {
      final data = json.decode(responseBody);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception('Upload failed: ${response.statusCode} - $responseBody');
    }
  }

  // Base64 upload method
  Future<String?> _base64Upload(Uint8List imageBytes) async {
    final base64Image = base64Encode(imageBytes);

    final response = await http
        .post(
          Uri.parse(
            'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/image/upload',
          ),
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'file': 'data:image/jpeg;base64,$base64Image',
            'upload_preset': AppConstants.cloudinaryPreset,
            'folder': 'students',
            'public_id': 'student_${DateTime.now().millisecondsSinceEpoch}',
            // Note: Transformation parameters are not allowed with unsigned uploads
          }),
        )
        .timeout(const Duration(seconds: 30));

    debugPrint('📊 Base64 upload response status: ${response.statusCode}');
    debugPrint('📊 Base64 upload response body: ${response.body}');

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['secure_url'] ?? data['url'];
    } else {
      throw Exception(
        'Base64 upload failed: ${response.statusCode} - ${response.body}',
      );
    }
  }

  Future<Uint8List> _compressImage(XFile imageFile) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        throw Exception(
          'Could not decode image. Please try a different image.',
        );
      }

      // Resize image if it's too large (max 800px on longest side)
      img.Image resizedImage = image;
      if (image.width > 800 || image.height > 800) {
        resizedImage = img.copyResize(
          image,
          width: image.width > image.height ? 800 : null,
          height: image.height > image.width ? 800 : null,
          maintainAspect: true,
        );
      }

      // Compress the image with good quality
      final compressedBytes = img.encodeJpg(resizedImage, quality: 90);
      return Uint8List.fromList(compressedBytes);
    } catch (e) {
      throw Exception('Failed to process image: ${e.toString()}');
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
              if (!kIsWeb) // Only show camera option on mobile platforms
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

  void _showIdPhotoPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select ID Photo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickIdPhoto();
                },
              ),
              if (!kIsWeb) // Only show camera option on mobile platforms
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () {
                    Navigator.of(context).pop();
                    _takeIdPhoto();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickIdPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedIdPhotoFile = image;
      });

      // Automatically upload the ID photo
      await _uploadIdPhotoToCloudinary();
    }
  }

  Future<void> _takeIdPhoto() async {
    final XFile? image = await _imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );

    if (image != null) {
      setState(() {
        _selectedIdPhotoFile = image;
      });

      // Automatically upload the ID photo
      await _uploadIdPhotoToCloudinary();
    }
  }

  Future<void> _uploadIdPhotoToCloudinary() async {
    if (_selectedIdPhotoFile == null) return;

    setState(() {
      _isUploadingIdPhoto = true;
    });

    try {
      // Compress the image
      final compressedImageBytes = await _compressImage(_selectedIdPhotoFile!);
      debugPrint(
        '📸 Compressed ID photo size: ${compressedImageBytes.length} bytes',
      );

      // Use the new robust upload method
      final uploadedUrl = await _robustCloudinaryUpload(compressedImageBytes);

      if (uploadedUrl != null) {
        setState(() {
          _idPhotoUrl = uploadedUrl;
          debugPrint('✅ ID Photo URL set: $_idPhotoUrl');
        });

        if (mounted) {
          showSnackbar(context, 'ID Photo uploaded successfully!');
        }
      } else {
        throw Exception(
          'All upload strategies failed. Please check your Cloudinary configuration.',
        );
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error uploading ID photo';
        if (e.toString().contains('Upload failed')) {
          errorMessage = e.toString();
        } else if (e.toString().contains('SocketException')) {
          errorMessage =
              'Network error. Please check your internet connection.';
        } else if (e.toString().contains('TimeoutException')) {
          errorMessage = 'Upload timeout. Please try again.';
        } else if (e.toString().contains('All upload presets failed')) {
          errorMessage = 'Upload configuration error. Please contact support.';
        } else {
          errorMessage = 'Error uploading ID photo: ${e.toString()}';
        }

        showSnackbar(context, errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingIdPhoto = false;
        });
      }
    }
  }

  Widget _buildIdPhotoPreview() {
    if (_idPhotoUrl != null) {
      // Show uploaded image from Cloudinary
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _idPhotoUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.badge, size: 40, color: Colors.grey);
          },
        ),
      );
    } else if (_selectedIdPhotoFile != null) {
      // Show selected image (web-compatible)
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            (_selectedIdPhotoBytes != null)
                ? Image.memory(_selectedIdPhotoBytes!, fit: BoxFit.cover)
                : (kIsWeb
                    ? Image.network(
                      _selectedIdPhotoFile!.path,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.badge,
                          size: 40,
                          color: Colors.grey,
                        );
                      },
                    )
                    : const SizedBox.shrink()),
      );
    } else {
      // Show placeholder
      return const Icon(Icons.badge, size: 40, color: Colors.grey);
    }
  }

  Widget _buildImagePreview() {
    if (_imageUrl != null) {
      // Show uploaded image from Cloudinary
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          _imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return const Icon(Icons.person, size: 40, color: Colors.grey);
          },
        ),
      );
    } else if (_selectedImageFile != null) {
      // Show selected image (web-compatible)
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child:
            (_selectedImageBytes != null)
                ? Image.memory(_selectedImageBytes!, fit: BoxFit.cover)
                : (kIsWeb
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
                    : const SizedBox.shrink()),
      );
    } else {
      // Show placeholder
      return const Icon(Icons.person, size: 40, color: Colors.grey);
    }
  }

  Widget _buildImageUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Profile Picture',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a clear photo of the student',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Image display and upload button
          Row(
            children: [
              // Image preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[100],
                ),
                child: _buildImagePreview(),
              ),
              const SizedBox(width: 16),

              // Upload button and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
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
                                  : const Icon(Icons.upload),
                          label: Text(
                            _isUploadingImage ? 'Uploading...' : 'Upload Image',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_imageUrl != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Image uploaded successfully',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                ),
                              ),
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
  }

  Widget _buildIdPhotoUploadSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'ID Photo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload a clear photo of the student\'s ID document',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // Image display and upload button
          Row(
            children: [
              // Image preview
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey[300]!),
                  color: Colors.grey[100],
                ),
                child: _buildIdPhotoPreview(),
              ),
              const SizedBox(width: 16),

              // Upload button and status
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        ElevatedButton.icon(
                          onPressed:
                              _isUploadingIdPhoto
                                  ? null
                                  : _showIdPhotoPickerDialog,
                          icon:
                              _isUploadingIdPhoto
                                  ? const SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                  : const Icon(Icons.upload),
                          label: Text(
                            _isUploadingIdPhoto
                                ? 'Uploading...'
                                : 'Upload ID Photo',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.orange,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (_idPhotoUrl != null)
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.green[50],
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.green[200]!),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: Colors.green[600],
                              size: 16,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'ID Photo uploaded successfully',
                                style: TextStyle(
                                  color: Colors.green[700],
                                  fontSize: 12,
                                ),
                              ),
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
  }

  void _showCredentialsDialog(
    BuildContext context,
    Map<String, dynamic> response,
  ) {
    final data = response['data'];
    final student = data?['student'];
    final loginCredentials = data?['loginCredentials'];
    final parentCredentials = data?['parentCredentials'] as List<dynamic>?;
    // Normalize parents credentials (support both Map { parents: [...] } and List [...])
    final dynamic loginCredentialsRaw = data?['loginCredentials'];
    final List<dynamic> parentsFromLogin =
        loginCredentialsRaw is List
            ? loginCredentialsRaw
            : (loginCredentialsRaw is Map &&
                    loginCredentialsRaw['parents'] is List
                ? (loginCredentialsRaw['parents'] as List)
                : <dynamic>[]);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Row(
            children: [
              Icon(Icons.security, color: Color(0xFF6366F1)),
              SizedBox(width: 8),
              Text(
                'Student Created Successfully!',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Success Message
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green[600],
                        size: 20,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Student ${student?['personalInfo']?['firstName'] ?? ''} ${student?['personalInfo']?['lastName'] ?? ''} has been successfully created!',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),

                // Student Details (new response shape)
                if (student != null) ...[
                  _buildCredentialSection(
                    'Student Information',
                    Icons.person,
                    Color(0xFF10B981),
                    [
                      _buildCredentialItem(
                        'Full Name',
                        student['name'] ?? 'N/A',
                      ),
                      _buildCredentialItem(
                        'Admission Number',
                        student['admissionNumber'] ?? 'N/A',
                      ),
                      _buildCredentialItem('Class', student['class'] ?? 'N/A'),
                    ],
                  ),
                  SizedBox(height: 16),
                ],

                // Student Login Credentials (not in new response, keep guarded-off)
                if (student?['user'] != null) ...[
                  _buildCredentialSection(
                    'Student Login Credentials',
                    Icons.school,
                    Color(0xFF3B82F6),
                    [
                      _buildCredentialItem(
                        'Email',
                        student['user']['email'] ?? 'N/A',
                      ),
                      _buildCredentialItem(
                        'Student ID',
                        student['user']['_id'] ?? 'N/A',
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                ],

                // Parent Login Credentials (from loginCredentials.parents or direct list)
                if (parentsFromLogin.isNotEmpty) ...[
                  _buildCredentialSection(
                    'Parent Login Credentials',
                    Icons.family_restroom,
                    Color(0xFF8B5CF6),
                    parentsFromLogin
                        .map<Widget>(
                          (parent) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${parent['parentType']?.toString().toUpperCase()} - ${parent['fullName']}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFF374151),
                                  fontSize: 14,
                                ),
                              ),
                              SizedBox(height: 8),
                              _buildCredentialItem('Email', parent['email']),
                              _buildCredentialItem(
                                'Temporary Password',
                                parent['temporaryPassword'],
                              ),
                              _buildCredentialItem(
                                'Parent ID',
                                parent['parentId'],
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],

                // Alternative parent credentials format
                if (parentCredentials != null &&
                    parentCredentials.isNotEmpty) ...[
                  _buildCredentialSection(
                    'Parent Login Credentials',
                    Icons.family_restroom,
                    Color(0xFF8B5CF6),
                    parentCredentials
                        .map<Widget>(
                          (credential) => Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildCredentialItem(
                                'Email',
                                credential['email'],
                              ),
                              _buildCredentialItem(
                                'Temporary Password',
                                credential['temporaryPassword'],
                              ),
                              _buildCredentialItem(
                                'Parent ID',
                                credential['parentId'],
                              ),
                              SizedBox(height: 12),
                            ],
                          ),
                        )
                        .toList(),
                  ),
                ],

                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.amber[600], size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please save these credentials securely. Parents will need them to log in.',
                          style: TextStyle(
                            color: Colors.amber[700],
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.go('/students');
              },
              child: Text(
                'Done',
                style: TextStyle(
                  color: Color(0xFF6366F1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCredentialSection(
    String title,
    IconData icon,
    Color color,
    List<Widget> items,
  ) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          ...items,
        ],
      ),
    );
  }

  Widget _buildCredentialItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF64748B),
              ),
            ),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF0F172A),
                fontFamily: 'monospace',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
