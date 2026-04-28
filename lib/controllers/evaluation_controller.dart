import 'package:get/get.dart';
import '../core/api_service.dart';
import '../models/evaluation_model.dart';
import 'package:dio/dio.dart';

class EvaluationController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  
  final idea = 0.0.obs;
  final speech = 0.0.obs;
  final problemSolution = 0.0.obs;
  final presentation = 0.0.obs;
  final futureScope = 0.0.obs;
  
  final topTeams = [].obs;

  double get totalScore => idea.value + speech.value + problemSolution.value + presentation.value + futureScope.value;

  void resetScores() {
    idea.value = 0;
    speech.value = 0;
    problemSolution.value = 0;
    presentation.value = 0;
    futureScope.value = 0;
  }

  Future<void> submitEvaluation(String teamId) async {
    try {
      isLoading.value = true;
      
      Scores scores = Scores(
        idea: idea.value,
        speech: speech.value,
        problemSolution: problemSolution.value,
        presentation: presentation.value,
        futureScope: futureScope.value
      );

      Evaluation eval = Evaluation(teamId: teamId, scores: scores, totalScore: totalScore);

      Response response = await _apiService.post('/evaluate-team', eval.toJson());
      if (response.statusCode == 200) {
        Get.snackbar('Success', 'Evaluation submitted successfully');
        Get.offAllNamed('/dashboard');
        resetScores();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Evaluation failed', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchTopTeams() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/top-teams');
      if (response.statusCode == 200) {
        topTeams.value = response.data['topTeams'];
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to fetch top teams');
    } finally {
      isLoading.value = false;
    }
  }
}
