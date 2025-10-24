import 'package:flutter/material.dart';



class ExamScreen extends StatefulWidget {
  const ExamScreen({Key? key}) : super(key: key);

  @override
  State<ExamScreen> createState() => _ExamScreenState();
}

class _ExamScreenState extends State<ExamScreen> {
  int selectedAnswer = 2; // Default to option C (index 2)
  int currentQuestion = 15;
  final int totalQuestions = 50;

  // Question navigator states
  List<QuestionState> questionStates = List.generate(50, (index) {
    if (index < 14) return QuestionState.completed;
    if (index == 14) return QuestionState.current;
    if (index == 17 || index == 24 || index == 30 || index == 32)
      return QuestionState.flagged;
    return QuestionState.unanswered;
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Left sidebar with question navigator
          Container(
            width: 280,
            color: Colors.white,
            child: Column(
              children: [
                _buildHeader(),
                Expanded(child: _buildQuestionNavigator()),
              ],
            ),
          ),
          // Main content area
          Expanded(
            child: Column(
              children: [_buildTopBar(), Expanded(child: _buildMainContent())],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Mathematics',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Final Examination - Algebra & Calculus',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 16),
          const Text(
            'Question Navigator',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionNavigator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
          childAspectRatio: 1,
          crossAxisSpacing: 8,
          mainAxisSpacing: 8,
        ),
        itemCount: totalQuestions,
        itemBuilder: (context, index) {
          return _buildQuestionButton(index + 1, questionStates[index]);
        },
      ),
    );
  }

  Widget _buildQuestionButton(int questionNumber, QuestionState state) {
    Color backgroundColor;
    Color textColor;

    switch (state) {
      case QuestionState.completed:
        backgroundColor = Colors.green;
        textColor = Colors.white;
        break;
      case QuestionState.current:
        backgroundColor = Colors.blue;
        textColor = Colors.white;
        break;
      case QuestionState.flagged:
        backgroundColor = Colors.orange;
        textColor = Colors.white;
        break;
      case QuestionState.unanswered:
        backgroundColor = Colors.grey[300]!;
        textColor = Colors.black87;
        break;
    }

    return GestureDetector(
      onTap: () {
        setState(() {
          currentQuestion = questionNumber;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            questionNumber.toString(),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Question 15',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              const Text(
                'Multiple Choice',
                style: TextStyle(color: Colors.grey, fontSize: 14),
              ),
            ],
          ),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: Colors.orange[700], size: 16),
                    const SizedBox(width: 4),
                    Text(
                      'Flag for Review',
                      style: TextStyle(
                        color: Colors.orange[700],
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.orange,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  '02:42:19',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Row(
                children: [
                  Icon(Icons.list, color: Colors.grey[600]),
                  const SizedBox(width: 4),
                  Text(
                    'Question 15 of 50',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question text
          const Text(
            'Find the derivative of the function f(x) = 3x³ - 2x² + 5x - 1 at the point x = 2.',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 32),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Answer choices
              Expanded(
                flex: 1,
                child: Column(
                  children: [
                    _buildAnswerOption(0, 'A) f\'(2) = 31'),
                    const SizedBox(height: 12),
                    _buildAnswerOption(1, 'B) f\'(2) = 29'),
                    const SizedBox(height: 12),
                    _buildAnswerOption(2, 'C) f\'(2) = 33'),
                    const SizedBox(height: 12),
                    _buildAnswerOption(3, 'D) f\'(2) = 27'),
                  ],
                ),
              ),

              const SizedBox(width: 32),

              // Graph placeholder
              Expanded(
                flex: 1,
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF7CB342,
                    ), // Green color from the image
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Stack(
                    children: [
                      // Grid lines
                      CustomPaint(
                        painter: GridPainter(),
                        size: const Size(double.infinity, 300),
                      ),
                      // Coordinate axes and line
                      CustomPaint(
                        painter: GraphPainter(),
                        size: const Size(double.infinity, 300),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOption(int index, String text) {
    bool isSelected = selectedAnswer == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedAnswer = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue[50] : Colors.white,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey[400]!,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child:
                  isSelected
                      ? const Icon(Icons.circle, color: Colors.white, size: 8)
                      : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 16,
                  color: isSelected ? Colors.blue[800] : Colors.black87,
                  fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

enum QuestionState { completed, current, flagged, unanswered }

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withOpacity(0.3)
          ..strokeWidth = 1;

    // Draw vertical grid lines
    for (int i = 0; i <= 10; i++) {
      double x = (size.width / 10) * i;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }

    // Draw horizontal grid lines
    for (int i = 0; i <= 10; i++) {
      double y = (size.height / 10) * i;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final axisPaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    final linePaint =
        Paint()
          ..color = Colors.black
          ..strokeWidth = 2;

    // Draw x-axis
    canvas.drawLine(
      Offset(0, size.height / 2),
      Offset(size.width, size.height / 2),
      axisPaint,
    );

    // Draw y-axis
    canvas.drawLine(
      Offset(size.width / 2, 0),
      Offset(size.width / 2, size.height),
      axisPaint,
    );

    // Draw a simple line (representing the function)
    canvas.drawLine(
      Offset(size.width * 0.2, size.height * 0.8),
      Offset(size.width * 0.8, size.height * 0.2),
      linePaint,
    );

    // Draw axis labels/ticks
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    // Draw some tick marks
    for (int i = -5; i <= 5; i++) {
      if (i == 0) continue;

      double x = size.width / 2 + (i * size.width / 10);
      double y = size.height / 2;

      // Vertical tick on x-axis
      canvas.drawLine(Offset(x, y - 5), Offset(x, y + 5), axisPaint);

      // Horizontal tick on y-axis
      canvas.drawLine(
        Offset(size.width / 2 - 5, size.height / 2 - (i * size.height / 10)),
        Offset(size.width / 2 + 5, size.height / 2 - (i * size.height / 10)),
        axisPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
