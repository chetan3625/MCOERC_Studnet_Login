import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controllers/auth_controller.dart';
import '../controllers/evaluation_controller.dart';
import '../controllers/team_controller.dart';

class EvaluationScreen extends StatefulWidget {
  const EvaluationScreen({Key? key}) : super(key: key);

  @override
  State<EvaluationScreen> createState() => _EvaluationScreenState();
}

class _EvaluationScreenState extends State<EvaluationScreen> {
  final EvaluationController evalController = Get.put(EvaluationController());
  final TeamController teamController = Get.find<TeamController>();
  final AuthController authController = Get.find<AuthController>();
  final TextEditingController _minuteController = TextEditingController(text: '5');

  Timer? _timer;
  int _initialSeconds = 300;
  int _remainingSeconds = 300;
  bool _isTimerRunning = false;

  String teamName = '';
  String teamId = '';
  Map<String, dynamic>? _teamEvaluation;

  @override
  void initState() {
    super.initState();
    evalController.resetScores();

    final Map<String, dynamic>? argTeam = Get.arguments;

    if (argTeam != null) {
      teamName = argTeam['teamName'] ?? '';
      teamId = argTeam['teamId'] ?? '';
      _teamEvaluation = _asMap(argTeam['evaluation']);
    } else if (teamController.searchResult.value != null) {
      teamName = teamController.searchResult.value!.teamName;
      teamId = teamController.searchResult.value!.teamId ?? '';
      _teamEvaluation = teamController.searchEvaluation.value;
    }

    final myEval = _supervisorEvaluations[authController.supervisorId.value];
    if (myEval != null) {
      _prefillScores(myEval);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _minuteController.dispose();
    super.dispose();
  }

  Map<String, dynamic> get _supervisorEvaluations =>
      _asMap(_teamEvaluation?['supervisorEvaluations']);

  void _prefillScores(Map<String, dynamic> myEval) {
    evalController.idea.value = (myEval['idea'] as num?)?.toDouble() ?? 0;
    evalController.speech.value = (myEval['speech'] as num?)?.toDouble() ?? 0;
    evalController.problemSolution.value =
        (myEval['problemSolution'] as num?)?.toDouble() ?? 0;
    evalController.presentation.value =
        (myEval['presentation'] as num?)?.toDouble() ?? 0;
    evalController.futureScope.value =
        (myEval['futureScope'] as num?)?.toDouble() ?? 0;
  }

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  void _configureTimer() {
    final minutes = int.tryParse(_minuteController.text.trim()) ?? 5;
    final safeMinutes = minutes.clamp(1, 180);
    _initialSeconds = safeMinutes * 60;
    _remainingSeconds = _initialSeconds;
    _isTimerRunning = false;
    _timer?.cancel();
    setState(() {});
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() => _isTimerRunning = false);
      return;
    }

