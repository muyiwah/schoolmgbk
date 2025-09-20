import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/providers/provider.dart';

class RemoveTeacherDialog extends ConsumerStatefulWidget {
  final Class classData;

  const RemoveTeacherDialog({super.key, required this.classData});

  @override
  ConsumerState<RemoveTeacherDialog> createState() =>
      _RemoveTeacherDialogState();
}

class _RemoveTeacherDialogState extends ConsumerState<RemoveTeacherDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.7,
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Column(
          children: [
            // Header
            _buildHeader(),

            // Tab Bar
            _buildTabBar(),

            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [_buildClassTeacherTab(), _buildSubjectTeachersTab()],
              ),
            ),

            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.8)],
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
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.person_remove,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Remove Teachers',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Class: ${widget.classData.name} (${widget.classData.level})',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.close, color: Colors.white, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: AppColors.primary,
          borderRadius: BorderRadius.circular(12),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade600,
        labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
        tabs: const [
          Tab(icon: Icon(Icons.school, size: 20), text: 'Class Teacher'),
          Tab(icon: Icon(Icons.subject, size: 20), text: 'Subject Teachers'),
        ],
      ),
    );
  }

  Widget _buildClassTeacherTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Current Class Teacher',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          if (widget.classData.classTeacher != null)
            _buildTeacherCard(
              teacher: widget.classData.classTeacher!,
              role: 'classTeacher',
              isClassTeacher: true,
            )
          else
            _buildEmptyState('No class teacher assigned'),
        ],
      ),
    );
  }

  Widget _buildSubjectTeachersTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Subject Teachers',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          const SizedBox(height: 16),

          Expanded(
            child:
                widget.classData.subjectTeachers != null &&
                        widget.classData.subjectTeachers!.isNotEmpty
                    ? ListView.builder(
                      itemCount: widget.classData.subjectTeachers!.length,
                      itemBuilder: (context, index) {
                        final subjectTeacher =
                            widget.classData.subjectTeachers![index];
                        return _buildSubjectTeacherCard(subjectTeacher);
                      },
                    )
                    : _buildEmptyState('No subject teachers assigned'),
          ),
        ],
      ),
    );
  }

  Widget _buildTeacherCard({
    required Teacher teacher,
    required String role,
    bool isClassTeacher = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color:
              isClassTeacher
                  ? AppColors.primary.withValues(alpha: 0.2)
                  : Colors.grey.shade200,
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary,
                  AppColors.primary.withValues(alpha: 0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '${teacher.personalInfo?.firstName?.substring(0, 1) ?? ''}${teacher.personalInfo?.lastName?.substring(0, 1) ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Teacher Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${teacher.personalInfo?.firstName ?? ''} ${teacher.personalInfo?.lastName ?? ''}'
                      .trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  teacher.user?.email ?? 'No email',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color:
                        isClassTeacher
                            ? AppColors.primary.withValues(alpha: 0.1)
                            : Colors.orange.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isClassTeacher ? 'Class Teacher' : 'Subject Teacher',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color:
                          isClassTeacher
                              ? AppColors.primary
                              : Colors.orange.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () => _showRemoveConfirmation(teacher, role),
              icon: const Icon(Icons.person_remove, size: 18),
              label: const Text('Remove'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectTeacherCard(SubjectTeacher subjectTeacher) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.2),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orange.shade500, Colors.orange.shade300],
              ),
              borderRadius: BorderRadius.circular(30),
            ),
            child: Center(
              child: Text(
                '${subjectTeacher.teacher?.personalInfo?.firstName?.substring(0, 1) ?? ''}${subjectTeacher.teacher?.personalInfo?.lastName?.substring(0, 1) ?? ''}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Teacher Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${subjectTeacher.teacher?.personalInfo?.firstName ?? ''} ${subjectTeacher.teacher?.personalInfo?.lastName ?? ''}'
                      .trim(),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subjectTeacher.teacher?.user?.email ?? 'No email',
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    subjectTeacher.subject ?? 'Unknown Subject',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Remove Button
          Container(
            margin: const EdgeInsets.only(left: 16),
            child: ElevatedButton.icon(
              onPressed:
                  _isLoading
                      ? null
                      : () => _showRemoveConfirmation(
                        subjectTeacher.teacher!,
                        'subjectTeacher',
                      ),
              icon: const Icon(Icons.person_remove, size: 18),
              label: const Text('Remove'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade500,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.person_off,
              size: 48,
              color: Colors.grey.shade400,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showRemoveConfirmation(Teacher teacher, String role) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.orange.shade600,
                  size: 28,
                ),
                const SizedBox(width: 12),
                const Text('Confirm Removal'),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Are you sure you want to remove:',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  '${teacher.personalInfo?.firstName ?? ''} ${teacher.personalInfo?.lastName ?? ''}'
                      .trim(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'as ${role == 'classTeacher' ? 'Class Teacher' : 'Subject Teacher'}?',
                  style: TextStyle(color: Colors.grey.shade700, fontSize: 14),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: Colors.orange.shade600,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'This action cannot be undone.',
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _removeTeacher(teacher, role);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red.shade500,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Remove'),
              ),
            ],
          ),
    );
  }

  Future<void> _removeTeacher(Teacher teacher, String role) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ref
          .read(RiverpodProvider.classProvider)
          .removeTeacherFromClass(
            context,
            widget.classData.id!,
            teacher.id!,
            role: role,
          );

      // Refresh the class data
      await ref
          .read(RiverpodProvider.classProvider)
          .getAllClassesWithMetric(context);

    
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error removing teacher: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
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
}
