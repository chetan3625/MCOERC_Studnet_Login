import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/evaluation_controller.dart';
import '../controllers/team_controller.dart';
import '../controllers/auth_controller.dart';
import '../models/team_model.dart';
import '../views/custom_button.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final EvaluationController evalController = Get.put(EvaluationController());
  final TeamController teamController = Get.find<TeamController>();
  final AuthController authController = Get.find<AuthController>();

  String teamName = "";
  String teamId = "";

  @override
  void initState() {
    super.initState();
    evalController.resetScores();
    
    // Get team data from arguments or controllers
    Map<String, dynamic>? argTeam = Get.arguments;
    
    if (argTeam != null) {
      teamName = argTeam['teamName'] ?? "";
      teamId = argTeam['teamId'] ?? "";
      
      final eval = argTeam['evaluation'];
      if (eval != null && eval['supervisorEvaluations'] != null) {
        final myEval = eval['supervisorEvaluations'][authController.supervisorId.value];
        if (myEval != null) {
          _prefillScores(myEval);
        }
      }
    } else if (teamController.searchResult.value != null) {
      teamName = teamController.searchResult.value!.teamName!;
      teamId = teamController.searchResult.value!.teamId!;
      
      final eval = teamController.searchEvaluation.value;
      if (eval != null && eval['supervisorEvaluations'] != null) {
        final myEval = eval['supervisorEvaluations'][authController.supervisorId.value];
        if (myEval != null) {
          _prefillScores(myEval);
        }
      }
    }
  }

  void _prefillScores(Map<String, dynamic> myEval) {
    evalController.idea.value = (myEval['idea'] as num).toDouble();
    evalController.speech.value = (myEval['speech'] as num).toDouble();
    evalController.problemSolution.value = (myEval['problemSolution'] as num).toDouble();
    evalController.presentation.value = (myEval['presentation'] as num).toDouble();
    evalController.futureScope.value = (myEval['futureScope'] as num).toDouble();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text('Evaluation Form', style: TextStyle(color: Colors.white)),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: teamId.isEmpty 
      ? const Center(child: Text('No team selected'))
      : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade50, Colors.white],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.blue.shade100),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 5)),
                ],
              ),
              child: Column(
                children: [
                  Text(teamName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF1e3c72))),
                  const SizedBox(height: 8),
                  Text('ID: $teamId', style: TextStyle(fontSize: 14, color: Colors.blue.shade700, fontWeight: FontWeight.w600)),
                  const SizedBox(height: 4),
                  Text('Judging as: ${authController.supervisorId.value}', style: const TextStyle(fontSize: 14, color: Colors.grey)),
                ],
              ),
            ),
            const SizedBox(height: 40),
            _buildSlider('Idea & Innovation', evalController.idea, Colors.blue),
            _buildSlider('Speech & Communication', evalController.speech, Colors.green),
            _buildSlider('Problem Solution', evalController.problemSolution, Colors.orange),
            _buildSlider('Presentation Skills', evalController.presentation, Colors.purple),
            _buildSlider('Future Scope', evalController.futureScope, Colors.red),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1e3c72),
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: const Color(0xFF1e3c72).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'TOTAL POINTS: ',
                    style: TextStyle(fontSize: 16, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                  Obx(() => Text(
                    '${evalController.totalScore.toInt()}',
                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  )),
                  const Text(
                    ' / 100',
                    style: TextStyle(fontSize: 18, color: Colors.white70, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 48),
            Obx(() => SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                onPressed: evalController.isLoading.value ? null : () => evalController.submitEvaluation(teamId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2a5298),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  elevation: 5,
                ),
                child: evalController.isLoading.value 
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Evaluation', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ),
            )),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider(String label, RxDouble value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87)),
              Obx(() => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text('${value.value.toInt()}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
              )),
            ],
          ),
          const SizedBox(height: 8),
          Obx(() => Slider(
            value: value.value,
            min: 0,
            max: 20,
            divisions: 20,
            activeColor: color,
            inactiveColor: color.withOpacity(0.1),
            onChanged: (val) => value.value = val,
          )),
        ],
      ),
    );
  }
}
