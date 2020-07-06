class Validation {
  static String validationPass(String pass) {
    if (pass == null) {
      return 'pasword invvalid';
    }
    if (pass.length < 0) {
      return 'password require minimum 1 charactor';
    }
    return null;
  }

  static String validationEmail(String email) {
    if (email == null) {
      return 'Email invalid';
    }
    return null;
  }
}
