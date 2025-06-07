import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SingleParent extends StatefulWidget {
  final Function navigateBack;
  SingleParent({Key? key, required this.navigateBack}) : super(key: key);

  @override
  _SingleParentState createState() => _SingleParentState();
}

class _SingleParentState extends State<SingleParent> {
  final Map<String, dynamic> parentData = {
    'photoUrl': 'assets/images/1.jpeg',
    'name': 'Calvin Stoon',
    'phone': '+123-90937837',
    'email': 'parent@gmail.com',
    'address': '8 Webley St, Kelvin City',
    'joinDate': '2025-04-03',
    'totalFeesDue': 400,
    'attendanceRate': 4,
    'lastPaymentDate': '2025-05-03',
    'communications': [
      'Your child was absent on 3rd May',
      'School fees payment is due soon.',
    ],
  };

  final List<Map<String, dynamic>> children = [
    {
      'name': 'Emily Stoon',
      'age': 9,
      'class': 'Primary 5',
      'photoUrl': 'assets/images/child1.png',
    },
    {
      'name': 'Leo Stoon',
      'age': 7,
      'class': 'Primary 3',
      'photoUrl': 'assets/images/child2.png',
    },
  ];

  final List<Payment> payments = [
    Payment(DateTime(2025, 1, 5), 200),
    Payment(DateTime(2025, 2, 10), 300),
    Payment(DateTime(2025, 3, 15), 250),
    Payment(DateTime(2025, 4, 20), 400),
    Payment(DateTime(2025, 5, 3), 350),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: GestureDetector(
          onTap: () {
            widget.navigateBack();
          },
          child: Icon(Icons.arrow_back_ios_new_rounded),
        ),
        title: Text("Parent Dashboard"),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ParentCard(data: parentData),
            SizedBox(height: 16),
            MetricsRow(data: parentData),
            SizedBox(height: 16),
            ChildrenList(children: children),
            SizedBox(height: 16),
            PaymentHistoryChart(payments: payments),
            SizedBox(height: 16),
            CommunicationList(messages: parentData['communications']),
          ],
        ),
      ),
    );
  }
}

// 📦 Payment Model
class Payment {
  final DateTime date;
  final double amount;

  Payment(this.date, this.amount);
}

class ParentCard extends StatelessWidget {
  final Map<String, dynamic> data;

  const ParentCard({required this.data});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundImage: AssetImage(data['photoUrl']),
          radius: 30,
        ),
        title: Text(
          data['name'],
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(data['email']),
            Text(data['phone']),
            Text(data['address']),
            Text('Joined: ${data['joinDate']}'),
          ],
        ),
      ),
    );
  }
}

class MetricsRow extends StatelessWidget {
  final Map<String, dynamic> data;

  const MetricsRow({required this.data});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        MetricCard(label: 'Total Due', value: '₦${data['totalFeesDue']}'),
        MetricCard(
          label: 'Attendance',
          value: '${data['attendanceRate']} days',
        ),
        MetricCard(label: 'Last Payment', value: data['lastPaymentDate']),
      ],
    );
  }
}

class MetricCard extends StatelessWidget {
  final String label;
  final String value;

  const MetricCard({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        color: Colors.blue.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            children: [
              Text(
                value,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(label, style: TextStyle(color: Colors.grey[600])),
            ],
          ),
        ),
      ),
    );
  }
}

class ChildrenList extends StatelessWidget {
  final List<Map<String, dynamic>> children;

  const ChildrenList({required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Children", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        ...children.map(
          (child) => SizedBox(width: 440,
            child: Card(
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: AssetImage(child['photoUrl']),
                ),
                title: Text(child['name']),
                subtitle: Text('Age: ${child['age']} | Class: ${child['class']}'),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PaymentHistoryChart extends StatelessWidget {
  final List<Payment> payments;

  const PaymentHistoryChart({required this.payments});

  @override
  Widget build(BuildContext context) {
    final startDate = payments.first.date;
    final maxY = payments.map((e) => e.amount).reduce((a, b) => a > b ? a : b);
    final spots =
        payments
            .map(
              (p) => FlSpot(
                p.date.difference(startDate).inDays.toDouble(),
                p.amount,
              ),
            )
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Payment History", style: Theme.of(context).textTheme.titleMedium),
        SizedBox(height: 8),
        AspectRatio(
          aspectRatio: 1.7,
          child: LineChart(
            LineChartData(
              minY: 0,
              maxY: maxY + 100,
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      final date = startDate.add(Duration(days: value.toInt()));
                      return Text(
                        DateFormat.Md().format(date),
                        style: TextStyle(fontSize: 10),
                      );
                    },
                    interval: 5,
                    reservedSize: 30,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(showTitles: true, reservedSize: 40),
                ),
              ),
              borderData: FlBorderData(show: true),
              gridData: FlGridData(show: true),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: Colors.indigo,
                  barWidth: 4,
                  belowBarData: BarAreaData(
                    show: true,
                    color: Colors.indigo.withOpacity(0.3),
                  ),
                  dotData: FlDotData(show: true),
                ),
              ],
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  // tooltipBgColor: Colors.black87,
                  getTooltipItems:
                      (touchedSpots) =>
                          touchedSpots.map((spot) {
                            final date = startDate.add(
                              Duration(days: spot.x.toInt()),
                            );
                            return LineTooltipItem(
                              '${DateFormat.MMMd().format(date)}\n₦${spot.y.toStringAsFixed(0)}',
                              TextStyle(color: Colors.white),
                            );
                          }).toList(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class CommunicationList extends StatelessWidget {
  final List<String> messages;

  const CommunicationList({required this.messages});

  @override
  Widget build(BuildContext context) {
    if (messages.isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Recent Communications",
          style: Theme.of(context).textTheme.titleMedium,
        ),
        SizedBox(height: 8),
        ...messages.map(
          (msg) => Card(
            child: ListTile(
              leading: Icon(Icons.mail_outline),
              title: Text(msg),
            ),
          ),
        ),
      ],
    );
  }
}
