import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'webpage/landing_page.dart';
import 'webpage/registration_page.dart';
import 'webpage/success_page.dart';
import 'webpage/results_page.dart';
import 'admin/login_screen.dart';
import 'admin/dashboard_screen.dart';
import 'admin/search_result_screen.dart';
import 'admin/evaluation_screen.dart';
import 'admin/top_teams_screen.dart';
import 'admin/admin_management_screen.dart';
import 'admin/team_details_screen.dart';
import 'views/splash_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'controllers/auth_controller.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize AuthController globally
  Get.put(AuthController(), permanent: true);
  
  bool isLogged = false;
  if (!kIsWeb) {
    final prefs = await SharedPreferences.getInstance();
    isLogged = prefs.getBool('isLoggedIn') ?? false;
  }
  runApp(HackathonApp(isLogged: isLogged));
}

class HackathonApp extends StatelessWidget {
  final bool isLogged;
  const HackathonApp({Key? key, this.isLogged = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Project Competition System',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        useMaterial3: true,
      ),
      initialRoute: '/splash',
      getPages: [
        GetPage(name: '/splash', page: () => const SplashScreen()),
        // Web routes
        GetPage(name: '/', page: () => const LandingPage()),
        GetPage(name: '/register', page: () => const RegistrationPage()),
        GetPage(name: '/success', page: () => const SuccessPage()),
        GetPage(name: '/results', page: () => const ResultsPage()),
        
        // Admin routes
        GetPage(name: '/admin-login', page: () => const LoginScreen()),
        GetPage(name: '/dashboard', page: () => const DashboardScreen()),
        GetPage(name: '/search-result', page: () => const SearchResultScreen()),
        GetPage(name: '/evaluation', page: () => const EvaluationScreen()),
        GetPage(name: '/top-teams', page: () => const TopTeamsScreen()),
        GetPage(name: '/admin-management', page: () => const AdminManagementScreen()),
        GetPage(name: '/team-details', page: () => const TeamDetailsScreen()),
      ],
      debugShowCheckedModeBanner: false,
    );
  }
}
