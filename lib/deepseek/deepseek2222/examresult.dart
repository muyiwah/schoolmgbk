import 'dart:math';

import 'package:data_table_2/data_table_2.dart';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/material.dart';
import 'package:schmgtsystem/deepseek/deepseek2222/exammodel.dart'
    show ExamResult;

class ExamResultsScreen extends StatefulWidget {
  final String examId;

  const ExamResultsScreen({super.key, required this.examId});

  @override
  State<ExamResultsScreen> createState() => _ExamResultsScreenState();
}

class _ExamResultsScreenState extends State<ExamResultsScreen> {
  List<ExamResult> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    // Simulate loading
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _results = List.generate(20, (index) {
        return ExamResult(
          examId: widget.examId,
          studentId: 'student${index + 1}',
          studentName: 'Student ${index + 1}',
          score: Random().nextInt(20) + 1,
          totalQuestions: 20,
          answers: {}, // Empty for now
        );
      });
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Exam Results'),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: _exportResults,
            tooltip: 'Export Results',
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _buildResultsTable(),
    );
  }

  Widget _buildResultsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable2(
        columnSpacing: 12,
        horizontalMargin: 12,
        minWidth: 600,
        columns: const [
          DataColumn2(label: Text('S/N'), size: ColumnSize.S),
          DataColumn(label: Text('Student ID')),
          DataColumn(label: Text('Student Name')),
          DataColumn(label: Text('Score'), numeric: true),
          DataColumn(label: Text('Percentage'), numeric: true),
          DataColumn(label: Text('Actions')),
        ],
        rows:
            _results.asMap().entries.map((entry) {
              final index = entry.key;
              final result = entry.value;
              final percentage = (result.score / result.totalQuestions * 100)
                  .toStringAsFixed(1);

              return DataRow(
                cells: [
                  DataCell(Text('${index + 1}')),
                  DataCell(Text(result.studentId)),
                  DataCell(Text(result.studentName)),
                  DataCell(Text('${result.score}/${result.totalQuestions}')),
                  DataCell(Text('$percentage%')),
                  DataCell(
                    IconButton(
                      icon: const Icon(Icons.visibility),
                      onPressed: () => _viewStudentAnswers(result),
                    ),
                  ),
                ],
              );
            }).toList(),
      ),
    );
  }

  void _viewStudentAnswers(ExamResult result) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('${result.studentName}\'s Answers'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView(
                shrinkWrap: true,
                children: [
                  Text('Score: ${result.score}/${result.totalQuestions}'),
                  const SizedBox(height: 16),
                  ..._buildAnswerDetails(result),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }

  List<Widget> _buildAnswerDetails(ExamResult result) {
    return result.answers.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text('Q${entry.key}: Selected option ${entry.value}'),
      );
    }).toList();
  }

  Future<void> _exportResults() async {
    final excel = Excel.createExcel();
    final sheet = excel['Exam Results'];

    sheet.appendRow([
      'S/N',
      'Student ID',
      'Student Name',
      'Score',
      'Percentage',
    ]);

    for (var i = 0; i < _results.length; i++) {
      final result = _results[i];
      final percentage = (result.score / result.totalQuestions * 100)
          .toStringAsFixed(1);

      sheet.appendRow([
        i + 1,
        result.studentId,
        result.studentName,
        '${result.score}/${result.totalQuestions}',
        '$percentage%',
      ]);
    }

    final bytes = excel.encode();

    // if (bytes != null) {
    //   final fileName = 'Exam_${widget.examId}_Results.xlsx';
    //   await FileSaver.instance.saveFile(
    //     fileName,
    //     bytes,
    //     'xlsx',
    //     mimeType: MimeType.MICROSOFTEXCEL,
    //   );

    //   ScaffoldMessenger.of(
    //     context,
    //   ).showSnackBar(SnackBar(content: Text('Results exported to $fileName')));
    // }
  }
}
