import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_controller.dart';
import '../models/system_log_model.dart';

class SystemLogsScreen extends StatefulWidget {
  const SystemLogsScreen({Key? key}) : super(key: key);

  @override
  State<SystemLogsScreen> createState() => _SystemLogsScreenState();
}

class _SystemLogsScreenState extends State<SystemLogsScreen> {
  final AdminController controller = Get.find<AdminController>();

  @override
  void initState() {
    super.initState();
    controller.fetchSystemLogs();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('System Logs'),
        backgroundColor: const Color(0xFF1e3c72),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.fetchSystemLogs,
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.systemLogs.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.systemLogs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.assignment_outlined, size: 80, color: Colors.grey[300]),
                const SizedBox(height: 16),
                const Text('No logs found', style: TextStyle(color: Colors.grey, fontSize: 18)),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.systemLogs.length,
          itemBuilder: (context, index) {
            final log = controller.systemLogs[index];
            return _buildLogCard(log);
          },
        );
      }),
    );
  }

  Widget _buildLogCard(SystemLogModel log) {
    Color levelColor = Colors.blue;
    IconData levelIcon = Icons.info_outline;

    if (log.level == 'WARN') {
      levelColor = Colors.orange;
      levelIcon = Icons.warning_amber_rounded;
    } else if (log.level == 'ERROR') {
      levelColor = Colors.red;
      levelIcon = Icons.error_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: ExpansionTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: levelColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(levelIcon, color: levelColor, size: 20),
        ),
        title: Text(
          log.message ?? '',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          '${log.module} • ${log.formattedTime}',
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (log.admin != null) _buildDetailRow('Admin', log.admin!),
                if (log.ip != null) _buildDetailRow('IP Address', log.ip!),
                if (log.method != null) _buildDetailRow('Method', log.method!),
                if (log.path != null) _buildDetailRow('Path', log.path!),
                if (log.details != null) ...[
                  const SizedBox(height: 8),
                  const Text('Details:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                  const SizedBox(height: 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      log.details.toString(),
                      style: const TextStyle(fontFamily: 'monospace', fontSize: 11),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
          Text(value, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}
