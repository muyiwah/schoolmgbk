import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/single_class_model.dart';
import 'package:schmgtsystem/models/attendance_model.dart';
import 'package:schmgtsystem/models/communication_model.dart';
import 'package:schmgtsystem/models/class_payment_data_model.dart' as payment;
import 'package:schmgtsystem/models/fee_breakdown_model.dart' as fee;
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/message_popup.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';
import 'package:schmgtsystem/utils/academic_year_helper.dart';
import 'package:schmgtsystem/repository/class_repo.dart';
import 'package:schmgtsystem/repository/payment_repo.dart';
import 'package:schmgtsystem/utils/locator.dart';
import 'package:schmgtsystem/utils/response_model.dart';

class ClassDetailsScreen extends ConsumerStatefulWidget {
  final String classId;

  const ClassDetailsScreen({super.key, required this.classId});

  @override
  ConsumerState<ClassDetailsScreen> createState() => _ClassDetailsScreenState();
}

class _ClassDetailsScreenState extends ConsumerState<ClassDetailsScreen> {
  int selectedTabIndex = 0;
  bool _isLoading = true;
  String? _errorMessage;
  SingleClass _localClassData = SingleClass(); // Local state for class data

  // Attendance state
  DateTime _selectedDate = DateTime.now();
  final Map<String, String> _attendanceStatus = {};
  final Map<String, String> _attendanceRemarks = {};
  bool _isSubmittingAttendance = false;
  bool _hasUnsavedChanges = false;

  // Payment data state
  payment.ClassPaymentDataResponse? _paymentData;
  bool _isLoadingPaymentData = false;
  String? _paymentErrorMessage;

  // Fee breakdown state
  fee.FeeBreakdownResponse? _feeBreakdownData;
  bool _isLoadingFeeBreakdown = false;
  String? _feeBreakdownErrorMessage;

  @override
  void initState() {
    super.initState();
    _loadClassData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when screen becomes active (e.g., when navigating back)
    _loadClassData();
  }

  @override
  void didUpdateWidget(ClassDetailsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (selectedTabIndex == 1) {
      _loadAttendanceForDate();
    }
  }

  Future<void> _loadClassData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      print(
        'Loading class data directly from API for classId: ${widget.classId}',
      );

