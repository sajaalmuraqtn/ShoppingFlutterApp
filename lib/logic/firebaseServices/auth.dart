import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> registerUser({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      // التحقق من وجود المستخدم مسبقاً عبر Firebase Auth
      final methods = await _auth.fetchSignInMethodsForEmail(email);
      if (methods.isNotEmpty) {
        // البريد الإلكتروني موجود مسبقاً
        print("Email already in use");
        return null;
      }

      // إنشاء الحساب
      UserCredential userCred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCred.user!.uid;

      // إضافة بيانات المستخدم في Firestore
      await _firestore.collection("users").doc(uid).set({
        "id": uid,
        "name": name,
        "email": email,
      });
      await _firestore.collection("likes").doc(uid).set({
        "userId": uid,
        "products": [],
      });
      return {"id": uid, "name": name, "email": email};
    } catch (e) {
      return null;
    }
  }

  // تسجيل الدخول
  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      UserCredential userCred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCred.user!.uid;

      // جلب بيانات المستخدم من Firestore
      DocumentSnapshot snap = await _firestore
          .collection("users")
          .doc(uid)
          .get();

      return snap.data() as Map<String, dynamic>;
    } catch (e) {
      return null;
    }
  }
}
