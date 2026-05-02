import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../views/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());
  final TextEditingController userCtrl = TextEditingController();
  final TextEditingController passCtrl = TextEditingController();

  void _showPinDialog() {
    final List<TextEditingController> controllers = List.generate(4, (index) => TextEditingController());
    final List<FocusNode> focusNodes = List.generate(4, (index) => FocusNode());

    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_outline, size: 48, color: Color(0xFF1e3c72)),
              const SizedBox(height: 16),
              const Text(
                'Superadmin PIN',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF1e3c72)),
              ),
              const SizedBox(height: 8),
              const Text('Enter the 4-digit security PIN', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(4, (index) {
                  return SizedBox(
                    width: 55,
                    height: 65,
                    child: TextField(
                      controller: controllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      obscureText: true,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        counterText: '',
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade300, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: Color(0xFF1e3c72), width: 2),
                        ),
                      ),
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          if (index < 3) {
                            focusNodes[index + 1].requestFocus();
                          } else {
                            String pin = controllers.map((e) => e.text).join();
                            if (pin == '1234') {
                              Get.back();
                              authController.loginAsSuperAdmin();
                            } else {
                              Get.snackbar(
                                'Access Denied',
                                'Incorrect PIN entered',
                                snackPosition: SnackPosition.BOTTOM,
                                backgroundColor: Colors.red.withOpacity(0.8),
                                colorText: Colors.white,
                                margin: const EdgeInsets.all(16),
                                borderRadius: 12,
                              );
                              for (var controller in controllers) {
                                controller.clear();
                              }
                              focusNodes[0].requestFocus();
                            }
                          }
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }
                      },
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),
              TextButton(
                onPressed: () => Get.back(),
                style: TextButton.styleFrom(foregroundColor: Colors.grey),
                child: const Text('Cancel', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset('assets/logo.png', height: 100, errorBuilder: (c, e, s) => const Icon(Icons.admin_panel_settings, size: 80, color: Color(0xFF1e3c72))),
                  const SizedBox(height: 24),
                  const Text(
                    'Admin Portal',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1e3c72)),
                  ),
                  const SizedBox(height: 8),
                  const Text('Please login to continue', style: TextStyle(color: Colors.grey)),
                  const SizedBox(height: 32),
                  CustomTextField(
                    label: 'Username',
                    controller: userCtrl,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    label: 'Password',
                    controller: passCtrl,
                    isPassword: true,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed: () => authController.login(userCtrl.text, passCtrl.text),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1e3c72),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        elevation: 4,
                      ),
                      child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('OR', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 24),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      return SuperAdminSlider(
                        width: constraints.maxWidth,
                        onSwipeCompleted: _showPinDialog,
                      );
                    }
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SuperAdminSlider extends StatefulWidget {
  final VoidCallback onSwipeCompleted;
  final double width;
  const SuperAdminSlider({Key? key, required this.onSwipeCompleted, required this.width}) : super(key: key);

  @override
  State<SuperAdminSlider> createState() => _SuperAdminSliderState();
}

class _SuperAdminSliderState extends State<SuperAdminSlider> {
  double _dragValue = 0.0;
  bool _isCompleted = false;

  @override
  Widget build(BuildContext context) {
    double maxDrag = widget.width - 60; // 60 is the width of the circle plus margins

    return Container(
      width: widget.width,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Stack(
        children: [
          Center(
            child: Text(
              "Login as Superadmin",
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          AnimatedPositioned(
            duration: _isCompleted ? const Duration(milliseconds: 200) : Duration.zero,
            left: _dragValue,
            top: 5,
            child: GestureDetector(
              onHorizontalDragUpdate: (details) {
                if (_isCompleted) return;
                setState(() {
                  _dragValue += details.delta.dx;
                  if (_dragValue < 0) _dragValue = 0;
                  if (_dragValue > maxDrag) _dragValue = maxDrag;
                });
              },
              onHorizontalDragEnd: (details) {
                if (_dragValue > maxDrag * 0.8) {
                  setState(() {
                    _dragValue = maxDrag;
                    _isCompleted = true;
                  });
                  widget.onSwipeCompleted();
                  // Reset after a delay
                  Future.delayed(const Duration(seconds: 1), () {
                    if (mounted) {
                      setState(() {
                        _dragValue = 0;
                        _isCompleted = false;
                      });
                    }
                  });
                } else {
                  setState(() {
                    _dragValue = 0;
                  });
                }
              },
              child: Container(
                width: 50,
                height: 50,
                decoration: const BoxDecoration(
                  color: Color(0xFF1e3c72),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
                  ],
                ),
                child: const Icon(Icons.arrow_forward_ios, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
