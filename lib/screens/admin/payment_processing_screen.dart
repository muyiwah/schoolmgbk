import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/admin_payment_provider.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/services/global_academic_year_service.dart';
import 'package:schmgtsystem/models/class_statistics_model.dart';

/// Screen for processing student payments with itemized breakdown
class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String studentId;
  final String? studentName;
  final String? parentName;
  final String? className;
  final String? classLevel;
  final String? currentAcademicYear;
  final String? currentTerm;
  final int? outstandingBalance;
  final int? paidAmount;
  final String? paymentStatus;

  const PaymentProcessingScreen({
    super.key,
    required this.studentId,
    this.studentName,
    this.parentName,
    this.className,
    this.currentAcademicYear,
    this.currentTerm,
    this.outstandingBalance,
    this.paidAmount,
    this.paymentStatus,
    this.classLevel,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _referenceController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _remarksController = TextEditingController();

  String _selectedPaymentStatus = 'Pending';
  String _selectedPaymentMethod = 'Manual Entry';
  late GlobalAcademicYearService _academicYearService;

  // Fee breakdown data
  Map<String, dynamic> _feeBreakdown = {};
  List<FeeAddOnModel> _addOns = [];
  List<bool> _selectedAddOns = []; // Track which optional add-ons are selected
  int _baseFee = 0;
  int _totalAmount = 0;

  // Loading states
  bool _isLoadingFeeStructure = true;
  String? _classId;
  FeeStructureDetails? _feeStructureDetails;

  @override
  void initState() {
    super.initState();
    try {
      _academicYearService = GlobalAcademicYearService();

      // Debug logging
      print('PaymentProcessingScreen initialized with:');
      print('Student ID: ${widget.studentId}');
      print('Student Name: ${widget.studentName}');
      print('Parent Name: ${widget.parentName}');
      print('Class: ${widget.className}');
      print('Outstanding Balance: ${widget.outstandingBalance}');
      print('Payment Status: ${widget.paymentStatus}');

      _initializeForm();
      _loadFeeStructure();
    } catch (e) {
      print('Error initializing PaymentProcessingScreen: $e');
    }
  }

  void _initializeForm() {
    // Map payment status to valid options
    final paymentStatus = widget.paymentStatus?.toLowerCase();
    print('Original payment status: ${widget.paymentStatus}');
    print('Lowercase payment status: $paymentStatus');

    if (paymentStatus == 'owing' ||
        paymentStatus == 'unpaid' ||
        paymentStatus == 'not paid') {
      _selectedPaymentStatus = 'Pending';
    } else if (paymentStatus == 'paid' || paymentStatus == 'completed') {
      _selectedPaymentStatus = 'Completed';
    } else if (paymentStatus == 'partial') {
      _selectedPaymentStatus =
          'Pending'; // Treat partial as pending for processing
    } else {
      _selectedPaymentStatus = 'Pending';
    }

    print('Mapped payment status: $_selectedPaymentStatus');
    _selectedPaymentMethod = 'Manual Entry';
  }

  Future<void> _loadFeeStructure() async {
    try {
      setState(() {
        _isLoadingFeeStructure = true;
      });

      print('Loading fee structure for class: ${widget.className}');
      print('Student ID: ${widget.studentId}');

      // Use the className passed from the dashboard to find the correct class
      if (widget.className != null && widget.className!.isNotEmpty) {
        await _findClassByName(widget.className!);
      } else {
        print('No class name provided, falling back to student lookup');
        await _loadFeeStructureFromStudent();
      }
    } catch (e) {
      print('Error loading fee structure: $e');
      _loadFallbackFeeStructure();
    } finally {
      setState(() {
        _isLoadingFeeStructure = false;
      });
    }
  }

  Future<void> _findClassByName(String className) async {
    try {
      // Ensure classes are loaded into provider state
      await ref
          .read(RiverpodProvider.classProvider.notifier)
          .getAllClassesWithMetric(context);

      final classMetric =
          ref.read(RiverpodProvider.classProvider).classData; // typed model
      final classes = classMetric.classes ?? [];
      print('Searching through ${classes.length} classes for: $className');

      for (final cls in classes) {
        final currentClassName = cls.name?.toString() ?? '';
        final classId = cls.id ?? cls.classId ?? '';

        print('Checking class: $currentClassName (ID: $classId)');

        if (currentClassName.toLowerCase() == className.toLowerCase()) {
          _classId = classId;
          print(
            'Found matching class ID: $_classId for class: $currentClassName',
          );
          await _loadClassFeeStructure();
          return;
        }
      }

      print('No matching class found for: $className');
      _loadFallbackFeeStructure();
    } catch (e) {
      print('Error finding class by name: $e');
      _loadFallbackFeeStructure();
    }
  }

  Future<void> _loadFeeStructureFromStudent() async {
    try {
      // Fallback: get student details to find the class ID
      final studentResponse = await ref
          .read(RiverpodProvider.studentProvider.notifier)
          .getStudentById(context, widget.studentId);

      if (studentResponse != null && studentResponse['academicInfo'] != null) {
        final academicInfo = studentResponse['academicInfo'];
        final currentClass = academicInfo['currentClass'];

        if (currentClass != null && currentClass['id'] != null) {
          _classId = currentClass['id'];
          print('Found class ID from student: $_classId');

          // Now get the class fee structure
          await _loadClassFeeStructure();
        } else {
          print('No class ID found for student');
          _loadFallbackFeeStructure();
        }
      } else {
        print('Failed to get student details');
        _loadFallbackFeeStructure();
      }
    } catch (e) {
      print('Error loading fee structure from student: $e');
      _loadFallbackFeeStructure();
    }
  }

  Future<void> _loadClassFeeStructure() async {
    if (_classId == null) return;

    try {
      // Get class fee structures
      final feeStructureData = await ref
          .read(RiverpodProvider.classProvider.notifier)
          .getClassFeeStructures(context, _classId!);

      if (feeStructureData != null &&
          feeStructureData['activeFeeStructure'] != null) {
        final activeFeeStructure = feeStructureData['activeFeeStructure'];
        _feeStructureDetails = FeeStructureDetails.fromJson(activeFeeStructure);

        print('Loaded fee structure: ${_feeStructureDetails?.toJson()}');
        print('Base fee: ${_feeStructureDetails?.baseFee}');
        print('Add-ons: ${_feeStructureDetails?.addOns}');
        _buildFeeBreakdownFromStructure();
      } else {
        print('No active fee structure found');
        _loadFallbackFeeStructure();
      }
    } catch (e) {
      print('Error loading class fee structure: $e');
      _loadFallbackFeeStructure();
    }
  }

  void _buildFeeBreakdownFromStructure() {
    if (_feeStructureDetails == null) {
      _loadFallbackFeeStructure();
      return;
    }

    _baseFee = _feeStructureDetails!.baseFee ?? 0;
    _addOns = [];

    // Add base fee as first item only if it exists in the structure
    if (_baseFee > 0) {
      _addOns.add(
        FeeAddOnModel(
          name: 'Base Fee',
          amount: _baseFee,
          description: 'Main tuition fee for the term',
          isCompulsory: true,
          isActive: true,
        ),
      );
    }

    // Add fee add-ons exactly as they appear in the structure
    final addOns = _feeStructureDetails!.addOns ?? [];
    print('Processing ${addOns.length} add-ons from fee structure');

    for (int i = 0; i < addOns.length; i++) {
      final addOn = addOns[i];
      print('Add-on $i: $addOn');

      // Use exact names and amounts from the fee structure
      final name = addOn['name']?.toString() ?? 'Additional Fee';
      final amount =
          (addOn['amount'] ?? 0) is int
              ? addOn['amount'] as int
              : (addOn['amount'] as double?)?.round() ?? 0;
      final compulsory = addOn['compulsory'] ?? false;
      final isActive = addOn['isActive'] ?? true;
      final description = addOn['description']?.toString() ?? '';

      print(
        'Parsed add-on: name="$name", amount=$amount, compulsory=$compulsory, active=$isActive',
      );

      // Include all add-ons, even if amount is 0 (they might be optional)
      _addOns.add(
        FeeAddOnModel(
          name: name,
          amount: amount,
          description: description,
          isCompulsory: compulsory,
          isActive: isActive,
        ),
      );
    }

    // Initialize selection for optional add-ons (compulsory ones are pre-selected)
    _selectedAddOns = List.generate(
      _addOns.length,
      (index) => _addOns[index].isCompulsory,
    );

    _updateFeeBreakdown();
  }

  void _loadFallbackFeeStructure() {
    // Fallback to a basic structure if we can't load the real one
    _baseFee = (widget.outstandingBalance ?? 0) ~/ 2; // Half as base fee

    _addOns = [
      FeeAddOnModel(
        name: 'Base Fee',
        amount: _baseFee,
        description: 'Main tuition fee for the term',
        isCompulsory: true,
        isActive: true,
      ),
      FeeAddOnModel(
        name: 'Additional Fees',
        amount: (widget.outstandingBalance ?? 0) - _baseFee,
        description: 'Additional fees and charges',
        isCompulsory: true,
        isActive: true,
      ),
    ];

    // Initialize selection (all compulsory)
    _selectedAddOns = List.generate(
      _addOns.length,
      (index) => _addOns[index].isCompulsory,
    );

    _updateFeeBreakdown();
  }

  @override
  void dispose() {
    _referenceController.dispose();
    _descriptionController.dispose();
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final adminPaymentState = ref.watch(adminPaymentProvider);
      final paymentStatusOptions = ref.watch(paymentStatusOptionsProvider);
      final paymentMethodOptions = ref.watch(paymentMethodOptionsProvider);

      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Process Payment${widget.studentName != null ? ' - ${widget.studentName}' : ''}',
          ),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Student Information Card
                _buildStudentInfoCard(),
                const SizedBox(height: 16),

                // Fee Breakdown Card
                _buildFeeBreakdownCard(),
                const SizedBox(height: 16),

                // Payment Processing Card
                _buildPaymentProcessingCard(
                  paymentStatusOptions,
                  paymentMethodOptions,
                ),
                const SizedBox(height: 16),

                // Remarks Card
                _buildRemarksCard(),
                const SizedBox(height: 24),

                // Action Buttons
                _buildActionButtons(adminPaymentState),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      print('Error in PaymentProcessingScreen build: $e');
      return Scaffold(
        appBar: AppBar(
          title: const Text('Process Payment'),
          backgroundColor: Colors.blue[700],
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error, size: 64, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error loading payment processing screen',
                style: TextStyle(fontSize: 18, color: Colors.red[300]),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                style: const TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => context.pop(),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildStudentInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Student Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                    'Student Name',
                    widget.studentName ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField('Student ID', widget.studentId),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                    'Parent Name',
                    widget.parentName ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField('Class', widget.className ?? 'N/A'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildInfoField(
                    'Academic Year',
                    widget.currentAcademicYear ??
                        _academicYearService.currentAcademicYearString,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildInfoField(
                    'Term',
                    widget.currentTerm ??
                        _academicYearService.currentTermString,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildFeeBreakdownCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Fee Breakdown',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue[800],
                  ),
                ),
                if (widget.className != null) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Class: ${widget.className}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),

            if (_isLoadingFeeStructure) ...[
              // Loading state
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32.0),
                  child: Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text('Loading fee structure...'),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Fee breakdown items with selection for optional ones
              if (_addOns.isEmpty) ...[
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32.0),
                    child: Column(
                      children: [
                        Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        SizedBox(height: 16),
                        Text('No fee structure available'),
                        SizedBox(height: 8),
                        Text(
                          'Please contact administrator to set up fee structure for this class.',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ] else ...[
                // Display fee breakdown similar to class fee breakdown screen
                _buildItemizedFeeBreakdown(),

                const SizedBox(height: 12),

                // Total amount
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue[300]!),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Total Amount:',
                        style: Theme.of(
                          context,
                        ).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        '₦$_totalAmount',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildItemizedFeeBreakdown() {
    return Column(
      children: [
        // Base Fee
        _buildFeeItem(
          'Base Fee',
          '₦${_baseFee.toStringAsFixed(0)}',
          Colors.blue,
          isBaseFee: true,
        ),

        // Add-ons
        if (_addOns.isNotEmpty) ...[
          const SizedBox(height: 8),
          ..._addOns.asMap().entries.map((entry) {
            final index = entry.key;
            final addOn = entry.value;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildSelectableFeeItem(addOn, index),
            );
          }).toList(),
        ],
      ],
    );
  }

  Widget _buildFeeItem(
    String name,
    String amount,
    Color color, {
    bool isBaseFee = false,
    bool isCompulsory = false,
    bool isActive = true,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Row(
              children: [
                if (isBaseFee) ...[
                  Icon(Icons.account_balance_wallet, size: 14, color: color),
                  const SizedBox(width: 4),
                ] else ...[
                  Icon(
                    isCompulsory ? Icons.star : Icons.add_circle_outline,
                    size: 14,
                    color: color,
                  ),
                  const SizedBox(width: 4),
                ],
                Expanded(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: color,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (!isActive) ...[
                  const SizedBox(width: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                      vertical: 1,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'Inactive',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectableFeeItem(FeeAddOnModel addOn, int index) {
    final isCompulsory = addOn.isCompulsory;
    final isSelected = _selectedAddOns[index];
    final primaryColor = isCompulsory ? Colors.red[700]! : Colors.green[700]!;
    final backgroundColor = isCompulsory ? Colors.red[50]! : Colors.green[50]!;
    final borderColor = isCompulsory ? Colors.red[200]! : Colors.green[200]!;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          // Checkbox for optional items
          if (!isCompulsory) ...[
            Checkbox(
              value: isSelected,
              onChanged: (value) {
                setState(() {
                  _selectedAddOns[index] = value ?? false;
                  _updateFeeBreakdown();
                });
              },
              activeColor: primaryColor,
            ),
            const SizedBox(width: 8),
          ] else ...[
            // Icon for compulsory items
            Icon(Icons.star, size: 20, color: primaryColor),
            const SizedBox(width: 8),
          ],

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  addOn.name,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: primaryColor,
                  ),
                ),
                if (addOn.description?.isNotEmpty == true)
                  Text(
                    addOn.description!,
                    style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                  ),
                if (isCompulsory)
                  Text(
                    'Compulsory',
                    style: TextStyle(
                      fontSize: 10,
                      color: primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),

          Text(
            '₦${addOn.amount}',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isSelected ? primaryColor : Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentProcessingCard(
    List<String> paymentStatusOptions,
    List<String> paymentMethodOptions,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Processing',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),

            // Payment Status
            DropdownButtonFormField<String>(
              value: _selectedPaymentStatus,
              decoration: const InputDecoration(
                labelText: 'Payment Status *',
                prefixIcon: Icon(Icons.check_circle),
                border: OutlineInputBorder(),
              ),
              items:
                  paymentStatusOptions.map((status) {
                    return DropdownMenuItem(value: status, child: Text(status));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentStatus = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Payment status is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Payment Method
            DropdownButtonFormField<String>(
              value: _selectedPaymentMethod,
              decoration: const InputDecoration(
                labelText: 'Payment Method *',
                prefixIcon: Icon(Icons.payment),
                border: OutlineInputBorder(),
              ),
              items:
                  paymentMethodOptions.map((method) {
                    return DropdownMenuItem(value: method, child: Text(method));
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedPaymentMethod = value;
                  });
                }
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Payment method is required';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Reference Number
            TextFormField(
              controller: _referenceController,
              decoration: const InputDecoration(
                labelText: 'Reference Number (Optional)',
                prefixIcon: Icon(Icons.receipt),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                prefixIcon: Icon(Icons.description),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRemarksCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Remarks',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              decoration: const InputDecoration(
                labelText: 'Remarks',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(AdminPaymentState adminPaymentState) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton(
            onPressed: adminPaymentState.isLoading ? null : _processPayment,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue[700],
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child:
                adminPaymentState.isLoading
                    ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                    : const Text('Process Payment'),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: OutlinedButton(
            onPressed: adminPaymentState.isLoading ? null : _clearForm,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Clear Form'),
          ),
        ),
      ],
    );
  }

  void _updateFeeBreakdown() {
    // Calculate total based on selected add-ons
    _totalAmount = 0;
    final selectedAddOns = <FeeAddOnModel>[];

    for (int i = 0; i < _addOns.length; i++) {
      if (_selectedAddOns[i]) {
        _totalAmount += _addOns[i].amount;
        selectedAddOns.add(_addOns[i]);
      }
    }

    _feeBreakdown = {
      'baseFee': _baseFee,
      'addOns': selectedAddOns.map((addOn) => addOn.toJson()).toList(),
      'totalAmount': _totalAmount,
    };
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _initializeForm();
    // Reset add-on selections to default (compulsory only)
    _selectedAddOns = List.generate(
      _addOns.length,
      (index) => _addOns[index].isCompulsory,
    );
    _updateFeeBreakdown();
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final response = await ref
        .read(adminPaymentProvider.notifier)
        .createPaymentEntry(
          studentId: widget.studentId,
          academicYear:
              widget.currentAcademicYear ??
              _academicYearService.currentAcademicYearString,
          term: widget.currentTerm ?? _academicYearService.currentTermString,
          amount: _totalAmount,
          method: _selectedPaymentMethod,
          paymentStatus: _selectedPaymentStatus,
          reference:
              _referenceController.text.isEmpty
                  ? null
                  : _referenceController.text,
          description:
              _descriptionController.text.isEmpty
                  ? null
                  : _descriptionController.text,
          remarks:
              _remarksController.text.isEmpty ? null : _remarksController.text,
          feeBreakdown: _feeBreakdown,
          context: context,
        );

    if (response != null) {
      // Show the backend response to the user
      _showBackendResponse(response);
    }
  }

  void _showBackendResponse(Map<String, dynamic> response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Processing Response'),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'Backend Response:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[300]!),
                    ),
                    child: Text(
                      response.toString(),
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  // Return to dashboard with success indicator
                  context.pop(true);
                },
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
    );
  }
}

// Extended FeeAddOnModel to include compulsory and active flags
class FeeAddOnModel {
  final String name;
  final int amount;
  final String? description;
  final bool isCompulsory;
  final bool isActive;

  FeeAddOnModel({
    required this.name,
    required this.amount,
    this.description,
    this.isCompulsory = true,
    this.isActive = true,
  });

  factory FeeAddOnModel.fromJson(Map<String, dynamic> json) {
    return FeeAddOnModel(
      name: json['name'] ?? '',
      amount: json['amount'] ?? 0,
      description: json['description'],
      isCompulsory: json['compulsory'] ?? true,
      isActive: json['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'amount': amount,
      'description': description,
      'compulsory': isCompulsory,
      'isActive': isActive,
    };
  }
}
