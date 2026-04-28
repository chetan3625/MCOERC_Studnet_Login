import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/evaluation_controller.dart';
import '../controllers/team_controller.dart';
import '../views/custom_button.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final EvaluationController evalController = Get.put(EvaluationController());
  final TeamController teamController = Get.find<TeamController>();

  @override
  void initState() {
    super.initState();
    evalController.resetScores();
    
    // Pre-fill if already evaluated
    final eval = teamController.searchEvaluation.value;
    if (eval != null) {
      evalController.idea.value = (eval['scores']['idea'] as num).toDouble();
      evalController.speech.value = (eval['scores']['speech'] as num).toDouble();
      evalController.problemSolution.value = (eval['scores']['problemSolution'] as num).toDouble();
      evalController.presentation.value = (eval['scores']['presentation'] as num).toDouble();
      evalController.futureScope.value = (eval['scores']['futureScope'] as num).toDouble();
    }
  }

  Widget _buildSlider(String label, RxDouble value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Obx(() => Text('$label: ${value.value.toInt()}', style: const TextStyle(fontSize: 16))),
        Obx(() => Slider(
          value: value.value,
          min: 0,
          max: 10,
          divisions: 10,
          label: value.value.toInt().toString(),
          onChanged: (val) {
            value.value = val;
          },
        )),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final teamId = teamController.searchResult.value!.teamId!;

    return Scaffold(
      appBar: AppBar(title: const Text('Evaluate Team')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            Text('Team: ${teamController.searchResult.value!.teamName}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            _buildSlider('Idea', evalController.idea),
            _buildSlider('Speech', evalController.speech),
            _buildSlider('Problem Solution', evalController.problemSolution),
            _buildSlider('Presentation', evalController.presentation),
            _buildSlider('Future Scope', evalController.futureScope),
            const Divider(height: 48),
            Obx(() => Text(
              'Total Score: ${evalController.totalScore.toInt()}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blueAccent),
            )),
            const SizedBox(height: 48),
            Obx(() => CustomButton(
              text: 'Submit Evaluation',
              onPressed: () => evalController.submitEvaluation(teamId),
              isLoading: evalController.isLoading.value,
            ))
          ],
        ),
      ),
    );
  }
}
