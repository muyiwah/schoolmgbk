import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/appcolor.dart';
import '../../models/academic_settings_model.dart';
import '../../providers/academic_settings_provider.dart';
import '../../widgets/custom_toast_notification.dart';
// import '../../widgets/custom_app_bar.dart';

class CreateAcademicSettingsScreen extends ConsumerStatefulWidget {
  const CreateAcademicSettingsScreen({super.key});

  @override
  ConsumerState<CreateAcademicSettingsScreen> createState() =>
      _CreateAcademicSettingsScreenState();
}

class _CreateAcademicSettingsScreenState
    extends ConsumerState<CreateAcademicSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _academicYearController = TextEditingController();
  final _descriptionController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  String _currentTerm = 'First';
  bool _isLoading = false;

  // Individual term dates
  DateTime? _firstTermStart;
  DateTime? _firstTermEnd;
  DateTime? _secondTermStart;
  DateTime? _secondTermEnd;
  DateTime? _thirdTermStart;
  DateTime? _thirdTermEnd;

  final List<String> _terms = ['First', 'Second', 'Third'];

  @override
  void dispose() {
    _academicYearController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _selectStartDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _startDate) {
      setState(() {
        _startDate = picked;
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = null;
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null && picked != _endDate) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  Future<void> _selectTermDate(String term, String type) async {
    DateTime? currentDate;
    DateTime? firstDate;
    DateTime? lastDate;

    switch (term) {
      case 'First':
        currentDate = type == 'start' ? _firstTermStart : _firstTermEnd;
        firstDate = _startDate ?? DateTime.now();
        lastDate = _secondTermStart ?? _endDate ?? DateTime(2030);
        break;
      case 'Second':
        currentDate = type == 'start' ? _secondTermStart : _secondTermEnd;
        firstDate = _firstTermEnd ?? _startDate ?? DateTime.now();
        lastDate = _thirdTermStart ?? _endDate ?? DateTime(2030);
        break;
      case 'Third':
        currentDate = type == 'start' ? _thirdTermStart : _thirdTermEnd;
        firstDate = _secondTermEnd ?? _startDate ?? DateTime.now();
        lastDate = _endDate ?? DateTime(2030);
        break;
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate ?? firstDate ?? DateTime.now(),
      firstDate: firstDate ?? DateTime.now(),
      lastDate: lastDate ?? DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        switch (term) {
          case 'First':
            if (type == 'start') {
              _firstTermStart = picked;
            } else {
              _firstTermEnd = picked;
            }
            break;
          case 'Second':
            if (type == 'start') {
              _secondTermStart = picked;
            } else {
              _secondTermEnd = picked;
            }
            break;
          case 'Third':
            if (type == 'start') {
              _thirdTermStart = picked;
            } else {
              _thirdTermEnd = picked;
            }
            break;
        }
      });
    }
  }

  List<TermModel> _generateTerms() {
    // Use individual term dates if available, otherwise fall back to auto-generated dates
    if (_firstTermStart != null &&
        _firstTermEnd != null &&
        _secondTermStart != null &&
        _secondTermEnd != null &&
        _thirdTermStart != null &&
        _thirdTermEnd != null) {
      return [
        TermModel(
          id: '',
          name: 'First',
          startDate: _firstTermStart!,
          endDate: _firstTermEnd!,
          isActive: _currentTerm == 'First',
        ),
        TermModel(
          id: '',
          name: 'Second',
          startDate: _secondTermStart!,
          endDate: _secondTermEnd!,
          isActive: _currentTerm == 'Second',
        ),
        TermModel(
          id: '',
          name: 'Third',
          startDate: _thirdTermStart!,
          endDate: _thirdTermEnd!,
          isActive: _currentTerm == 'Third',
        ),
      ];
    }

    // Fallback to auto-generated dates
    if (_startDate == null || _endDate == null) return [];

    final duration = _endDate!.difference(_startDate!);
    final termDuration = Duration(days: duration.inDays ~/ 3);

    return [
      TermModel(
        id: '',
        name: 'First',
        startDate: _startDate!,
        endDate: _startDate!.add(termDuration),
        isActive: _currentTerm == 'First',
      ),
      TermModel(
        id: '',
        name: 'Second',
        startDate: _startDate!.add(termDuration),
        endDate: _startDate!.add(Duration(days: (duration.inDays * 2) ~/ 3)),
        isActive: _currentTerm == 'Second',
      ),
      TermModel(
        id: '',
        name: 'Third',
        startDate: _startDate!.add(Duration(days: (duration.inDays * 2) ~/ 3)),
        endDate: _endDate!,
        isActive: _currentTerm == 'Third',
      ),
    ];
  }

  Future<void> _createAcademicSettings() async {
    if (!_formKey.currentState!.validate()) return;
    if (_startDate == null || _endDate == null) {
      CustomToastNotification.show(
        'Please select start and end dates',
        type: ToastType.error,
      );
      return;
    }

    // Validate academic year date range
    if (_startDate!.isAfter(_endDate!)) {
      CustomToastNotification.show(
        'Start date must be before end date',
        type: ToastType.error,
      );
      return;
    }

    // Validate individual term dates if they are set
    if (_firstTermStart != null ||
        _firstTermEnd != null ||
        _secondTermStart != null ||
        _secondTermEnd != null ||
        _thirdTermStart != null ||
        _thirdTermEnd != null) {
      if (_firstTermStart == null ||
          _firstTermEnd == null ||
          _secondTermStart == null ||
          _secondTermEnd == null ||
          _thirdTermStart == null ||
          _thirdTermEnd == null) {
        CustomToastNotification.show(
          'Please set all term dates or leave them empty to auto-generate',
          type: ToastType.error,
        );
        return;
      }

      // Validate term date order
      if (_firstTermStart!.isAfter(_firstTermEnd!) ||
          _secondTermStart!.isAfter(_secondTermEnd!) ||
          _thirdTermStart!.isAfter(_thirdTermEnd!)) {
        CustomToastNotification.show(
          'Term start date must be before end date',
          type: ToastType.error,
        );
        return;
      }

      // Validate term sequence
      if (_firstTermEnd!.isAfter(_secondTermStart!) ||
          _secondTermEnd!.isAfter(_thirdTermStart!)) {
        CustomToastNotification.show(
          'Terms must be in chronological order',
          type: ToastType.error,
        );
        return;
      }

      // Validate term dates are within academic year range
      if (_firstTermStart!.isBefore(_startDate!) ||
          _firstTermEnd!.isAfter(_endDate!) ||
          _secondTermStart!.isBefore(_startDate!) ||
          _secondTermEnd!.isAfter(_endDate!) ||
          _thirdTermStart!.isBefore(_startDate!) ||
          _thirdTermEnd!.isAfter(_endDate!)) {
        CustomToastNotification.show(
          'Term dates must be within the academic year range',
          type: ToastType.error,
        );
        return;
      }
    }

    setState(() {
      _isLoading = true;
    });

    // Prepare terms for API call
    List<TermModel>? termsToSend;

    // If all individual term dates are set, send them to the API
    if (_firstTermStart != null &&
        _firstTermEnd != null &&
        _secondTermStart != null &&
        _secondTermEnd != null &&
        _thirdTermStart != null &&
        _thirdTermEnd != null) {
      termsToSend = [
        TermModel(
          id: '',
          name: 'First',
          startDate: _firstTermStart!,
          endDate: _firstTermEnd!,
          isActive: _currentTerm == 'First',
        ),
        TermModel(
          id: '',
          name: 'Second',
          startDate: _secondTermStart!,
          endDate: _secondTermEnd!,
          isActive: _currentTerm == 'Second',
        ),
        TermModel(
          id: '',
          name: 'Third',
          startDate: _thirdTermStart!,
          endDate: _thirdTermEnd!,
          isActive: _currentTerm == 'Third',
        ),
      ];
    }
    // If no individual term dates are set, send null to let backend auto-generate
    else {
      termsToSend = null;
    }

    final success = await ref
        .read(academicSettingsProvider.notifier)
        .createAcademicSettings(
          academicYear: _academicYearController.text.trim(),
          currentTerm: _currentTerm,
          startDate: _startDate!,
          endDate: _endDate!,
          terms: termsToSend,
          description:
              _descriptionController.text.trim().isEmpty
                  ? null
                  : _descriptionController.text.trim(),
        );

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        CustomToastNotification.show(
          'Academic settings created successfully',
          type: ToastType.success,
        );
        Navigator.pop(context);
      }
    } else {
      if (mounted) {
        final errorMessage = ref.read(academicSettingsProvider).errorMessage;
        CustomToastNotification.show(
          errorMessage ?? 'Failed to create academic settings',
          type: ToastType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Create Academic Year'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Academic Year Input
              _buildInputCard(
                'Academic Year',
                'Enter academic year (e.g., 2024/2025)',
                _academicYearController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Academic year is required';
                  }
                  final pattern = RegExp(r'^(20\d{2}[-/]20\d{2}|20\d{2})$');
                  if (!pattern.hasMatch(value.trim())) {
                    return 'Invalid format. Use 2024/2025, 2024-2025, or 2024';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 16),

              // Current Term Selection
              _buildTermSelectionCard(),

              const SizedBox(height: 16),

              // Date Selection
              _buildDateSelectionCard(),

              const SizedBox(height: 16),

              // Individual Term Dates
              _buildIndividualTermDatesCard(),

              const SizedBox(height: 16),

              // Description
              _buildInputCard(
                'Description (Optional)',
                'Enter a description for this academic year',
                _descriptionController,
                maxLines: 3,
                maxLength: 500,
              ),

              const SizedBox(height: 24),

              // Terms Preview
              if (_startDate != null && _endDate != null)
                _buildTermsPreviewCard(),

              const SizedBox(height: 32),

              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createAcademicSettings,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Text(
                            'Create Academic Year',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputCard(
    String title,
    String hint,
    TextEditingController controller, {
    String? Function(String?)? validator,
    int maxLines = 1,
    int? maxLength,
  }) {
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
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: controller,
            validator: validator,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
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
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermSelectionCard() {
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
            'Current Term',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _currentTerm,
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
                borderSide: BorderSide(color: AppColors.primary),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            items:
                _terms.map((term) {
                  return DropdownMenuItem(value: term, child: Text(term));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _currentTerm = value!;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDateSelectionCard() {
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
            'Academic Year Duration',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDateField(
                  'Start Date',
                  _startDate,
                  _selectStartDate,
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateField(
                  'End Date',
                  _endDate,
                  _selectEndDate,
                  Icons.event,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateField(
    String label,
    DateTime? date,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 14,
                      color: date != null ? Colors.black : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIndividualTermDatesCard() {
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
          Row(
            children: [
              const Text(
                'Individual Term Dates (Optional)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Optional',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Set custom dates for each term. Leave empty to auto-generate based on academic year duration. All three terms must be set if you choose custom dates.',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
          const SizedBox(height: 16),

          // First Term
          _buildTermDateSection('First Term', 'First'),
          const SizedBox(height: 16),

          // Second Term
          _buildTermDateSection('Second Term', 'Second'),
          const SizedBox(height: 16),

          // Third Term
          _buildTermDateSection('Third Term', 'Third'),
        ],
      ),
    );
  }

  Widget _buildTermDateSection(String title, String term) {
    DateTime? startDate;
    DateTime? endDate;

    switch (term) {
      case 'First':
        startDate = _firstTermStart;
        endDate = _firstTermEnd;
        break;
      case 'Second':
        startDate = _secondTermStart;
        endDate = _secondTermEnd;
        break;
      case 'Third':
        startDate = _thirdTermStart;
        endDate = _thirdTermEnd;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildTermDateField(
                  'Start Date',
                  startDate,
                  () => _selectTermDate(term, 'start'),
                  Icons.calendar_today,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTermDateField(
                  'End Date',
                  endDate,
                  () => _selectTermDate(term, 'end'),
                  Icons.event,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTermDateField(
    String label,
    DateTime? date,
    VoidCallback onTap,
    IconData icon,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 6),
        InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    date != null
                        ? '${date.day}/${date.month}/${date.year}'
                        : 'Select date',
                    style: TextStyle(
                      fontSize: 12,
                      color: date != null ? Colors.black : Colors.grey[500],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsPreviewCard() {
    final terms = _generateTerms();

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
          Row(
            children: [
              const Text(
                'Terms Preview',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color:
                      (_firstTermStart != null &&
                              _firstTermEnd != null &&
                              _secondTermStart != null &&
                              _secondTermEnd != null &&
                              _thirdTermStart != null &&
                              _thirdTermEnd != null)
                          ? Colors.green[50]
                          : Colors.orange[50],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  (_firstTermStart != null &&
                          _firstTermEnd != null &&
                          _secondTermStart != null &&
                          _secondTermEnd != null &&
                          _thirdTermStart != null &&
                          _thirdTermEnd != null)
                      ? 'Custom Dates'
                      : 'Auto-Generated',
                  style: TextStyle(
                    fontSize: 12,
                    color:
                        (_firstTermStart != null &&
                                _firstTermEnd != null &&
                                _secondTermStart != null &&
                                _secondTermEnd != null &&
                                _thirdTermStart != null &&
                                _thirdTermEnd != null)
                            ? Colors.green[600]
                            : Colors.orange[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...terms
              .map(
                (term) => Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        term.isActive
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color:
                          term.isActive ? AppColors.primary : Colors.grey[300]!,
                      width: term.isActive ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              term.name,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color:
                                    term.isActive
                                        ? AppColors.primary
                                        : Colors.black,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${term.startDate.day}/${term.startDate.month}/${term.startDate.year} - ${term.endDate.day}/${term.endDate.month}/${term.endDate.year}',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (term.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'Active',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
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
    );
  }
}
