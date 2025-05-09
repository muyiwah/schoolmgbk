import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart' hide Text;
import 'package:flutter_quill_extensions/flutter_quill_extensions.dart';

class QuillEditorExample extends StatefulWidget {
  const QuillEditorExample({super.key});

  @override
  State<QuillEditorExample> createState() => _QuillEditorExampleState();
}

class _QuillEditorExampleState extends State<QuillEditorExample> {
  late QuillController _controller;
  final FocusNode _focusNode = FocusNode();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = QuillController.basic();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quill Editor Example')),
      body: Column(
        children: [
         Expanded(
            child: QuillSimpleToolbar(
              config: QuillSimpleToolbarConfig(
                embedButtons: FlutterQuillEmbeds.toolbarButtons(),
              ), controller: _controller,
            ),
          ),
          Expanded(
            child: QuillEditor(
              controller: _controller,
              scrollController: _scrollController,
              focusNode: _focusNode,
            ),
          ),
        ],
      ),
    );
  }

  /// Pick image
  Future<String> _onImagePickCallback(File file) async {
    // In production, upload the file to a server and return the URL
    return file.path;
  }

  /// Pick video
  Future<String> _onVideoPickCallback(File file) async {
    return file.path;
  }

  /// Pick file (PDF, DOC, etc.)
  Future<String> _onFilePickCallback(File file) async {
    return file.path;
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
