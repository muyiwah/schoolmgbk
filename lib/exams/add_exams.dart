import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/widgets/success_snack.dart';

class CreateNewExamScreen extends StatefulWidget {
  final Function navigateBack;
  CreateNewExamScreen({Key? key, required this.navigateBack}) : super(key: key);

  @override
  State<CreateNewExamScreen> createState() => _CreateNewExamScreenState();
}

class _CreateNewExamScreenState extends State<CreateNewExamScreen> {
  final TextEditingController _titleController = TextEditingController(
    text: 'Mid-Term Mathematics Test',
  );
  final TextEditingController _durationController = TextEditingController(
    text: '60',
  );
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _startTimeController = TextEditingController();
  final TextEditingController _endTimeController = TextEditingController();

  String? _selectedSubject;
  bool _addInstructions = false;

  final List<String> _classes = [
    'JSS1A',
    'JSS1B',
    'JSS2A',
    'JSS2B',
    'JSS3A',
    'JSS3B',
  ];
  final List<bool> _selectedClasses = List.generate(6, (index) => false);

  final List<String> _subjects = [
    'Mathematics',
    'English Language',
    'Physics',
    'Chemistry',
    'Biology',
    'Economics',
    'Geography',
    'History',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          color: AppColors.secondary,
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            widget.navigateBack();
          },
        ),
        title: const Text(
          'Create New Exam',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: Colors.grey),
            onPressed: () {
              widget.navigateBack();
            },
          ),
        ],
      ),
      body: Row(
        children: [
          // Main Content Area
          Expanded(
            flex: 3,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Progress Steps
                  _buildProgressSteps(),
                  const SizedBox(height: 32),

                  // Form Content
                  _buildFormContent(),
                ],
              ),
            ),
          ),

          // Sidebar
          Container(width: 320, color: Colors.white, child: _buildSidebar()),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildProgressSteps() {
    return Row(
      children: [
        _buildStep(1, 'Basic Info', true, true),
        _buildStepConnector(true),
        _buildStep(2, 'Instructions', false, false),
        _buildStepConnector(false),
        _buildStep(3, 'Confirm', false, false),
      ],
    );
  }

  Widget _buildStep(int number, String title, bool isActive, bool isCompleted) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color:
                isActive
                    ? const Color(0xFF6366F1)
                    : (isCompleted
                        ? const Color(0xFF10B981)
                        : Colors.grey[300]),
            shape: BoxShape.circle,
          ),
          child: Center(
            child:
                isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 16)
                    : Text(
                      number.toString(),
                      style: TextStyle(
                        color: isActive ? Colors.white : Colors.grey[600],
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: TextStyle(
            color: isActive ? const Color(0xFF6366F1) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildStepConnector(bool isActive) {
    return Container(
      width: 40,
      height: 2,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      color: isActive ? const Color(0xFF6366F1) : Colors.grey[300],
    );
  }

  Widget _buildFormContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Exam Title
        _buildFormField(
          'Exam Title',
          true,
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Enter exam title',
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Select Classes
        _buildFormField('Select Class(es)', true, _buildClassSelection()),
        const SizedBox(height: 24),

        // Subject
        _buildFormField(
          'Subject',
          true,
          DropdownButtonFormField<String>(
            value: _selectedSubject,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: 'Select Subject',
            ),
            items:
                _subjects.map((subject) {
                  return DropdownMenuItem(value: subject, child: Text(subject));
                }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedSubject = value;
              });
            },
          ),
        ),
        const SizedBox(height: 24),

        // Exam Duration
        _buildFormField(
          'Exam Duration',
          false,
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _durationController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '60',
                  ),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'minutes',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Date and Time
        _buildDateTimeSection(),
        const SizedBox(height: 24),

        // Add Instructions Checkbox
        Row(
          children: [
            Checkbox(
              value: _addInstructions,
              onChanged: (value) {
                setState(() {
                  _addInstructions = value ?? false;
                });
              },
            ),
            const Text('Add Exam Instructions'),
          ],
        ),
        const SizedBox(height: 24),

        // File Upload Section
        _buildFileUploadSection(),
      ],
    );
  }

  Widget _buildFormField(String label, bool isRequired, Widget child) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            if (isRequired)
              const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }

  Widget _buildClassSelection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(child: _buildClassCheckbox(0, 'JSS1A')),
              Expanded(child: _buildClassCheckbox(1, 'JSS1B')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildClassCheckbox(2, 'JSS2A')),
              Expanded(child: _buildClassCheckbox(3, 'JSS2B')),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: _buildClassCheckbox(4, 'JSS3A')),
              Expanded(child: _buildClassCheckbox(5, 'JSS3B')),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildClassCheckbox(int index, String className) {
    return Row(
      children: [
        Checkbox(
          value: _selectedClasses[index],
          onChanged: (value) {
            setState(() {
              _selectedClasses[index] = value ?? false;
            });
          },
        ),
        Text(className),
      ],
    );
  }

  Widget _buildDateTimeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Exam Date',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextField(
                controller: _dateController,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'mm/dd/yyyy',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
                readOnly: true,
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (date != null) {
                    _dateController.text =
                        '${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}/${date.year}';
                  }
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _startTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '--:-- --',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(_startTimeController),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'End Time',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: _endTimeController,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: '--:-- --',
                      suffixIcon: Icon(Icons.access_time),
                    ),
                    readOnly: true,
                    onTap: () => _selectTime(_endTimeController),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _selectTime(TextEditingController controller) async {
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (time != null) {
      controller.text = time.format(context);
    }
  }

  Widget _buildFileUploadSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Attach Exam Guide or Syllabus',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 120,
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey[300]!,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 40,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 8),
              const Text(
                'Drag and drop files here or',
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 8),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6366F1),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Browse Files'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSidebar() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Exam Summary',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 24),

          _buildSummaryItem(
            Icons.school,
            'Classes',
            '${_selectedClasses.where((selected) => selected).length} selected',
            const Color(0xFF6366F1),
          ),
          const SizedBox(height: 16),

          _buildSummaryItem(
            Icons.book,
            'Subject',
            _selectedSubject ?? 'Not selected',
            const Color(0xFF8B5CF6),
          ),
          const SizedBox(height: 16),

          _buildSummaryItem(
            Icons.access_time,
            'Duration',
            '${_durationController.text.isEmpty ? '0' : _durationController.text} min',
            const Color(0xFF06B6D4),
          ),
          const SizedBox(height: 16),

          _buildSummaryItem(
            Icons.attach_file,
            'Attachments',
            '0 files',
            const Color(0xFFF59E0B),
          ),
          const SizedBox(height: 16),

          _buildSummaryItem(
            Icons.circle,
            'Status',
            'Draft',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Row(
            children: [
              const Icon(Icons.save, size: 16, color: Colors.grey),
              const SizedBox(width: 8),
              Text(
                'Auto-saved 2 minutes ago',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Save as Draft'),
          ),
          const SizedBox(width: 12),
          ElevatedButton(
            onPressed: () {
              showSnackbar(context, '');
              widget.navigateBack();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Publish Exam'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _durationController.dispose();
    _dateController.dispose();
    _startTimeController.dispose();
    _endTimeController.dispose();
    super.dispose();
  }
}
