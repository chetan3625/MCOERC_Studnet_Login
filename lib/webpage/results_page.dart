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
                final isPublished = teamController.isResultPublished.value;

                if (!isPublished) {
                  return const Card(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Column(
                        children: [
                          Icon(Icons.timer, size: 48, color: Colors.orange),
                          SizedBox(height: 16),
                          Text(
                            'Results will be announced soon!',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 8),
                          Text('Evaluation is in progress. Please check back later.'),
                        ],
                      ),
                    ),
                  );
                }

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
                          _scoreRow('Idea', eval['scores']?['idea'] ?? 0),
                          _scoreRow('Speech', eval['scores']?['speech'] ?? 0),
                          _scoreRow('Problem Solution', eval['scores']?['problemSolution'] ?? 0),
                          _scoreRow('Presentation', eval['scores']?['presentation'] ?? 0),
                          _scoreRow('Future Scope', eval['scores']?['futureScope'] ?? 0),
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

  Widget _scoreRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 16)),
          Text('$value', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
