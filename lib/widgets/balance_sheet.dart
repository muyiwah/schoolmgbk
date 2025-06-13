import 'package:flutter/material.dart';

class BalanceSheetReconciliationPopup extends StatefulWidget {
  const BalanceSheetReconciliationPopup({Key? key}) : super(key: key);

  @override
  State<BalanceSheetReconciliationPopup> createState() =>
      _BalanceSheetReconciliationPopupState();
}

class _BalanceSheetReconciliationPopupState
    extends State<BalanceSheetReconciliationPopup> {
  final TextEditingController _notesController = TextEditingController();
  String _selectedCategory = 'All Categories';
  String _selectedStatus = 'All Status';
  String _selectedVerifier = 'John Adebayo (Accountant)';

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(20),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        // height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryCards(),
                    const SizedBox(height: 24),
                    _buildFiltersAndTable(),
                    const SizedBox(height: 24),
                    _buildActionButtons(),
                    const SizedBox(height: 24),
                    _buildNotesSection(),
                    const SizedBox(height: 16),
                    _buildVerificationSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12),
          topRight: Radius.circular(12),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Text(
                'Balance Sheet Reconciliation',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 4),
              Text(
                'Compare and reconcile transactions to ensure accounting accuracy.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, size: 24),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Income',
            amount: '₦5,250,000',
            subtitle: 'Current Term',
            status: 'Balanced',
            statusColor: Colors.green,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Total Expenses',
            amount: '₦4,580,000',
            subtitle:
                'Salaries: ₦1,950,000\nRepairs: ₦500,000\nServices: ₦1,200,000\nOthers: ₦930,000',
            hasIcon: true,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildSummaryCard(
            title: 'Net Balance',
            amount: '₦670,000',
            subtitle: 'Positive Balance',
            status: 'Surplus',
            statusColor: Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard({
    required String title,
    required String amount,
    required String subtitle,
    String? status,
    Color? statusColor,
    bool hasIcon = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (hasIcon)
                Container(
                  width: 20,
                  height: 20,
                  decoration: const BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
              if (status != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor?.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    status,
                    style: TextStyle(
                      fontSize: 12,
                      color: statusColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            amount,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildFiltersAndTable() {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      _buildDropdown('All Categories', [
                        'All Categories',
                        'Salaries',
                        'Repairs',
                        'Miscellaneous',
                      ]),
                      const SizedBox(width: 16),
                      _buildDropdown('All Status', [
                        'All Status',
                        'Matched',
                        'Unmatched',
                      ]),
                    ],
                  ),
                  const Text(
                    'Showing 3 of 3 entries',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Expanded(child: SingleChildScrollView(child: _buildDataTable())),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown(String value, List<String> items) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items:
            items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }).toList(),
        onChanged: (String? newValue) {
          // Handle dropdown change
        },
      ),
    );
  }

  Widget _buildDataTable() {
    return DataTable(
      headingRowColor: MaterialStateProperty.all(Colors.grey.shade50),
      columns: const [
        DataColumn(
          label: Text(
            'CATEGORY',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'EXPECTED AMOUNT',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'RECORDED AMOUNT',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'DIFFERENCE',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
        DataColumn(
          label: Text(
            'STATUS',
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
          ),
        ),
      ],
      rows: [
        _buildDataRow(
          'Salaries',
          '₦2,000,000',
          '₦1,950,000',
          '-₦50,000',
          'Unmatched',
          false,
        ),
        _buildDataRow('Repairs', '₦500,000', '₦500,000', '₦0', 'Matched', true),
        _buildDataRow(
          'Miscellaneous',
          '₦150,000',
          '₦130,000',
          '-₦20,000',
          'Unmatched',
          false,
        ),
      ],
    );
  }

  DataRow _buildDataRow(
    String category,
    String expected,
    String recorded,
    String difference,
    String status,
    bool isMatched,
  ) {
    return DataRow(
      cells: [
        DataCell(Text(category, style: const TextStyle(fontSize: 14))),
        DataCell(Text(expected, style: const TextStyle(fontSize: 14))),
        DataCell(Text(recorded, style: const TextStyle(fontSize: 14))),
        DataCell(
          Text(
            difference,
            style: TextStyle(
              fontSize: 14,
              color: difference.startsWith('-') ? Colors.red : Colors.black,
            ),
          ),
        ),
        DataCell(
          Row(
            children: [
              Icon(
                isMatched ? Icons.check : Icons.warning,
                size: 16,
                color: isMatched ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                status,
                style: TextStyle(
                  fontSize: 14,
                  color: isMatched ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.edit, size: 16),
          label: const Text('Reconcile Manually'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF00BCD4),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.auto_fix_high, size: 16),
          label: const Text('Auto Reconcile'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download, size: 16),
          label: const Text('Export Sheet'),
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Notes & Comments',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Add reconciliation note',
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        const SizedBox(height: 12),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(4),
          ),
          child: TextField(
            controller: _notesController,
            maxLines: null,
            expands: true,
            decoration: const InputDecoration(
              hintText: 'Enter your reconciliation notes here...',
              hintStyle: TextStyle(color: Colors.grey),
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildVerificationSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mark as Verified by',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 8),
            Container(
              width: 300,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
              child: DropdownButton<String>(
                value: _selectedVerifier,
                isExpanded: true,
                underline: const SizedBox(),
                items:
                    ['John Adebayo (Accountant)', 'Other Verifier'].map((
                      String item,
                    ) {
                      return DropdownMenuItem<String>(
                        value: item,
                        child: Text(item, style: const TextStyle(fontSize: 14)),
                      );
                    }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    _selectedVerifier = newValue!;
                  });
                },
              ),
            ),
          ],
        ),
        ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1976D2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Finish Reconciliation',
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}

// Usage example:
void showBalanceSheetReconciliation(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return const BalanceSheetReconciliationPopup();
    },
  );
}
