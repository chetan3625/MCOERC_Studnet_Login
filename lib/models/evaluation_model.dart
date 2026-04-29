class Evaluation {
  String teamId;
  Scores scores;
  num totalScore;

  Evaluation({
    required this.teamId,
    required this.scores,
    required this.totalScore,
  });

  Map<String, dynamic> toJson() => {
    'teamId': teamId,
    'scores': scores.toJson(),
  };

  factory Evaluation.fromJson(Map<String, dynamic> json) => Evaluation(
    teamId: json['teamId'],
    scores: Scores.fromJson(json['scores'] ?? {}),
    totalScore: json['totalScore'] ?? 0,
  );
}

class Scores {
  num originality;
  num technical;
  num presentation;
  num impact;

  Scores({
    required this.originality,
    required this.technical,
    required this.presentation,
    required this.impact,
  });

  Map<String, dynamic> toJson() => {
    'originality': originality,
    'technical': technical,
    'presentation': presentation,
    'impact': impact,
  };

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
    originality: json['originality'] ?? 0,
    technical: json['technical'] ?? 0,
    presentation: json['presentation'] ?? 0,
    impact: json['impact'] ?? 0,
  );
}
