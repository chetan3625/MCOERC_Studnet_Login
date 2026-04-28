import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;
  final supervisorId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
    supervisorId.value = prefs.getString('supervisorId') ?? '';
  }

  Future<void> login(String username, String password) async {
    final allowedAdmins = ['admin1', 'admin2', 'admin3', 'admin'];
    if (allowedAdmins.contains(username) && password == 'Pass@123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      await prefs.setString('supervisorId', username);
      isLoggedIn.value = true;
      supervisorId.value = username;
      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar('Error', 'Invalid username or password', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    await prefs.remove('supervisorId');
    isLoggedIn.value = false;
    supervisorId.value = '';
    Get.offAllNamed('/admin-login');
  }
}