    if (_remainingSeconds <= 0) {
      _configureTimer();
    }

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds <= 1) {
        timer.cancel();
        setState(() {
          _remainingSeconds = 0;
          _isTimerRunning = false;
        });
        _playTimerAlert();
        return;
      }

      setState(() {
        _remainingSeconds--;
      });
    });

    setState(() => _isTimerRunning = true);
  }

  Future<void> _playTimerAlert() async {
    await SystemSound.play(SystemSoundType.alert);
    if (!mounted) return;
    Get.snackbar(
      'Time Up',
      'The evaluation timer has finished.',
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 4),
      backgroundColor: const Color(0xFF1e3c72),
      colorText: Colors.white,
    );
  }

  void _resetTimer() {
    _configureTimer();
  }

  void _addOneMinute() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds += 60;
      _initialSeconds = _remainingSeconds > _initialSeconds
          ? _remainingSeconds
          : _initialSeconds;
      _isTimerRunning = false;
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  double get _timerProgress {
    if (_initialSeconds == 0) return 0;
    return (_remainingSeconds / _initialSeconds).clamp(0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: const Text(
          'Evaluation Form',
          style: TextStyle(color: Colors.white),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: teamId.isEmpty
          ? const Center(child: Text('No team selected'))
          : SingleChildScrollView(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 24),
              child: Column(
                children: [
                  _buildTeamHeader(),
                  const SizedBox(height: 24),
                  _buildTimerCard(),
                  const SizedBox(height: 24),
                  _buildScoringCard(),
                  const SizedBox(height: 24),
                  if (_supervisorEvaluations.isNotEmpty) _buildExistingMarksCard(),
                  const SizedBox(height: 24),
                  _buildSubmitButton(),
                ],
              ),
            ),
    );
  }

  Widget _buildTeamHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.blue.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            teamName,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e3c72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ID: $teamId',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Judging as: ${authController.supervisorId.value}',
            style: const TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1e3c72).withOpacity(0.08),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final vertical = constraints.maxWidth < 760;
          final children = [
            Expanded(
              flex: vertical ? 0 : 5,
              child: _buildClockFace(),
            ),
            SizedBox(width: vertical ? 0 : 20, height: vertical ? 20 : 0),
            Expanded(
              flex: vertical ? 0 : 6,
              child: _buildTimerControls(),
            ),
          ];

          return vertical
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: children,
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: children,
                );
        },
      ),
    );
  }

  Widget _buildClockFace() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF132A4D), Color(0xFF2A5298)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Evaluation Timer',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: 180,
            height: 180,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 180,
                  height: 180,
                  child: CircularProgressIndicator(
                    value: _timerProgress,
                    strokeWidth: 12,
                    backgroundColor: Colors.white12,
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFFFFD166),
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _formattedTime,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isTimerRunning ? 'Running' : 'Ready',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Set speaking time',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1e3c72),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Enter minutes, then start the timer. A sound alert will play when the time is exhausted.',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 18),
        TextField(
          controller: _minuteController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'Time in minutes',
            hintText: '5',
            prefixIcon: const Icon(Icons.timer_outlined),
            filled: true,
            fillColor: const Color(0xFFF6F8FC),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
          onSubmitted: (_) => _configureTimer(),
        ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            ElevatedButton.icon(
              onPressed: _toggleTimer,
              icon: Icon(_isTimerRunning ? Icons.pause : Icons.play_arrow),
              label: Text(_isTimerRunning ? 'Pause' : 'Start'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2a5298),
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _resetTimer,
              icon: const Icon(Icons.restart_alt),
              label: const Text('Reset'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            OutlinedButton.icon(
              onPressed: _addOneMinute,
              icon: const Icon(Icons.add_alarm),
              label: const Text('+1 Min'),
              style: OutlinedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScoringCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildSlider('Idea & Innovation', evalController.idea, Colors.blue),
          _buildSlider(
            'Speech & Communication',
            evalController.speech,
            Colors.green,
          ),
          _buildSlider(
            'Problem Solution',
            evalController.problemSolution,
            Colors.orange,
          ),
          _buildSlider(
            'Presentation Skills',
            evalController.presentation,
            Colors.purple,
          ),
          _buildSlider('Future Scope', evalController.futureScope, Colors.red),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFF1e3c72),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1e3c72).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'TOTAL POINTS: ',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Obx(
                  () => Text(
                    '${evalController.totalScore.toInt()}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                const Text(
                  ' / 50',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExistingMarksCard() {
    final entries = _supervisorEvaluations.entries.toList();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Marks Assigned By Admins',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1e3c72),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'See the marks already assigned to this team by each admin.',
            style: TextStyle(color: Colors.grey.shade700),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 14,
            runSpacing: 14,
            children: entries.map((entry) {
              final data = _asMap(entry.value);
              return Container(
                width: 220,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F9FD),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blueGrey.shade50),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1e3c72),
                      ),
                    ),
                    const SizedBox(height: 10),
                    _marksRow('Idea', data['idea']),
                    _marksRow('Speech', data['speech']),
                    _marksRow('Solution', data['problemSolution']),
                    _marksRow('Presentation', data['presentation']),
                    _marksRow('Future', data['futureScope']),
                    const Divider(height: 20),
                    Text(
                      'Total: ${data['total'] ?? 0} / 50',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2a5298),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _marksRow(String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(color: Colors.grey.shade700)),
          Text(
            '${value ?? 0}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(
      () => SizedBox(
        width: double.infinity,
        height: 60,
        child: ElevatedButton(
          onPressed: evalController.isLoading.value
              ? null
              : () => evalController.submitEvaluation(teamId),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2a5298),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            elevation: 5,
          ),
          child: evalController.isLoading.value
              ? const CircularProgressIndicator(color: Colors.white)
              : const Text(
                  'Submit Evaluation',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
        ),
      ),
    );
  }

  Widget _buildSlider(String label, RxDouble value, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Obx(
                () => Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${value.value.toInt()} / 10',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Obx(
            () => Slider(
              value: value.value,
              min: 0,
              max: 10,
              divisions: 10,
              activeColor: color,
              inactiveColor: color.withOpacity(0.14),
              onChanged: (val) => value.value = val,
            ),
          ),
        ],
      ),
    );
  }
}
