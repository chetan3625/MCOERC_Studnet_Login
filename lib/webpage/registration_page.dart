import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/team_controller.dart';
import '../models/team_model.dart';
import '../views/custom_button.dart';
import '../views/custom_text_field.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({Key? key}) : super(key: key);

  @override
  State<RegistrationPage> createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final TeamController teamController = Get.put(TeamController());
  final _formKey = GlobalKey<FormState>();

  final TextEditingController teamNameCtrl = TextEditingController();
  final TextEditingController projectTitleCtrl = TextEditingController();
  final TextEditingController problemStatementCtrl = TextEditingController();
  
  List<Map<String, TextEditingController>> memberControllers = [];

  @override
  void initState() {
    super.initState();
    addMember();
  }

  void addMember() {
    if (memberControllers.length < 4) {
      setState(() {
        memberControllers.add({
          'name': TextEditingController(),
          'email': TextEditingController(),
          'phone': TextEditingController(),
        });
      });
    }
  }

  void removeMember(int index) {
    if (memberControllers.length > 1) {
      setState(() {
        memberControllers.removeAt(index);
      });
    }
  }

  void submit() {
    if (_formKey.currentState!.validate()) {
      List<Member> members = memberControllers.map((ctrls) => Member(
        name: ctrls['name']!.text,
        email: ctrls['email']!.text,
        phone: ctrls['phone']!.text,
      )).toList();

      Team team = Team(
        teamName: teamNameCtrl.text,
        members: members,
        projectTitle: projectTitleCtrl.text,
        problemStatement: problemStatementCtrl.text,
      );

      teamController.registerTeam(team);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Register Team'), centerTitle: true),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(24.0),
              children: [
                CustomTextField(
                  label: 'Team Name',
                  controller: teamNameCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                CustomTextField(
                  label: 'Project Title',
                  controller: projectTitleCtrl,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                CustomTextField(
                  label: 'Problem Statement',
                  controller: problemStatementCtrl,
                  maxLines: 3,
                  validator: (v) => v!.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 24),
                const Text('Team Members', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                ...memberControllers.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var ctrls = entry.value;
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Member ${idx + 1}', style: const TextStyle(fontWeight: FontWeight.bold)),
                              if (idx > 0)
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => removeMember(idx),
                                )
                            ],
                          ),
                          CustomTextField(
                            label: 'Name',
                            controller: ctrls['name'],
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                          CustomTextField(
                            label: 'Email',
                            controller: ctrls['email'],
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) => !GetUtils.isEmail(v ?? '') ? 'Invalid Email' : null,
                          ),
                          CustomTextField(
                            label: 'Phone',
                            controller: ctrls['phone'],
                            keyboardType: TextInputType.phone,
                            validator: (v) => v!.isEmpty ? 'Required' : null,
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
                if (memberControllers.length < 4)
                  TextButton.icon(
                    onPressed: addMember,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Member'),
                  ),
                const SizedBox(height: 32),
                Obx(() => CustomButton(
                  text: 'Submit Registration',
                  onPressed: submit,
                  isLoading: teamController.isLoading.value,
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
