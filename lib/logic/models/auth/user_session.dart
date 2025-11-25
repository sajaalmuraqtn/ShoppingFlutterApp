import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserSession {
 
   static const String _keyUserId = "user_id";
  static const String _keyUserEmail = "user_email";
  static const String _keyUserName = "user_name";
  static const String _keyIsLoggedIn = "is_logged_in";

  /// حفظ بيانات المستخدم عند تسجيل الدخول
  static Future<void> saveUser({
    required String userId,
    required String email,
    String? name,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(_keyUserId, userId);
    await prefs.setString(_keyUserEmail, email);

    if (name != null) {
      await prefs.setString(_keyUserName, name);
    }

    await prefs.setBool(_keyIsLoggedIn, true);
  }

   static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserId);
  }

   static Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserEmail);
  }

   static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserName);
  }

  /// هل المستخدم مسجّل دخول؟
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// تسجيل خروج ومسح كل البيانات
  static Future<void> logout() async {
   await FirebaseAuth.instance.signOut();

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserEmail);
    await prefs.remove(_keyUserName);
    await prefs.remove(_keyIsLoggedIn);
  }
 

  
}
