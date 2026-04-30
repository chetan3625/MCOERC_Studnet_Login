class EvaluationModel {
  String teamId;
  Map<String, Scores> supervisorEvaluations;
  num totalScore;
  DateTime? updatedAt;

  EvaluationModel({
    required this.teamId,
    required this.supervisorEvaluations,
    required this.totalScore,
    this.updatedAt,
  });

  factory EvaluationModel.fromJson(Map<String, dynamic> json) {
    Map<String, Scores> evaluations = {};
    if (json['supervisorEvaluations'] != null) {
      if (json['supervisorEvaluations'] is Map) {
        (json['supervisorEvaluations'] as Map).forEach((key, value) {
          evaluations[key] = Scores.fromJson(value);
        });
      }
    }

    return EvaluationModel(
      teamId: json['teamId'] ?? '',
      supervisorEvaluations: evaluations,
      totalScore: json['totalScore'] ?? 0,
      updatedAt: json['updatedAt'] != null ? DateTime.parse(json['updatedAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    Map<String, dynamic> supervisorEvalsJson = {};
    supervisorEvaluations.forEach((key, value) {
      supervisorEvalsJson[key] = value.toJson();
    });

    return {
      'teamId': teamId,
      'supervisorEvaluations': supervisorEvalsJson,
      'totalScore': totalScore,
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class Scores {
  num originality;
  num technical;
  num presentation;
  num impact;
  num? total;

  Scores({
    required this.originality,
    required this.technical,
    required this.presentation,
    required this.impact,
    this.total,
  });

  Map<String, dynamic> toJson() => {
    'originality': originality,
    'technical': technical,
    'presentation': presentation,
    'impact': impact,
    'total': total,
  };

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
    originality: json['originality'] ?? 0,
    technical: json['technical'] ?? 0,
    presentation: json['presentation'] ?? 0,
    impact: json['impact'] ?? 0,
    total: json['total'] ?? 0,
  );
}
