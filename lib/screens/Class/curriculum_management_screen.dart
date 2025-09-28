import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/models/class_metrics_model.dart';
import 'package:schmgtsystem/providers/provider.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/widgets/pdf_viewer_dialog.dart';
import 'package:schmgtsystem/utils/constants.dart';

class CurriculumManagementScreen extends ConsumerStatefulWidget {
  const CurriculumManagementScreen({super.key});

  @override
  ConsumerState<CurriculumManagementScreen> createState() =>
      _CurriculumManagementScreenState();
}

class _CurriculumManagementScreenState
    extends ConsumerState<CurriculumManagementScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadClasses();
    });
  }

  Future<void> _loadClasses() async {
    await ref
        .read(RiverpodProvider.classProvider)
        .getAllClassesWithMetric(context);
  }

  Future<String> _uploadToCloudinary(PlatformFile file, String publicId) async {
    try {
      debugPrint('🚀 Starting PDF upload to Cloudinary...');
      debugPrint('📁 File: ${file.name}, Size: ${file.size} bytes');
      debugPrint('🆔 Public ID: $publicId');

      // Use the same Cloudinary configuration as addStudent
      final uploadUrl =
          'https://api.cloudinary.com/v1_1/${AppConstants.cloudinaryCloudName}/raw/upload';

      // Create form data
      final request = http.MultipartRequest('POST', Uri.parse(uploadUrl));

      // Add file
      if (file.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            file.bytes!,
            filename: file.name,
          ),
        );
      } else {
        throw Exception('File bytes are null');
      }

      // Add Cloudinary parameters using the same preset as addStudent
      request.fields['public_id'] = publicId;
      request.fields['resource_type'] = 'raw'; // Important for PDF files
      request.fields['upload_preset'] = AppConstants.cloudinaryPreset;
      request.fields['folder'] = 'curriculum';

      debugPrint('📤 Uploading to: $uploadUrl');
      debugPrint('🔑 Using preset: ${AppConstants.cloudinaryPreset}');

      // Send request
      final response = await request.send().timeout(
        const Duration(seconds: 30),
      );
      final responseBody = await response.stream.bytesToString();

      debugPrint('📊 Upload response status: ${response.statusCode}');
      debugPrint('📊 Upload response body: $responseBody');

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(responseBody);
        final secureUrl = jsonResponse['secure_url'] as String;

        debugPrint('✅ Upload successful! URL: $secureUrl');

        // Ensure the URL is the delivery URL format
        if (secureUrl.contains('/raw/upload/')) {
          return secureUrl;
        } else {
          throw Exception('Invalid Cloudinary URL format: $secureUrl');
        }
      } else {
        throw Exception(
          'Upload failed: ${response.statusCode} - $responseBody',
        );
      }
    } catch (e) {
      debugPrint('❌ Cloudinary upload error: $e');
      throw Exception('Cloudinary upload error: $e');
    }
  }

  Future<void> _uploadCurriculum(Class classData) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Check file size (5MB = 5 * 1024 * 1024 bytes)
        const maxFileSize = 5 * 1024 * 1024; // 5MB in bytes
        if (file.size > maxFileSize) {
          CustomToastNotification.show(
            'File size exceeds 5MB limit. Please choose a smaller file.',
            type: ToastType.error,
          );
          return;
        }

        // Upload to Cloudinary with raw resource type for PDF
        final publicId =
            'curriculum/${classData.name?.toLowerCase().replaceAll(' ', '_')}_${DateTime.now().millisecondsSinceEpoch}';

        // Upload to Cloudinary
        final curriculumUrl = await _uploadToCloudinary(file, publicId);

        final success = await ref
            .read(RiverpodProvider.classProvider)
            .addCurriculum(context, classData.id ?? '', curriculumUrl);

        if (success) {
          setState(() {});
        }
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error uploading curriculum: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _deleteCurriculum(Class classData) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Delete Curriculum'),
            content: Text(
              'Are you sure you want to delete the curriculum for ${classData.name}?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text('Delete'),
              ),
            ],
          ),
    );

    if (confirmed == true) {
      final success = await ref
          .read(RiverpodProvider.classProvider)
          .deleteCurriculum(context, classData.id ?? '');

      if (success) {
        setState(() {});
      }
    }
  }

  Future<void> _previewCurriculum(
    String curriculumUrl,
    String className,
  ) async {
    try {
      // Show PDF viewer dialog
      showDialog(
        context: context,
        barrierDismissible: true,
        barrierColor: Colors.black.withOpacity(0.5),
        builder:
            (context) => PdfViewerDialog(
              pdfUrl: curriculumUrl,
              title: 'Curriculum - $className',
            ),
      );
    } catch (e) {
      CustomToastNotification.show(
        'Error opening curriculum: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final classData = ref.watch(RiverpodProvider.classProvider).classData;
    final classes = classData.classes ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text(
          'Curriculum Management',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppColors.primary,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primary,
                    AppColors.primary.withOpacity(0.8),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.school, size: 48, color: Colors.white),
                  const SizedBox(height: 16),
                  const Text(
                    'Manage Class Curricula',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload, preview, and manage curriculum PDFs for each class',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Classes Grid
            if (classes.isEmpty)
              Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.school_outlined,
                      size: 64,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No classes found',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                  ],
                ),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 20,
                  mainAxisSpacing: 20,
                  childAspectRatio: 1.2,
                ),
                itemCount: classes.length,
                itemBuilder: (context, index) {
                  final classItem = classes[index];
                  return _buildClassCurriculumCard(classItem);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassCurriculumCard(Class classData) {
    final hasCurriculum =
        classData.curriculumUrl != null && classData.curriculumUrl!.isNotEmpty;

    return Container(
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
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Class Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        hasCurriculum
                            ? Colors.green.withOpacity(0.1)
                            : Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasCurriculum
                        ? Icons.description
                        : Icons.description_outlined,
                    color: hasCurriculum ? Colors.green : Colors.orange,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        classData.name ?? 'Unknown Class',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F2937),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        classData.level ?? '',
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Status
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    hasCurriculum
                        ? Colors.green.withOpacity(0.1)
                        : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                hasCurriculum ? 'Curriculum Available' : 'No Curriculum',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: hasCurriculum ? Colors.green : Colors.orange,
                ),
              ),
            ),

            const Spacer(),

            // Action Buttons
            if (hasCurriculum) ...[
              // Preview Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed:
                      () => _previewCurriculum(
                        classData.curriculumUrl!,
                        classData.name ?? 'Unknown Class',
                      ),
                  icon: const Icon(Icons.visibility, size: 18),
                  label: const Text('Preview'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              // Delete Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _deleteCurriculum(classData),
                  icon: const Icon(Icons.delete, size: 18),
                  label: const Text('Delete'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ] else ...[
              // Upload Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _uploadCurriculum(classData),
                  icon: const Icon(Icons.upload, size: 18),
                  label: const Text('Upload Curriculum'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
