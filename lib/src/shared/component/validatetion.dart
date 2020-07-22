class Validation {
  static String validationPass(String pass) {
    if (pass.length == null) {
      return 'pasword invvalid';
    }
    if (pass.length < 3) {
      return 'password require minimum 1 charactor';
    }
    return null;
  }

//  static String validationEmail(String email) {
//    if (email.length <= 0) {
//      return 'Email invalid';
//    }
//    return null;
//  }

  static String validationEmail(String value) {
    Pattern pattern =
        r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
    RegExp regex = new RegExp(pattern);
    if (!regex.hasMatch(value))
      return 'Enter Valid Email';
    else
      return null;
  }
}
