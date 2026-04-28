import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../controllers/team_controller.dart';
import '../models/team_model.dart';
import '../views/custom_button.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthController authController = Get.find<AuthController>();
  final TeamController teamController = Get.put(TeamController());

  @override
  void initState() {
    super.initState();
    teamController.fetchAllTeams();
  }

  void openTeamDetails(Map<String, dynamic> teamData) {
    teamController.searchResult.value = Team.fromJson(teamData);
    if (teamData['evaluation'] != null) {
      teamController.searchEvaluation.value = teamData['evaluation'];
    } else {
      teamController.searchEvaluation.value = null;
    }
    Get.toNamed('/search-result');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supervisor Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: authController.logout,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            CustomButton(
              text: 'View Top Teams',
              onPressed: () => Get.toNamed('/top-teams'),
            ),
            const SizedBox(height: 16),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'All Registered Teams',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(() {
                if (teamController.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (teamController.allTeams.isEmpty) {
                  return const Center(child: Text('No teams found.'));
                }

                return ListView.builder(
                  itemCount: teamController.allTeams.length,
                  itemBuilder: (context, index) {
                    final teamData = teamController.allTeams[index];
                    final teamName = teamData['teamName'];
                    final teamId = teamData['teamId'];
                    final eval = teamData['evaluation'];
                    final hasEvaluated = eval != null;
                    final totalScore = hasEvaluated ? eval['totalScore'] : 0;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        onTap: () => openTeamDetails(teamData),
                        title: Text(teamName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('ID: $teamId'),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              hasEvaluated ? 'Score: $totalScore' : 'Pending',
                              style: TextStyle(
                                color: hasEvaluated ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: teamController.fetchAllTeams,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
