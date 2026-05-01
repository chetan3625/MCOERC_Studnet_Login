import 'package:flutter/material.dart';
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

  Future<void> distributeCertificates() async {
    try {
      isLoading.value = true;
      Get.snackbar('Processing', 'Generating and sending certificates...', 
        showProgressIndicator: true, 
        duration: const Duration(seconds: 2),
        snackPosition: SnackPosition.BOTTOM
      );
      
      final response = await _apiService.post('/distribute-certificates', {});
      
      if (response.statusCode == 200) {
        Get.snackbar(
          'Success', 
          'Certificates distributed: ${response.data['sent']} sent, ${response.data['errors']} failed.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to distribute certificates', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
