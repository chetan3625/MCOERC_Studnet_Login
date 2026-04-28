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
  num idea;
  num speech;
  num problemSolution;
  num presentation;
  num futureScope;

  Scores({
    required this.idea,
    required this.speech,
    required this.problemSolution,
    required this.presentation,
    required this.futureScope,
  });

  Map<String, dynamic> toJson() => {
    'idea': idea,
    'speech': speech,
    'problemSolution': problemSolution,
    'presentation': presentation,
    'futureScope': futureScope,
  };

  factory Scores.fromJson(Map<String, dynamic> json) => Scores(
    idea: json['idea'] ?? 0,
    speech: json['speech'] ?? 0,
    problemSolution: json['problemSolution'] ?? 0,
    presentation: json['presentation'] ?? 0,
    futureScope: json['futureScope'] ?? 0,
  );
}
