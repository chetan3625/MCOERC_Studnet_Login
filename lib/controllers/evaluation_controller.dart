import 'package:get/get.dart' hide Response;
import '../core/api_service.dart';
import '../models/evaluation_model.dart';
import 'auth_controller.dart';
import 'package:dio/dio.dart';

class EvaluationController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  
  final originality = 0.0.obs;
  final technical = 0.0.obs;
  final presentation = 0.0.obs;
  final impact = 0.0.obs;
  
  final topTeams = [].obs;
  final message = ''.obs;

  double get totalScore => originality.value + technical.value + presentation.value + impact.value;

  void resetScores() {
    originality.value = 0;
    technical.value = 0;
    presentation.value = 0;
    impact.value = 0;
  }

  Future<void> submitEvaluation(String teamId) async {
    try {
      isLoading.value = true;
      final AuthController authController = Get.find<AuthController>();
      
      Scores scores = Scores(
        originality: originality.value,
        technical: technical.value,
        presentation: presentation.value,
        impact: impact.value,
      );

      Map<String, dynamic> payload = {
        'teamId': teamId,
        'scores': scores.toJson(),
        'supervisorId': authController.supervisorId.value,
      };

      Response response = await _apiService.post('/evaluate-team', payload);
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
        message.value = response.data['message'] ?? '';
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to fetch top teams');
    } finally {
      isLoading.value = false;
    }
  }
}
