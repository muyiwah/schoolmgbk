import 'package:flutter/material.dart';

class CustomInput extends StatelessWidget {
  final String title;
  final TextEditingController controller;
  final bool showError;

  const CustomInput({
    Key? key,
    required this.title,
    required this.controller,
    this.showError = false,
    String? Function(dynamic value)? validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool hasError = showError && controller.text.isEmpty;
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          label: Text(title, style: const TextStyle(fontSize: 12)),
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          isDense: true,
          errorText: hasError ? 'This field is required' : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.blue),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
