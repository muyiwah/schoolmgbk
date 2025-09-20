import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/models/staff_model.dart' as staff;
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/providers/staff_provider.dart';

class AssignNewTeacherDialog extends ConsumerStatefulWidget {
  final Class? classData;

  const AssignNewTeacherDialog({super.key, this.classData});

  @override
  ConsumerState<AssignNewTeacherDialog> createState() =>
      _AssignNewTeacherDialogState();
}

class _AssignNewTeacherDialogState
    extends ConsumerState<AssignNewTeacherDialog> {
  staff.Staff? selectedTeacher;
  bool _isLoading = false;
  List<staff.Staff> teachers = [];

  @override
  void initState() {
    super.initState();
    // Use post-frame callback to avoid setState during build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTeachers();
    });
  }

  Future<void> _loadTeachers() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
      });

      // Get all staff and filter for teachers
      await ref.read(staffNotifierProvider.notifier).getAllStaff();

      if (!mounted) return;
      final staffState = ref.read(staffNotifierProvider);
      final allStaff = staffState.staff;

      // Filter staff to get only teachers
      teachers =
          allStaff.where((staffMember) {
            // Check if staff has teacher role
            final role = staffMember.user?.role?.toLowerCase();
            return role == 'teacher';
          }).toList();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading teachers: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _assignTeacher() async {
    if (selectedTeacher == null) return;

    try {
      setState(() {
        _isLoading = true;
      });

      // Prepare the assignment data
      final assignmentData = {
        "teacherId": selectedTeacher!.id,
        "assignmentDate": DateTime.now().toIso8601String(),
        "term": "First Term", // Default term, can be made dynamic
        "academicYear":
            "2025/2026", // Default academic year, can be made dynamic
        "notes": "Class teacher assignment",
      };

      // Call the assignment method only if classData is provided
      if (widget.classData != null) {
        await ref
            .read(RiverpodProvider.classProvider)
            .assignClassTeacherToClass(
              context,
              assignmentData,
              widget.classData!.id ?? '',
            );
      }

      // Store context before async operation
      final currentContext = context;

      // Refresh the class list to show the updated teacher
      await ref
          .read(RiverpodProvider.classProvider)
          .getAllClassesWithMetric(currentContext);

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '${selectedTeacher!.personalInfo?.firstName} ${selectedTeacher!.personalInfo?.lastName} assigned as class teacher successfully!',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error assigning teacher: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildStyledInput({
    required String label,
    required String value,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        initialValue: value,
        enabled: false,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          filled: true,
          fillColor: Colors.grey.shade50,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required String label,
    required List<staff.Staff> items,
    required staff.Staff? value,
    required Function(staff.Staff?) onChanged,
    IconData? icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<staff.Staff>(
        value: value,
        dropdownColor: Colors.white,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon:
              icon != null ? Icon(icon, color: AppColors.primary) : null,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: TextStyle(color: Colors.grey.shade700, fontSize: 14),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
        items:
            items.map((staff.Staff teacher) {
              final fullName =
                  '${teacher.personalInfo?.firstName ?? ''} ${teacher.personalInfo?.lastName ?? ''}'
                      .trim();
              final position = teacher.employmentInfo?.position ?? 'Teacher';
              final email = teacher.contactInfo?.email ?? 'N/A';
              return DropdownMenuItem<staff.Staff>(
                value: teacher,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      fullName,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      position,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
        onChanged: onChanged,
      ),
    );
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
        width: MediaQuery.of(context).size.width * 0.6,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withValues(alpha: 0.8),
                  ],
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
                  const Icon(Icons.person_add, color: Colors.white, size: 28),
                  const SizedBox(width: 12),
                  const Text(
                    'Assign Class Teacher',
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

            // Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Class Information Section (only show if classData is provided)
                    if (widget.classData != null)
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.school, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                Text(
                                  'Class Information',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Class Name',
                                    value: widget.classData!.name ?? 'N/A',
                                    icon: Icons.class_,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Level',
                                    value: widget.classData!.level ?? 'N/A',
                                    icon: Icons.grade,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Section',
                                    value: widget.classData!.section ?? 'N/A',
                                    icon: Icons.segment,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Capacity',
                                    value:
                                        '${widget.classData!.capacity ?? 0} students',
                                    icon: Icons.groups,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Current Students',
                                    value:
                                        '${widget.classData!.students?.length ?? 0} students',
                                    icon: Icons.people,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Current Teacher',
                                    value:
                                        widget.classData!.classTeacher != null
                                            ? '${widget.classData!.classTeacher?.personalInfo?.firstName ?? ''} ${widget.classData!.classTeacher?.personalInfo?.lastName ?? ''}'
                                                .trim()
                                            : 'No teacher assigned',
                                    icon: Icons.person,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    const SizedBox(height: 24),

                    // Teacher Selection Section
                    Text(
                      'Select New Class Teacher',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    const SizedBox(height: 16),

                    if (_isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.all(20),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    else if (teachers.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.warning, color: Colors.orange.shade600),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'No teachers found. Please add teachers first.',
                                style: TextStyle(
                                  color: Colors.orange.shade800,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      _buildStyledDropdown(
                        label: 'Choose Teacher *',
                        items: teachers,
                        value: selectedTeacher,
                        onChanged: (staff.Staff? teacher) {
                          setState(() {
                            selectedTeacher = teacher;
                          });
                        },
                        icon: Icons.person,
                      ),

                    const SizedBox(height: 24),

                    // Assignment Details Section
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                color: Colors.orange.shade600,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Assignment Details',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange.shade800,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStyledInput(
                                  label: 'Term',
                                  value: 'First Term',
                                  icon: Icons.schedule,
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildStyledInput(
                                  label: 'Academic Year',
                                  value: '2025/2026',
                                  icon: Icons.calendar_month,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Selected Teacher Details
                    if (selectedTeacher != null) ...[
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.green.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.check_circle,
                                  color: Colors.green.shade600,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Selected Teacher',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Teacher Name',
                                    value:
                                        '${selectedTeacher!.personalInfo?.firstName ?? ''} ${selectedTeacher!.personalInfo?.lastName ?? ''}'
                                            .trim(),
                                    icon: Icons.person,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Position',
                                    value:
                                        selectedTeacher!
                                            .employmentInfo
                                            ?.position ??
                                        'Teacher',
                                    icon: Icons.work,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Email',
                                    value:
                                        selectedTeacher!.contactInfo?.email ??
                                        'N/A',
                                    icon: Icons.email,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: _buildStyledInput(
                                    label: 'Phone',
                                    value:
                                        selectedTeacher!
                                            .contactInfo
                                            ?.primaryPhone ??
                                        'N/A',
                                    icon: Icons.phone,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Info Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade600),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'The selected teacher will become the primary class teacher responsible for this class. This will replace any existing class teacher assignment.',
                              style: TextStyle(
                                color: Colors.blue.shade800,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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
                      onPressed:
                          (_isLoading || selectedTeacher == null)
                              ? null
                              : _assignTeacher,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
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
                                'Assign Teacher',
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
