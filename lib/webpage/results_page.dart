import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../views/custom_button.dart';
import '../views/custom_text_field.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({Key? key}) : super(key: key);

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  final TeamController teamController = Get.put(TeamController());
  final TextEditingController searchCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Check Results'), centerTitle: true),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 600),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      label: 'Enter Team ID',
                      controller: searchCtrl,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Obx(() => ElevatedButton(
                    onPressed: teamController.isLoading.value 
                      ? null 
                      : () {
                          if (searchCtrl.text.isNotEmpty) {
                            teamController.searchTeam(searchCtrl.text);
                          }
                        },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                    ),
                    child: teamController.isLoading.value 
                      ? const CircularProgressIndicator()
                      : const Text('Check Result'),
                  )),
                ],
              ),
              const SizedBox(height: 32),
              Obx(() {
                if (teamController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final team = teamController.searchResult.value;
                if (team == null) {
                  return const Text('Enter a valid Team ID to search');
                }

                final eval = teamController.searchEvaluation.value;

                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Team: ${team.teamName}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text('Project: ${team.projectTitle}', style: const TextStyle(fontSize: 18)),
                        const Divider(height: 32),
                        if (eval == null)
                          const Text('Evaluation pending.', style: TextStyle(fontSize: 18, color: Colors.orange))
                        else ...[
                          const Text('Evaluation Scores:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          Text('Idea: ${eval['scores']['idea']}'),
                          Text('Speech: ${eval['scores']['speech']}'),
                          Text('Problem Solution: ${eval['scores']['problemSolution']}'),
                          Text('Presentation: ${eval['scores']['presentation']}'),
                          Text('Future Scope: ${eval['scores']['futureScope']}'),
                          const Divider(height: 32),
                          Text(
                            'Total Score: ${eval['totalScore']}',
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.green),
                          ),
                        ]
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
