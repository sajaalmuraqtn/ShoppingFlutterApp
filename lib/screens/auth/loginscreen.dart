import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/logic/controller/user_controller.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/user_session.dart';
import 'package:electrical_store_mobile_app/screens/auth/registerscreen.dart';
import 'package:electrical_store_mobile_app/screens/userscreens/homeScreen.dart';
import 'package:electrical_store_mobile_app/screens/adminproductscreens/productsview.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    UserController controller = UserController();
    final user = await controller.login(
      _emailController.text.trim(),
      _passwordController.text.trim(),
    );

    setState(() => _isLoading = false);

    if (user != null) {
      UserSession.saveUser(
        userId: user["id"],
        email: user["email"],
        name: user["name"],
      );

      if (user != null) {
        await UserSession.saveUser(
          userId: user["id"],
          email: user["email"],
          name: user["name"],
        );

        if (user['email'] == "admin@gmail.com") {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const AdminProductsScreen()),
            (route) => false,
          );
        } else {
          // تمرير true عند العودة للـ HomeScreen لتحديث الحالة
          Navigator.pop(context, true);
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("فشل تسجيل الدخول")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text(
          "تسجيل الدخول",
          style: TextStyle(color: kBackgroundColor),
        ),
        backgroundColor: kPrimaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),

                 TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: "البريد الإلكتروني",
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال البريد الإلكتروني";
                    }
                    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return "صيغة البريد الإلكتروني غير صحيحة";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                 TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: "كلمة المرور"),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "الرجاء إدخال كلمة المرور";
                    }
                    if (value.length < 6) {
                      return "كلمة المرور يجب أن تكون 6 أحرف على الأقل";
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 50),

                _isLoading
                    ? const CircularProgressIndicator(color:kPrimaryColor)
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text(
                          "تسجيل الدخول",
                          style: TextStyle(color: kPrimaryColor),
                        ),
                      ),

                const SizedBox(height: 20),

                 Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("ليس لديك حساب؟"),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => RegisterScreen()),
                        );
                      },
                      child: const Text(
                        "إنشاء حساب جديد",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("هل تريد الإستمرار كضيف؟"),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => HomeScreen()),
                        );
                      },

                      child: const Text(
                        "تصفح المنتجات",

                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
