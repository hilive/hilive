import 'package:bcrypt/bcrypt.dart';

class PasswordUtils {
  static String hashPassword(String password) {
    return BCrypt.hashpw(password, BCrypt.gensalt());
  }

  static bool verifyPassword(String password, String hash) {
    return BCrypt.checkpw(password, hash);
  }

  static bool isValidPassword(String password) {
    // At least 6 characters
    if (password.length < 6) return false;
    return true;
  }

  static bool isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidUsername(String username) {
    // 2-20 characters, alphanumeric and underscore only
    if (username.length < 2 || username.length > 20) return false;
    final usernameRegex = RegExp(r'^[a-zA-Z0-9_\u4e00-\u9fa5]+$');
    return usernameRegex.hasMatch(username);
  }
}