      // Call the API directly instead of going through provider
      final classRepository = locator<ClassRepo>();
      final response = await classRepository.getSingleClass(widget.classId);

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        print('Raw API response: ${response.data}');
        try {
          _localClassData = SingleClass.fromJson(response.data);
          print('✅ Class data loaded directly from API');
          print(
            '✅ Class teacher: ${_localClassData.data?.dataClass?.classTeacher?.name ?? 'None'}',
          );
        } catch (e) {
          print('❌ Error parsing class data: $e');
          print('❌ Error type: ${e.runtimeType}');
          _errorMessage = 'Failed to parse class data: $e';
        }
      } else {
        print('❌ Failed to load class: ${response.message}');
        _errorMessage = 'Failed to load class data: ${response.message}';
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading class data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Failed to load class data: $e';
        });
      }
    }
  }

  Future<void> _loadAttendanceForDate() async {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final dateString = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // First, ensure we have class data loaded
    if (classProvider.singlgeClassData.data?.students == null) {
      await _loadClassData();
    }

    // Try to fetch existing attendance data for the date
    await attendanceProvider.getAttendanceByDate(
      classId: widget.classId,
      date: dateString,
    );

    // Initialize all students with default absent status
    _initializeAllStudentsWithDefaultStatus();

    // If we have existing attendance data, update the UI
    if (attendanceProvider.hasAttendanceData) {
      _populateExistingAttendance();
    }

    setState(() {});
  }

  double _parseToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is num) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  Future<void> _loadPaymentData() async {
    try {
      setState(() {
        _isLoadingPaymentData = true;
        _paymentErrorMessage = null;
      });

      // Use the existing class data instead of making a separate API call
      // since the payment endpoint returns empty data
      if (_localClassData.data != null) {
        try {
          // Convert the existing class data to payment data format
          final classData = _localClassData.data!;

          // Create payment data from existing class data
          _paymentData = payment.ClassPaymentDataResponse(
            classInfo: payment.ClassInfo(
              id: classData.dataClass?.id ?? '',
              name: classData.dataClass?.name ?? '',
              level: classData.dataClass?.level ?? '',
              section: classData.dataClass?.section,
              classTeacher: classData.dataClass?.classTeacher?.name,
            ),
            students:
                classData.students
                    ?.map(
                      (student) => payment.StudentPaymentInfo(
                        id: student.id ?? '',
                        name: student.name ?? '',
                        admissionNumber: student.admissionNumber ?? '',
                        parentName: student.parentName ?? '',
                        feeStatus: student.feeStatus ?? 'unknown',
                        todayAttendance:
                            student.todayAttendance ?? 'Not Marked',
                      ),
                    )
                    .toList() ??
                [],
            metrics: payment.PaymentMetrics(
              totalStudents: classData.metrics?.totalStudents ?? 0,
              maleStudents: classData.metrics?.maleStudents ?? 0,
              femaleStudents: classData.metrics?.femaleStudents ?? 0,
              genderRatio: payment.GenderRatio(
                male: _parseToDouble(classData.metrics?.genderRatio?.male),
                female: _parseToDouble(classData.metrics?.genderRatio?.female),
              ),
              feeStatus: payment.FeeStatus(
                paid: classData.metrics?.feeStatus?.paid ?? 0,
                partial: classData.metrics?.feeStatus?.partial ?? 0,
                unpaid: classData.metrics?.feeStatus?.unpaid ?? 0,
              ),
              feeCollectionRate: _parseToDouble(
                classData.metrics?.feeCollectionRate,
              ),
              todayAttendance: payment.TodayAttendance(
                present: classData.metrics?.todayAttendance?.present ?? 0,
                absent: classData.metrics?.todayAttendance?.absent ?? 0,
                late: classData.metrics?.todayAttendance?.late ?? 0,
                notMarked: classData.metrics?.todayAttendance?.notMarked ?? 0,
                attendancePercentage: _parseToDouble(
                  classData.metrics?.todayAttendance?.attendancePercentage,
                ),
              ),
              enrollmentRate: _parseToDouble(classData.metrics?.enrollmentRate),
              availableSlots: classData.metrics?.availableSlots ?? 0,
              currentFeeStructure: payment.CurrentFeeStructure(
                baseFee: _parseToDouble(
                  classData.metrics?.currentFeeStructure?.baseFee,
                ),
                totalFee: _parseToDouble(
                  classData.metrics?.currentFeeStructure?.totalFee,
                ),
                term: classData.metrics?.currentFeeStructure?.term ?? '',
                academicYear:
                    classData.metrics?.currentFeeStructure?.academicYear ?? '',
              ),
            ),
            academicInfo: payment.AcademicInfo(
              currentAcademicYear:
                  classData.academicInfo?.currentAcademicYear ?? '',
              currentTerm: classData.academicInfo?.currentTerm ?? '',
              attendanceDate:
                  classData.academicInfo?.attendanceDate?.toString() ?? '',
            ),
            recentCommunications: classData.recentCommunications ?? [],
          );

          print('✅ Payment data loaded from existing class data');
          print('Class name: ${_paymentData?.classInfo.name}');
          print('Total students: ${_paymentData?.metrics.totalStudents}');
          print('Male students: ${_paymentData?.metrics.maleStudents}');
          print('Female students: ${_paymentData?.metrics.femaleStudents}');
          print(
            'Base fee: ${_paymentData?.metrics.currentFeeStructure.baseFee}',
          );
        } catch (e) {
          print('❌ Error converting class data to payment data: $e');
          _paymentErrorMessage = 'Failed to convert class data: $e';
        }
      } else {
        _paymentErrorMessage = 'No class data available';
      }

      if (mounted) {
        setState(() {
          _isLoadingPaymentData = false;
        });
      }
    } catch (e) {
      print('Error loading payment data: $e');
      if (mounted) {
        setState(() {
          _isLoadingPaymentData = false;
          _paymentErrorMessage = 'Failed to load payment data: $e';
        });
      }
    }
  }

  Future<void> _loadFeeBreakdown() async {
    try {
      setState(() {
        _isLoadingFeeBreakdown = true;
        _feeBreakdownErrorMessage = null;
      });

      final currentTerm = AcademicYearHelper.getCurrentTerm(ref);
      final paymentRepository = locator<PaymentRepository>();

      final response = await paymentRepository.getClassFeeBreakdown(
        classId: widget.classId,
        term: currentTerm,
      );

      if (HTTPResponseModel.isApiCallSuccess(response)) {
        try {
          print('Raw fee breakdown response: ${response.data}');
          _feeBreakdownData = fee.FeeBreakdownResponse.fromJson(response.data);
          print('✅ Fee breakdown data loaded successfully');
          print('Class name: ${_feeBreakdownData?.data.classInfo.name}');
          print(
            'Total students: ${_feeBreakdownData?.data.paymentStatistics.totalStudents}',
          );
          print(
            'Paid students: ${_feeBreakdownData?.data.paymentStatistics.paidStudents}',
          );
          print(
            'Total outstanding: ${_feeBreakdownData?.data.paymentStatistics.totalOutstandingAmount}',
          );
          print(
            'Expected revenue: ${_feeBreakdownData?.data.paymentStatistics.expectedRevenue}',
          );
          print(
            'Collection rate: ${_feeBreakdownData?.data.paymentStatistics.collectionRate}',
          );
          print(
            'Total amount paid: ${_feeBreakdownData?.data.paymentStatistics.totalAmountPaid}',
          );
          print(
            'Total amount left: ${_feeBreakdownData?.data.paymentStatistics.totalAmountLeft}',
          );
        } catch (e) {
          print('❌ Error parsing fee breakdown data: $e');
          _feeBreakdownErrorMessage = 'Failed to parse fee breakdown data: $e';
        }
      } else {
        print('❌ Failed to load fee breakdown data: ${response.message}');
        _feeBreakdownErrorMessage =
            'Failed to load fee breakdown data: ${response.message}';
      }

      if (mounted) {
        setState(() {
          _isLoadingFeeBreakdown = false;
        });
      }
    } catch (e) {
      print('Error loading fee breakdown data: $e');
      if (mounted) {
        setState(() {
          _isLoadingFeeBreakdown = false;
          _feeBreakdownErrorMessage = 'Failed to load fee breakdown data: $e';
        });
      }
    }
  }

  void _initializeAllStudentsWithDefaultStatus() {
    final students = _localClassData.data?.students ?? [];

    // Initialize all students with default absent status
    for (var student in students) {
      final studentId = student.id ?? student.admissionNumber ?? 'N/A';
      if (!_attendanceStatus.containsKey(studentId)) {
        _attendanceStatus[studentId] = 'absent';
        _attendanceRemarks[studentId] = '';
      }
    }
  }

  void _populateExistingAttendance() {
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);
    final records = attendanceProvider.attendanceRecords;

    // Update status and remarks for students who have existing attendance records
    for (var record in records) {
      _attendanceStatus[record.student.id] = record.status;
      _attendanceRemarks[record.student.id] = record.remarks;
    }
  }

  void _markStudentAttendance(String studentId, String status) {
    setState(() {
      _attendanceStatus[studentId] = status;
      _hasUnsavedChanges = true;
    });
  }

  void _updateStudentRemarks(String studentId, String remarks) {
    setState(() {
      _attendanceRemarks[studentId] = remarks;
      _hasUnsavedChanges = true;
    });
  }

  Future<void> _submitAttendance() async {
    final classProvider = ref.read(RiverpodProvider.classProvider);
    final students = classProvider.singlgeClassData.data?.students ?? [];
    final attendanceProvider = ref.read(RiverpodProvider.attendanceProvider);

    if (students.isEmpty) {
      showSnackbar(context, 'No students found for this class');
      return;
    }

    // Create attendance records for all students in the class
    final allStudentRecords =
        students.map((student) {
          final studentId = student.id ?? student.admissionNumber ?? 'N/A';
          final status = _attendanceStatus[studentId] ?? 'absent';
          final remarks = _attendanceRemarks[studentId] ?? '';

          return AttendanceRecord(
            studentId: studentId,
            status: status,
            remarks: remarks,
          );
        }).toList();

    setState(() {
      _isSubmittingAttendance = true;
    });

    try {
      final profileProvider = ref.read(RiverpodProvider.profileProvider);
      final user = profileProvider.user;

      if (user == null) {
        showSnackbar(context, 'User not found. Please login again.');
        return;
      }

      final request = MarkAttendanceRequest(
        date: DateFormat('yyyy-MM-dd').format(_selectedDate),
        term: AcademicYearHelper.getCurrentTerm(ref),
        academicYear: AcademicYearHelper.getCurrentAcademicYear(ref),
        markerId: user.id ?? '',
        records: allStudentRecords,
      );

      final success = await attendanceProvider.markAttendance(
        classId: widget.classId,
        request: request,
      );

      if (success) {
        showSnackbar(context, 'Attendance marked successfully!');
        setState(() {
          _hasUnsavedChanges = false;
        });

        // Reload the attendance data
        await _loadAttendanceForDate();
      } else {
        showSnackbar(
          context,
          attendanceProvider.errorMessage ?? 'Failed to mark attendance',
        );
      }
    } catch (e) {
      showSnackbar(context, 'Error: ${e.toString()}');
    } finally {
      setState(() {
        _isSubmittingAttendance = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading class details...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loadClassData,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final classData = _localClassData;

    print('ClassData received: ${classData.toJson()}');
    print('ClassData.data: ${classData.data}');
    print('ClassData.data?.dataClass: ${classData.data?.dataClass}');
    print(
      'Class teacher name: ${classData.data?.dataClass?.classTeacher?.name}',
    );

    if (classData.data == null) {
      return Scaffold(
        backgroundColor: Colors.grey[50],
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text('No class data found'),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          _buildClassOverview(classData.data!),
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 3, child: _buildMainContent(classData.data!)),
                const SizedBox(width: 16),
                Expanded(flex: 1, child: _buildSidebar(classData.data!)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClassOverview(Data data) {
    final classInfo = data.dataClass;
    final metrics = data.metrics;
    final classTeacher = classInfo?.classTeacher;

    return Stack(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.secondary, Color(0xFF8B5CF6)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Class Details – ${classInfo?.name ?? 'Unknown Class'}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${classInfo?.level ?? 'Unknown Level'} ${classInfo?.section ?? ''}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Comprehensive view of class assignments, performance, and student information',
                      style: TextStyle(fontSize: 14, color: Colors.white70),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor: Colors.white.withOpacity(0.2),
                          child: Text(
                            classTeacher?.name?.substring(0, 1).toUpperCase() ??
                                '?',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              classTeacher?.name ?? 'No Class Teacher',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Staff ID: ${classTeacher?.staffId ?? 'N/A'}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.phone,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.email,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                                const SizedBox(width: 4),
                                Icon(
                                  Icons.message,
                                  size: 14,
                                  color: Colors.white70,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                children: [
                  Text(
                    '${metrics?.totalStudents ?? 0}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const Text(
                    'Total Students',
                    style: TextStyle(fontSize: 12, color: Colors.white70),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildGenderIcon('👨', '${metrics?.maleStudents ?? 0}'),
                      const SizedBox(width: 8),
                      _buildGenderIcon('👩', '${metrics?.femaleStudents ?? 0}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Text(
                      '${metrics?.todayAttendance?.attendancePercentage ?? 0}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const Text(
                      'Today\'s Attendance',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Column(
                children: [
                  _buildActionButton(
                    '📧 Message Class Teacher',
                    Colors.white,
                    const Color(0xFF6366F1),
                    data,
                  ),
                  const SizedBox(height: 8),

                  _buildActionButton(
                    '✏️ Message Single Parent',
                    AppColors.tertiary3,
                    Colors.white,
                    data,
                  ),
                  const SizedBox(height: 8),
                  _buildActionButton(
                    '👤 Message All Parents',
                    const Color(0xFF06B6D4),
                    Colors.white,
                    data,
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          top: 20,
          left: 0,
          child: IconButton(
            onPressed: () {
              context.pop();
            },
            icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderIcon(String emoji, String count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 12)),
          const SizedBox(width: 2),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton(
    String text,
    Color bgColor,
    Color textColor,
    Data classData,
  ) {
    return ElevatedButton(
      onPressed: () {
        if (text.contains('Message Class Teacher')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to Class Teacher',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  communicationType: CommunicationType.adminTeacher,
                ),
          );
        }
        if (text.contains('Single')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to a Parent',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  communicationType: CommunicationType.adminParent,
                ),
          );
        }
        if (text.contains('All')) {
          showDialog(
            context: context,
            barrierDismissible: true,
            barrierColor: Colors.black.withOpacity(0.5),
            builder:
                (context) => MessagePopup(
                  title: 'Message to all Parents',
                  classId: classData.dataClass?.id ?? '',
                  classData: classData,
                  parentIds: _getAllParentIds(classData),
                  communicationType: CommunicationType.adminParent,
                ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: bgColor,
        foregroundColor: textColor,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 0,
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }

  List<String> _getAllParentIds(Data classData) {
    // Since parentId doesn't exist in Student model, we'll return student IDs for now
    // The backend will use these student IDs to find the associated parents
    // This would need to be updated when parentId is added to the Student model
    return classData.students
            ?.map((student) => student.id ?? '')
            .where((id) => id.isNotEmpty)
            .toList() ??
        [];
  }

  Widget _buildMainContent(Data data) {
    return Container(
      margin: const EdgeInsets.all(16),
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
        children: [_buildTabBar(), Expanded(child: _buildTabContent(data))],
      ),
    );
  }

  Widget _buildTabBar() {
    final tabs = [
      'Students List',
      'Attendance',
      'Payment Data',
      'Fee Breakdown',
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children:
            tabs.asMap().entries.map((entry) {
              final index = entry.key;
              final tab = entry.value;
              final isSelected = index == selectedTabIndex;

              return GestureDetector(
                onTap: () {
                  setState(() => selectedTabIndex = index);
                  if (index == 1) {
                    _loadAttendanceForDate();
                  } else if (index == 2) {
                    _loadPaymentData();
                  } else if (index == 3) {
                    _loadFeeBreakdown();
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(right: 16),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(
                        color:
                            isSelected
                                ? const Color(0xFF6366F1)
                                : Colors.transparent,
                        width: 2,
                      ),
                    ),
                  ),
                  child: Text(
                    tab,
                    style: TextStyle(
                      color:
                          isSelected
                              ? const Color(0xFF6366F1)
                              : Colors.grey[600],
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }

  Widget _buildTabContent(Data data) {
    switch (selectedTabIndex) {
      case 0:
        return _buildStudentsList(data.students ?? []);
      case 1:
        return _buildStudentsListAttendance(data.students ?? []);
      case 2:
        return _buildPaymentData();
      case 3:
        return _buildFeeBreakdown();
      default:
        return _buildStudentsList(data.students ?? []);
    }
  }

  Widget _buildPaymentData() {
    if (_isLoadingPaymentData) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading payment data...'),
          ],
        ),
      );
    }

    if (_paymentErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
            const SizedBox(height: 16),
            Text(
              _paymentErrorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadPaymentData,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_paymentData == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.payment_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No payment data available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with class info and academic term
          _buildPaymentHeader(),
          const SizedBox(height: 24),

          // Payment statistics cards
          _buildPaymentStatisticsCards(),
          const SizedBox(height: 24),

          // Fee structure breakdown
          _buildFeeStructureBreakdown(),
          const SizedBox(height: 24),

          // Payment breakdown details
          _buildPaymentBreakdownDetails(),
        ],
      ),
    );
  }

  Widget _buildPaymentHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade600,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.account_balance_wallet,
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
                  'Payment Data - ${_paymentData!.classInfo.name}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_paymentData!.academicInfo.currentAcademicYear} • ${_paymentData!.academicInfo.currentTerm} Term',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_paymentData!.metrics.totalStudents} Students • Level ${_paymentData!.classInfo.level}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentStatisticsCards() {
    final metrics = _paymentData!.metrics;

    print('🔍 Debug - Payment Statistics:');
    print('Total students: ${metrics.totalStudents}');
    print('Male students: ${metrics.maleStudents}');
    print('Female students: ${metrics.femaleStudents}');
    print('Paid students: ${metrics.feeStatus.paid}');
    print('Unpaid students: ${metrics.feeStatus.unpaid}');
    print('Collection rate: ${metrics.feeCollectionRate}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Statistics',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Total Students',
                '${metrics.totalStudents}',
                Icons.people,
                Colors.blue,
                Colors.blue.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Paid Students',
                '${metrics.feeStatus.paid}',
                Icons.check_circle,
                Colors.green,
                Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Unpaid Students',
                '${metrics.feeStatus.unpaid}',
                Icons.warning,
                Colors.red,
                Colors.red.shade50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Partial Payments',
                '${metrics.feeStatus.partial}',
                Icons.pending,
                Colors.orange,
                Colors.orange.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Collection Rate',
                '${metrics.feeCollectionRate.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
                Colors.purple.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Available Slots',
                '${metrics.availableSlots}',
                Icons.event_seat,
                Colors.indigo,
                Colors.indigo.shade50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeStructureBreakdown() {
    final metrics = _paymentData!.metrics;
    final feeStructure = metrics.currentFeeStructure;

    print('🔍 Debug - Fee Structure:');
    print('Base fee: ${feeStructure.baseFee}');
    print('Total fee: ${feeStructure.totalFee}');
    print('Term: ${feeStructure.term}');
    print('Academic year: ${feeStructure.academicYear}');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fee Structure Information',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // Fee Structure Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.withOpacity(0.3)),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.school,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Current Fee Structure',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                        Text(
                          '${feeStructure.academicYear} • ${feeStructure.term} Term',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '£${NumberFormat('#,##0.00').format(feeStructure.totalFee)}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildFeeDetailCard(
                      'Base Fee',
                      '£${NumberFormat('#,##0.00').format(feeStructure.baseFee)}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildFeeDetailCard(
                      'Total Fee',
                      '£${NumberFormat('#,##0.00').format(feeStructure.totalFee)}',
                      Colors.green,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Gender Distribution
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.withOpacity(0.3)),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.people,
                      color: Colors.purple,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Gender Distribution',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildGenderCard(
                      'Male Students',
                      '${metrics.maleStudents}',
                      '${metrics.genderRatio.male.toStringAsFixed(1)}%',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildGenderCard(
                      'Female Students',
                      '${metrics.femaleStudents}',
                      '${metrics.genderRatio.female.toStringAsFixed(1)}%',
                      Colors.pink,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Attendance Summary
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.orange.withOpacity(0.3)),
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
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: Colors.orange,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Today\'s Attendance',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildAttendanceCard(
                      'Present',
                      '${metrics.todayAttendance.present}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAttendanceCard(
                      'Absent',
                      '${metrics.todayAttendance.absent}',
                      Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAttendanceCard(
                      'Late',
                      '${metrics.todayAttendance.late}',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildAttendanceCard(
                      'Not Marked',
                      '${metrics.todayAttendance.notMarked}',
                      Colors.grey,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Attendance Rate: ${metrics.todayAttendance.attendancePercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeDetailCard(String title, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGenderCard(
    String title,
    String count,
    String percentage,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(percentage, style: TextStyle(fontSize: 12, color: color)),
        ],
      ),
    );
  }

  Widget _buildAttendanceCard(String status, String count, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            status,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentBreakdownDetails() {
    final students = _paymentData!.students;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Student Payment Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // Students List
        Container(
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
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                ),
                child: const Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text(
                        'Student Name',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Admission No.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Parent',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Fee Status',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Attendance',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Students List
              ...students
                  .map(
                    (student) => Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Colors.grey[200]!,
                            width: 1,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 16,
                                  backgroundColor: _getFeeStatusColor(
                                    student.feeStatus,
                                  ).withOpacity(0.1),
                                  child: Text(
                                    (student.name.isNotEmpty
                                            ? student.name.substring(0, 1)
                                            : '?')
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: _getFeeStatusColor(
                                        student.feeStatus,
                                      ),
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    student.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 14,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Text(
                              student.admissionNumber,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              student.parentName,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getFeeStatusColor(
                                  student.feeStatus,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                student.feeStatus.toUpperCase(),
                                style: TextStyle(
                                  color: _getFeeStatusColor(student.feeStatus),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: _getAttendanceStatusColor(
                                  student.todayAttendance,
                                ).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                student.todayAttendance,
                                style: TextStyle(
                                  color: _getAttendanceStatusColor(
                                    student.todayAttendance,
                                  ),
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ],
          ),
        ),
      ],
    );
  }

  Color _getFeeStatusColor(String feeStatus) {
    switch (feeStatus.toLowerCase()) {
      case 'paid':
        return Colors.green;
      case 'partial':
        return Colors.orange;
      case 'unpaid':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getAttendanceStatusColor(String attendanceStatus) {
    switch (attendanceStatus.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      case 'notmarked':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStudentsList(List<Student> students) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
          ),
          child: const Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  'Student',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Admission No.',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Parent/Guardian',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Fee Status',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Attendance',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
              Expanded(
                child: Text(
                  'Action',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child:
              students.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.people_outline,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'No students found',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: students.length,
                    itemBuilder: (context, index) {
                      final student = students[index];
                      return _buildStudentRow(
                        student.name ?? 'Unknown Student',
                        student.admissionNumber ?? 'N/A',
                        student.parentName ?? 'N/A',
                        student.feeStatus ?? 'Unknown',
                        student.todayAttendance ?? 'N/A',
                        _getFeeStatusColor(student.feeStatus ?? 'Unknown'),
                        student.id ??
                            student.admissionNumber ??
                            'N/A', // Pass student ID
                      );
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildStudentsListAttendance(List<Student> students) {
    final attendanceProvider = ref.watch(RiverpodProvider.attendanceProvider);
    final isSubmitted =
        attendanceProvider.attendanceByDate?.isSubmitted ?? false;
    final isLocked = attendanceProvider.attendanceByDate?.isLocked ?? false;

    return Column(
      children: [
        // Header with date picker and status
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
          ),
          child: Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 20,
                      color: Colors.blue[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
              ),
              if (_hasUnsavedChanges && !isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.orange,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Unsaved Changes',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              if (isSubmitted)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    'Submitted',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Students list - Always show all students
        Expanded(
          child:
              attendanceProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : students.isEmpty
                  ? _buildEmptyAttendanceState()
                  : _buildAllStudentsAttendanceList(students, isLocked),
        ),

        // Submit/Resubmit button - Always show if there are students
        if (students.isNotEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Summary of what will be submitted
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.blue[700],
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Attendance Summary',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'All ${students.length} students will be marked for ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
                        style: TextStyle(fontSize: 13, color: Colors.blue[600]),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isSubmitted
                            ? 'Click "Resubmit" to update attendance records'
                            : 'All students default to "Absent" until marked',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),

                // Submit button
                ElevatedButton(
                  onPressed:
                      isLocked || _isSubmittingAttendance
                          ? null
                          : _submitAttendance,
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _hasUnsavedChanges
                            ? Colors.green[600]
                            : Colors.grey[400],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child:
                      _isSubmittingAttendance
                          ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('Submitting...'),
                            ],
                          )
                          : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.check_circle_outline, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                isSubmitted
                                    ? 'Resubmit Attendance Updates'
                                    : 'Submit Attendance for All Students',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
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

  Widget _buildStudentRow(
    String name,
    String admissionNo,
    String parent,
    String feeStatus,
    String attendance,
    Color statusColor,
    String studentId,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: NetworkImage(
                    'https://via.placeholder.com/32',
                  ),
                ),
                const SizedBox(width: 8),
                Text(name, style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          ),
          Expanded(child: Text(admissionNo)),
          Expanded(child: Text(parent)),
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                feeStatus,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
          Expanded(child: Text(attendance)),
          Expanded(
            child: TextButton(
              onPressed: () {
                // Navigate to student profile using the student ID
                context.go('/students/single/$studentId');
              },
              child: const Text(
                'View Profile',
                style: TextStyle(color: Color(0xFF6366F1)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllStudentsAttendanceList(
    List<Student> students,
    bool isLocked,
  ) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: students.length,
      itemBuilder: (context, index) {
        final student = students[index];
        final studentId = student.id ?? student.admissionNumber ?? 'N/A';
        final currentStatus = _attendanceStatus[studentId] ?? 'absent';
        final currentRemarks = _attendanceRemarks[studentId] ?? '';

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getStatusColor(currentStatus).withOpacity(0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: _getStatusColor(
                      currentStatus,
                    ).withOpacity(0.1),
                    child: Text(
                      (student.name ?? 'Unknown')[0].toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
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
                          student.name ?? 'Unknown Student',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          student.admissionNumber ?? 'N/A',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Status indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _getStatusColor(currentStatus).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: _getStatusColor(currentStatus).withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      currentStatus.toUpperCase(),
                      style: TextStyle(
                        color: _getStatusColor(currentStatus),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              if (!isLocked) ...[
                const SizedBox(height: 16),

                // Quick action buttons
                Row(
                  children: [
                    Expanded(
                      child: _buildStatusButton(
                        'Present',
                        'present',
                        studentId,
                        Colors.green,
                        currentStatus == 'present',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusButton(
                        'Absent',
                        'absent',
                        studentId,
                        Colors.red,
                        currentStatus == 'absent',
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildStatusButton(
                        'Late',
                        'late',
                        studentId,
                        Colors.orange,
                        currentStatus == 'late',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Remarks field
                TextFormField(
                  initialValue: currentRemarks,
                  decoration: InputDecoration(
                    labelText: 'Remarks (Optional)',
                    hintText: 'Add any notes...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    prefixIcon: const Icon(Icons.note_add, size: 20),
                  ),
                  onChanged: (value) {
                    _updateStudentRemarks(studentId, value);
                  },
                ),
              ] else if (currentRemarks.isNotEmpty) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.note, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          currentRemarks,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatusButton(
    String label,
    String status,
    String studentId,
    Color color,
    bool isSelected,
  ) {
    return GestureDetector(
      onTap: () => _markStudentAttendance(studentId, status),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? color : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(status),
              size: 16,
              color: isSelected ? Colors.white : color,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : color,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyAttendanceState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.school_outlined, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'No Attendance Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Attendance records will appear here once marked',
            style: TextStyle(fontSize: 14, color: Colors.grey[500]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Colors.green;
      case 'absent':
        return Colors.red;
      case 'late':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'present':
        return Icons.check_circle;
      case 'absent':
        return Icons.cancel;
      case 'late':
        return Icons.schedule;
      default:
        return Icons.help;
    }
  }

  Widget _buildSidebar(Data data) {
    return Container(
      margin: const EdgeInsets.only(top: 16, right: 16, bottom: 16),
      child: Container(
        height: double.infinity,
        child: ListView(
          children: [
            _buildQuickMetrics(data.metrics),
            const SizedBox(height: 16),
            _buildWeeklySchedule(data.academicInfo),
            const SizedBox(height: 16),
            _buildRecentCommunications(data.recentCommunications),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickMetrics(Metrics? metrics) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Quick Metrics',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          _buildMetricRow(
            'Outstanding Fees',
            '${metrics?.feeStatus?.unpaid ?? 0} Students',
            Colors.red,
          ),
          _buildMetricRow(
            'Fee Collection Rate',
            '${metrics?.feeCollectionRate ?? '0%'}',
            Colors.green,
          ),
          _buildMetricRow(
            'Gender Ratio',
            '${metrics?.genderRatio?.male ?? '0%'} : ${metrics?.genderRatio?.female ?? '0%'}',
            Colors.grey,
          ),
          _buildMetricRow(
            'Available Slots',
            '${metrics?.availableSlots ?? 0}',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildMetricRow(String label, String value, Color valueColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklySchedule(AcademicInfo? academicInfo) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Academic Information',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'CURRENT TERM',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          _buildScheduleItem(
            'Academic Year',
            academicInfo?.currentAcademicYear ?? 'N/A',
            const Color(0xFF6366F1),
          ),
          _buildScheduleItem(
            'Current Term',
            academicInfo?.currentTerm ?? 'N/A',
            Colors.grey,
          ),
          if (academicInfo?.attendanceDate != null)
            _buildScheduleItem(
              'Last Attendance',
              '${academicInfo!.attendanceDate!.day}/${academicInfo.attendanceDate!.month}/${academicInfo.attendanceDate!.year}',
              Colors.orange,
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleItem(String subject, String time, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:
            color == const Color(0xFF6366F1)
                ? color.withOpacity(0.1)
                : Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color == const Color(0xFF6366F1) ? color : Colors.transparent,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color:
                  color == const Color(0xFF6366F1) ? color : Colors.grey[800],
            ),
          ),
          Text(time, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildRecentCommunications(List<dynamic>? recentCommunications) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Recent Communications',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1F2937),
            ),
          ),
          const SizedBox(height: 16),
          if (recentCommunications == null || recentCommunications.isEmpty)
            const Center(
              child: Column(
                children: [
                  Icon(Icons.message_outlined, size: 32, color: Colors.grey),
                  SizedBox(height: 8),
                  Text(
                    'No recent communications',
                    style: TextStyle(color: Colors.grey, fontSize: 14),
                  ),
                ],
              ),
            )
          else
            ...recentCommunications
                .take(2)
                .map(
                  (communication) => _buildCommunicationItem(
                    '📧',
                    'Communication',
                    'Recent message',
                  ),
                ),
        ],
      ),
    );
  }

  Widget _buildCommunicationItem(String icon, String title, String subtitle) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 16)),
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
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown() {
    if (_isLoadingFeeBreakdown) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading fee breakdown...'),
          ],
        ),
      );
    }

    if (_feeBreakdownErrorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading fee breakdown',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              _feeBreakdownErrorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFeeBreakdown,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_feeBreakdownData == null) {
      return const Center(child: Text('No fee breakdown data available'));
    }

    final data = _feeBreakdownData!.data;
    final stats = data.paymentStatistics;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildFeeBreakdownHeader(data),
          const SizedBox(height: 24),
          _buildFeeBreakdownPaymentStatisticsCards(stats),
          const SizedBox(height: 24),
          _buildFeeStructureCards(data),
          const SizedBox(height: 24),
          _buildPaymentBreakdownCards(data),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdownHeader(fee.FeeBreakdownData data) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.indigo.shade50],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200),
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.account_balance,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Fee Breakdown - ${data.classInfo.name}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.academicTerm.academicYear} • ${data.academicTerm.term} Term',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                Text(
                  '${data.classInfo.totalStudents} Students • Level ${data.classInfo.level}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdownPaymentStatisticsCards(fee.PaymentStatistics stats) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Statistics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // Revenue Overview Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.indigo.shade50, Colors.purple.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.indigo.shade200),
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
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade600,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.trending_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      'Revenue Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                  Text(
                    '${stats.collectionRate.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color:
                          stats.collectionRate > 50 ? Colors.green : Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: _buildRevenueCard(
                      'Expected Revenue',
                      '£${NumberFormat('#,##0.00').format(stats.expectedRevenue)}',
                      Icons.account_balance,
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRevenueCard(
                      'Amount Collected',
                      '£${NumberFormat('#,##0.00').format(stats.totalAmountPaid)}',
                      Icons.check_circle,
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildRevenueCard(
                      'Amount Left',
                      '£${NumberFormat('#,##0.00').format(stats.totalAmountLeft)}',
                      Icons.pending,
                      Colors.orange,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Student Payment Status
        const Text(
          'Student Payment Status',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Total Students',
                '${stats.totalStudents}',
                Icons.people,
                Colors.blue,
                Colors.blue.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Paid Students',
                '${stats.paidStudents}',
                Icons.check_circle,
                Colors.green,
                Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Partial Students',
                '${stats.partialStudents}',
                Icons.pending,
                Colors.orange,
                Colors.orange.shade50,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Owing Students',
                '${stats.owingStudents}',
                Icons.warning,
                Colors.red,
                Colors.red.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Completion Rate',
                '${stats.overallCompletionPercentage.toStringAsFixed(1)}%',
                Icons.trending_up,
                Colors.purple,
                Colors.purple.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildFeeBreakdownStatCard(
                'Collection Rate',
                '${stats.collectionRate.toStringAsFixed(1)}%',
                Icons.analytics,
                Colors.indigo,
                Colors.indigo.shade50,
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // Payment Summary Cards
        const Text(
          'Payment Summary',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _buildAmountCard(
                'Total Paid',
                '£${NumberFormat('#,##0.00').format(stats.totalPaidAmount)}',
                Icons.account_balance_wallet,
                Colors.green,
                Colors.green.shade50,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAmountCard(
                'Outstanding Amount',
                '£${NumberFormat('#,##0.00').format(stats.totalOutstandingAmount)}',
                Icons.money_off,
                Colors.red,
                Colors.red.shade50,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeeStructureCards(fee.FeeBreakdownData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fee Structure',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // Base fee card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.school,
                  color: Colors.blue.shade600,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data.feeBreakdown.baseFee.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      data.feeBreakdown.baseFee.description,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '£${NumberFormat('#,##0.00').format(data.feeBreakdown.baseFee.amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 12),

        // Add-ons
        ...data.feeBreakdown.addOns
            .map(
              (addOn) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        Icons.add_circle,
                        color: Colors.green.shade600,
                        size: 20,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            addOn.name.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          Text(
                            addOn.description,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '£${NumberFormat('#,##0.00').format(addOn.amount)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),

        const SizedBox(height: 16),

        // Total fees card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.purple.shade50, Colors.indigo.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.purple.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.purple.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.calculate,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Fees Per Student',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      'Base: £${NumberFormat('#,##0.00').format(data.totals.baseFee)} + Add-ons: £${NumberFormat('#,##0.00').format(data.totals.addOnFees)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '£${NumberFormat('#,##0.00').format(data.totals.totalFees)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Expected Revenue Card
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.green.shade50, Colors.teal.shade50],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade600,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.account_balance,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Total Expected Revenue',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    Text(
                      '${data.classInfo.totalStudents} students × £${NumberFormat('#,##0.00').format(data.totals.totalFees)}',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Text(
                '£${NumberFormat('#,##0.00').format(data.totals.totalExpectedRevenue)}',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentBreakdownCards(fee.FeeBreakdownData data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Breakdown',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 16),

        // Base fee payment breakdown
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.school,
                      color: Colors.blue.shade600,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Base Fee Payments',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _buildPaymentDetailCard(
                      'Total Amount',
                      '£${NumberFormat('#,##0.00').format(data.paymentBreakdown.baseFee.totalAmount)}',
                      Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentDetailCard(
                      'Paid Amount',
                      '£${NumberFormat('#,##0.00').format(data.paymentBreakdown.baseFee.paidAmount)}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildPaymentDetailCard(
                      'Outstanding',
                      '£${NumberFormat('#,##0.00').format(data.paymentBreakdown.baseFee.outstandingAmount)}',
                      Colors.red,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'Completion: ${data.paymentBreakdown.baseFee.completionPercentage.toStringAsFixed(1)}%',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        // Add-ons payment breakdown
        ...data.paymentBreakdown.addOns
            .map(
              (addOn) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green.shade50,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.add_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${addOn.name.toUpperCase()} Payments',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildPaymentDetailCard(
                            'Total Amount',
                            '£${NumberFormat('#,##0.00').format(addOn.totalAmount)}',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentDetailCard(
                            'Paid Amount',
                            '£${NumberFormat('#,##0.00').format(addOn.paidAmount)}',
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildPaymentDetailCard(
                            'Outstanding',
                            '£${NumberFormat('#,##0.00').format(addOn.outstandingAmount)}',
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.green.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Completion: ${addOn.completionPercentage.toStringAsFixed(1)}%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ],
    );
  }

  Widget _buildFeeBreakdownStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAmountCard(
    String title,
    String value,
    IconData icon,
    Color color,
    Color backgroundColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentDetailCard(String title, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w500,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF1F2937),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
