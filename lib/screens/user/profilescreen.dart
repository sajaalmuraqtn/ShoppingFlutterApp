import 'package:electrical_store_mobile_app/helpers/constants.dart';
 import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:electrical_store_mobile_app/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? userId;
  String? userName;
  String? userEmail;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  Future<void> loadUserData() async {
    userId = await UserSession.getUserId();
    userName = await UserSession.getUserName();
    userEmail = await UserSession.getUserEmail();

    setState(() {
      isLoading = false;
    });
  }

  void logout() async {
     await UserSession.logout();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
     backgroundColor: kBackgroundColor,

      appBar: AppBar(
        title: Text("الملف الشخصي", style: TextStyle(color: kBackgroundColor)),
        backgroundColor: kPrimaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator(color: kPrimaryColor))
          : Padding(
              padding: const EdgeInsets.all(40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("الاسم: ${userName ?? 'غير متوفر'}",
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 10),
                  Text("البريد الإلكتروني: ${userEmail ?? 'غير متوفر'}",
                      style: TextStyle(fontSize: 20)),
                  SizedBox(height: 50),
                  ElevatedButton(
                    onPressed: logout,
                      style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                 ),
                    child: Text("تسجيل خروج",
                         style: TextStyle(color: kBackgroundColor, fontSize: 16)),
                  ),
                ],
              ),
            ),
    );
  }
}
