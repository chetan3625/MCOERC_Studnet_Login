import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../views/custom_button.dart';

class LandingPage extends StatelessWidget {
  const LandingPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset('assets/logo.png', width: 100, height: 100),
              const SizedBox(height: 24),
              const Text(
                'Project Competition Registration',
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Register Team',
                onPressed: () => Get.toNamed('/register'),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Check Results',
                onPressed: () => Get.toNamed('/results'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
