import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/all_terms_class_statistics_model.dart'
    as new_model;
import 'package:schmgtsystem/services/global_academic_year_service.dart';

class PaymentBreakdownScreen extends ConsumerStatefulWidget {
  const PaymentBreakdownScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<PaymentBreakdownScreen> createState() =>
      _PaymentBreakdownScreenState();
}

class _PaymentBreakdownScreenState
    extends ConsumerState<PaymentBreakdownScreen> {
  String _selectedTerm = 'All Terms';
  final TextEditingController _searchController = TextEditingController();
  late GlobalAcademicYearService _academicYearService;

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadAllTermsStatistics();
    });
  }

  Future<void> _loadAllTermsStatistics({
    bool showSuccessMessage = false,
  }) async {
    try {
      final success = await ref
          .read(RiverpodProvider.classProvider.notifier)
          .getAllTermsClassStatistics(context);

      if (success && showSuccessMessage && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data refreshed successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error refreshing data: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadStatistics() async {
    await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getClassStatistics(
          context,
          term: _selectedTerm == 'All Terms' ? null : _selectedTerm,
          academicYear: _academicYearService.currentAcademicYearString,
        );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        Text(
          value,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildFeeStructureStatusByTerm(new_model.ClassStatistics classData) {
    final classState = ref.read(RiverpodProvider.classProvider);
    final allTermsData = classState.allTermsClassStatisticsData;
    final availableTerms = allTermsData.availableTerms;
    final hasFeeStructure = classData.feeStructureDetails != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Row(
          children: [
            Icon(Icons.schedule, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 8),
            Text(
              'Fee Structures by Term',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Term status indicators
        ...availableTerms.map((term) {
          final isCurrentTerm = term == _selectedTerm;
          final hasStructureForTerm =
              hasFeeStructure && isCurrentTerm; // Simplified for now

          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: hasStructureForTerm ? Colors.green[50] : Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color:
                    hasStructureForTerm
                        ? Colors.green[200]!
                        : Colors.orange[200]!,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  hasStructureForTerm ? Icons.check_circle : Icons.warning,
                  size: 16,
                  color:
                      hasStructureForTerm
                          ? Colors.green[600]
                          : Colors.orange[600],
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '$term Term',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color:
                          hasStructureForTerm
                              ? Colors.green[700]
                              : Colors.orange[700],
                    ),
                  ),
                ),
                if (isCurrentTerm)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue[100],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'Current',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[700],
                      ),
                    ),
                  ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildTermSpecificActions(new_model.ClassStatistics classData) {
    final classState = ref.read(RiverpodProvider.classProvider);
    final allTermsData = classState.allTermsClassStatisticsData;
    final availableTerms = allTermsData.availableTerms;
    final hasFeeStructure = classData.feeStructureDetails != null;
    final hasStructureForCurrentTerm =
        hasFeeStructure &&
        _selectedTerm == _academicYearService.currentTermString;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current term actions
        Container(
          padding: const EdgeInsets.all(12),
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
                  Icon(Icons.today, size: 16, color: Colors.blue[600]),
                  const SizedBox(width: 8),
                  Text(
                    'Current Term: $_selectedTerm',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue[700],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              if (hasStructureForCurrentTerm) ...[
                // Edit and Delete buttons for current term
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _showEditFeeStructureDialog(classData),
                        icon: Icon(Icons.edit, size: 16),
                        label: Text(
                          'Edit $_selectedTerm',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed:
                            () => _showDeleteFeeStructureDialog(classData),
                        icon: Icon(Icons.delete, size: 16),
                        label: Text(
                          'Delete',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Add button for current term
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _showAddFeeStructureDialog(classData),
                    icon: Icon(Icons.add, size: 16),
                    label: Text(
                      'Add $_selectedTerm Fee Structure',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.secondary,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),

        // Quick actions for other terms
        if (availableTerms.length > 1) ...[
          const SizedBox(height: 12),
          Text(
            'Quick Actions for Other Terms',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children:
                availableTerms.where((term) => term != _selectedTerm).map((
                  term,
                ) {
                  return OutlinedButton.icon(
                    onPressed:
                        () =>
                            _showAddFeeStructureForTermDialog(classData, term),
                    icon: Icon(Icons.add, size: 14),
                    label: Text('Add $term', style: TextStyle(fontSize: 11)),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                      side: BorderSide(color: Colors.grey[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  );
                }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildItemizedFeeBreakdown(dynamic feeStructureDetails) {
    final baseFee = feeStructureDetails.baseFee ?? 0;
    final addOns = feeStructureDetails.addOns as List<dynamic>? ?? [];
    final totalFee = feeStructureDetails.totalFee ?? baseFee;

    return Column(
      children: [
        // Base Fee
        _buildFeeItem(
          'Base Fee',
          '£${baseFee.toStringAsFixed(0)}',
          Colors.blue,
          isBaseFee: true,
        ),

        // Add-ons
        if (addOns.isNotEmpty) ...[
          const SizedBox(height: 8),
          ...addOns.map((addOn) {
            final name = addOn.name ?? 'Additional Fee';
            final amount = addOn.amount ?? 0;
            final compulsory = addOn.compulsory ?? false;
            final isActive = addOn.isActive ?? true;

            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _buildFeeItem(
                name,
                '£${amount.toStringAsFixed(0)}',
                compulsory ? Colors.red : Colors.green,
                isCompulsory: compulsory,
                isActive: isActive,
              ),
            );
          }).toList(),
        ],

        // Total Fee
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Fee',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
              Text(
                '£${totalFee.toStringAsFixed(0)}',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
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
                      color: Colors.grey[400],
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: Text(
                      'Inactive',
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white,
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
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddFeeStructureDialog(
    new_model.ClassStatistics classData,
  ) async {
    showDialog(
      context: context,
      builder:
          (context) => _AddFeeStructureDialog(
            classData: classData,
            onFeeStructureAdded: () {
              _loadAllTermsStatistics(); // Refresh the data
            },
          ),
    );
  }

  Future<void> _showAddFeeStructureForTermDialog(
    new_model.ClassStatistics classData,
    String term,
  ) async {
    showDialog(
      context: context,
      builder:
          (context) => _AddFeeStructureDialog(
            classData: classData,
            preSelectedTerm: term, // Pre-select the specific term
            onFeeStructureAdded: () {
              _loadAllTermsStatistics(); // Refresh the data
            },
          ),
    );
  }

  Future<void> _showBulkFeeStructureDialog() async {
    final classState = ref.read(RiverpodProvider.classProvider);
    final allTermsData = classState.allTermsClassStatisticsData;
    final classes = allTermsData.classes;
    final availableTerms = allTermsData.availableTerms;

    if (classes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No classes available for bulk fee structure creation'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => _BulkFeeStructureDialog(
            classes: classes,
            availableTerms: availableTerms,
            onFeeStructuresAdded: () {
              _loadAllTermsStatistics(); // Refresh the data
            },
          ),
    );
  }

  Future<void> _showEditFeeStructureDialog(
    new_model.ClassStatistics classData,
  ) async {
    // Get the current fee structure data
    final feeStructure = classData.feeStructureDetails;

    if (feeStructure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fee structure found to edit'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the full fee structures with IDs
    final feeStructuresData = await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getClassFeeStructures(context, classData.id!);

    if (feeStructuresData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load fee structure details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the active fee structure with ID
    final feeStructures = feeStructuresData['feeStructures'] as List?;
    Map<String, dynamic>? feeStructureWithId;

    if (feeStructures != null && feeStructures.isNotEmpty) {
      // Find the active fee structure or use the first one
      feeStructureWithId = feeStructures.firstWhere(
        (fs) => fs['isActive'] == true,
        orElse: () => feeStructures.first,
      );
    }

    if (feeStructureWithId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fee structure found with ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => _EditFeeStructureDialog(
            classData: classData,
            feeStructure: feeStructureWithId!,
            onFeeStructureUpdated: () {
              _loadAllTermsStatistics(); // Refresh the data
            },
          ),
    );
  }

  Future<void> _showDuplicateFeeStructureDialog(
    new_model.ClassStatistics classData,
  ) async {
    final feeStructure = classData.feeStructureDetails;

    if (feeStructure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fee structure to duplicate'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Duplicate Fee Structure'),
            content: Text(
              'Are you sure you want to duplicate the fee structure for ${classData.classLevel?.displayName ?? classData.level}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Duplicate'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      // Create a new fee structure with the same data but different term
      final feeStructureData = {
        'classId': classData.id,
        'term': _selectedTerm == 'All Terms' ? 'First' : _selectedTerm,
        'academicYear': _academicYearService.currentAcademicYearString,
        'baseFee': feeStructure.baseFee,
        'addOns':
            feeStructure.addOns
                .map(
                  (addOn) => {
                    'name': addOn.name,
                    'amount': addOn.amount,
                    'compulsory': addOn.compulsory,
                    'isActive': addOn.isActive,
                  },
                )
                .toList(),
        'setAsActive': false, // Don't set as active by default
        'creatorId':
            '68ccb7b8b576836f0f473c11', // This should come from user context
      };

      try {
        final success = await ref
            .read(RiverpodProvider.classProvider.notifier)
            .addFeeStructureToClass(
              context,
              classData.id ?? '',
              feeStructureData,
            );

        if (success) {
          await _loadAllTermsStatistics(
            showSuccessMessage: true,
          ); // Refresh the data
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error duplicating fee structure: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showDeleteFeeStructureDialog(
    new_model.ClassStatistics classData,
  ) async {
    // Get the current fee structure data
    final feeStructure = classData.feeStructureDetails;

    if (feeStructure == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fee structure found to delete'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Get the full fee structures with IDs
    final feeStructuresData = await ref
        .read(RiverpodProvider.classProvider.notifier)
        .getClassFeeStructures(context, classData.id!);

    if (feeStructuresData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load fee structure details'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Find the active fee structure with ID
    final feeStructures = feeStructuresData['feeStructures'] as List?;
    Map<String, dynamic>? feeStructureWithId;

    if (feeStructures != null && feeStructures.isNotEmpty) {
      // Find the active fee structure or use the first one
      feeStructureWithId = feeStructures.firstWhere(
        (fs) => fs['isActive'] == true,
        orElse: () => feeStructures.first,
      );
    }

    if (feeStructureWithId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No fee structure found with ID'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(Icons.warning, color: Colors.red, size: 24),
                const SizedBox(width: 12),
                const Text(
                  'Delete Fee Structure',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to delete this fee structure?',
                  style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Class: ${classData.classLevel?.displayName ?? classData.level} ${classData.section ?? ''}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Base Fee: £${feeStructureWithId?['baseFee']?.toString() ?? '0'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Total Fee: £${feeStructureWithId?['totalFee']?.toString() ?? '0'}',
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.orange, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'This action cannot be undone. All associated data will be permanently removed.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange[800],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Cancel',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              ElevatedButton(
                onPressed:
                    feeStructureWithId != null
                        ? () async {
                          Navigator.of(context).pop();
                          await _deleteFeeStructure(
                            classData,
                            feeStructureWithId!,
                          );
                        }
                        : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Delete',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _deleteFeeStructure(
    new_model.ClassStatistics classData,
    Map<String, dynamic>? feeStructure,
  ) async {
    try {
      if (feeStructure == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fee structure data is null'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final feeStructureId = feeStructure['_id'] ?? feeStructure['id'];

      if (feeStructureId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fee structure ID not found'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final success = await ref
          .read(RiverpodProvider.classProvider.notifier)
          .deleteFeeStructure(context, feeStructureId);

      if (success) {
        await _loadAllTermsStatistics(
          showSuccessMessage: true,
        ); // Refresh the data
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting fee structure: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classState = ref.watch(RiverpodProvider.classProvider);
    final allTermsData = classState.allTermsClassStatisticsData;
    final groupedByTerm = allTermsData.groupedByTerm;
    final overallStats = allTermsData.overallStats;
    final filters = allTermsData.filters;
    final availableTerms = allTermsData.availableTerms;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(filters),
            const SizedBox(height: 24),
            _buildControlsSection(availableTerms),
            const SizedBox(height: 32),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: _buildTermGroupedClassesSection(groupedByTerm),
                ),
                const SizedBox(width: 24),
                Expanded(flex: 1, child: _buildSummarySection(overallStats)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(new_model.Filters? filters) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Payment Breakdown',
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Comprehensive fee overview for all classes',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        Row(
          children: [
            ElevatedButton.icon(
              onPressed: () => _showBulkFeeStructureDialog(),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Bulk Add Fee Structures'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.download, size: 16),
              label: const Text('Export Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF3B82F6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                elevation: 0,
              ),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              onPressed:
                  () => _loadAllTermsStatistics(showSuccessMessage: true),
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                side: BorderSide(color: Colors.grey[300]!),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildControlsSection(List<String> availableTerms) {
    return Row(
      children: [
        Container(
          width: 200,
          child: DropdownButtonFormField<String>(
            value: _selectedTerm,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
            items: [
              const DropdownMenuItem(
                value: 'All Terms',
                child: Text(
                  'All Terms',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
              ...availableTerms.map((term) {
                return DropdownMenuItem(
                  value: term,
                  child: Text(
                    '$term Term',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
            ],
            onChanged: (value) {
              setState(() {
                _selectedTerm = value!;
              });
              // Reload statistics when term changes
              if (value == 'All Terms') {
                _loadAllTermsStatistics();
              } else {
                _loadStatistics();
              }
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 1,
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search by Class...',
              prefixIcon: Icon(Icons.search, color: Colors.grey[400], size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.help_outline, color: Colors.grey[400]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          onPressed: () {},
          icon: Icon(Icons.view_list, color: Colors.grey[700]),
          style: IconButton.styleFrom(
            backgroundColor: Colors.grey[100],
            padding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }

  Widget _buildTermGroupedClassesSection(
    List<new_model.TermGroup> groupedByTerm,
  ) {
    if (groupedByTerm.isEmpty) {
      return Container(
        height: 200,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.school_outlined, size: 48, color: Colors.grey[400]),
              SizedBox(height: 16),
              Text(
                'No classes available',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Add classes to see fee structures',
                style: TextStyle(fontSize: 14, color: Colors.grey[500]),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          groupedByTerm.map((termGroup) {
            return _buildTermSection(termGroup);
          }).toList(),
    );
  }

  Widget _buildTermSection(new_model.TermGroup termGroup) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Term Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _getTermColor(termGroup.term),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: _getTermColor(termGroup.term).withOpacity(0.1),
                  spreadRadius: 0,
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
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.schedule, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${termGroup.term} Term',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '${termGroup.classes.length} classes • ${termGroup.academicYear}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${termGroup.classes.length}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Classes Grid
          if (termGroup.classes.isEmpty)
            Container(
              height: 120,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.class_outlined,
                      size: 32,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'No classes in ${termGroup.term} Term',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    termGroup.classes.map((classData) {
                      final index = termGroup.classes.indexOf(classData);
                      return Container(
                        width: 320,
                        margin: EdgeInsets.only(
                          right: index < termGroup.classes.length - 1 ? 16 : 0,
                        ),
                        child: _buildClassCard(classData),
                      );
                    }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Color _getTermColor(String term) {
    switch (term.toLowerCase()) {
      case 'first':
        return const Color(0xFF3B82F6); // Blue
      case 'second':
        return const Color(0xFF10B981); // Green
      case 'third':
        return const Color(0xFFF59E0B); // Orange
      default:
        return const Color(0xFF6B7280); // Gray
    }
  }

  Widget _buildClassCard(new_model.ClassStatistics classData) {
    final hasFeeStructure = classData.feeStructureDetails != null;
    final studentCount = classData.studentCount ?? 0;
    final capacity = classData.capacity ?? 0;
    final capacityUtilization = classData.capacityUtilization ?? 0;
    final expectedRevenue = classData.expectedRevenue ?? 0;
    final totalPaidAmount = classData.totalPaidAmount ?? 0;
    final paymentCollectionRate = classData.paymentCollectionRate ?? 0;

    return PopupMenuButton<String>(
      tooltip: 'Fee structure options',
      onSelected: (value) {
        switch (value) {
          case 'edit':
            _showEditFeeStructureDialog(classData);
            break;
          case 'delete':
            _showDeleteFeeStructureDialog(classData);
            break;
          case 'duplicate':
            _showDuplicateFeeStructureDialog(classData);
            break;
          case 'add':
            _showAddFeeStructureDialog(classData);
            break;
        }
      },
      itemBuilder:
          (context) => [
            if (hasFeeStructure) ...[
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                    const SizedBox(width: 8),
                    Text('Edit Fee Structure'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'duplicate',
                child: Row(
                  children: [
                    Icon(Icons.copy, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text('Duplicate Fee Structure'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, size: 16, color: Colors.red[600]),
                    const SizedBox(width: 8),
                    Text('Delete Fee Structure'),
                  ],
                ),
              ),
            ] else ...[
              PopupMenuItem(
                value: 'add',
                child: Row(
                  children: [
                    Icon(Icons.add, size: 16, color: Colors.green[600]),
                    const SizedBox(width: 8),
                    Text('Add Fee Structure'),
                  ],
                ),
              ),
            ],
          ],
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.08),
              spreadRadius: 0,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      '${classData.classLevel?.displayName ?? classData.level ?? 'Unknown'} ${classData.section ?? ''}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Row(
                    children: [
                      // Edit Button in Header
                      if (hasFeeStructure) ...[
                        InkWell(
                          onTap: () => _showEditFeeStructureDialog(classData),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(
                                color: Colors.blue[200]!,
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              Icons.edit,
                              size: 16,
                              color: Colors.blue[600],
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Context Menu Indicator
                        Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            Icons.more_vert,
                            size: 14,
                            color: Colors.grey[400],
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '$studentCount/$capacity',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          Text(
                            '$capacityUtilization% capacity',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Fee Structure Status by Term
              _buildFeeStructureStatusByTerm(classData),
              const SizedBox(height: 12),

              if (hasFeeStructure) ...[
                // Revenue Information
                _buildInfoRow(
                  'Expected Revenue',
                  '£${expectedRevenue.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Paid Amount',
                  '£${totalPaidAmount.toStringAsFixed(0)}',
                ),
                const SizedBox(height: 8),
                _buildInfoRow('Collection Rate', '$paymentCollectionRate%'),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Avg Fee/Student',
                  '£${classData.averageFeePerStudent?.toStringAsFixed(0) ?? '0'}',
                ),
                const SizedBox(height: 12),

                // Fee Structure Breakdown
                if (classData.feeStructureDetails != null) ...[
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with Edit Button
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Fee Breakdown',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[700],
                              ),
                            ),
                            // Edit Button
                            InkWell(
                              onTap:
                                  () => _showEditFeeStructureDialog(classData),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.blue[100],
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: Colors.blue[300]!,
                                    width: 1,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 12,
                                      color: Colors.blue[700],
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Edit',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                        color: Colors.blue[700],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        _buildItemizedFeeBreakdown(
                          classData.feeStructureDetails!,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
              ],

              // Action Buttons
              const SizedBox(height: 16),
              _buildTermSpecificActions(classData),

              // Quick Edit Button (if fee structure exists)
              if (hasFeeStructure) ...[
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _showEditFeeStructureDialog(classData),
                    icon: Icon(Icons.edit, size: 16, color: Colors.blue[600]),
                    label: Text(
                      'Edit Fee Structure',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.blue[600],
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.blue[300]!),
                      padding: EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummarySection(new_model.OverallStats? overallStats) {
    final totalRevenue = overallStats?.totalExpectedRevenue ?? 0;
    final totalPaidAmount = overallStats?.totalPaidAmount ?? 0;
    final collectionRate = overallStats?.overallCollectionRate ?? 0;

    return Column(
      children: [
        _buildSummaryAnalyticsCard(
          totalRevenue,
          totalPaidAmount,
          collectionRate.round(),
        ),
        const SizedBox(height: 24),
        _buildRequiredVsOptionalChart(overallStats?.feeStructureStats),
        const SizedBox(height: 24),
        _buildClassesOverviewCard(overallStats),
      ],
    );
  }

  Widget _buildSummaryAnalyticsCard(
    int totalRevenue,
    int totalPaidAmount,
    int collectionRate,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        const Text(
          'Summary Analytics',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 16),

        // Three separate cards
        Column(
          children: [
            // Total Expected Revenue Card
            _buildRevenueCard(totalRevenue),
            const SizedBox(height: 12),
            // Total Paid Amount Card
            _buildPaidAmountCard(totalPaidAmount),
            const SizedBox(height: 12),
            // Collection Rate Card
            _buildCollectionRateCard(collectionRate),
          ],
        ),
      ],
    );
  }

  Widget _buildRevenueCard(int totalRevenue) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD), // Light blue background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF1976D2).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1976D2).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Expected Revenue',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF1976D2), // Medium blue
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '£${totalRevenue.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0D47A1), // Dark blue
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaidAmountCard(int totalPaidAmount) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E8), // Light green background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF388E3C).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF388E3C).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Total Paid Amount',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF388E3C), // Medium green
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '£${totalPaidAmount.toStringAsFixed(0)}',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1B5E20), // Dark green
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCollectionRateCard(int collectionRate) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0), // Light orange background
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF57C00).withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFF57C00).withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Collection Rate',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFF57C00), // Medium orange
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$collectionRate%',
            style: const TextStyle(
              fontSize: 36,
              fontWeight: FontWeight.bold,
              color: Color(0xFFE65100), // Dark orange
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRequiredVsOptionalChart(
    new_model.FeeStructureStats? feeStructureStats,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Required vs Optional Fees',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Icon(Icons.more_horiz, color: Colors.grey[400]),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              // Chart
              SizedBox(
                height: 120,
                width: 120,
                child: PieChart(
                  PieChartData(
                    sectionsSpace: 2,
                    centerSpaceRadius: 30,
                    sections: [
                      PieChartSectionData(
                        color: const Color(0xFF3B82F6),
                        value:
                            (feeStructureStats?.averageRequiredFeePercentage ??
                                    75)
                                .toDouble(),
                        title: '',
                        radius: 35,
                      ),
                      PieChartSectionData(
                        color: const Color(0xFF10B981),
                        value:
                            (feeStructureStats?.averageOptionalFeePercentage ??
                                    25)
                                .toDouble(),
                        title: '',
                        radius: 35,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 20),
              // Labels with lines
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildChartLabel(
                      'Required Fees',
                      '${feeStructureStats?.averageRequiredFeePercentage ?? 75}%',
                      const Color(0xFF3B82F6),
                    ),
                    const SizedBox(height: 16),
                    _buildChartLabel(
                      'Optional Fees',
                      '${feeStructureStats?.averageOptionalFeePercentage ?? 25}%',
                      const Color(0xFF10B981),
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

  Widget _buildChartLabel(String label, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Row(
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
              ),
              const Spacer(),
              Text(
                percentage,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClassesOverviewCard(new_model.OverallStats? overallStats) {
    final totalStudents = overallStats?.totalStudents ?? 0;
    final totalClasses = overallStats?.totalClasses ?? 0;
    final averageStudentsPerClass = overallStats?.averageStudentsPerClass ?? 0;
    final highestFeeClass = overallStats?.classWithHighestFee?.name ?? 'N/A';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Classes Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          _buildOverviewRow('Total Classes', '$totalClasses'),
          const SizedBox(height: 12),
          _buildOverviewRow('Total Students', '$totalStudents'),
          const SizedBox(height: 12),
          _buildOverviewRow('Avg Students/Class', '$averageStudentsPerClass'),
          const SizedBox(height: 12),
          _buildOverviewRow('Highest Fee Class', highestFeeClass),
        ],
      ),
    );
  }

  Widget _buildOverviewRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class GradeClassData {
  final String name;
  final int studentCount;
  final Map<String, int> requiredFees;
  final Map<String, int> optionalFees;

  GradeClassData({
    required this.name,
    required this.studentCount,
    required this.requiredFees,
    required this.optionalFees,
  });
}

class _AddFeeStructureDialog extends ConsumerStatefulWidget {
  final new_model.ClassStatistics classData;
  final VoidCallback onFeeStructureAdded;
  final String? preSelectedTerm; // Optional pre-selected term

  const _AddFeeStructureDialog({
    required this.classData,
    required this.onFeeStructureAdded,
    this.preSelectedTerm,
  });

  @override
  ConsumerState<_AddFeeStructureDialog> createState() =>
      _AddFeeStructureDialogState();
}

class _AddFeeStructureDialogState
    extends ConsumerState<_AddFeeStructureDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseFeeController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  late GlobalAcademicYearService _academicYearService;

  String _selectedTerm = 'First';
  bool _setAsActive = true;
  List<AddOnFee> _addOns = [];

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _academicYearController.text =
        _academicYearService.currentAcademicYearString;
    // Use pre-selected term if provided, otherwise use current term
    _selectedTerm =
        widget.preSelectedTerm ?? _academicYearService.currentTermString;
    _addOns = [AddOnFee(name: '', amount: 0, compulsory: true, isActive: true)];
  }

  List<String> _getCurrentAcademicYearTerms() {
    final academicYear = _academicYearService.currentAcademicYear;
    if (academicYear?.terms != null) {
      return academicYear!.terms.map((term) => term.name).toList();
    }
    return ['First', 'Second', 'Third']; // Fallback terms
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_balance_wallet, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Add Fee Structure - ${widget.classData.classLevel?.displayName ?? widget.classData.level} ${widget.classData.section ?? ''}',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        if (widget.preSelectedTerm != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'For ${widget.preSelectedTerm} Term',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      SizedBox(height: 16),

                      // Term Selection
                      _buildDropdownField(
                        label: 'Term',
                        value: _selectedTerm,
                        items: _getCurrentAcademicYearTerms(),
                        onChanged:
                            (value) => setState(() => _selectedTerm = value!),
                      ),
                      SizedBox(height: 16),

                      // Academic Year (Read-only)
                      _buildReadOnlyField(
                        label: 'Academic Year',
                        value: _academicYearService.currentAcademicYearString,
                      ),
                      SizedBox(height: 16),

                      // Base Fee
                      _buildTextField(
                        controller: _baseFeeController,
                        label: 'Base Fee (£)',
                        hint: 'e.g., 30000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Base fee is required';
                          if (int.tryParse(value!) == null)
                            return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Add-ons Section
                      _buildSectionTitle('Additional Fees'),
                      SizedBox(height: 16),

                      ..._addOns.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addOn = entry.value;
                        return _buildAddOnRow(index, addOn);
                      }).toList(),

                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addAddOn,
                        icon: Icon(Icons.add, size: 16),
                        label: Text('Add Another Fee'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Set as Active
                      Row(
                        children: [
                          Checkbox(
                            value: _setAsActive,
                            onChanged:
                                (value) => setState(
                                  () => _setAsActive = value ?? true,
                                ),
                          ),
                          Expanded(
                            child: Text(
                              'Set as active fee structure for this class',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Add Fee Structure'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items:
                  items
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnRow(int index, AddOnFee addOn) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: addOn.name,
                  decoration: InputDecoration(
                    labelText: 'Fee Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _addOns[index].name = value,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: addOn.amount.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (£)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged:
                      (value) =>
                          _addOns[index].amount = int.tryParse(value) ?? 0,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: () => _removeAddOn(index),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Compulsory', style: TextStyle(fontSize: 14)),
                  value: addOn.compulsory,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].compulsory = value ?? false,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text('Active', style: TextStyle(fontSize: 14)),
                  value: addOn.isActive,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].isActive = value ?? true,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAddOn() {
    setState(() {
      _addOns.add(
        AddOnFee(name: '', amount: 0, compulsory: false, isActive: true),
      );
    });
  }

  void _removeAddOn(int index) {
    if (_addOns.length > 1) {
      setState(() {
        _addOns.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Filter out empty add-ons
    final validAddOns =
        _addOns
            .where((addOn) => addOn.name.isNotEmpty && addOn.amount > 0)
            .toList();

    final feeStructureData = {
      'term': _selectedTerm,
      'academicYear': _academicYearService.currentAcademicYearString,
      'baseFee': int.parse(_baseFeeController.text.trim()),
      'addOns':
          validAddOns
              .map(
                (addOn) => {
                  'name': addOn.name,
                  'amount': addOn.amount,
                  'compulsory': addOn.compulsory,
                  'isActive': addOn.isActive,
                },
              )
              .toList(),
      'setAsActive': _setAsActive,
      'creatorId':
          '68ccb7b8b576836f0f473c11', // This should come from user context
    };

    final success = await ref
        .read(RiverpodProvider.classProvider.notifier)
        .addFeeStructureToClass(
          context,
          widget.classData.id!,
          feeStructureData,
        );

    if (success) {
      Navigator.of(context).pop();
      widget.onFeeStructureAdded();
    }
  }
}

class AddOnFee {
  String name;
  int amount;
  bool compulsory;
  bool isActive;

  AddOnFee({
    required this.name,
    required this.amount,
    required this.compulsory,
    required this.isActive,
  });
}

// Edit Fee Structure Dialog
class _EditFeeStructureDialog extends ConsumerStatefulWidget {
  final new_model.ClassStatistics classData;
  final Map<String, dynamic> feeStructure; // The existing fee structure data
  final VoidCallback onFeeStructureUpdated;

  const _EditFeeStructureDialog({
    required this.classData,
    required this.feeStructure,
    required this.onFeeStructureUpdated,
  });

  @override
  ConsumerState<_EditFeeStructureDialog> createState() =>
      _EditFeeStructureDialogState();
}

class _EditFeeStructureDialogState
    extends ConsumerState<_EditFeeStructureDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseFeeController = TextEditingController();
  final TextEditingController _academicYearController = TextEditingController();
  late GlobalAcademicYearService _academicYearService;

  String _selectedTerm = 'First';
  bool _setAsActive = true;
  List<AddOnFee> _addOns = [];

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _populateForm();
  }

  // Terms sourced from the current academic year set by admin
  List<String> _getCurrentAcademicYearTerms() {
    final academicYear = _academicYearService.currentAcademicYear;
    if (academicYear?.terms != null) {
      return academicYear!.terms.map((term) => term.name).toList();
    }
    return ['First', 'Second', 'Third'];
  }

  // Simple read-only field renderer for immutable values like academic year
  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  void _populateForm() {
    // Populate form with existing fee structure data
    // widget.feeStructure is now a Map<String, dynamic>, so we access it using map notation
    _selectedTerm = widget.feeStructure['term'] ?? 'First';
    _academicYearController.text =
        widget.feeStructure['academicYear'] ??
        _academicYearService.currentAcademicYearString;
    _baseFeeController.text = widget.feeStructure['baseFee']?.toString() ?? '';
    _setAsActive = widget.feeStructure['isActive'] ?? true;

    // Populate add-ons
    if (widget.feeStructure['addOns'] != null) {
      _addOns =
          (widget.feeStructure['addOns'] as List).map<AddOnFee>((addOn) {
            // Handle both Map and object types
            if (addOn is Map<String, dynamic>) {
              return AddOnFee(
                name: addOn['name'] ?? '',
                amount: addOn['amount'] ?? 0,
                compulsory: addOn['compulsory'] ?? false,
                isActive: addOn['isActive'] ?? true,
              );
            } else if (addOn is new_model.AddOn) {
              // Handle new AddOn objects from the new model
              return AddOnFee(
                name: addOn.name ?? '',
                amount: addOn.amount ?? 0,
                compulsory: addOn.compulsory ?? false,
                isActive: addOn.isActive ?? true,
              );
            } else {
              // If it's not a Map or AddOn object, create a default AddOnFee
              return AddOnFee(
                name: '',
                amount: 0,
                compulsory: false,
                isActive: true,
              );
            }
          }).toList();
    }

    if (_addOns.isEmpty) {
      _addOns = [
        AddOnFee(name: '', amount: 0, compulsory: true, isActive: true),
      ];
    }
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    _academicYearController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Edit Fee Structure - ${widget.classData.classLevel?.displayName ?? widget.classData.level} ${widget.classData.section ?? ''}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Flexible(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Basic Information
                      _buildSectionTitle('Basic Information'),
                      SizedBox(height: 16),

                      // Term Selection
                      _buildDropdownField(
                        label: 'Term',
                        value: _selectedTerm,
                        items: _getCurrentAcademicYearTerms(),
                        onChanged:
                            (value) => setState(() => _selectedTerm = value!),
                      ),
                      SizedBox(height: 16),

                      // Academic Year (Read-only)
                      _buildReadOnlyField(
                        label: 'Academic Year',
                        value: _academicYearService.currentAcademicYearString,
                      ),
                      SizedBox(height: 16),

                      // Base Fee
                      _buildTextField(
                        controller: _baseFeeController,
                        label: 'Base Fee (£)',
                        hint: 'e.g., 30000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Base fee is required';
                          if (int.tryParse(value!) == null)
                            return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      SizedBox(height: 24),

                      // Add-ons Section
                      _buildSectionTitle('Additional Fees'),
                      SizedBox(height: 16),

                      ..._addOns.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addOn = entry.value;
                        return _buildAddOnRow(index, addOn);
                      }).toList(),

                      SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _addAddOn,
                        icon: Icon(Icons.add, size: 16),
                        label: Text('Add Another Fee'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24),

                      // Set as Active
                      Row(
                        children: [
                          Checkbox(
                            value: _setAsActive,
                            onChanged:
                                (value) => setState(
                                  () => _setAsActive = value ?? true,
                                ),
                          ),
                          Expanded(
                            child: Text(
                              'Set as active fee structure for this class',
                              style: TextStyle(fontSize: 14),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text('Cancel'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                      ),
                      child: Text('Update Fee Structure'),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              items:
                  items
                      .map(
                        (item) =>
                            DropdownMenuItem(value: item, child: Text(item)),
                      )
                      .toList(),
              onChanged: onChanged,
              isExpanded: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddOnRow(int index, AddOnFee addOn) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: addOn.name,
                  decoration: InputDecoration(
                    labelText: 'Fee Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _addOns[index].name = value,
                ),
              ),
              SizedBox(width: 12),
              SizedBox(
                width: 120,
                child: TextFormField(
                  initialValue: addOn.amount.toString(),
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Amount (£)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                  onChanged:
                      (value) =>
                          _addOns[index].amount = int.tryParse(value) ?? 0,
                ),
              ),
              SizedBox(width: 12),
              IconButton(
                onPressed: () => _removeAddOn(index),
                icon: Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
          SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: CheckboxListTile(
                  title: Text('Compulsory', style: TextStyle(fontSize: 14)),
                  value: addOn.compulsory,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].compulsory = value ?? false,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: CheckboxListTile(
                  title: Text('Active', style: TextStyle(fontSize: 14)),
                  value: addOn.isActive,
                  onChanged:
                      (value) => setState(
                        () => _addOns[index].isActive = value ?? true,
                      ),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAddOn() {
    setState(() {
      _addOns.add(
        AddOnFee(name: '', amount: 0, compulsory: false, isActive: true),
      );
    });
  }

  void _removeAddOn(int index) {
    if (_addOns.length > 1) {
      setState(() {
        _addOns.removeAt(index);
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Filter out empty add-ons
    final validAddOns =
        _addOns
            .where((addOn) => addOn.name.isNotEmpty && addOn.amount > 0)
            .toList();
    print('Valid add-ons: $validAddOns');

    // Get the fee structure ID
    final feeStructureId =
        widget.feeStructure['_id'] ?? widget.feeStructure['id'];

    if (feeStructureId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fee structure ID not found'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Prepare fee structure data
    final feeStructureData = {
      'term': _selectedTerm,
      'academicYear': _academicYearService.currentAcademicYearString,
      'baseFee': int.parse(_baseFeeController.text.trim()),
      'addOns':
          validAddOns
              .map(
                (addOn) => {
                  'name': addOn.name,
                  'amount': addOn.amount,
                  'compulsory': addOn.compulsory,
                  'isActive': addOn.isActive,
                },
              )
              .toList(),
      'setAsActive': _setAsActive,
      'creatorId':
          '68ccb7b8b576836f0f473c11', // This should come from user context
    };

    final success = await ref
        .read(RiverpodProvider.classProvider.notifier)
        .updateFeeStructure(context, feeStructureId, feeStructureData);

    if (success) {
      Navigator.of(context).pop();
      widget.onFeeStructureUpdated();
    }
  }
}

/// Bulk Fee Structure Dialog for adding fee structures to multiple classes and terms
class _BulkFeeStructureDialog extends ConsumerStatefulWidget {
  final List<new_model.ClassStatistics> classes;
  final List<String> availableTerms;
  final VoidCallback onFeeStructuresAdded;

  const _BulkFeeStructureDialog({
    required this.classes,
    required this.availableTerms,
    required this.onFeeStructuresAdded,
  });

  @override
  ConsumerState<_BulkFeeStructureDialog> createState() =>
      _BulkFeeStructureDialogState();
}

class _BulkFeeStructureDialogState
    extends ConsumerState<_BulkFeeStructureDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _baseFeeController = TextEditingController();
  late GlobalAcademicYearService _academicYearService;

  Set<String> _selectedClasses = {};
  Set<String> _selectedTerms = {};
  List<AddOnFee> _addOns = [];
  bool _setAsActive = true;

  @override
  void initState() {
    super.initState();
    _academicYearService = GlobalAcademicYearService();
    _addOns = [AddOnFee(name: '', amount: 0, compulsory: true, isActive: true)];
  }

  @override
  void dispose() {
    _baseFeeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.secondary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.batch_prediction, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bulk Add Fee Structures',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create fee structures for multiple classes and terms at once',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Academic Year (Read-only)
                      _buildReadOnlyField(
                        label: 'Academic Year',
                        value: _academicYearService.currentAcademicYearString,
                      ),
                      const SizedBox(height: 20),

                      // Class Selection
                      _buildSectionTitle('Select Classes'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value:
                                      _selectedClasses.length ==
                                      widget.classes.length,
                                  tristate: true,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedClasses =
                                            widget.classes
                                                .map((c) => c.id ?? '')
                                                .toSet()
                                                .cast<String>();
                                      } else {
                                        _selectedClasses.clear();
                                      }
                                    });
                                  },
                                ),
                                const Text(
                                  'Select All Classes',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...widget.classes.map((classData) {
                              final classId = classData.id ?? '';
                              final className =
                                  '${classData.classLevel?.displayName ?? classData.level} ${classData.section ?? ''}';
                              final hasFeeStructure =
                                  classData.feeStructureDetails != null;

                              return CheckboxListTile(
                                value: _selectedClasses.contains(classId),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedClasses.add(classId);
                                    } else {
                                      _selectedClasses.remove(classId);
                                    }
                                  });
                                },
                                title: Text(className),
                                subtitle: Text(
                                  hasFeeStructure
                                      ? 'Has fee structure'
                                      : 'No fee structure',
                                  style: TextStyle(
                                    color:
                                        hasFeeStructure
                                            ? Colors.green[600]
                                            : Colors.orange[600],
                                    fontSize: 12,
                                  ),
                                ),
                                dense: true,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Term Selection
                      _buildSectionTitle('Select Terms'),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value:
                                      _selectedTerms.length ==
                                      widget.availableTerms.length,
                                  tristate: true,
                                  onChanged: (value) {
                                    setState(() {
                                      if (value == true) {
                                        _selectedTerms =
                                            widget.availableTerms
                                                .toSet()
                                                .cast<String>();
                                      } else {
                                        _selectedTerms.clear();
                                      }
                                    });
                                  },
                                ),
                                const Text(
                                  'Select All Terms',
                                  style: TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                            const Divider(),
                            ...widget.availableTerms.map((term) {
                              return CheckboxListTile(
                                value: _selectedTerms.contains(term),
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedTerms.add(term);
                                    } else {
                                      _selectedTerms.remove(term);
                                    }
                                  });
                                },
                                title: Text('$term Term'),
                                dense: true,
                              );
                            }).toList(),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Base Fee
                      _buildTextField(
                        controller: _baseFeeController,
                        label: 'Base Fee (£)',
                        hint: 'e.g., 30000',
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value?.isEmpty == true)
                            return 'Base fee is required';
                          if (int.tryParse(value!) == null)
                            return 'Enter a valid amount';
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),

                      // Add-ons Section
                      _buildSectionTitle('Additional Fees'),
                      const SizedBox(height: 12),
                      ..._addOns.asMap().entries.map((entry) {
                        final index = entry.key;
                        final addOn = entry.value;
                        return _buildAddOnRow(index, addOn);
                      }).toList(),

                      // Add Add-on Button
                      OutlinedButton.icon(
                        onPressed: _addAddOn,
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Add Additional Fee'),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey[300]!),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Set as Active
                      CheckboxListTile(
                        value: _setAsActive,
                        onChanged:
                            (value) =>
                                setState(() => _setAsActive = value ?? true),
                        title: const Text('Set as Active'),
                        subtitle: const Text(
                          'Make this fee structure active for the selected classes',
                        ),
                        dense: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton.icon(
                      onPressed:
                          _selectedClasses.isNotEmpty &&
                                  _selectedTerms.isNotEmpty
                              ? _createBulkFeeStructures
                              : null,
                      icon: const Icon(Icons.batch_prediction, size: 16),
                      label: Text(
                        'Create ${_selectedClasses.length * _selectedTerms.length} Fee Structures',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.secondary,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildReadOnlyField({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value,
            style: TextStyle(fontSize: 14, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
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
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
          ),
          keyboardType: keyboardType,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildAddOnRow(int index, AddOnFee addOn) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  initialValue: addOn.name,
                  decoration: const InputDecoration(
                    labelText: 'Fee Name',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onChanged: (value) => _addOns[index].name = value,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: TextFormField(
                  initialValue: addOn.amount.toString(),
                  decoration: const InputDecoration(
                    labelText: 'Amount (£)',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  onChanged:
                      (value) =>
                          _addOns[index].amount = int.tryParse(value) ?? 0,
                ),
              ),
              const SizedBox(width: 12),
              Column(
                children: [
                  CheckboxListTile(
                    value: addOn.compulsory,
                    onChanged:
                        (value) => setState(
                          () => _addOns[index].compulsory = value ?? false,
                        ),
                    title: const Text(
                      'Required',
                      style: TextStyle(fontSize: 12),
                    ),
                    dense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
              IconButton(
                onPressed: () => _removeAddOn(index),
                icon: const Icon(Icons.delete, color: Colors.red),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _addAddOn() {
    setState(() {
      _addOns.add(
        AddOnFee(name: '', amount: 0, compulsory: false, isActive: true),
      );
    });
  }

  void _removeAddOn(int index) {
    setState(() {
      _addOns.removeAt(index);
    });
  }

  Future<void> _createBulkFeeStructures() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      // Show loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      final baseFee = int.parse(_baseFeeController.text.trim());
      int successCount = 0;
      int totalCount = _selectedClasses.length * _selectedTerms.length;

      // Create fee structures for each class and term combination
      for (final classId in _selectedClasses) {
        for (final term in _selectedTerms) {
          try {
            final feeStructureData = {
              'term': term,
              'academicYear': _academicYearService.currentAcademicYearString,
              'baseFee': baseFee,
              'addOns':
                  _addOns
                      .where((addOn) => addOn.name.isNotEmpty)
                      .map(
                        (addOn) => {
                          'name': addOn.name,
                          'amount': addOn.amount,
                          'compulsory': addOn.compulsory,
                          'isActive': addOn.isActive,
                        },
                      )
                      .toList(),
              'setAsActive': _setAsActive,
              'creatorId':
                  '68ccb7b8b576836f0f473c11', // This should come from user context
            };

            final success = await ref
                .read(RiverpodProvider.classProvider.notifier)
                .addFeeStructureToClass(context, classId, feeStructureData);

            if (success) {
              successCount++;
            }
          } catch (e) {
            print(
              'Error creating fee structure for class $classId, term $term: $e',
            );
          }
        }
      }

      // Close loading dialog
      Navigator.of(context).pop();

      // Data will be refreshed by the callback

      // Show result
      if (mounted) {
        showDialog(
          context: context,
          builder:
              (context) => AlertDialog(
                title: const Text('Bulk Creation Complete'),
                content: Text(
                  'Successfully created $successCount out of $totalCount fee structures.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Close result dialog
                      Navigator.of(context).pop(); // Close bulk dialog
                      widget.onFeeStructuresAdded();
                    },
                    child: const Text('OK'),
                  ),
                ],
              ),
        );
      }
    } catch (e) {
      // Close loading dialog if still open
      if (Navigator.canPop(context)) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error creating bulk fee structures: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
