import 'package:flutter/material.dart';

class ClassPaymentReportPopup extends StatelessWidget {
  // Dummy data
  final String className = 'JSS 2A';
  final String classTeacher = 'Mrs. Sarah Johnson';
  final int totalStudents = 35;
  final int paidInFull = 22;
  final int partiallyPaid = 8;
  final int owing = 5;
  final double totalExpected = 350000.0;
  final double totalReceived = 287500.0;
  final String academicSession = '2024/2025 Academic Session';

  const ClassPaymentReportPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 8,
      child: Container(
        width: MediaQuery.of(context).size.width * 0.6,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.blue.shade50, Colors.white],
          ),
        ),
        child: Column(
          children: [
            // Header Section
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(
                        Icons.analytics_outlined,
                        color: Colors.white,
                        size: 28,
                      ),
                  Text(
                        'Payment Report',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),    IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(
                          Icons.close,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                    ],
                  ),
              
                  
                  const SizedBox(height: 5),
                  Text(
                    academicSession,
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Content Section
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class Information
                    _buildInfoCard(
                      icon: Icons.school,
                      title: 'Class Information',
                      children: [
                        _buildInfoRow('Class Name', className),
                        _buildInfoRow('Class Teacher', classTeacher),
                        _buildInfoRow(
                          'Total Students',
                          totalStudents.toString(),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Payment Statistics
                    _buildInfoCard(
                      icon: Icons.payments,
                      title: 'Payment Statistics',
                      children: [
                        Wrap(spacing: 19,runSpacing: 10,
                          children: [
                            _buildStatCard(
                              'Paid in Full',
                              paidInFull.toString(),
                              Colors.green,
                              Icons.check_circle,
                            ),
                            _buildStatCard(
                              'Partial Payment',
                              partiallyPaid.toString(),
                              Colors.orange,
                              Icons.access_time,
                            ),
                           _buildStatCard(
                              'Outstanding',
                              owing.toString(),
                              Colors.red,
                              Icons.warning,
                            ),
                            // _buildStatCard(
                            //   'Collection Rate',
                            //   '${((paidInFull + partiallyPaid) / totalStudents * 100).toStringAsFixed(1)}%',
                            //   Colors.blue,
                            //   Icons.trending_up,
                            // ),
                             ],
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                          
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Financial Summary
                    _buildInfoCard(
                      icon: Icons.attach_money,
                      title: 'Financial Summary',
                      children: [
                        _buildFinancialRow(
                          'Total Expected',
                          totalExpected,
                          Colors.grey.shade700,
                        ),
                        _buildFinancialRow(
                          'Total Received',
                          totalReceived,
                          Colors.green.shade600,
                        ),
                        _buildFinancialRow(
                          'Outstanding Balance',
                          totalExpected - totalReceived,
                          Colors.red.shade600,
                        ),
                      ],
                    ),

                    const Spacer(),

                    // Action Buttons
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // Export functionality
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Report exported successfully!',
                                  ),
                                  backgroundColor: Colors.green,
                                ),
                              );
                            },
                            icon: const Icon(Icons.file_download),
                            label: const Text('Export'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              // View details functionality
                              Navigator.of(context).pop();
                            },
                            icon: const Icon(Icons.visibility),
                            label: const Text('View Details'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.blue.shade600, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(width: 180,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          Icon(icon, color: color, size: 24),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: color.withOpacity(0.8)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildFinancialRow(String label, double amount, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
          ),
          Text(
            '₦${amount.toStringAsFixed(2)}',
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
}

// Example usage
class PaymentReportExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Class Management'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const ClassPaymentReportPopup(),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue.shade600,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          ),
          child: const Text('Show Payment Report'),
        ),
      ),
    );
  }
}
