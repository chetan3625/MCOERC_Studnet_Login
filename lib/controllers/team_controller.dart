import 'package:get/get.dart' hide Response;
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
  final isResultPublished = true.obs;

  // All Teams
  final allTeams = <Map<String, dynamic>>[].obs;
  final searchQuery = "".obs;

  Future<void> registerTeam(Team team) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.post('/register-team', team.toJson());
      if (response.statusCode == 201) {
        registeredTeamId.value = response.data['team']['teamId'];
        Get.offAllNamed('/success');
      }
    } on DioException catch (e) {
      String message = 'Registration failed';
      if (e.type == DioExceptionType.connectionError || e.response == null) {
        message = 'Connection blocked. Please allow the site in your browser (red icon in address bar) and try again.';
      } else {
        message = e.response?.data['error'] ?? 'Registration failed';
      }
      Get.snackbar('Error', message, snackPosition: SnackPosition.BOTTOM, duration: const Duration(seconds: 5));
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
        isResultPublished.value = response.data['isPublished'] ?? true;
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
      final authController = Get.find<AuthController>();
      if (authController.adminRole.value == 'super_admin' && allTeams.isEmpty) {
        // Fallback to mock data for demo
        allTeams.value = [
          {
            'teamId': 'T001',
            'teamName': 'Alpha Squad',
            'projectTitle': 'AI Health Assistant',
            'members': [{'name': 'User 1', 'email': 'u1@ex.com', 'phone': '123'}],
            'evaluation': null,
          },
          {
            'teamId': 'T002',
            'teamName': 'Beta Builders',
            'projectTitle': 'Smart Home IoT',
            'members': [{'name': 'User 2', 'email': 'u2@ex.com', 'phone': '456'}],
            'evaluation': {
              'totalScore': 45,
              'supervisorEvaluations': {
                'superadmin': {'total': 45, 'originality': 10, 'technical': 20, 'presentation': 10, 'impact': 5}
              }
            },
          },
          {
            'teamId': 'T003',
            'teamName': 'Gamma Gamers',
            'projectTitle': 'Unity 3D Game',
            'members': [{'name': 'User 3', 'email': 'u3@ex.com', 'phone': '789'}],
            'evaluation': null,
          },
        ];
        Get.snackbar('Demo Mode', 'Backend unreachable. Loading sample teams.', 
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.blue.withOpacity(0.8),
          colorText: Colors.white);
      } else {
        Get.snackbar('Error', e.message ?? 'Failed to fetch teams', snackPosition: SnackPosition.BOTTOM);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteTeam(String teamId) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.delete('/team/$teamId');
      if (response.statusCode == 200) {
        fetchAllTeams();
        Get.snackbar('Success', 'Team deleted successfully');
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to delete team');
    } finally {
      isLoading.value = false;
    }
  }
}
