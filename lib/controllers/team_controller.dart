import 'package:get/get.dart';
import '../core/api_service.dart';
import '../models/team_model.dart';
import 'package:dio/dio.dart';

class TeamController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  
  // Registration data
  final registeredTeamId = ''.obs;

  // Search data
  final searchResult = Rxn<Team>();
  final searchEvaluation = Rxn<Map<String, dynamic>>();

  // All Teams
  final allTeams = <Map<String, dynamic>>[].obs;

  Future<void> registerTeam(Team team) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.post('/register-team', team.toJson());
      if (response.statusCode == 201) {
        registeredTeamId.value = response.data['team']['teamId'];
        Get.offAllNamed('/success');
      }
    } on DioException catch (e) {
      String message = e.response?.data['error'] ?? 'Registration failed';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> searchTeam(String teamId) async {
    try {
      isLoading.value = true;
      searchResult.value = null;
      searchEvaluation.value = null;
      
      Response response = await _apiService.get('/team/$teamId');
      if (response.statusCode == 200) {
        searchResult.value = Team.fromJson(response.data['team']);
        if (response.data['evaluation'] != null) {
          searchEvaluation.value = response.data['evaluation'];
        }
      }
    } on DioException catch (e) {
      String message = e.response?.data['error'] ?? 'Team not found';
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAllTeams() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/all-teams');
      if (response.statusCode == 200) {
        allTeams.value = List<Map<String, dynamic>>.from(response.data['teams']);
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.message ?? 'Failed to fetch teams', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
