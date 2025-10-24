// widgets/subject_dropdown.dart
import 'package:flutter/material.dart';
import 'package:schmgtsystem/models/subject_model.dart';

class SubjectDropdown extends StatefulWidget {
  final ValueChanged<Subject?> onSubjectSelected;
  final String? initialValue;
  final String? departmentFilter;

  const SubjectDropdown({
    Key? key,
    required this.onSubjectSelected,
    this.initialValue,
    this.departmentFilter,
  }) : super(key: key);

  @override
  _SubjectDropdownState createState() => _SubjectDropdownState();
}

class _SubjectDropdownState extends State<SubjectDropdown> {
  Subject? _selectedSubject;
  List<Subject> _subjects = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
   
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? CircularProgressIndicator()
        : DropdownButtonFormField<Subject>(
          value: _selectedSubject,
          decoration: InputDecoration(
            labelText: 'Select Subject',
            border: OutlineInputBorder(),
          ),
          items:
              _subjects.map((Subject subject) {
                return DropdownMenuItem<Subject>(
                  value: subject,
                  child: Text(subject.name),
                );
              }).toList(),
          onChanged: (Subject? newValue) {
            setState(() {
              _selectedSubject = newValue;
            });
            widget.onSubjectSelected(newValue);
          },
          validator: (value) {
            if (value == null) {
              return 'Please select a subject';
            }
            return null;
          },
        );
  }
}
