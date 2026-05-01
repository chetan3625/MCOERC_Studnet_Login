import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../models/admin_model.dart';
import '../views/custom_text_field.dart';

class AdminManagementScreen extends StatelessWidget {
  const AdminManagementScreen({Key? key}) : super(key: key);

  static void showAddDialog(BuildContext context) {
    final controller = Get.find<AdminController>();
    _showAdminDialog(context, controller);
  }

  @override
  Widget build(BuildContext context) {
    final AdminController controller = Get.put(AdminController());

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Obx(() {
        if (controller.isLoading.value && controller.admins.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchAdmins,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            children: [
              // Automation Card
              Container(
                margin: const EdgeInsets.only(bottom: 24),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.auto_fix_high, color: Colors.white, size: 28),
                        SizedBox(width: 12),
                        Text(
                          'Automation Tasks',
                          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Trigger mass actions like certificate distribution to all participants via n8n.',
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () => _showDistributeConfirm(context, controller),
                        icon: const Icon(Icons.send_rounded),
                        label: const Text('Distribute Certificates'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1e3c72),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              
              const Text(
                'Registered Admins & Judges',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey),
              ),
              const SizedBox(height: 16),
              
              ...controller.admins.map((admin) {
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10, offset: const Offset(0, 4)),
                    ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                    leading: CircleAvatar(
                      backgroundColor: admin.role == 'super_admin' ? Colors.deepPurple.shade100 : Colors.blue.shade100,
                      child: Icon(
                        admin.role == 'super_admin' ? Icons.security : Icons.person,
                        color: admin.role == 'super_admin' ? Colors.deepPurple : Colors.blue,
                      ),
                    ),
                    title: Text(admin.name ?? '', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    subtitle: Text('${admin.username} • ${admin.role}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
                          onPressed: () => _showAdminDialog(context, controller, admin: admin),
                        ),
                        if (admin.username != 'superadmin')
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                            onPressed: () => _showDeleteConfirm(context, controller, admin),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        );
      }),
    );
  }

  void _showDistributeConfirm(BuildContext context, AdminController controller) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Confirm Distribution'),
        content: const Text(
          'This will trigger the n8n automation to generate and email certificates to ALL registered participants. Continue?'
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.distributeCertificates();
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
            child: const Text('Distribute Now'),
          ),
        ],
      ),
    );
  }

  static void _showAdminDialog(BuildContext context, AdminController controller, {AdminModel? admin}) {
    final isEdit = admin != null;
    final nameCtrl = TextEditingController(text: admin?.name);
    final userCtrl = TextEditingController(text: admin?.username);
    final passCtrl = TextEditingController();
    String selectedRole = admin?.role ?? 'admin';

    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(isEdit ? 'Edit Admin' : 'Add New Admin', style: const TextStyle(fontWeight: FontWeight.bold)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextField(label: 'Full Name', controller: nameCtrl),
              CustomTextField(label: 'Username', controller: userCtrl),
              CustomTextField(label: 'Password', controller: passCtrl, isPassword: true),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRole,
                decoration: InputDecoration(
                  labelText: 'Role',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
                items: const [
                  DropdownMenuItem(value: 'admin', child: Text('Admin (Judge)')),
                  DropdownMenuItem(value: 'super_admin', child: Text('Super Admin')),
                ],
                onChanged: (val) => selectedRole = val!,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1e3c72),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () {
              if (nameCtrl.text.isEmpty || userCtrl.text.isEmpty || (!isEdit && passCtrl.text.isEmpty)) {
                Get.snackbar('Error', 'Please fill all required fields');
                return;
              }
              final newAdmin = AdminModel(
                name: nameCtrl.text,
                username: userCtrl.text,
                role: selectedRole,
                password: passCtrl.text,
              );
              if (isEdit) {
                controller.updateAdmin(admin.id!, newAdmin);
              } else {
                controller.createAdmin(newAdmin);
              }
            },
            child: Text(isEdit ? 'Update' : 'Create'),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirm(BuildContext context, AdminController controller, AdminModel admin) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Admin'),
        content: Text('Are you sure you want to delete ${admin.name}? This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              controller.deleteAdmin(admin.id!);
              Get.back();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
