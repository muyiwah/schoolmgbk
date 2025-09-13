import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/teacher_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/services/http_service.dart';
import 'package:schmgtsystem/utils/enums.dart';
import 'package:schmgtsystem/utils/locator.dart';

class AddClassDialog extends ConsumerStatefulWidget {
  final String academicYear;
  final TeacherListModel teacherData;
  const AddClassDialog({
    Key? key,
    required this.academicYear,
    required this.teacherData,
  }) : super(key: key);

  @override
  ConsumerState<AddClassDialog> createState() => _AddClassDialogState();
}

class _AddClassDialogState extends ConsumerState<AddClassDialog> {
  final _formKey = GlobalKey<FormState>();
  final _classNameController = TextEditingController();
  final _capacityController = TextEditingController();
  final _roomNumberController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _baseFeeController = TextEditingController();

  final HttpService _httpService = locator<HttpService>();

  String? selectedLevel;
  String? selectedClassTeacher;
  String? selectedClassTeacherId;
  String? selectedSection;
  String? selectedTerm;
  bool _isLoading = false;

  // Dummy data for dropdowns
  final List<String> levels = [
    'Grade 1',
    'Grade 2',
    'Grade 3',
    'Grade 4',
    'Grade 5',
    'Grade 6',
    'Grade 7',
    'Grade 8',
    'Grade 9',
    'Grade 10',
    'Grade 11',
    'Grade 12',
    'Kindergarten',
    'Pre-K',
  ];

  final List<String> teachers = [
    'Mrs. Sarah Johnson',
    'Mr. David Smith',
    'Ms. Emily Davis',
    'Mr. Michael Brown',
    'Mrs. Jessica Wilson',
    'Mr. Robert Taylor',
    'Ms. Amanda Clark',
    'Mrs. Lisa Anderson',
    'Mr. James Martinez',
    'Ms. Rachel White',
  ];

  final List<String> sections = ['A', 'B', 'C', 'D', 'E'];
  final List<String> terms = ['First', 'Second', 'Third'];

  @override
  void dispose() {
    _classNameController.dispose();
    _capacityController.dispose();
    _roomNumberController.dispose();
    _descriptionController.dispose();
    _baseFeeController.dispose();
    super.dispose();
  }

  Future<void> _saveClass() async {
    if (_formKey.currentState!.validate()) {
      try {
        final Map<String, dynamic> requestBody = {
          "name": _classNameController.text.trim(),
          "level": selectedLevel,
          "section": selectedSection,
          "academicYear": widget.academicYear,
          "classTeacher": selectedClassTeacherId,
          "capacity": int.tryParse(_capacityController.text) ?? 30,
          "classroom": _roomNumberController.text.trim(),
          "description": _descriptionController.text.trim(),
        };

        // Add fee structure if base fee is provided
        if (_baseFeeController.text.isNotEmpty) {
          final baseFee = double.tryParse(_baseFeeController.text);
          if (baseFee != null && baseFee > 0) {
            requestBody["feeStructure"] = {
              "term": selectedTerm ?? terms.first,
              "year": widget.academicYear,
              "baseFee": baseFee,
              "addOns": [],
            };
            requestBody["setAsActive"] = true;
          }
        }
        await ref
            .read(RiverpodProvider.classProvider)
            .createClass(context, requestBody);
        Navigator.pop(context);
        print(requestBody);
      } catch (e) {}
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 16,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        width: MediaQuery.of(context).size.width * 0.5,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade600, Colors.blue.shade800],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.school, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Add New Class',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed:
                        _isLoading ? null : () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Form Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Academic Year (read-only)
                      TextFormField(
                        initialValue: widget.academicYear,
                        decoration: InputDecoration(
                          labelText: 'Academic Year',
                          prefixIcon: const Icon(Icons.calendar_today),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade100,
                        ),
                        readOnly: true,
                      ),
                      const SizedBox(height: 16),

                      // Class Name
                      TextFormField(
                        controller: _classNameController,
                        decoration: InputDecoration(
                          labelText: 'Class Name*',
                          hintText: 'Enter class name (e.g., Grade 1A)',
                          prefixIcon: const Icon(Icons.class_),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a class name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Level and Section Row
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              value: selectedLevel,
                              decoration: InputDecoration(
                                labelText: 'Grade Level*',
                                prefixIcon: const Icon(Icons.grade),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items:
                                  levels.map((String level) {
                                    return DropdownMenuItem<String>(
                                      value: level,
                                      child: Text(level),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedLevel = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a grade level';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              dropdownColor: Colors.white,
                              value: selectedSection,
                              decoration: InputDecoration(
                                labelText: 'Section*',
                                prefixIcon: const Icon(Icons.segment),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              items:
                                  sections.map((String section) {
                                    return DropdownMenuItem<String>(
                                      value: section,
                                      child: Text('Section $section'),
                                    );
                                  }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedSection = newValue;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Please select a section';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Class Teacher
                      DropdownButtonFormField<String>(
                        dropdownColor: Colors.white,
                        value: selectedClassTeacher,
                        decoration: InputDecoration(
                          labelText: 'Class Teacher*',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items:
                            (widget.teacherData.teachers??[]).map((teacher) {
                              return DropdownMenuItem<String>(
                                onTap: () {
                                  selectedClassTeacherId = teacher.id;
                                },
                                value:
                                    '${teacher.fullName} ${teacher.teachingInfo?.classTeacherClasses?.isNotEmpty == true ? teacher.teachingInfo?.classTeacherClasses?.first?.name ?? '' : ''} ',
                                child: Text(teacher.fullName.toString()),
                              );
                            }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            selectedClassTeacher = newValue;
                          });
                        },

                        validator: (value) {
                          if (value == null) {
                            return 'Please select a class teacher';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      // Room Number and Capacity Row
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _roomNumberController,
                              decoration: InputDecoration(
                                labelText: 'Room Number*',
                                hintText: 'e.g., A-101',
                                prefixIcon: const Icon(Icons.room),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter room number';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: TextFormField(
                              controller: _capacityController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Capacity*',
                                hintText: 'Max students',
                                prefixIcon: const Icon(Icons.groups),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                filled: true,
                                fillColor: Colors.grey.shade50,
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter capacity';
                                }
                                final capacity = int.tryParse(value);
                                if (capacity == null || capacity <= 0) {
                                  return 'Enter valid number';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Fee Structure Section
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.grey.shade50,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Fee Structure (Optional)',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'You can add fee structure now or later',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(height: 16),

                            Row(
                              children: [
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    dropdownColor: Colors.white,
                                    value: selectedTerm,
                                    decoration: InputDecoration(
                                      labelText: 'Term',
                                      prefixIcon: const Icon(Icons.schedule),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    items:
                                        terms.map((String term) {
                                          return DropdownMenuItem<String>(
                                            value: term,
                                            child: Text(term),
                                          );
                                        }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedTerm = newValue;
                                      });
                                    },
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: TextFormField(
                                    controller: _baseFeeController,
                                    keyboardType: TextInputType.number,
                                    decoration: InputDecoration(
                                      labelText: 'Base Fee',
                                      hintText: 'e.g., 5000',
                                      prefixIcon: const Icon(
                                        Icons.attach_money,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Description
                      TextFormField(
                        controller: _descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Description (Optional)',
                          hintText: 'Additional notes about the class',
                          prefixIcon: const Icon(Icons.description),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Action Buttons
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isLoading ? null : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancel',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _saveClass,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 2,
                      ),
                      child:
                          _isLoading
                              ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                              : const Text(
                                'Add Class',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
