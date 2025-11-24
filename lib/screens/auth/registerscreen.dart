import 'package:electrical_store_mobile_app/helpers/constants.dart';
import 'package:electrical_store_mobile_app/helpers/database_helper.dart';
import 'package:electrical_store_mobile_app/logic/controller/user_controller.dart';
import 'package:electrical_store_mobile_app/logic/models/auth/auth.dart';
import 'package:electrical_store_mobile_app/screens/auth/loginscreen.dart';
import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

void register() async {
  if (_formKey.currentState!.validate()) {
    User user = User(
      name: nameController.text,
      email: emailController.text,
      password: passwordController.text,
    );
    UserController controller = UserController();

    bool success = await controller.register(user);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("تم إنشاء الحساب بنجاح"),backgroundColor: Colors.green),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => LoginScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        
        SnackBar(content: Text("البريد الإلكتروني موجود مسبقاً"),backgroundColor: Colors.red,),
      );
    }
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
            backgroundColor: kBackgroundColor,

      appBar: AppBar(title: Text("تسجيل حساب جديد",style: TextStyle(color: kBackgroundColor),),backgroundColor: kPrimaryColor,),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // الاسم
              TextFormField(
                controller: nameController,
                decoration: InputDecoration(labelText: "الاسم الكامل"),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء إدخال الاسم";
                  }
                  if (value.length < 3) {
                    return "الاسم يجب أن يكون 3 أحرف على الأقل";
                  }
                  return null;
                },
              ),
             const SizedBox(height: 20),

              // الإيميل
              TextFormField(
                controller: emailController,
                decoration: InputDecoration(labelText: "البريد الإلكتروني"),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "الرجاء إدخال البريد الإلكتروني";
                  }
                  if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                    return "بريد إلكتروني غير صالح";
                  }
                  return null;
                },
              ),
             const SizedBox(height: 20),

              // كلمة السر
              TextFormField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(labelText: "كلمة المرور"),
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

              ElevatedButton(onPressed: register, child: Text("تسجيل الحساب",style: TextStyle(color: kPrimaryColor),) ),
            ],
          ),
        ),
      ),
    );
  }
}
