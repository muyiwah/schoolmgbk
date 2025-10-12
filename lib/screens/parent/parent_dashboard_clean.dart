import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/models/parent_login_response_model.dart';

class ParentDashboardClean extends ConsumerStatefulWidget {
  const ParentDashboardClean({super.key});

  @override
  ConsumerState<ParentDashboardClean> createState() =>
      _ParentDashboardCleanState();
}

class _ParentDashboardCleanState extends ConsumerState<ParentDashboardClean> {
  int _selectedChildIndex = 0;

  @override
  Widget build(BuildContext context) {
    final parentLoginProvider = ref.watch(RiverpodProvider.parentLoginProvider);
    final children = parentLoginProvider.parentLoginData?.data?.children ?? [];

    if (children.isEmpty) {
      return const Scaffold(body: Center(child: Text('No children found')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Fees & Payments'),
        actions: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Unverified',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Academic Year and Term
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Academic Year'),
                      DropdownButton<String>(
                        value: '2025/2026',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: '2025/2026',
                            child: Text('2025/2026'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Term'),
                      DropdownButton<String>(
                        value: 'First',
                        isExpanded: true,
                        items: const [
                          DropdownMenuItem(
                            value: 'First',
                            child: Text('First'),
                          ),
                        ],
                        onChanged: (value) {},
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Outstanding Balance
            _buildOutstandingBalance(children[_selectedChildIndex]),
            const SizedBox(height: 16),

            // Fee Breakdown
            _buildFeeBreakdown(children[_selectedChildIndex]),
          ],
        ),
      ),
    );
  }

  Widget _buildOutstandingBalance(Child child) {
    final feeDetails = child.currentTerm?.feeRecord?.feeDetails;
    final totalFee = feeDetails?.totalFee ?? 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Outstanding Balance',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                '£$totalFee',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Due: December 15, 2024 - First 2025/2026',
            style: TextStyle(fontSize: 12, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildFeeBreakdown(Child child) {
    final feeDetails = child.currentTerm?.feeRecord?.feeDetails;

    if (feeDetails == null) {
      return Container(
        padding: const EdgeInsets.all(20),
        child: const Center(child: Text('No fee information available')),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fee Breakdown',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),

        // Fee Items
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey[300]!),
          ),
          child: Column(
            children: [
              // Base Fee
              _buildFeeItem('Base Fee', feeDetails.baseFee ?? 0),

              // Add-ons
              if (feeDetails.addOns != null &&
                  feeDetails.addOns!.isNotEmpty) ...[
                const SizedBox(height: 12),
                ...feeDetails.addOns!.map((addOn) {
                  final addOnMap = addOn as Map<String, dynamic>;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildFeeItem(
                      addOnMap['name'] ?? 'Additional Fee',
                      addOnMap['amount'] ?? 0,
                    ),
                  );
                }),
              ],

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              // Summary
              _buildSummaryRow('Total Fees', feeDetails.totalFee ?? 0),
              const SizedBox(height: 8),
              _buildSummaryRow('Amount Paid', 0),
              const SizedBox(height: 8),
              _buildSummaryRow(
                'Outstanding Balance',
                feeDetails.totalFee ?? 0,
                isBold: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFeeItem(String name, int amount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
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
                  'Amount: £$amount',
                  style: const TextStyle(fontSize: 14, color: Colors.grey),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Required',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Pending',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, int amount, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        Text(
          '£$amount',
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.red : Colors.black87,
          ),
        ),
      ],
    );
  }
}
