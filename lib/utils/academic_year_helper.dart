import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/academic_settings_provider.dart';

class AcademicYearHelper {
  /// Get the current academic year from the provider
  static String getCurrentAcademicYear(WidgetRef ref) {
    final academicSettingsState = ref.read(academicSettingsProvider);
    final academicYear =
        academicSettingsState.currentAcademicYear?.academicYear;

    return academicYear ?? '2025/2026';
  }

  /// Get the current term from the provider
  static String getCurrentTerm(WidgetRef ref) {
    final academicSettingsState = ref.read(academicSettingsProvider);
    return academicSettingsState.currentAcademicYear?.currentTerm ?? 'First';
  }

  /// Get the current academic year asynchronously
  static Future<String> getCurrentAcademicYearAsync(WidgetRef ref) async {
    try {
      await ref
          .read(academicSettingsProvider.notifier)
          .getCurrentAcademicYear(forceRefresh: true);

      final academicSettingsState = ref.read(academicSettingsProvider);
      return academicSettingsState.currentAcademicYear?.academicYear ??
          '2025/2026';
    } catch (e) {
      print('Error getting current academic year: $e');
      return '2025/2026'; // Fallback
    }
  }

  /// Get the current term asynchronously
  static Future<String> getCurrentTermAsync(WidgetRef ref) async {
    try {
      await ref
          .read(academicSettingsProvider.notifier)
          .getCurrentAcademicYear(forceRefresh: true);

      final academicSettingsState = ref.read(academicSettingsProvider);
      return academicSettingsState.currentAcademicYear?.currentTerm ?? 'First';
    } catch (e) {
      print('Error getting current term: $e');
      return 'First'; // Fallback
    }
  }

  /// Generate admission number with current academic year
  static String generateAdmissionNumber(WidgetRef ref) {
    final currentYear = getCurrentAcademicYear(ref);
    final yearPart =
        currentYear.split('/')[0]; // Get first part of academic year
    final timestamp = DateTime.now().millisecondsSinceEpoch
        .toString()
        .substring(8);
    return 'ADM-$yearPart-$timestamp';
  }

  /// Check if academic year is available
  static bool isAcademicYearAvailable(WidgetRef ref) {
    final academicSettingsState = ref.read(academicSettingsProvider);
    return academicSettingsState.currentAcademicYear != null;
  }
}
