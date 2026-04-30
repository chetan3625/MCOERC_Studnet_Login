import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';
import '../controllers/team_controller.dart';
import '../controllers/evaluation_controller.dart';
import '../controllers/settings_controller.dart';
import 'admin_management_screen.dart';
import 'marks_overview_screen.dart';

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
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    teamController.fetchAllTeams();
  }

  static const List<Widget> _titles = [
    Text('Pending Evaluations'),
    Text('Completed Evaluations'),
    Text('Marks Assigned'),
    Text('Top 3 Performers'),
  ];

  @override
  Widget build(BuildContext context) {
    final isSuperAdmin = authController.adminRole.value == 'super_admin';
    final adminTabIndex = isSuperAdmin ? 4 : -1;

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
      body: Column(
        children: [
          if (_selectedIndex < 3) _buildSearchWidget(),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
              ),



              /////////
              
              ////////
              child: IndexedStack(
                index: _selectedIndex,
                children: [
                  _buildPendingScreen(),
                  _buildCompletedScreen(),
                  const MarksOverviewScreen(),
                  _buildTopPerformersScreen(),
                  if (authController.adminRole.value == 'super_admin') const AdminManagementScreen(),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
              _searchController.clear();
              teamController.searchQuery.value = "";
            });
            if (index != adminTabIndex) teamController.fetchAllTeams();
          },
          selectedItemColor: const Color(0xFF1e3c72),
          unselectedItemColor: Colors.grey,
          showUnselectedLabels: true,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(icon: Icon(Icons.pending_actions), label: 'Pending'),
            const BottomNavigationBarItem(icon: Icon(Icons.assignment_turned_in), label: 'Completed'),
            const BottomNavigationBarItem(icon: Icon(Icons.pie_chart_outline), label: 'Marks'),
            const BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Top 3'),
            if (authController.adminRole.value == 'super_admin')
              const BottomNavigationBarItem(icon: Icon(Icons.people_alt), label: 'Admins'),
          ],
        ),
      ),
      floatingActionButton: _selectedIndex == adminTabIndex
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
        bool isPending = false;
        if (eval == null || eval['supervisorEvaluations'] == null) {
          isPending = true;
        } else {
          isPending = eval['supervisorEvaluations'][supervisorId] == null;
        }

        if (!isPending) return false;

        final query = teamController.searchQuery.value.toLowerCase();
        if (query.isEmpty) return true;

        final name = team['teamName'].toString().toLowerCase();
        final id = team['teamId'].toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();

      if (pendingTeams.isEmpty) {
        return teamController.searchQuery.value.isEmpty
            ? _buildEmptyState(Icons.check_circle_outline, 'All evaluations completed!', 'No pending teams to evaluate.')
            : _buildEmptyState(Icons.search_off, 'No teams found', 'No team matches "${teamController.searchQuery.value}"');
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
        bool isCompleted = false;
        if (eval == null || eval['supervisorEvaluations'] == null) {
          isCompleted = false;
        } else {
          isCompleted = eval['supervisorEvaluations'][supervisorId] != null;
        }

        if (!isCompleted) return false;

        final query = teamController.searchQuery.value.toLowerCase();
        if (query.isEmpty) return true;

        final name = team['teamName'].toString().toLowerCase();
        final id = team['teamId'].toString().toLowerCase();
        return name.contains(query) || id.contains(query);
      }).toList();

      if (completedTeams.isEmpty) {
        return teamController.searchQuery.value.isEmpty
            ? _buildEmptyState(Icons.assignment_outlined, 'No evaluations yet', 'Start evaluating teams to see them here.')
            : _buildEmptyState(Icons.search_off, 'No teams found', 'No team matches "${teamController.searchQuery.value}"');
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
            statusText: 'Score: ${myEval['total']} / 50',
            onTap: () => Get.toNamed('/team-details', arguments: {
              'team': team,
              'scores': team['evaluation'],
              'title': 'Evaluation Insights',
            }),
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

      return Column(
        children: [
          if (authController.adminRole.value == 'super_admin')
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Distribute Certificates'),
                      content: const Text('Are you sure you want to generate and email certificates to all students?'),
                      actions: [
                        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
                        ElevatedButton(
                          onPressed: () {
                            Get.back();
                            settingsController.distributeCertificates();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
                          child: const Text('Distribute'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.send),
                label: const Text('Distribute Certificates to All'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
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
                  'Average Score: $score / 50',
                  style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
              onTap: () => Get.toNamed('/team-details', arguments: {
                'team': team,
                'scores': team['evaluation'],
                'title': 'Average Performance',
              }),
            ),
          );
        },
      ),
    ),
  ],
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
                if (authController.adminRole.value == 'super_admin') ...[
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: Colors.redAccent, size: 22),
                    onPressed: () => _showDeleteTeamDialog(context, team),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showDeleteTeamDialog(BuildContext context, Map<String, dynamic> team) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Delete Team'),
        content: Text('Are you sure you want to delete "${team['teamName']}"? This will also remove all associated evaluations.'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              teamController.deleteTeam(team['teamId']);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          onChanged: (val) {
            teamController.searchQuery.value = val;
            setState(() {});
          },
          decoration: InputDecoration(
            hintText: 'Search team name or ID...',
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 15),
            prefixIcon: const Icon(Icons.search, color: Color(0xFF1e3c72), size: 22),
            suffixIcon: _searchController.text.isNotEmpty 
              ? IconButton(
                  icon: const Icon(Icons.cancel, color: Colors.grey, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    teamController.searchQuery.value = "";
                    setState(() {});
                  },
                )
              : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
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

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }



}
