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

      final evaluatedTeams = teamController.allTeams
          .where((team) => team['evaluation'] != null)
          .toList();

      if (evaluatedTeams.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Icon(Icons.insights_outlined, size: 72, color: Colors.grey),
              SizedBox(height: 16),
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
                onTap: () => _showMarksSheet(team),
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

  void _showMarksSheet(Map<String, dynamic> team) {
    final evaluation = _asMap(team['evaluation']);
    final supervisorEvals = _asMap(evaluation['supervisorEvaluations']);
    final entries = supervisorEvals.entries.toList();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              team['teamName'] ?? 'Unknown Team',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1e3c72),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 6),
            Text(
              'Marks assigned by admins',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: Get.height * 0.62,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final crossAxisCount = constraints.maxWidth < 700 ? 1 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      childAspectRatio: crossAxisCount == 1 ? 2.2 : 0.84,
                    ),
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final entry = entries[index];
                      final score = _asMap(entry.value);
                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F9FD),
                          borderRadius: BorderRadius.circular(22),
                          border: Border.all(color: Colors.blueGrey.shade50),
                        ),
                        child: Column(
                          children: [
                            Expanded(child: _buildAdminPieChart(score)),
                            const SizedBox(height: 12),
                            Text(
                              entry.key,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1e3c72),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${score['total'] ?? 0} / 50',
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
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

  Widget _buildAdminPieChart(Map<String, dynamic> score) {
    return _buildPieChart(score, showLabels: true);
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
