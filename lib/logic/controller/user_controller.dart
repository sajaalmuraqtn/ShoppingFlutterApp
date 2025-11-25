import 'package:electrical_store_mobile_app/helpers/database_helper.dart';
import 'package:electrical_store_mobile_app/logic/firebaseServices/auth.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/auth.dart';
 
class UserController {
  final dbHelper = DatabaseHelper.instance;
  final firebase = FirebaseAuthService();

Future<bool> register(User user) async {
  final remoteUser = await firebase.registerUser(
    name: user.name,
    email: user.email,
    password: user.password,
  );

  if (remoteUser == null) {
    // البريد موجود مسبقاً أو خطأ
    return false;
  }

  // تخزين نسخة محلية في SQLite
  final db = await dbHelper.database;
  await db.insert("users", {
    "name": remoteUser["name"],
    "email": remoteUser["email"],
    "password": user.password, // مهم لحالات offline
  });

  return true;
}

   Future<Map<String, dynamic>?> login(String email, String password) async {
     final remoteUser = await firebase.login(email, password);

    if (remoteUser != null) {
       final db = await dbHelper.database;

      await db.delete("users", where: "email = ?", whereArgs: [email]);
      await db.insert("users", {
        "name": remoteUser["name"],
        "email": remoteUser["email"],
        "password": password,
      });
      return remoteUser;
    }

    // 2) في حال عدم الاتصال يسجيل دخول sqlite
    final db = await dbHelper.database;

    final result = await db.query(
      "users",
      where: "email = ? AND password = ?",
      whereArgs: [email, password],
      limit: 1,
    );

    if (result.isNotEmpty) {
      return result.first;
    }

    return null;
  }
}
