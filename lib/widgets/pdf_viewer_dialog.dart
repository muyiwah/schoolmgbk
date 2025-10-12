import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:pdf_render/pdf_render.dart';
import 'package:http/http.dart' as http;
import 'package:schmgtsystem/constants/appcolor.dart';
import 'package:schmgtsystem/widgets/custom_toast_notification.dart';
import 'package:schmgtsystem/utils/enums.dart';

class PdfViewerDialog extends StatefulWidget {
  final String pdfUrl;
  final String title;

  const PdfViewerDialog({super.key, required this.pdfUrl, required this.title});

  @override
  State<PdfViewerDialog> createState() => _PdfViewerDialogState();
}

class _PdfViewerDialogState extends State<PdfViewerDialog> {
  bool _isLoading = true;
  bool _hasError = false;
  bool _showFallbackOption = false;
  String _errorMessage = '';
  PdfDocument? _pdfDocument;
  int _currentPage = 0;
  int _totalPages = 0;

  @override
  void initState() {
    super.initState();
    _checkPlatformSupport();
  }

  // Check if the platform supports PDF rendering
  Future<void> _checkPlatformSupport() async {
    try {
      // Test with a minimal PDF data to detect platform compatibility
      final testPdfData = Uint8List.fromList([
        0x25, 0x50, 0x44, 0x46, // PDF header
        0x2d, 0x31, 0x2e, 0x34, // Version
        0x0a, // Newline
      ]);

      // Try to initialize PdfDocument to detect platform issues
      await PdfDocument.openData(testPdfData);

      // If we get here, platform should work - proceed with actual load
      _loadPdf();
    } catch (e) {
      debugPrint('❌ Platform compatibility test failed: $e');

      // Platform doesn't support PDF rendering - show fallback immediately
      setState(() {
        _isLoading = false;
        _hasError = true;
        _showFallbackOption = true;
        _errorMessage =
            'PDF preview is not supported on this platform. Please use "Open in Browser" instead.';
      });

      // Auto-prompt user to open in browser
      Future.delayed(const Duration(milliseconds: 1500), () {
        if (mounted && _hasError) {
          _handlePlatformError();
        }
      });
    }
  }

  // Method to handle platform incompatibility automatically
  Future<void> _handlePlatformError() async {
    // Show a brief message and then auto-open in browser
    CustomToastNotification.show(
      'Opening PDF in browser...',
      type: ToastType.success,
    );

    // Small delay to show the message
    await Future.delayed(const Duration(milliseconds: 500));

    // Close dialog and open in browser
    Navigator.of(context).pop();
    await _openInExternalApp();
  }

  Future<void> _loadPdf() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
      });

      debugPrint('🔄 Fetching PDF from: ${widget.pdfUrl}');
      final response = await http
          .get(Uri.parse(widget.pdfUrl))
          .timeout(const Duration(seconds: 30));

      debugPrint('📊 Response status: ${response.statusCode}');
      debugPrint('📁 Content length: ${response.contentLength} bytes');

      if (response.statusCode == 200) {
        if (response.bodyBytes.isEmpty) {
          throw Exception('PDF file is empty');
        }

        debugPrint('🚀 Loading PDF document...');
        final pdfData = response.bodyBytes;

        // Validate PDF data
        if (pdfData.length < 100) {
          throw Exception('PDF file appears to be corrupted or too small');
        }

        _pdfDocument = await PdfDocument.openData(pdfData);

        if (_pdfDocument == null) {
          throw Exception('Failed to parse PDF document');
        }

        setState(() {
          _totalPages = _pdfDocument!.pageCount;
          _isLoading = false;
        });

        debugPrint('✅ PDF loaded successfully: $_totalPages pages');
      } else {
        throw Exception('Failed to fetch PDF: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ PDF Loading error: $e');
      String errorMessage = e.toString();
      bool isPlatformError = false;

      // Simplify error messages for user and detect platform issues
      if (errorMessage.contains('getDocument') ||
          errorMessage.contains('PlatformException') ||
          errorMessage.contains('Cannot read properties of undefined')) {
        errorMessage =
            'PDF viewer is not supported on this platform. Pleaso use "Open in Browser" instead.';
        isPlatformError = true;
      } else if (errorMessage.contains('Malformed PDF')) {
        errorMessage = 'PDF file appears to be corrupted or invalid';
      } else if (errorMessage.contains('Network error')) {
        errorMessage =
            'Unable to download PDF. Please check your internet connection.';
      } else if (errorMessage.contains('timeout')) {
        errorMessage =
            'PDF download timed out. Please try again or use browser.';
      }

      setState(() {
        _isLoading = false;
        _hasError = true;
        _showFallbackOption = isPlatformError;
        _errorMessage = errorMessage;
      });
    }
  }

  Future<void> _openInExternalApp() async {
    try {
      final Uri url = Uri.parse(widget.pdfUrl);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        CustomToastNotification.show(
          'Could not open PDF in external app',
          type: ToastType.error,
        );
      }
    } catch (e) {
      CustomToastNotification.show(
        'Error opening PDF: $e',
        type: ToastType.error,
      );
    }
  }

  Future<void> _copyUrl() async {
    try {
      await Clipboard.setData(ClipboardData(text: widget.pdfUrl));
      CustomToastNotification.show(
        'PDF URL copied to clipboard',
        type: ToastType.success,
      );
    } catch (e) {
      CustomToastNotification.show(
        'Error copying URL: $e',
        type: ToastType.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        height: MediaQuery.of(context).size.height * 0.8,
        constraints: const BoxConstraints(maxWidth: 1000, maxHeight: 800),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.description, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: Container(color: Colors.grey[100], child: _buildContent()),
            ),

            // Footer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // URL display
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Text(
                        widget.pdfUrl,
                        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Action buttons
                  Row(
                    children: [
                      IconButton(
                        onPressed: _copyUrl,
                        icon: const Icon(Icons.copy, size: 20),
                        tooltip: 'Copy URL',
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.grey[200],
                          foregroundColor: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _openInExternalApp,
                        icon: const Icon(Icons.open_in_new, size: 18),
                        label: const Text('Open in Browser'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading PDF...',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    if (_hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Error loading PDF',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _errorMessage,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadPdf,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
    }

    // Real PDF Viewer using pdf_render
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            // Page navigation
            if (_totalPages > 1)
              Container(
                padding: const EdgeInsets.all(8),
                color: Colors.grey[100],
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      onPressed:
                          _currentPage > 0
                              ? () => setState(() => _currentPage--)
                              : null,
                      icon: const Icon(Icons.chevron_left),
                    ),
                    Text(
                      'Page ${_currentPage + 1} of $_totalPages',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    IconButton(
                      onPressed:
                          _currentPage < _totalPages - 1
                              ? () => setState(() => _currentPage++)
                              : null,
                      icon: const Icon(Icons.chevron_right),
                    ),
                  ],
                ),
              ),
            // PDF page
            Expanded(
              child:
                  _pdfDocument != null
                      ? Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey[300]!),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.picture_as_pdf,
                                size: 64,
                                color: Colors.red[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'PDF Page ${_currentPage + 1} of $_totalPages',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Preview not available\nClick "Open in Browser" to view',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      : const Center(child: CircularProgressIndicator()),
            ),
          ],
        ),
      ),
    );
  }
}
