import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'dart:async';
import '../core/api_service.dart';
import 'package:dio/dio.dart';

class SettingsController extends GetxController {
  final ApiService _apiService = ApiService();
  final isResultPublished = false.obs;
  final isLoading = false.obs;

  var totalCertificates = 0.obs;
  var distributedCertificates = 0.obs;
  var isDistributing = false.obs;
  Timer? _progressTimer;

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
      final response = await _apiService.post('/distribute-certificates', {});
      if (response.statusCode == 200) {
        totalCertificates.value = response.data['totalMembers'] ?? 0;
        distributedCertificates.value = 0;
        isDistributing.value = true;
        _showProgressBottomSheet();
        _startProgressPolling();
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to distribute certificates', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  void _showProgressBottomSheet() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Obx(() {
          double progress = totalCertificates.value == 0 
              ? 0.0 
              : distributedCertificates.value / totalCertificates.value;
              
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Distributing Certificates',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 32),
              SizedBox(
                height: 140,
                width: 140,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    CircularProgressIndicator(
                      value: progress,
                      strokeWidth: 12,
                      backgroundColor: Colors.grey[200],
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                    ),
                    Center(
                      child: Text(
                        '${(progress * 100).toInt()}%',
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.blueAccent),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      const Text('Total', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text('${totalCertificates.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Sent', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text('${distributedCertificates.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Remaining', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text('${totalCertificates.value - distributedCertificates.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.orange)),
                    ],
                  ),
                ],
              ),
              if (distributedCertificates.value >= totalCertificates.value && totalCertificates.value > 0)
                const Padding(
                  padding: EdgeInsets.only(top: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle, color: Colors.green, size: 28),
                      SizedBox(width: 8),
                      Text(
                        'Distribution Complete!',
                        style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 16),
            ],
          );
        }),
      ),
      isDismissible: false,
      enableDrag: false,
    );
  }

  void _startProgressPolling() {
    _progressTimer?.cancel();
    _progressTimer = Timer.periodic(const Duration(seconds: 2), (timer) async {
      try {
        final response = await _apiService.get('/distribution-progress');
        if (response.statusCode == 200) {
          distributedCertificates.value = response.data['processedCount'] ?? 0;
          
          if (distributedCertificates.value >= totalCertificates.value && totalCertificates.value > 0) {
            timer.cancel();
            isDistributing.value = false;
            Future.delayed(const Duration(seconds: 3), () {
              if (Get.isBottomSheetOpen == true) {
                Get.back();
              }
            });
          }
        }
      } catch (e) {
        // Ignore polling errors to keep trying
      }
    });
  }
}
