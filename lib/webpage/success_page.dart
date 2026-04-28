import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../views/custom_button.dart';

class SuccessPage extends StatelessWidget {
  const SuccessPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TeamController teamController = Get.find<TeamController>();

    return Scaffold(
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 500),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              const Text(
                'Registration Successful!',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('Your Team ID is:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              Obx(() => SelectableText(
                teamController.registeredTeamId.value,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.blueAccent),
              )),
              const SizedBox(height: 48),
              CustomButton(
                text: 'Go to Home',
                onPressed: () => Get.offAllNamed('/'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
