import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';
import '../controllers/team_controller.dart';
import '../controllers/evaluation_controller.dart';
import '../controllers/settings_controller.dart';
import 'admin_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  final AuthController authController = Get.find<AuthController>();
  final TeamController teamController = Get.put(TeamController());
  final EvaluationController evaluationController = Get.put(EvaluationController());
  final SettingsController settingsController = Get.put(SettingsController());

  @override
  void initState() {
    super.initState();
    teamController.fetchAllTeams();
  }

  static const List<Widget> _titles = [
    Text('Pending Evaluations'),
    Text('Completed Evaluations'),
    Text('Top 3 Performers'),
  ];

  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      backgroundColor: Colors.grey[50],
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
        title: _selectedIndex < _titles.length 
            ? _titles[_selectedIndex] 
            : const Text('Manage Admins'),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          Obx(() {
            if (authController.adminRole.value == 'super_admin') {
              return Row(
                children: [
                  const Text('Publish', style: TextStyle(fontSize: 12, color: Colors.white)),
                  Switch(
                    value: settingsController.isResultPublished.value,
                    onChanged: (val) => settingsController.toggleResultPublish(val),
                    activeColor: Colors.greenAccent,
                    activeTrackColor: Colors.white24,
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: authController.logout,
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Obx(() => IndexedStack(
          index: _selectedIndex,
          children: [
            _buildPendingScreen(),
            _buildCompletedScreen(),
            _buildTopPerformersScreen(),
            if (authController.adminRole.value == 'super_admin') const AdminManagementScreen(),
          ],
        )),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Obx(() => BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
            if (index < 3) teamController.fetchAllTeams();
          },
          selectedItemColor: const Color(0xFF1e3c72),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Pending'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Completed'),
            const BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Top 3'),
            if (authController.adminRole.value == 'super_admin')
              const BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Admins'),
          ],
        )),
      ),
      floatingActionButton: _selectedIndex == 3
          ? FloatingActionButton(
              onPressed: () => AdminManagementScreen.showAddDialog(context),
              backgroundColor: const Color(0xFF1e3c72),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : FloatingActionButton(
              onPressed: teamController.fetchAllTeams,
              backgroundColor: const Color(0xFF2a5298),
              child: const Icon(Icons.refresh, color: Colors.white),
            ),
    );
  }

  Widget _buildPendingScreen() {
    return Obx(() {
      if (teamController.isLoading.value) return const Center(child: CircularProgressIndicator());
      
      final supervisorId = authController.supervisorId.value;
      final pendingTeams = teamController.allTeams.where((team) {
        final eval = team['evaluation'];
        if (eval == null || eval['supervisorEvaluations'] == null) return true;
        return eval['supervisorEvaluations'][supervisorId] == null;
      }).toList();

      if (pendingTeams.isEmpty) {
        return _buildEmptyState(Icons.check_circle_outline, 'All evaluations completed!', 'No pending teams to evaluate.');
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: pendingTeams.length,
        itemBuilder: (context, index) {
          final team = pendingTeams[index];
          return _buildTeamCard(
            team: team,
            icon: Icons.edit_note,
            iconColor: Colors.orange,
            statusText: 'Evaluation Pending',
            onTap: () {
              teamController.searchResult.value = null;
              Get.toNamed('/evaluation', arguments: team);
            },
          );
        },
      );
    });
  }

  Widget _buildCompletedScreen() {
    return Obx(() {
      if (teamController.isLoading.value) return const Center(child: CircularProgressIndicator());
      
      final supervisorId = authController.supervisorId.value;
      final completedTeams = teamController.allTeams.where((team) {
        final eval = team['evaluation'];
        if (eval == null || eval['supervisorEvaluations'] == null) return false;
        return eval['supervisorEvaluations'][supervisorId] != null;
      }).toList();

      if (completedTeams.isEmpty) {
        return _buildEmptyState(Icons.assignment_outlined, 'No evaluations yet', 'Start evaluating teams to see them here.');
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: completedTeams.length,
        itemBuilder: (context, index) {
          final team = completedTeams[index];
          final myEval = team['evaluation']['supervisorEvaluations'][supervisorId];
          return _buildTeamCard(
            team: team,
            icon: Icons.pie_chart,
            iconColor: Colors.blue,
            statusText: 'Score: ${myEval['total']}',
            onTap: () => _showTeamDetailSheet(team, myEval, 'Your Evaluation'),
          );
        },
      );
    });
  }

  Widget _buildTopPerformersScreen() {
    return Obx(() {
      if (teamController.isLoading.value) return const Center(child: CircularProgressIndicator());
      
      final sortedTeams = List.from(teamController.allTeams);
      sortedTeams.sort((a, b) {
        final scoreA = (a['evaluation'] != null) ? (a['evaluation']['totalScore'] ?? 0) : 0;
        final scoreB = (b['evaluation'] != null) ? (b['evaluation']['totalScore'] ?? 0) : 0;
        return scoreB.compareTo(scoreA);
      });

      final evaluatedTeams = sortedTeams.where((t) => t['evaluation'] != null).toList();

      if (evaluatedTeams.isEmpty) {
        return _buildEmptyState(Icons.emoji_events_outlined, 'Leaderboard Empty', 'Performances will appear after evaluation.');
      }

      final top3 = evaluatedTeams.take(3).toList();

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: top3.length,
        itemBuilder: (context, index) {
          final team = top3[index];
          final score = team['evaluation']['totalScore'];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: _getRankGradient(index),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: _getRankColor(index).withOpacity(0.3), blurRadius: 8, spreadRadius: 1),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),
              title: Text(
                team['teamName'],
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4.0),
                child: Text(
                  'Average Score: $score%',
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => _showTeamDetailSheet(team, team['evaluation'], 'Average Performance'),
            ),
          );
        },
      );
    });
  }

  Widget _buildTeamCard({
    required Map<String, dynamic> team,
    required IconData icon,
    required Color iconColor,
    required String statusText,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 12, offset: const Offset(0, 4)),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        team['teamName'],
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ID: ${team['teamId']}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      statusText,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: iconColor,
                        fontSize: 14,
                      ),
                    ),
                    const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.grey)),
          const SizedBox(height: 8),
          Text(subtitle, style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }

  List<Color> _getRankGradient(int index) {
    switch (index) {
      case 0: return [const Color(0xFFFFD700), const Color(0xFFFFA500)]; // Gold
      case 1: return [const Color(0xFFC0C0C0), const Color(0xFF808080)]; // Silver
      case 2: return [const Color(0xFFCD7F32), const Color(0xFF8B4513)]; // Bronze
      default: return [const Color(0xFF1e3c72), const Color(0xFF2a5298)];
    }
  }

  Color _getRankColor(int index) {
    switch (index) {
      case 0: return Colors.amber;
      case 1: return Colors.grey;
      case 2: return Colors.brown;
      default: return Colors.blue;
    }
  }

  void _showTeamDetailSheet(Map<String, dynamic> team, Map<String, dynamic> scores, String title) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 60,
                height: 5,
                decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
              ),
              const SizedBox(height: 24),
              Text(team['teamName'], style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(title, style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w500)),
              const SizedBox(height: 32),
              SizedBox(
                height: 220,
                child: _buildPieChart(scores),
              ),
              const SizedBox(height: 32),
              _buildScoreBreakdown(scores),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Project Title', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 8),
                    Text(team['projectTitle'], style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Widget _buildPieChart(Map<String, dynamic> data) {
    final Map<String, String> labels = {
      'idea': 'Idea',
      'speech': 'Speech',
      'problemSolution': 'Solution',
      'presentation': 'Present',
      'futureScope': 'Future',
    };

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      const Color(0xFF4facfe),
      const Color(0xFF43e97b),
      const Color(0xFFfa709a),
      const Color(0xFFf6d365),
      const Color(0xFF667eea),
    ];
    int colorIndex = 0;

    labels.forEach((key, label) {
      final value = (data[key] ?? 0).toDouble();
      if (value > 0) {
        sections.add(PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: '$value',
          radius: 70,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          badgeWidget: _buildBadge(label, colors[colorIndex % colors.length]),
          badgePositionPercentageOffset: 1.1,
        ));
        colorIndex++;
      }
    });

    if (sections.isEmpty) return const Center(child: Text('No score data available'));

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: 40,
        sectionsSpace: 4,
      ),
    );
  }

  Widget _buildBadge(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(4),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
      ),
      child: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildScoreBreakdown(Map<String, dynamic> data) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _scoreChip('Idea', data['idea'], const Color(0xFF4facfe)),
        _scoreChip('Speech', data['speech'], const Color(0xFF43e97b)),
        _scoreChip('Solution', data['problemSolution'], const Color(0xFFfa709a)),
        _scoreChip('Presentation', data['presentation'], const Color(0xFFf6d365)),
        _scoreChip('Future', data['futureScope'], const Color(0xFF667eea)),
      ],
    );
  }

  Widget _scoreChip(String label, dynamic value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 8),
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text('${value ?? 0}', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}
