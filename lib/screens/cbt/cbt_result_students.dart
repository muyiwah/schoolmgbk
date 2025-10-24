import 'package:flutter/material.dart';

class CBTResultsScreen extends StatefulWidget {
  const CBTResultsScreen({Key? key}) : super(key: key);

  @override
  State<CBTResultsScreen> createState() => _CBTResultsScreenState();
}

class _CBTResultsScreenState extends State<CBTResultsScreen> {
  bool isChartView = true;
  String selectedFilter = 'All (20)';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: const Icon(Icons.shield_outlined, color: Colors.blue),
        title: const Text(
          'CBT Results',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: Row(
              children: [
                const Text(
                  'Sarah Johnson',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey.shade300,
                  child: const Text(
                    'SJ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),
            const SizedBox(height: 24),

            // Performance Analytics
            _buildPerformanceAnalytics(),
            const SizedBox(height: 24),

            // Question Breakdown
            _buildQuestionBreakdown(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                'Mathematics | Final Exam 2024',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Submitted on: March 15, 2024 at 2:30 PM',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
          const SizedBox(height: 24),

          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatItem('85/100', 'Total Score', Colors.blue),
              ),
              Expanded(child: _buildStatItem('B+', 'Grade', Colors.green)),
              Expanded(
                child: _buildStatItem(
                  'PASSED',
                  'Status',
                  Colors.green,
                  showCheckmark: true,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  '28/45 min',
                  'Completion Time',
                  Colors.grey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Improvement message
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(Icons.emoji_events, color: Colors.orange, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'Great improvement! You scored 15% higher than your last attempt.',
                  style: TextStyle(fontSize: 12, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    String value,
    String label,
    Color color, {
    bool showCheckmark = false,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (showCheckmark)
              Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.check, color: Colors.white, size: 12),
              ),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildPerformanceAnalytics() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                'Performance Analytics',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  _buildToggleButton('Chart View', isChartView),
                  const SizedBox(width: 8),
                  _buildToggleButton('Numbers', !isChartView),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          if (isChartView) ...[
            Row(
              children: [
                // Pie Chart
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      const Text(
                        'Answer Distribution',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 200,
                        child: CustomPaint(
                          painter: PieChartPainter(),
                          child: const SizedBox(width: 200, height: 200),
                        ),
                      ),
                    ],
                  ),
                ),

                // Stats
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildAnswerStat('Correct Answers', '17', Colors.green),
                      _buildAnswerStat('Incorrect Answers', '3', Colors.red),
                      _buildAnswerStat('Skipped Questions', '0', Colors.orange),
                      _buildAnswerStat('Total Questions', '20', Colors.blue),
                    ],
                  ),
                ),
              ],
            ),
          ] else ...[
            // Numbers view would go here
            const Center(
              child: Text(
                'Numbers view not available',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildToggleButton(String text, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          isChartView = text == 'Chart View';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.blue : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: isActive ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildAnswerStat(String label, String value, Color color) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: color.withOpacity(.2),
      ),
      padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 5),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Text(
            value,
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

  Widget _buildQuestionBreakdown() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
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
                'Question Breakdown',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              Row(
                children: [
                  _buildFilterChip('All (20)', true),
                  const SizedBox(width: 8),
                  _buildFilterChip('Correct (17)', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Incorrect (3)', false),
                  const SizedBox(width: 8),
                  _buildFilterChip('Skipped (0)', false),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Question Items
          _buildQuestionItem('Q1', 'What is 2 + 2?', true, '4', null),
          _buildQuestionItem('Q2', 'Solve for x: 3x + 5 = 14', false, '4', '3'),
          _buildQuestionItem(
            'Q3',
            'Calculate the area of a circle...',
            true,
            'πr²',
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String text, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isSelected ? Colors.blue : Colors.grey.shade200,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.grey.shade700,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildQuestionItem(
    String questionNum,
    String question,
    bool isCorrect,
    String userAnswer,
    String? correctAnswer,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isCorrect ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isCorrect ? Colors.green : Colors.red,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  isCorrect ? Icons.check : Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  '$questionNum  $question',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Text(
                'Your Answer: $userAnswer',
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),

          if (!isCorrect && correctAnswer != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        'Your Answer: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          userAnswer,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text(
                        'Correct Answer: ',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green.shade100,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          correctAnswer,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Explanation: 3x + 5 = 14, subtract 5 from both sides: 3x = 9, divide by 3: x = 3',
                    style: TextStyle(fontSize: 12, color: Colors.blue),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 10;

    final correctPaint =
        Paint()
          ..color = Colors.green
          ..style = PaintingStyle.fill;

    final incorrectPaint =
        Paint()
          ..color = Colors.red
          ..style = PaintingStyle.fill;

    // Draw correct portion (85%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708, // Start at top
      2 * 3.14159 * 0.85, // 85% of circle
      true,
      correctPaint,
    );

    // Draw incorrect portion (15%)
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -1.5708 + (2 * 3.14159 * 0.85), // Start after correct portion
      2 * 3.14159 * 0.15, // 15% of circle
      true,
      incorrectPaint,
    );

    // Draw labels
    final textStyle = TextStyle(
      color: Colors.black,
      fontSize: 12,
      fontWeight: FontWeight.w500,
    );

    final correctTextPainter = TextPainter(
      text: TextSpan(text: 'Correct: 85.0 %', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    correctTextPainter.layout();
    correctTextPainter.paint(
      canvas,
      Offset(size.width - 120, size.height - 40),
    );

    final incorrectTextPainter = TextPainter(
      text: TextSpan(text: 'Incorrect: 15.0 %', style: textStyle),
      textDirection: TextDirection.ltr,
    );
    incorrectTextPainter.layout();
    incorrectTextPainter.paint(canvas, Offset(10, 20));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
