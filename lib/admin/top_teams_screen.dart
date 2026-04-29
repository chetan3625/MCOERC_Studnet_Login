import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/evaluation_controller.dart';

class TopTeamsScreen extends StatefulWidget {
  const TopTeamsScreen({Key? key}) : super(key: key);

  @override
  State<TopTeamsScreen> createState() => _TopTeamsScreenState();
}

class _TopTeamsScreenState extends State<TopTeamsScreen> {
  final EvaluationController evalController = Get.put(EvaluationController());

  @override
  void initState() {
    super.initState();
    evalController.fetchTopTeams();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Teams')),
      body: Obx(() {
        if (evalController.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (evalController.topTeams.isEmpty) {
          return Center(
            child: Text(
              evalController.message.value.isNotEmpty 
                  ? evalController.message.value 
                  : 'No evaluations yet.',
              style: const TextStyle(fontSize: 18),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: evalController.topTeams.length,
          itemBuilder: (context, index) {
            final team = evalController.topTeams[index];
            return Card(
              color: index == 0 ? Colors.amber[100] : (index == 1 ? Colors.grey[200] : Colors.brown[100]),
              margin: const EdgeInsets.only(bottom: 16),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: Text('#${index + 1}', style: const TextStyle(color: Colors.white)),
                ),
                title: Text(team['teamName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text('ID: ${team['teamId']}'),
                trailing: Text(
                  'Score: ${team['totalScore']}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.green),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
