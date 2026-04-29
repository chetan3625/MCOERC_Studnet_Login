import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../views/custom_button.dart';

class SearchResultScreen extends StatelessWidget {
  const SearchResultScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final TeamController teamController = Get.find<TeamController>();
    final team = teamController.searchResult.value!;
    final eval = teamController.searchEvaluation.value;

    return Scaffold(
      appBar: AppBar(title: const Text('Team Details')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Team ID: ${team.teamId}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Name: ${team.teamName}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('Project: ${team.projectTitle}', style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            const Text('Members:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ...team.members.map((m) => Text('- ${m.name} (${m.phone})')).toList(),
            const Divider(height: 48),
            if (eval != null) ...[
              const Text('Already Evaluated:', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              Text('Total Score: ${eval['totalScore']} / 50'),
              const SizedBox(height: 24),
            ],
            const Spacer(),
            CustomButton(
              text: eval != null ? 'Re-Evaluate' : 'Evaluate',
              onPressed: () => Get.toNamed('/evaluation'),
            )
          ],
        ),
      ),
    );
  }
}
