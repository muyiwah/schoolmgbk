import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/appcolor.dart';
import '../../models/academic_settings_model.dart';
import '../../providers/academic_settings_provider.dart';
import '../../widgets/custom_toast_notification.dart';
// import '../../widgets/custom_app_bar.dart';

class AcademicSettingsDetailScreen extends ConsumerStatefulWidget {
  final AcademicSettingsModel academicSettings;

  const AcademicSettingsDetailScreen({
    super.key,
    required this.academicSettings,
  });

  @override
  ConsumerState<AcademicSettingsDetailScreen> createState() =>
      _AcademicSettingsDetailScreenState();
}

class _AcademicSettingsDetailScreenState
    extends ConsumerState<AcademicSettingsDetailScreen> {
  bool _isLoading = false;
  late AcademicSettingsModel _currentAcademicSettings;

  @override
  void initState() {
    super.initState();
    _currentAcademicSettings = widget.academicSettings;
  }

  Future<void> _refreshAcademicSettings() async {
    try {
      // Refresh the academic settings list to get updated data
      await ref
          .read(academicSettingsProvider.notifier)
          .getAllAcademicSettings(forceRefresh: true);

      // Find the updated academic settings from the provider state
      final academicSettingsState = ref.read(academicSettingsProvider);
      final updatedSettings =
          academicSettingsState.academicSettings
              .where((settings) => settings.id == _currentAcademicSettings.id)
              .firstOrNull;

      if (updatedSettings != null) {
        setState(() {
          _currentAcademicSettings = updatedSettings;
        });
      }
    } catch (e) {
      print('Error refreshing academic settings: $e');
    }
  }

  Future<void> _setActiveAcademicYear() async {
    setState(() {
      _isLoading = true;
    });

    final success = await ref
        .read(academicSettingsProvider.notifier)
        .setActiveAcademicYear(_currentAcademicSettings.id);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        // Get the update result from the provider state
        final academicSettingsState = ref.read(academicSettingsProvider);
        final updateResult = academicSettingsState.updateResult;

        String message = 'Academic year activated successfully';
        if (updateResult != null) {
          message += ' (${updateResult.modifiedCount} classes updated)';
        }

        CustomToastNotification.show(message, type: ToastType.success);
        // Refresh the academic settings data to update the UI
        await _refreshAcademicSettings();
      }
    } else {
      if (mounted) {
        final errorMessage = ref.read(academicSettingsProvider).errorMessage;
        CustomToastNotification.show(
          errorMessage ?? 'Failed to activate academic year',
          type: ToastType.error,
        );
      }
    }
  }

  Future<void> _updateCurrentTerm() async {
    final availableTerms = _currentAcademicSettings.terms;
    if (availableTerms.isEmpty) {
      CustomToastNotification.show(
        'No terms available for this academic year',
        type: ToastType.error,
      );
      return;
    }

    final selectedTerm = await showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Update Current Term'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  availableTerms.map((term) {
                    return RadioListTile<String>(
                      title: Text(term.name),
                      subtitle: Text(
                        '${_formatDate(term.startDate)} - ${_formatDate(term.endDate)}',
                      ),
                      value: term.name,
                      groupValue: _currentAcademicSettings.currentTerm,
                      onChanged: (value) {
                        Navigator.pop(context, value);
                      },
                    );
                  }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ],
          ),
    );

    if (selectedTerm != null &&
        selectedTerm != _currentAcademicSettings.currentTerm) {
      setState(() {
        _isLoading = true;
      });

      final success = await ref
          .read(academicSettingsProvider.notifier)
          .updateAcademicSettings(
            id: _currentAcademicSettings.id,
            currentTerm: selectedTerm,
          );

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          CustomToastNotification.show(
            'Current term updated to $selectedTerm',
            type: ToastType.success,
          );
          // Refresh the academic settings data to update the UI
          await _refreshAcademicSettings();
          // Also refresh the current academic year if this is the active one
          if (_currentAcademicSettings.isActive) {
            await ref
                .read(academicSettingsProvider.notifier)
                .getCurrentAcademicYear(forceRefresh: true);
          }
        }
      } else {
        if (mounted) {
          final errorMessage = ref.read(academicSettingsProvider).errorMessage;
          CustomToastNotification.show(
            errorMessage ?? 'Failed to update current term',
            type: ToastType.error,
          );
        }
      }
    }
  }

  Future<void> _deleteAcademicSettings() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Academic Year'),
            content: Text(
              'Are you sure you want to delete the academic year "${_currentAcademicSettings.academicYear}"? This action cannot be undone.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      setState(() {
        _isLoading = true;
      });

      final success = await ref
          .read(academicSettingsProvider.notifier)
          .deleteAcademicSettings(_currentAcademicSettings.id);

      setState(() {
        _isLoading = false;
      });

      if (success) {
        if (mounted) {
          CustomToastNotification.show(
            'Academic year deleted successfully',
            type: ToastType.success,
          );
          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          final errorMessage = ref.read(academicSettingsProvider).errorMessage;
          CustomToastNotification.show(
            errorMessage ?? 'Failed to delete academic year',
            type: ToastType.error,
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Academic Year Details'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            _buildHeaderCard(),

            const SizedBox(height: 16),

            // Basic Information
            _buildBasicInfoCard(),

            const SizedBox(height: 16),

            // Terms Information
            _buildTermsCard(),

            const SizedBox(height: 16),

            // Actions Card
            _buildActionsCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors:
              _currentAcademicSettings.isActive
                  ? [Colors.green, Colors.green.withOpacity(0.8)]
                  : [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: (widget.academicSettings.isActive
                    ? Colors.green
                    : AppColors.primary)
                .withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.school, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _currentAcademicSettings.academicYear,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Academic Year Settings',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.academicSettings.isActive)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildHeaderInfo(
                  'Current Term',
                  _currentAcademicSettings.currentTerm,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildHeaderInfo(
                  'Duration',
                  '${_calculateDuration()} days',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.8),
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildBasicInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Information',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow('Academic Year', _currentAcademicSettings.academicYear),
          _buildInfoRow('Current Term', _currentAcademicSettings.currentTerm),
          _buildInfoRow(
            'Status',
            _currentAcademicSettings.isActive ? 'Active' : 'Inactive',
          ),
          _buildInfoRow(
            'Start Date',
            '${_currentAcademicSettings.startDate.day}/${_currentAcademicSettings.startDate.month}/${_currentAcademicSettings.startDate.year}',
          ),
          _buildInfoRow(
            'End Date',
            '${_currentAcademicSettings.endDate.day}/${_currentAcademicSettings.endDate.month}/${_currentAcademicSettings.endDate.year}',
          ),
          if (_currentAcademicSettings.description != null &&
              _currentAcademicSettings.description!.isNotEmpty)
            _buildInfoRow('Description', _currentAcademicSettings.description!),
          _buildInfoRow(
            'Created',
            _formatDate(_currentAcademicSettings.createdAt),
          ),
          _buildInfoRow(
            'Last Updated',
            _formatDate(_currentAcademicSettings.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTermsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Terms',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ..._currentAcademicSettings.terms
              .map(
                (term) => Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color:
                        term.isActive
                            ? AppColors.primary.withOpacity(0.1)
                            : Colors.grey[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color:
                          term.isActive ? AppColors.primary : Colors.grey[300]!,
                      width: term.isActive ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              term.name,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color:
                                    term.isActive
                                        ? AppColors.primary
                                        : Colors.black,
                              ),
                            ),
                          ),
                          if (term.isActive)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Text(
                                'Active',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: _buildTermDateInfo(
                              'Start',
                              '${term.startDate.day}/${term.startDate.month}/${term.startDate.year}',
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildTermDateInfo(
                              'End',
                              '${term.endDate.day}/${term.endDate.month}/${term.endDate.year}',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ],
      ),
    );
  }

  Widget _buildTermDateInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _buildActionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Actions',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          if (!_currentAcademicSettings.isActive) ...[
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _setActiveAcademicYear,
                icon:
                    _isLoading
                        ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                        : const Icon(Icons.check_circle),
                label: Text(_isLoading ? 'Activating...' : 'Set as Active'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          // Update Current Term Button (always visible)
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _updateCurrentTerm,
              icon: const Icon(Icons.edit_calendar),
              label: const Text('Update Current Term'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _deleteAcademicSettings,
              icon: const Icon(Icons.delete),
              label: const Text('Delete Academic Year'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _calculateDuration() {
    return _currentAcademicSettings.endDate
        .difference(_currentAcademicSettings.startDate)
        .inDays;
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
