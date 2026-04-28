import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthController extends GetxController {
  final isLoggedIn = false.obs;

  @override
  void onInit() {
    super.onInit();
    checkLoginStatus();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    isLoggedIn.value = prefs.getBool('isLoggedIn') ?? false;
  }

  Future<void> login(String username, String password) async {
    if (username == 'admin' && password == 'Pass@123') {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isLoggedIn', true);
      isLoggedIn.value = true;
      Get.offAllNamed('/dashboard');
    } else {
      Get.snackbar('Error', 'Invalid username or password', snackPosition: SnackPosition.BOTTOM);
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('isLoggedIn');
    isLoggedIn.value = false;
    Get.offAllNamed('/admin-login');
  }
}
