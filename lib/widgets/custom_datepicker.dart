import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CustomDatePicker extends StatefulWidget {
  const CustomDatePicker({
    super.key,
    required this.type,
    required this.controller,
  });

  final String type;
  final TextEditingController controller;

  @override
  State<CustomDatePicker> createState() => _CustomDatePickerState();
}

class _CustomDatePickerState extends State<CustomDatePicker> {
  DateTime? selectedDate;

  Future<void> _pickDate() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder:
          (context, child) => Theme(
            data: Theme.of(
              context,
            ).copyWith(dialogBackgroundColor: Colors.white.withOpacity(.6)),
            child: child!,
          ),
    );

    if (date != null) {
      setState(() {
        selectedDate = date;
        widget.controller.text = DateFormat('yyyy-MM-dd').format(date);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: TextFormField(
        controller: widget.controller,
        readOnly: true,
        onTap: _pickDate,
        style: TextStyle(fontSize: 14),
        decoration: InputDecoration(
          labelText: widget.type,
          labelStyle: const TextStyle(fontSize: 12),
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          isDense: true,
          suffixIcon: const Icon(Icons.calendar_today),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.grey),
          ),
        ),
      ),
    );
  }
}
