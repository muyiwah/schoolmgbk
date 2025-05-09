// widgets/question_editor.dart
import 'package:flutter/material.dart';
import 'package:schmgtsystem/deepseek/cbt/model/exam.dart';

class QuestionEditor extends StatefulWidget {
  final Question question;
  final Function(Question) onChanged;
  final VoidCallback onDelete;

  const QuestionEditor({
    super.key,
    required this.question,
    required this.onChanged,
    required this.onDelete,
  });

  @override
  State<QuestionEditor> createState() => _QuestionEditorState();
}

class _QuestionEditorState extends State<QuestionEditor> {
  late TextEditingController _textController;
  late List<TextEditingController> _optionControllers;
  late TextEditingController _correctAnswerController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.question.text);
    _optionControllers =
        widget.question.options
            .map((option) => TextEditingController(text: option))
            .toList();
    _correctAnswerController = TextEditingController(
      text: widget.question.correctAnswer,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      labelText: 'Question Text',
                    ),
                    onChanged: (_) => _updateQuestion(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: widget.onDelete,
                ),
              ],
            ),
            if (widget.question.type == QuestionType.multipleChoice)
              ..._optionControllers.asMap().entries.map((entry) {
                final index = entry.key;
                final controller = entry.value;
                return TextFormField(
                  controller: controller,
                  decoration: InputDecoration(labelText: 'Option ${index + 1}'),
                  onChanged: (_) => _updateQuestion(),
                );
              }),
            TextFormField(
              controller: _correctAnswerController,
              decoration: const InputDecoration(labelText: 'Correct Answer'),
              onChanged: (_) => _updateQuestion(),
            ),
          ],
        ),
      ),
    );
  }

  void _updateQuestion() {
    widget.onChanged(
      Question(
        id: widget.question.id,
        text: _textController.text,
        type: widget.question.type,
        options: _optionControllers.map((c) => c.text).toList(),
        correctAnswer: _correctAnswerController.text,
        points: widget.question.points,
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    for (final controller in _optionControllers) {
      controller.dispose();
    }
    _correctAnswerController.dispose();
    super.dispose();
  }
}
