import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/team_controller.dart';

class MarksOverviewScreen extends StatelessWidget {
  const MarksOverviewScreen({Key? key}) : super(key: key);

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  @override
  Widget build(BuildContext context) {
    final TeamController teamController = Get.find<TeamController>();

    return Obx(() {
      if (teamController.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      final query = teamController.searchQuery.value.toLowerCase();
      final evaluatedTeams = teamController.allTeams
          .where((team) => team['evaluation'] != null)
          .where((team) {
            if (query.isEmpty) return true;
            final name = (team['teamName'] ?? '').toString().toLowerCase();
            final id = (team['teamId'] ?? '').toString().toLowerCase();
            return name.contains(query) || id.contains(query);
          })
          .toList();

      if (evaluatedTeams.isEmpty) {
        if (query.isNotEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.search_off, size: 72, color: Colors.grey),
                const SizedBox(height: 16),
                Text(
                  'No teams found for "$query"',
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.insights_outlined, size: 72, color: Colors.grey),
              const SizedBox(height: 16),
              Text(
                'No marks assigned yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      }

      return LayoutBuilder(
        builder: (context, constraints) {
          final crossAxisCount = constraints.maxWidth < 700 ? 1 : 2;
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: crossAxisCount,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: crossAxisCount == 1 ? 1.65 : 1.08,
            ),
            itemCount: evaluatedTeams.length,
            itemBuilder: (context, index) {
              final team = evaluatedTeams[index];
              final evaluation = _asMap(team['evaluation']);
              final supervisorEvals = _asMap(evaluation['supervisorEvaluations']);
              return InkWell(
                borderRadius: BorderRadius.circular(24),
                onTap: () => Get.toNamed('/team-details', arguments: {
                  'team': team,
                  'title': 'Marks Assigned by Admins',
                }),
                child: Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
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
                      Text(
                        team['teamName'] ?? 'Unknown Team',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1e3c72),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        team['teamId'] ?? '',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      const SizedBox(height: 14),
                      Expanded(
                        child: _buildTeamScoreChart(evaluation),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${supervisorEvals.length} admins',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${evaluation['totalScore'] ?? 0} / 50',
                            style: const TextStyle(
                              color: Color(0xFF2a5298),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      );
    });
  }



  Widget _buildTeamScoreChart(Map<String, dynamic> evaluation) {
    final avgScores = _asMap(evaluation['scores']);
    final supervisorMap = _asMap(evaluation['supervisorEvaluations']);
    final firstScore = supervisorMap.values.isNotEmpty
        ? _asMap(supervisorMap.values.first)
        : <String, dynamic>{};
    final chartSource = avgScores.isNotEmpty ? avgScores : firstScore;
    return _buildPieChart(chartSource, showLabels: false);
  }



  Widget _buildPieChart(Map<String, dynamic> data, {required bool showLabels}) {
    final labels = <String, String>{
      'idea': 'Idea',
      'speech': 'Speech',
      'problemSolution': 'Solution',
      'presentation': 'Present',
      'futureScope': 'Future',
    };

    final colors = <Color>[
      const Color(0xFF4facfe),
      const Color(0xFF43e97b),
      const Color(0xFFfa709a),
      const Color(0xFFf6d365),
      const Color(0xFF667eea),
    ];

    final sections = <PieChartSectionData>[];
    var colorIndex = 0;

    labels.forEach((key, label) {
      final raw = data[key];
      final value = raw is num ? raw.toDouble() : 0.0;
      if (value > 0) {
        sections.add(
          PieChartSectionData(
            color: colors[colorIndex % colors.length],
            value: value,
            title: showLabels ? value.toStringAsFixed(0) : '',
            radius: showLabels ? 54.0 : 46.0,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        );
      }
      colorIndex++;
    });

    if (sections.isEmpty) {
      return const Center(child: Text('No score data'));
    }

    return Column(
      children: [
        Expanded(
          child: PieChart(
            PieChartData(
              sections: sections,
              centerSpaceRadius: showLabels ? 20 : 16,
              sectionsSpace: 3,
            ),
          ),
        ),
        if (showLabels) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.center,
            children: labels.entries.map((entry) {
              final index = labels.keys.toList().indexOf(entry.key);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: colors[index].withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  entry.value,
                  style: TextStyle(
                    color: colors[index],
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }
}
