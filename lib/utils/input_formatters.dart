import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

String getNameInitials(String name) {
  if (name.isEmpty) return '';

  List<String> split =
      name.split(' ').where((element) => element.isNotEmpty).toList();

  if (split.length == 1) return split[0].substring(0, 1).toUpperCase();
  return split[0].substring(0, 1).toUpperCase() +
      split[1].substring(0, 1).toUpperCase();
}

String wrapName(receiverAccountName, {wrapLenght = 30}) {
  if (receiverAccountName != null && receiverAccountName.length > wrapLenght) {
    int lastSpaceIndex = receiverAccountName.lastIndexOf(" ");
    if (lastSpaceIndex != -1) {
      receiverAccountName = receiverAccountName.replaceRange(
          lastSpaceIndex, lastSpaceIndex + 1, "\n");
    }
  }
  return receiverAccountName;
}

String wordSplitter(String value, int i) {
  // ensure that number of words in title is greater than i
  if (value.split(' ').length <= i) return value;
  return '${value.split(' ').sublist(0, i).join(' ')}\n${value.split(' ').sublist(i).join(' ')}';
}

// convert from camelCase to seperated by space
String camelCaseSeperator(String text) {
  return text
      .replaceAllMapped(RegExp(r'[A-Z]'), (match) {
        return ' ${match.group(0)!}';
      })
      .split(' ')
      .map((word) =>
          word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1)}' : '')
      .join(' ');
}

currencyFormatter(var input, {bool hasDecimal = true}) {
  if (input == null || input.toString().isEmpty) {
    return hasDecimal ? "0.00" : "0";
  }

  if (input == 0 || input.toString() == '0' || input.toString() == '0.00') {
    return hasDecimal ? "0.00" : "0";
  }

  // remove all non-numeric characters
  input = input.toString().replaceAll(RegExp(r'[^\d.]'), '');

  return hasDecimal
      ? NumberFormat('#,##0.00').format(num.parse(input.toString()))
      : NumberFormat('#,###').format(num.parse(input.toString()));
}

String formatCurrency(value, {int decimal = 2}) {
  value ??= 0;
  if (value is bool) value = 0;
  if (value is String) value = num.tryParse(value) ?? 0;

  if (value == 0) return '0.${'0' * decimal}';

  if (value < 0.01) decimal = 4;
  if (value < 0.0001) decimal = 6;

  return value?.toStringAsFixed(decimal) ?? '0.${'0' * decimal}';
}

String parseDateTime(DateTime? obj) {
  // if (obj != null) return DateFormat.yMMMd().add_jm().format(obj.toLocal());
  if (obj != null) return DateFormat('d MMM y, h:mm a').format(obj.toLocal());
  return "N/A";
}

String parseStringToDate(String? date) {
  // if (obj != null) return DateFormat.yMMMd().add_jm().format(obj.toLocal());
  if (date != null) {
    return DateFormat('MMMM dd, y').format(DateTime.parse(date));
  }
  return "N/A";
}

String fixMessedUpPhoneNumber(String phoneNo,
    {countryCode = '+234', showCountryCode = true}) {
  phoneNo = phoneNo.replaceAll(RegExp(' '), '');
  if (phoneNo.startsWith('+')) {
    if (phoneNo.length > 14) {
      return phoneNo.substring(0, 4) + phoneNo.substring(5);
    }
    return phoneNo;
  }
  if (phoneNo.length == 11 || phoneNo.startsWith('0')) {
    phoneNo = phoneNo.substring(1);
  }
  return showCountryCode ? countryCode + phoneNo : phoneNo;
}

class NumberRemoveExtraDotFormatter extends TextInputFormatter {
  NumberRemoveExtraDotFormatter({this.decimalRange = 6})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String nValue = newValue.text;
    TextSelection nSelection = newValue.selection;

    Pattern p = RegExp(r'(\d+\.?)|(\.?\d+)|(\.?)');
    nValue = p
        .allMatches(nValue)
        .map<String>((Match match) => match.group(0)!)
        .join();

    if (nValue.startsWith('.')) {
      nValue = '0.';
    } else if (nValue.contains('.')) {
      if (nValue.substring(nValue.indexOf('.') + 1).length > decimalRange) {
        nValue = oldValue.text;
      } else {
        if (nValue.split('.').length > 2) {
          List<String> split = nValue.split('.');
          nValue = '${split[0]}.${split[1]}';
        }
      }
    }

    nSelection = newValue.selection.copyWith(
      baseOffset: math.min(nValue.length, nValue.length + 1),
      extentOffset: math.min(nValue.length, nValue.length + 1),
    );

    return TextEditingValue(
        text: nValue, selection: nSelection, composing: TextRange.empty);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  DecimalTextInputFormatter({required this.decimalRange})
      : assert(decimalRange > 0);

  final int decimalRange;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue, // unused.
    TextEditingValue newValue,
  ) {
    TextSelection newSelection = newValue.selection;
    String truncated = newValue.text;

    String value = newValue.text;

    if (value.contains(".") &&
        value.substring(value.indexOf(".") + 1).length > decimalRange) {
      truncated = oldValue.text;
      newSelection = oldValue.selection;
    } else if (value == ".") {
      truncated = "0.";

      newSelection = newValue.selection.copyWith(
        baseOffset: math.min(truncated.length, truncated.length + 1),
        extentOffset: math.min(truncated.length, truncated.length + 1),
      );
    }

    return TextEditingValue(
      text: truncated,
      selection: newSelection,
      composing: TextRange.empty,
    );
      return newValue;
  }
}
