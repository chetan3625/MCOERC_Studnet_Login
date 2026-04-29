import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';

class TeamDetailsScreen extends StatelessWidget {
  const TeamDetailsScreen({Key? key}) : super(key: key);

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    if (data is Map) return Map<String, dynamic>.from(data);
    return <String, dynamic>{};
  }

  Map<String, dynamic> _resolveDisplayScores(Map<String, dynamic> scores) {
    if (scores.containsKey('idea')) return scores;

    final directScores = _asMap(scores['scores']);
    if (directScores.isNotEmpty) return directScores;

    final supervisorEvaluations = _asMap(scores['supervisorEvaluations']);
    if (supervisorEvaluations.isEmpty) return <String, dynamic>{};

    final values = supervisorEvaluations.values
        .map((entry) => _asMap(entry))
        .where((entry) => entry.isNotEmpty)
        .toList();
    if (values.isEmpty) return <String, dynamic>{};

    num avg(String key) =>
        values.fold<num>(0, (sum, item) => sum + ((item[key] ?? 0) as num)) /
        values.length;

    return {
      'idea': avg('idea').round(),
      'speech': avg('speech').round(),
      'problemSolution': avg('problemSolution').round(),
      'presentation': avg('presentation').round(),
      'futureScope': avg('futureScope').round(),
    };
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> args = (Get.arguments is Map) ? Map<String, dynamic>.from(Get.arguments) : {};
    final team = _asMap(args['team']);
    final scores = _asMap(args['scores'] ?? team['evaluation']);
    final title = args['title'] ?? 'Team Performance';

    final displayScores = _resolveDisplayScores(scores);
    final supervisorEvaluations = _asMap(scores['supervisorEvaluations']);

    if (team.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Details')),
        body: const Center(child: Text('No team data provided')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Team Evaluation Details'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF1e3c72), Color(0xFF2a5298)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
                boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
              ),
              child: Column(
                children: [
                  Text(
                    team['teamName'] ?? 'Unknown Team',
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Color(0xFF1e3c72)),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    title,
                    style: TextStyle(fontSize: 16, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    height: 220,
                    child: _buildPieChart(displayScores),
                  ),
                  const SizedBox(height: 32),
                  _buildScoreBreakdown(displayScores),
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (supervisorEvaluations.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Admin Marks Breakdown',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade900,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _buildAdminMarksList(supervisorEvaluations),
            ],
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Project Information', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
                    const SizedBox(height: 12),
                    Text(
                      team['projectTitle'] ?? 'No Title Provided',
                      style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text('Team ID: ${team['teamId']}', style: TextStyle(color: Colors.grey.shade600)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminMarksList(Map<String, dynamic> supervisorEvaluations) {
    final entries = supervisorEvaluations.entries.toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      itemCount: entries.length,
      itemBuilder: (context, index) {
        final entry = entries[index];
        final score = _asMap(entry.value);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.blue.shade50),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
            ],
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.key,
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1e3c72)),
                        ),
                        Text(
                          'Total Score: ${score['total'] ?? 0} / 50',
                          style: TextStyle(color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.verified_user, color: Colors.green, size: 24),
                ],
              ),
              const Divider(height: 32),
              SizedBox(
                height: 140,
                child: _buildPieChart(score, isSmall: true),
              ),
              const SizedBox(height: 16),
              _buildScoreBreakdown(score, isSmall: true),
            ],
          ),
        );
      },
    );
  }

  Map<String, dynamic> _resolveDisplayScores(Map<String, dynamic> scores) {
    if (scores.containsKey('originality')) return scores;

    final directScores = _asMap(scores['scores']);
    if (directScores.isNotEmpty) return directScores;

    final supervisorEvaluations = _asMap(scores['supervisorEvaluations']);
    if (supervisorEvaluations.isEmpty) return <String, dynamic>{};

    final values = supervisorEvaluations.values
        .map((entry) => _asMap(entry))
        .where((entry) => entry.isNotEmpty)
        .toList();
    if (values.isEmpty) return <String, dynamic>{};

    num avg(String key) =>
        values.fold<num>(0, (sum, item) => sum + ((item[key] ?? 0) as num)) /
        values.length;

    return {
      'originality': avg('originality').round(),
      'technical': avg('technical').round(),
      'presentation': avg('presentation').round(),
      'impact': avg('impact').round(),
    };
  }

  Widget _buildPieChart(Map<String, dynamic> data, {bool isSmall = false}) {
    final Map<String, String> labels = {
      'originality': 'Originality',
      'technical': 'Technical',
      'presentation': 'Present',
      'impact': 'Impact',
    };

    final List<PieChartSectionData> sections = [];
    final List<Color> colors = [
      const Color(0xFF4facfe),
      const Color(0xFF43e97b),
      const Color(0xFFf6d365),
      const Color(0xFFfa709a),
    ];
    int colorIndex = 0;

    labels.forEach((key, label) {
      final raw = data[key];
      final value = raw is num ? raw.toDouble() : 0.0;
      if (value > 0) {
        sections.add(PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: value,
          title: isSmall ? '' : '$value',
          radius: isSmall ? 45.0 : 70.0,
          titleStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
          badgeWidget: isSmall ? null : _buildBadge(label, colors[colorIndex % colors.length]),
          badgePositionPercentageOffset: 1.1,
        ));
        colorIndex++;
      }
    });

    if (sections.isEmpty) return const Center(child: Text('No data recorded'));

    return PieChart(
      PieChartData(
        sections: sections,
        centerSpaceRadius: isSmall ? 25 : 40,
        sectionsSpace: 3,
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

  Widget _buildScoreBreakdown(Map<String, dynamic> data, {bool isSmall = false}) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        _scoreChip('Originality', data['originality'], const Color(0xFF4facfe), isSmall, 10),
        _scoreChip('Technical', data['technical'], const Color(0xFF43e97b), isSmall, 20),
        _scoreChip('Presentation', data['presentation'], const Color(0xFFf6d365), isSmall, 10),
        _scoreChip('Impact', data['impact'], const Color(0xFFfa709a), isSmall, 10),
      ],
    );
  }

  Widget _scoreChip(String label, dynamic value, Color color, bool isSmall, int max) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: isSmall ? 10 : 16, vertical: isSmall ? 6 : 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text('$label: ', style: TextStyle(fontWeight: FontWeight.w500, fontSize: isSmall ? 11 : 13)),
          Text('${value ?? 0} / $max', style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: isSmall ? 11 : 13)),
        ],
      ),
    );
  }
}
