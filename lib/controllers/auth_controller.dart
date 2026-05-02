import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_service.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final supervisorId = ''.obs;
  final adminRole = 'admin'.obs;
  final token = ''.obs;
  final ApiService _apiService = ApiService();

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    supervisorId.value = prefs.getString('supervisorId') ?? '';
    adminRole.value = prefs.getString('adminRole') ?? 'admin';
    token.value = prefs.getString('token') ?? '';
  }

  Future<void> loginAsSuperAdmin() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setBool('isLoggedIn', true);
    await prefs.setString('supervisorId', 'superadmin');
    await prefs.setString('adminRole', 'super_admin');
    await prefs.setString('token', 'static-superadmin-token');

    isLoggedIn.value = true;
    supervisorId.value = 'superadmin';
    adminRole.value = 'super_admin';
    token.value = 'static-superadmin-token';

    Get.offAllNamed('/dashboard');
  }

  Future<void> login(String username, String password) async {

    try {
      final response = await _apiService.post('/admin/login', {
        'username': username,
        'password': password,
      });

      if (response.statusCode == 200) {
        final data = response.data;
        final prefs = await SharedPreferences.getInstance();
        
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('supervisorId', data['admin']['username']);
        await prefs.setString('adminRole', data['admin']['role']);
        await prefs.setString('token', data['token']);

        isLoggedIn.value = true;
        supervisorId.value = data['admin']['username'];
        adminRole.value = data['admin']['role'];
        token.value = data['token'];

        Get.offAllNamed('/dashboard');
      }
    } catch (error) {
      Get.snackbar('Error', 'Invalid username or password', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    isLoggedIn.value = false;
    supervisorId.value = '';
    adminRole.value = 'admin';
    token.value = '';
    Get.offAllNamed('/admin-login');
  }
}

