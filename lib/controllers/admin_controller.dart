import 'package:get/get.dart' hide Response;
import '../core/api_service.dart';
import '../models/admin_model.dart';
import 'package:dio/dio.dart';

class AdminController extends GetxController {
  final ApiService _apiService = ApiService();
  final isLoading = false.obs;
  final admins = <AdminModel>[].obs;

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
      Get.snackbar('Error', e.response?.data['error'] ?? 'Failed to fetch admins');
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
}
