import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/custom_button.dart';
import '../views/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Login'), centerTitle: true),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.admin_panel_settings, size: 100, color: Colors.blueGrey),
              const SizedBox(height: 32),
              CustomTextField(
                label: 'Username',
                controller: userCtrl,
              ),
              CustomTextField(
                label: 'Password',
                controller: passCtrl,
                isPassword: true,
              ),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Login',
                onPressed: () {
                  authController.login(userCtrl.text, passCtrl.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
