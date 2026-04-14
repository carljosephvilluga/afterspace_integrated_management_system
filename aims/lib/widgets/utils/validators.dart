//Validators

class Validators {
  //Last and First Name
  static String? name(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (value.trim().length < 2) {
      return 'Too short';
    }
    return null;
  }

  //M.I. (Optional)
  static String? middleInitial(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    if (value.trim().length > 2) {
      return 'Invalid';
    }
  }

  //Email (Optional)
  static String? emailUserForm(String? value) {
    if (value == null || value.trim().isEmpty) return null; //Optional
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
    return emailValid ? null : "Invalid email format";
  }

  //Phone Number (kulang pa)
  static String? phoneNumber(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
  }

  //Type and Membership
  static String? selection(String value, String fieldName) {
    if (value.isEmpty) {
      return 'Required';
    }
    if (value.trim().length < 11) {
      return 'Incomplete';
    }
    return null;
  }

  // Added for login screen
  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    return null;
  }

  // Email Validator
  static String? emailValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    final bool emailValid = RegExp(
      r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9]+\.[a-zA-Z]+",
    ).hasMatch(value);
    return emailValid ? null : "Invalid email format";
  }

  // Password Validator
  static String? passwordValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Required';
    }
    if (value.trim().length < 6) {
      return 'Password too short';
    }
    
    final hasNumber = RegExp(r'\d').hasMatch(value);
    final hasUpper = RegExp(r'[A-Z]').hasMatch(value);
    if (!hasNumber || !hasUpper) {
      return 'Must include a number and uppercase letter';
    }
    return null;
  }

}
