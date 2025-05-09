import 'package:flutter/material.dart';

class CustomDropdown extends StatefulWidget {
  final void Function(String?)? onChanged;
  final String title;
  final List<String> allValues;
  final bool showError;

  const CustomDropdown({
    Key? key,
    this.onChanged,
    required this.allValues,
    required this.title,
     this.showError=false,
  }) : super(key: key);

  @override
  State<CustomDropdown> createState() => _CustomDropdownState();
}

class _CustomDropdownState extends State<CustomDropdown> {
  String? _localSelectedValue;

  @override
  Widget build(BuildContext context) {
    bool hasError =
        widget.showError &&
        (_localSelectedValue == null || _localSelectedValue!.isEmpty);

    return SizedBox(
      width: 200,
      child: DropdownButtonFormField<String>(
        value: _localSelectedValue,
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white.withOpacity(0.6),
          isDense: true,
          errorText: hasError ? 'Please select a value' : null,
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: hasError ? Colors.red : Colors.grey),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        hint: Text(widget.title, style: const TextStyle(fontSize: 12)),
        items:
            widget.allValues
                .map(
                  (item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item, style: const TextStyle(fontSize: 12)),
                  ),
                )
                .toList(),
        onChanged: (value) {
          setState(() {
            _localSelectedValue = value;
          });
          if (widget.onChanged != null) {
            widget.onChanged!(value);
          }
        },
      ),
    );
  }
}
