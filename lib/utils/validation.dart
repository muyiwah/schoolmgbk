String? validatePassword(String input) {
  if (input.isEmpty) {
    return "Password field cannot be empty";
  } else if (input.length < 4) {
    return "Password must be longer than 4 characters";
  }
  return null;
}

String? validatePassword2(String value) {
  RegExp regex =
      RegExp(r'^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[!@#\$&*~]).{8,}$');
  if (value.isEmpty) {
    return 'Password is required';
  } else {
    if (!regex.hasMatch(value) && value.length < 8) {
      return 'Must be atleast 8 characters containing a mix\nof uppercase and lowercase letters,\nnumbers & symbols';
    } else {
      return null;
    }
  }
}

RegExp? regex;
String? validateEmail(String? value) {
  String pattern =
      r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]"
      r"{0,253}[a-zA-Z0-9])?)*$";
  regex = RegExp(pattern);
  if (value == null || value.isEmpty) {
    return "Email is required";
  } else if (!regex!.hasMatch(value)) {
    return "Invalid email address";
  } else {
    return null;
  }
}
