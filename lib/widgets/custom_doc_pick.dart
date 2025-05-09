import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

class DocumentPicker extends StatefulWidget {
  const DocumentPicker({super.key, this.onFilePicked});

  final void Function(PlatformFile)? onFilePicked;

  @override
  State<DocumentPicker> createState() => _DocumentPickerState();
}

class _DocumentPickerState extends State<DocumentPicker> {
  TextEditingController _fileNameController = TextEditingController();

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'pdf',
        'doc',
        'docx',
        'txt',
      ], // You can add more types
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _fileNameController.text = file.name;
      });

      if (widget.onFilePicked != null) {
        widget.onFilePicked!(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _fileNameController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Select Document',
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          isDense: true,
          suffixIcon: IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickDocument,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}

class DocumentPickerWithValidator extends StatefulWidget {
  DocumentPickerWithValidator({
    super.key,
    this.onFilePicked,
    required this.validateTrigger,
    this.initialFile,
    required this.clearFile, // <-- Add this
  });
  final void Function() clearFile;
  final void Function(PlatformFile)? onFilePicked;
  final bool validateTrigger;
  final PlatformFile? initialFile; // <-- Add this

  @override
  State<DocumentPickerWithValidator> createState() =>
      _DocumentPickerWithVAlidatorState();
}

class _DocumentPickerWithVAlidatorState
    extends State<DocumentPickerWithValidator> {
  late TextEditingController _fileNameController;
  bool _showError = false;
 
  clearFile() {
    setState(() {
      _fileNameController.clear();
    });
  }

  @override
  void initState() {
    super.initState();
    _fileNameController = TextEditingController();

    // Initialize controller with the initial file if provided
    if (widget.initialFile != null) {
      _fileNameController.text = widget.initialFile!.name;
    } else {
      _fileNameController.text = '';
    }
  }

  @override
  void didUpdateWidget(covariant DocumentPickerWithValidator oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the initialFile changes, update the text field
    if (oldWidget.initialFile != widget.initialFile) {
      _fileNameController.text = widget.initialFile?.name ?? '';
    }

    // when validateTrigger changes to true, check validation
    if (widget.validateTrigger && _fileNameController.text.isEmpty) {
      setState(() {
        _showError = true;
      });
    }
  }

  void clearFileName() {
    setState(() {
      _fileNameController.clear();
    });
  }

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
    );

    if (result != null && result.files.isNotEmpty) {
      final file = result.files.first;
      setState(() {
        _fileNameController.text = file.name;
        _showError = false; // clear error on successful pick
      });

      if (widget.onFilePicked != null) {
        widget.onFilePicked!(file);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 250,
      child: TextField(
        controller: _fileNameController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: 'Select Document',
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          isDense: true,
          errorText: _showError ? 'Please select a document' : null,
          suffixIcon: IconButton(
            icon: Icon(Icons.attach_file),
            onPressed: _pickDocument,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _showError ? Colors.red : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: _showError ? Colors.red : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: _showError ? Colors.red : Colors.grey,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _fileNameController.dispose();
    super.dispose();
  }
}
