class Validations {
  static String? validateName(value) {
    if (value.isEmpty) return 'Username is Required.';
    final RegExp nameExp = RegExp(r'^[A-za-zğüşöçİĞÜŞÖÇ ]+$');
    if (!nameExp.hasMatch(value)) {
      return 'Please enter only alphabetical characters.';
    }
    return null;
  }

  static String? validateNumber(value, [bool isRequried = true]) {
    if (value.isEmpty && isRequried) return 'lorry number is required.';

    final RegExp nameExp = RegExp(
        r'(([A-Za-z]){2,3}(|-)(?:[0-9]){1,2}(|-)(?:[A-Za-z]){2}(|-)([0-9]){1,4})|(([A-Za-z]){2,3}(|-)([0-9]){1,4})$');
    if (!nameExp.hasMatch(value) && isRequried) return 'Enter lorry number';
    return null;
  }

  static String? validatePassword(String value) {
    if (value.isEmpty || value.length < 6) {
      return 'Please enter a valid password.';
    }
    return null;
  }

  static String? validatePANNumber(value, [bool isRequried = true]) {
    if (value.isEmpty && isRequried) return 'PAN Number is required.';

    final RegExp nameExp = RegExp('[A-Z]{5}[0-9]{4}[A-Z]{1}');
    if (!nameExp.hasMatch(value) && isRequried) return 'Invalid Number';
    return null;
  }

  static String? validateAadhaarNumber(value, [bool isRequried = true]) {
    if (value.isEmpty && isRequried) return 'Aadhaar Number is required.';

    final RegExp nameExp = RegExp("^[2-9]{1}[0-9]{3}[0-9]{4}[0-9]{4}");
    if (!nameExp.hasMatch(value) && isRequried) return 'Invalid Number';
    return null;
  }

  static String? validateGstNumber(value, [bool isRequired = true]) {
    if (value.isEmpty && isRequired) return "GST Number is required";

    final RegExp nameExp =
        RegExp("^[0-9]{2}[A-Z]{5}[0-9]{4}[A-Z]{1}[1-9A-Z]{1}Z[0-9A-Z]{1}");
    if (!nameExp.hasMatch(value) && isRequired) return "Invalid Number";
    return null;
  }
}
