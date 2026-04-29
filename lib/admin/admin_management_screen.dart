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
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            itemCount: controller.admins.length,
            itemBuilder: (context, index) {
              final admin = controller.admins[index];
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
            },
          ),
        );
      }),
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
