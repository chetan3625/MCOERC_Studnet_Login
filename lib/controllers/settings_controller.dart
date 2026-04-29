import 'package:get/get.dart';
import '../core/api_service.dart';

class SettingsController extends GetxController {
  final ApiService _apiService = ApiService();
  final isResultPublished = false.obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  Future<void> fetchSettings() async {
    try {
      isLoading.value = true;
      final response = await _apiService.get('/settings');
      if (response.statusCode == 200) {
        isResultPublished.value = response.data['isResultPublished'] ?? false;
      }
    } catch (e) {
      print('Error fetching settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> toggleResultPublish(bool value) async {
    try {
      isLoading.value = true;
      final response = await _apiService.post('/settings', {
        'isResultPublished': value,
      });
      if (response.statusCode == 200) {
        isResultPublished.value = response.data['settings']['isResultPublished'];
        Get.snackbar(
          'Success', 
          value ? 'Results published successfully!' : 'Results unpublished.',
          snackPosition: SnackPosition.BOTTOM
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to update settings', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
