// captalise first letter of string
import 'package:intl/intl.dart';

String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

// string extension to captalise first letter of string
extension StringExtension on String {
  String capitalize() => "${this[0].toUpperCase()}${substring(1)}";
  bool isNum() => double.tryParse(this) != null;
}

bool isNullOrEmpty(String? value) {
  return value == null || value == "null" || value.isEmpty;
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

String parseStringToDateTime(String? date, {String? separator = ' • '}) {
  // if (obj != null) return DateFormat.yMMMd().add_jm().format(obj.toLocal());
  if (date != null) {
    return DateFormat('dd MMMM y $separator h:mm a')
        .format(DateTime.parse(date));
  }
  return "N/A";
}

String formatTime(dateString) {
  DateTime parsedDate = DateTime.parse(dateString);

  String formattedDate = DateFormat('EEEE, d MMMM, y').format(parsedDate);
  print(formattedDate); // Output: Wednesday, 25 June, 2025
  return formattedDate;
}
