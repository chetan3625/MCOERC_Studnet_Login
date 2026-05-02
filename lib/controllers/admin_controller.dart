import 'package:flutter/material.dart';
import 'package:get/get.dart' hide Response;
import 'dart:async';
import '../core/api_service.dart';
import '../models/admin_model.dart';
import '../models/system_log_model.dart';
import 'package:dio/dio.dart';
import 'auth_controller.dart';

class AdminController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  final admins = <AdminModel>[].obs;
  final systemLogs = <SystemLogModel>[].obs;

  var totalCertificates = 0.obs;
  var distributedCertificates = 0.obs;
  var sentCertificates = 0.obs;
  var failedCertificates = 0.obs;
  var isDistributing = false.obs;
  Timer? _progressTimer;

  @override
  void onInit() {
    super.onInit();
    fetchAdmins();
  }

  Future<void> fetchAdmins() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/admins');
      if (response.statusCode == 200) {
        admins.value = (response.data as List)
            .map((e) => AdminModel.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      final authController = Get.find<AuthController>();
      if (authController.adminRole.value == 'super_admin') {
        // Fallback to mock data for demo/offline purposes
        if (admins.isEmpty) {
          admins.value = [
            AdminModel(id: '1', username: 'superadmin', name: 'Super Admin', role: 'super_admin'),
            AdminModel(id: '2', username: 'admin1', name: 'Demo Admin 1', role: 'admin'),
            AdminModel(id: '3', username: 'admin2', name: 'Demo Admin 2', role: 'admin'),
          ];
          Get.snackbar('Offline Mode', 'Server unreachable. Using demo data.', 
            snackPosition: SnackPosition.BOTTOM, 
            backgroundColor: Colors.orange.withOpacity(0.8),
            colorText: Colors.white);
        }
      } else {
        Get.snackbar('Error', e.message ?? 'Failed to fetch admins');
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createAdmin(AdminModel admin) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.post('/admins', admin.toJson());
      if (response.statusCode == 201) {
        Get.back(); // Close dialog
        fetchAdmins();
        Get.snackbar('Success', 'Admin created successfully');
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to create admin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateAdmin(String id, AdminModel admin) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.put('/admins/$id', admin.toJson());
      if (response.statusCode == 200) {
        Get.back(); // Close dialog
        fetchAdmins();
        Get.snackbar('Success', 'Admin updated successfully');
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to update admin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteAdmin(String id) async {
    try {
      isLoading.value = true;
      Response response = await _apiService.delete('/admins/$id');
      if (response.statusCode == 200) {
        fetchAdmins();
        Get.snackbar('Success', 'Admin deleted successfully');
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to delete admin');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> distributeCertificates() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.post('/distribute-certificates', {});
      if (response.statusCode == 200) {
        totalCertificates.value = response.data['totalMembers'] ?? 0;
        distributedCertificates.value = 0;
        isDistributing.value = true;
        _showProgressBottomSheet();
        _startProgressPolling();
      }
    } on DioException catch (e) {
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to distribute certificates');
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
                      Text('${sentCertificates.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
                    ],
                  ),
                  Column(
                    children: [
                      const Text('Failed', style: TextStyle(color: Colors.grey, fontSize: 14)),
                      Text('${failedCertificates.value}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
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
        Response response = await _apiService.get('/distribution-progress');
        if (response.statusCode == 200) {
          distributedCertificates.value = response.data['processedCount'] ?? 0;
          sentCertificates.value = response.data['sentCount'] ?? 0;
          failedCertificates.value = response.data['failedCount'] ?? 0;
          
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

  Future<void> fetchSystemLogs() async {
    try {
      isLoading.value = true;
      Response response = await _apiService.get('/system-logs');
      if (response.statusCode == 200) {
        systemLogs.value = (response.data['logs'] as List)
            .map((e) => SystemLogModel.fromJson(e))
            .toList();
      }
    } on DioException catch (e) {
      final authController = Get.find<AuthController>();
      if (authController.adminRole.value == 'super_admin' && systemLogs.isEmpty) {
         // Mock logs for demo
         systemLogs.value = [
            SystemLogModel(
              timestamp: DateTime.now(),
              level: 'INFO',
              module: 'AUTH',
              message: 'Admin superadmin logged in',
              ip: '127.0.0.1'
            ),
            SystemLogModel(
              timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
              level: 'INFO',
              module: 'SYSTEM',
              message: 'Database connected successfully',
            ),
         ];
      } else {
        Get.snackbar('Error', e.message ?? 'Failed to fetch system logs');
      }
    } finally {
      isLoading.value = false;
    }
  }
}
