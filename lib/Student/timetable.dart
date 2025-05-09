import 'package:flutter/material.dart';

class ExamTimeTable extends StatelessWidget {
  ExamTimeTable({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Schedule', style: TextStyle(color: Colors.black)),
        actions: [
          Row(
            children: [
              Text(
                'Monday Sep 16',
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 20),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade50,
                ),
                onPressed: () {},
                child: const Text('Work Week'),
              ),
              const SizedBox(width: 10),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple.shade100,
                ),
                onPressed: () {},
                child: const Text('Day'),
              ),
              const SizedBox(width: 20),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: table.map((slot) => _buildTimeSlotRow(slot)).toList(),
      ),
    );
  }

  Widget _buildTimeSlotRow(Map<String, String> slot) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color:
            slot['color'] == 'blue'
                ? Colors.blue.shade100
                : slot['color'] == 'yellow'
                ? Colors.yellow.shade100
                : slot['color'] == 'purple'
                ? Colors.purple.shade100
                : slot['color'] == 'pink'
                ? Colors.pink.shade100
                : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              slot['time']!,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
            const SizedBox(height: 4),
            Text(slot['duration']!, style: const TextStyle(fontSize: 12)),
          ],
        ),
        title: Text(
          slot['subject']!,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(slot['class']!),
      ),
    );
  }

  List<Map<String, String>> table = [
    {
      'time': '8:00 AM',
      'duration': '8:00 AM - 8:45 AM',
      'subject': '4A - Physics',
      'class': 'Classroom A1',
      'color': 'blue',
    },
    {
      'time': '9:00 AM',
      'duration': '9:00 AM - 9:45 AM',
      'subject': '3B - Physics',
      'class': 'Classroom B3',
      'color': 'yellow',
    },
    {
      'time': '10:00 AM',
      'duration': '10:00 AM - 10:45 AM',
      'subject': '2B',
      'class': 'Classroom B2',
      'color': 'purple',
    },
    {
      'time': '11:00 AM',
      'duration': '11:00 AM - 11:45 AM',
      'subject': '5A - Physics',
      'class': 'Classroom A5',
      'color': 'pink',
    },
    {
      'time': '1:00 PM',
      'duration': '1:00 PM - 1:45 PM',
      'subject': '6C',
      'class': 'Classroom C6',
      'color': 'blue',
    },
    {
      'time': '2:00 PM',
      'duration': '2:00 PM - 2:45 PM',
      'subject': '2B - Physics',
      'class': 'Classroom B2',
      'color': 'yellow',
    },
  ];
  List<Map<String, String>> _generateTimeSlots() {
    return [
      {
        'time': '8:00 AM',
        'duration': '8:00 AM - 8:45 AM',
        'subject': '4A - Physics',
        'class': 'Classroom A1',
        'color': 'blue',
      },
      {
        'time': '9:00 AM',
        'duration': '9:00 AM - 9:45 AM',
        'subject': '3B - Physics',
        'class': 'Classroom B3',
        'color': 'yellow',
      },
      {
        'time': '10:00 AM',
        'duration': '10:00 AM - 10:45 AM',
        'subject': '2B',
        'class': 'Classroom B2',
        'color': 'purple',
      },
      {
        'time': '11:00 AM',
        'duration': '11:00 AM - 11:45 AM',
        'subject': '5A - Physics',
        'class': 'Classroom A5',
        'color': 'pink',
      },
      {
        'time': '1:00 PM',
        'duration': '1:00 PM - 1:45 PM',
        'subject': '6C',
        'class': 'Classroom C6',
        'color': 'blue',
      },
      {
        'time': '2:00 PM',
        'duration': '2:00 PM - 2:45 PM',
        'subject': '2B - Physics',
        'class': 'Classroom B2',
        'color': 'yellow',
      },
    ];
  }
}
