import 'package:shared_preferences/shared_preferences.dart';
class Validation {
  static String passCheck;
  //password validation
  static String validationPass(String pass) {
    if (pass == null) {
      return 'This field is require';
    }
    if (pass.length < 3) {
      return 'Password require minimum 3 character';
    }
    passCheck = pass;
    return null;
  }

  //email validation
  static String validationEmail(String email) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(email))
      return 'Not a valid Email';
    else
      return null;
  }

// fullname validation
  static String validationFullname(String fullname) {
    if (fullname == null) {
      return 'This field is require';
    }
    if (fullname.length < 3) {
      return 'Full name require minimum 3 characters';
    }
    return null;
  }

  //phone number validation
  static String validationPhoneNumber(String phone) {
    String pattern = r'(^(?:[+0]9)?[0-9]{10,12}$)';
    RegExp regExp = new RegExp(pattern);
    if (phone.length == 0) {
      return 'Please enter mobile number';
    }
    else if (!regExp.hasMatch(phone)) {
      return 'Please enter valid mobile number';
    }
    return null;
  }

  //confirm pass validation
  static String validationPassConfirm(String cpass) {
    if (cpass == null) {
      return 'This field is require';
    }
    if (cpass.length < 3) {
      return 'Not a valid password';
    }
    if (cpass != passCheck){
      return 'Enter the same with above password';
    }
    return null;
  }
}
