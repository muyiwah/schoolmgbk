import 'package:flutter/material.dart';



class QuestionBankScreen extends StatefulWidget {
  const QuestionBankScreen({super.key});

  @override
  State<QuestionBankScreen> createState() => _QuestionBankScreenState();
}

class _QuestionBankScreenState extends State<QuestionBankScreen> {
  String selectedSort = 'Recent';
  bool isGridView = false;
  final TextEditingController _searchController = TextEditingController();

  // Sample data
  final List<String> subjects = [
    'Mathematics',
    'Science',
    'English',
    'History',
  ];
  final Map<String, int> subjectCounts = {
    'Mathematics': 847,
    'Science': 623,
    'English': 512,
    'History': 289,
  };

  final List<String> difficulties = ['Easy', 'Medium', 'Hard'];
  final List<String> questionTypes = [
    'Multiple Choice',
    'True/False',
    'Short Answer',
    'Essay',
  ];
  final List<String> popularTags = [
    'Algebra',
    'Geometry',
    'Fractions',
    'Physics',
    'Chemistry',
  ];

  final List<QuestionCard> questions = [
    QuestionCard(
      subject: 'Mathematics',
      grade: 'Grade 8',
      title: 'Solve for x: 2x + 5 = 13',
      options: ['A) x = 4', 'B) x = 6', 'C) x = 8', 'D) x = 9'],
      tags: ['Algebra', 'Equations'],
      difficulty: 'Medium',
      color: Colors.orange,
    ),
    QuestionCard(
      subject: 'Science',
      grade: 'Grade 7',
      title: 'What is the chemical symbol for water?',
      options: ['A) H2O', 'B) CO2', 'C) NaCl', 'D) O2'],
      tags: ['Chemistry', 'Basics'],
      difficulty: 'Easy',
      color: Colors.green,
    ),
    QuestionCard(
      subject: 'Mathematics',
      grade: 'Grade 9',
      title: 'Find the area of a circle with radius 5 cm',
      options: ['A) 25π cm²', 'B) 10π cm²', 'C) 5π cm²', 'D) 15π cm²'],
      tags: ['Geometry', 'Circle'],
      difficulty: 'Hard',
      color: Colors.red,
    ),
    QuestionCard(
      subject: 'English',
      grade: 'Grade 8',
      title: 'Which of the following is a synonym for "happy"?',
      options: ['A) Joyful', 'B) Sad', 'C) Angry', 'D) Confused'],
      tags: ['Vocabulary'],
      difficulty: 'Easy',
      color: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Row(
        children: [
          // Left Sidebar
          Container(
            width: 300,
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(24),
                  child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const Text(
                        'Question Bank',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4285F4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '2,847 Questions',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Search
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Search Questions',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Search by keyword, topic...',
                          prefixIcon: const Icon(
                            Icons.search,
                            color: Colors.grey,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: const BorderSide(
                              color: Color(0xFF4285F4),
                            ),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Filters
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    children: [
                      _buildFilterSection('Subject', subjects, subjectCounts),
                      const SizedBox(height: 24),
                      _buildClassFilter(),
                      const SizedBox(height: 24),
                      _buildDifficultyFilter(),
                      const SizedBox(height: 24),
                      _buildQuestionTypeFilter(),
                      const SizedBox(height: 24),
                      _buildPopularTags(),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Main Content
          Expanded(
            child: Column(
              children: [
                // Top Bar
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(24),
                  child: Row(
                    children: [
                      const Text(
                        'Showing 247 questions',
                        style: TextStyle(fontSize: 16, color: Colors.black87),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          const Text('Sort by: '),
                          DropdownButton<String>(
                            value: selectedSort,
                            underline: Container(),
                            items:
                                [
                                  'Recent',
                                  'Difficulty',
                                  'Subject',
                                  'Grade',
                                ].map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  );
                                }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                selectedSort = newValue!;
                              });
                            },
                          ),
                          const SizedBox(width: 16),
                          IconButton(
                            icon: Icon(
                              isGridView ? Icons.view_list : Icons.grid_view,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              setState(() {
                                isGridView = !isGridView;
                              });
                            },
                          ),
                          IconButton(
                            icon: Icon(
                              Icons.grid_view,
                              color:
                                  isGridView
                                      ? const Color(0xFF4285F4)
                                      : Colors.grey.shade400,
                            ),
                            onPressed: () {
                              setState(() {
                                isGridView = true;
                              });
                            },
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.add),
                        label: const Text('Add Question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4285F4),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      CircleAvatar(
                        backgroundColor: Colors.grey.shade300,
                        child: const Icon(Icons.person, color: Colors.grey),
                      ),
                    ],
                  ),
                ),

                // Questions Grid/List
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child:
                        isGridView
                            ? GridView.builder(
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 1.2,
                                  ),
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                return _buildQuestionCard(questions[index]);
                              },
                            )
                            : ListView.builder(
                              itemCount: questions.length,
                              itemBuilder: (context, index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 16),
                                  child: _buildQuestionCard(questions[index]),
                                );
                              },
                            ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> items,
    Map<String, int> counts,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...items.map(
          (item) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: item == 'Mathematics',
                  onChanged: (bool? value) {},
                  activeColor: const Color(0xFF4285F4),
                ),
                Expanded(
                  child: Text(item, style: const TextStyle(fontSize: 14)),
                ),
                Text(
                  '${counts[item] ?? 0}',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildClassFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Class',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Text('All Classes', style: TextStyle(fontSize: 14)),
        ),
      ],
    );
  }

  Widget _buildDifficultyFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Difficulty',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...difficulties.map(
          (difficulty) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (bool? value) {},
                  activeColor: const Color(0xFF4285F4),
                ),
                Expanded(
                  child: Text(difficulty, style: const TextStyle(fontSize: 14)),
                ),
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color:
                        difficulty == 'Easy'
                            ? Colors.green
                            : difficulty == 'Medium'
                            ? Colors.orange
                            : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionTypeFilter() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Question Type',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        ...questionTypes.map(
          (type) => Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Checkbox(
                  value: false,
                  onChanged: (bool? value) {},
                  activeColor: const Color(0xFF4285F4),
                ),
                Expanded(
                  child: Text(type, style: const TextStyle(fontSize: 14)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPopularTags() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Popular Tags',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              popularTags
                  .map(
                    (tag) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF4285F4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFF4285F4).withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        tag,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF4285F4),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
        ),
      ],
    );
  }

  Widget _buildQuestionCard(QuestionCard question) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
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
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: question.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  question.subject,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  question.grade,
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  icon: const Icon(Icons.more_horiz, size: 20),
                  itemBuilder:
                      (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              question.title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            ...question.options.map(
              (option) => Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  option,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                ...question.tags.map(
                  (tag) => Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF4285F4).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      tag,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF4285F4),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                TextButton(onPressed: () {}, child: const Text('Preview')),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4285F4),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('Add to Exam'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class QuestionCard {
  final String subject;
  final String grade;
  final String title;
  final List<String> options;
  final List<String> tags;
  final String difficulty;
  final Color color;

  QuestionCard({
    required this.subject,
    required this.grade,
    required this.title,
    required this.options,
    required this.tags,
    required this.difficulty,
    required this.color,
  });
}
