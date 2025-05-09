// widgets/question_widget.dart
import 'package:flutter/material.dart';
import 'package:schmgtsystem/deepseek/cbt/model/exam.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final Function(String) onAnswer;

  const QuestionWidget({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  State<QuestionWidget> createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> {
  String? _selectedAnswer;
  final _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.question.text,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (widget.question.type == QuestionType.multipleChoice)
              ...widget.question.options.map((option) {
                return RadioListTile<String>(
                  title: Text(option),
                  value: option,
                  groupValue: _selectedAnswer,
                  onChanged: (value) {
                    setState(() => _selectedAnswer = value);
                    widget.onAnswer(value!);
                  },
                );
              }),
            if (widget.question.type == QuestionType.trueFalse)
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('True'),
                    value: 'true',
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() => _selectedAnswer = value);
                      widget.onAnswer(value!);
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('False'),
                    value: 'false',
                    groupValue: _selectedAnswer,
                    onChanged: (value) {
                      setState(() => _selectedAnswer = value);
                      widget.onAnswer(value!);
                    },
                  ),
                ],
              ),
            if (widget.question.type == QuestionType.shortAnswer)
              TextField(
                controller: _textController,
                decoration: const InputDecoration(labelText: 'Your answer'),
                onChanged: (value) => widget.onAnswer(value),
              ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
