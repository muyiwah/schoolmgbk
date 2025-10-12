import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:schmgtsystem/providers/admin_payment_provider.dart';
import 'package:schmgtsystem/services/admin_payment_service.dart';
import 'package:schmgtsystem/repository/payment_repo.dart';
import 'package:schmgtsystem/models/class_fee_breakdown_model.dart';

class PaymentProcessingScreen extends ConsumerStatefulWidget {
  final String? studentId;
  final String? studentName;
  final String? parentName;
  final String? className;
  final String? classLevel;
  final String? classId;
  final String? currentAcademicYear;
  final String? currentTerm;
  final int? outstandingBalance;
  final int? paidAmount;
  final String? paymentStatus;

  const PaymentProcessingScreen({
    super.key,
    this.studentId,
    this.studentName,
    this.parentName,
    this.className,
    this.classLevel,
    this.classId,
    this.currentAcademicYear,
    this.currentTerm,
    this.outstandingBalance,
    this.paidAmount,
    this.paymentStatus,
  });

  @override
  ConsumerState<PaymentProcessingScreen> createState() =>
      _PaymentProcessingScreenState();
}

class _PaymentProcessingScreenState
    extends ConsumerState<PaymentProcessingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _remarksController = TextEditingController();

  ClassFeeBreakdownModel? _feeBreakdown;
  bool _isLoadingFeeBreakdown = false;
  bool _hasFeeStructure = false;

  @override
  void initState() {
    super.initState();
    print('PaymentProcessingScreen initialized with:');
    print('Student ID: ${widget.studentId}');
    print('Student Name: ${widget.studentName}');
    print('Parent Name: ${widget.parentName}');
    print('Class: ${widget.className}');
    print('Class ID: ${widget.classId}');
    print('Term: ${widget.currentTerm}');
    print('Outstanding Balance: ${widget.outstandingBalance}');
    print('Payment Status: ${widget.paymentStatus}');

    // Fetch class fee breakdown
    _fetchClassFeeBreakdown();
  }

  Future<void> _fetchClassFeeBreakdown() async {
    if (widget.classId == null || widget.currentTerm == null) {
      print('Missing classId or term, cannot fetch fee breakdown');
      return;
    }

    setState(() {
      _isLoadingFeeBreakdown = true;
    });

    try {
      final paymentRepo = PaymentRepository();
      final response = await paymentRepo.getClassFeeBreakdown(
        classId: widget.classId!,
        term: widget.currentTerm!,
      );

      if (response.code == 200 && response.data != null) {
        final feeBreakdown = ClassFeeBreakdownModel.fromJson(response.data);
        setState(() {
          _feeBreakdown = feeBreakdown;
          _hasFeeStructure = feeBreakdown.data?.feeStructure != null;
          _isLoadingFeeBreakdown = false;
        });
        print('Fee breakdown loaded successfully');
      } else {
        setState(() {
          _hasFeeStructure = false;
          _isLoadingFeeBreakdown = false;
        });
        print('No fee structure found for this class and term');
      }
    } catch (e) {
      setState(() {
        _hasFeeStructure = false;
        _isLoadingFeeBreakdown = false;
      });
      print('Error fetching fee breakdown: $e');
    }
  }

  @override
  void dispose() {
    _remarksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final adminPaymentState = ref.watch(adminPaymentProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Payment Processing'),
        backgroundColor: Colors.indigo[600],
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(false),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Student Information Card
              _buildStudentInfoCard(),
              const SizedBox(height: 24),

              // Fee Structure Breakdown Card
              if (_isLoadingFeeBreakdown)
                _buildLoadingCard()
              else if (_hasFeeStructure && _feeBreakdown != null)
                _buildFeeBreakdownCard()
              else
                _buildNoFeeStructureCard(),

              if (_hasFeeStructure) ...[
                const SizedBox(height: 24),
                // Remarks Section
                _buildRemarksSection(),
                const SizedBox(height: 32),
                // Process Payment Button
                _buildProcessPaymentButton(adminPaymentState),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStudentInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.indigo[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.person_outline,
                    color: Colors.indigo[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Student Information',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.indigo[800],
                        ),
                      ),
                      Text(
                        widget.studentName ?? 'N/A',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.indigo[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildInfoRow('Parent Name', widget.parentName ?? 'N/A'),
            _buildInfoRow(
              'Class',
              '${widget.classLevel ?? 'N/A'} - ${widget.className ?? 'N/A'}',
            ),
            _buildInfoRow('Academic Year', widget.currentAcademicYear ?? 'N/A'),
            _buildInfoRow('Term', widget.currentTerm ?? 'N/A'),
            const Divider(height: 32),
            _buildInfoRow(
              'Outstanding Balance',
              '£${_formatCurrency(widget.outstandingBalance ?? 0)}',
              isHighlight: true,
            ),
            _buildInfoRow('Current Status', widget.paymentStatus ?? 'N/A'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isHighlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isHighlight ? Colors.indigo[700] : Colors.grey[600],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: isHighlight ? FontWeight.bold : FontWeight.w500,
                color: isHighlight ? Colors.indigo[800] : Colors.black87,
                fontSize: isHighlight ? 16 : 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(
              'Loading fee structure...',
              style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeBreakdownCard() {
    final data = _feeBreakdown!.data;
    final feeBreakdown = data?.feeBreakdown;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.receipt_long_outlined,
                    color: Colors.green[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Fee Structure Breakdown',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[800],
                        ),
                      ),
                      Text(
                        '${widget.currentTerm} Term ${widget.currentAcademicYear}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Base Fee
            if (feeBreakdown?.baseFee != null) ...[
              _buildFeeItem(
                'Base Fee',
                feeBreakdown!.baseFee!.amount ?? 0,
                true,
                Icons.school_outlined,
              ),
              const SizedBox(height: 12),
            ],

            // Add-ons
            if (feeBreakdown?.addOns != null &&
                feeBreakdown!.addOns!.isNotEmpty) ...[
              ...feeBreakdown.addOns!.map(
                (addOn) => Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: _buildFeeItem(
                    addOn.name ?? 'Additional Fee',
                    addOn.amount ?? 0,
                    addOn.compulsory == true,
                    Icons.add_circle_outline,
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // Total
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Fee',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  Text(
                    '£${_formatCurrency(data?.totals?.totalFees ?? 0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
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

  Widget _buildNoFeeStructureCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.orange[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_outlined,
                color: Colors.orange[600],
                size: 48,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No Fee Structure',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.orange[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Fee structure has not been set up for ${widget.classLevel ?? 'this class'} - ${widget.className ?? 'N/A'} for ${widget.currentTerm} term ${widget.currentAcademicYear}.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[700],
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              'Please set up the fee structure before processing payments.',
              style: TextStyle(
                fontSize: 12,
                color: Colors.orange[600],
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeeItem(
    String name,
    int amount,
    bool isRequired,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isRequired ? Colors.red[200]! : Colors.grey[200]!,
          width: isRequired ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isRequired ? Colors.red[50] : Colors.grey[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: isRequired ? Colors.red[600] : Colors.grey[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[100],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Required',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.red[700],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '£${_formatCurrency(amount)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.green[700],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRemarksSection() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[50]!, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_note_outlined,
                    color: Colors.blue[600],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Payment Remarks',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue[800],
                        ),
                      ),
                      Text(
                        'Provide details about the payment update',
                        style: TextStyle(fontSize: 14, color: Colors.blue[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example: "Bank transfer confirmed. Reference: BT123456"',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _remarksController,
              maxLines: 4,
              decoration: InputDecoration(
                hintText: 'Enter payment update remarks...',
                hintStyle: TextStyle(color: Colors.grey[500]),
                filled: true,
                fillColor: Colors.white,
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
                  borderSide: BorderSide(color: Colors.blue[600]!, width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.red[400]!, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Remarks are required';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProcessPaymentButton(AdminPaymentState adminPaymentState) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[500]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: adminPaymentState.isLoading ? null : _processPayment,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 18),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child:
              adminPaymentState.isLoading
                  ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Processing...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  )
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_outline, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Update Payment Status',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }

  Future<void> _processPayment() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await AdminPaymentService.updateManualPaymentStatus(
        studentId: widget.studentId ?? '',
        academicYear: widget.currentAcademicYear ?? '',
        term: widget.currentTerm ?? '',
        remarks: _remarksController.text.trim(),
        context: context,
      );

      // Close loading dialog
      Navigator.of(context).pop();

      print('🔍 PaymentProcessingScreen: Response received: $response');

      if (response != null) {
        print(
          '🔍 PaymentProcessingScreen: Response is not null, showing success dialog',
        );
        // Show success dialog with response data and return to dashboard
        _showFallbackSuccessDialog();
        // _showSuccessDialog(response);
      } else {
        print(
          '🔍 PaymentProcessingScreen: Response is null, showing fallback dialog',
        );
        // Show a fallback success dialog
        // _showFallbackSuccessDialog();
        _showFallbackSuccessDialog();
      }
    } catch (e) {
      // Close loading dialog if it's still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      // Show error dialog
      showDialog(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Error'),
              content: Text('Failed to update payment status: $e'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
      );
    }
  }

  void _showFallbackSuccessDialog() {
    print('🔍 PaymentProcessingScreen: _showFallbackSuccessDialog called');
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Payment Status Updated'),
            content: const Text(
              'Payment status has been updated successfully.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  context.pop(true);
                },
                child: const Text('Continue to Dashboard'),
              ),
            ],
          ),
    );
  }

  String _formatCurrency(dynamic value) {
    final num = int.tryParse(value.toString()) ?? 0;
    return num.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }
}
