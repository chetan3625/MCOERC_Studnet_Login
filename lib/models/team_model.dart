class Member {
  String name;
  String email;
  String phone;

  Member({required this.name, required this.email, required this.phone});

  Map<String, dynamic> toJson() => {
    'name': name,
    'email': email,
    'phone': phone,
  };

  factory Member.fromJson(Map<String, dynamic> json) => Member(
    name: json['name'] ?? '',
    email: json['email'] ?? '',
    phone: json['phone'] ?? '',
  );
}

class Team {
  String? teamId;
  String teamName;
  List<Member> members;
  String projectTitle;
  String problemStatement;

  Team({
    this.teamId,
    required this.teamName,
    required this.members,
    required this.projectTitle,
    required this.problemStatement,
  });

  Map<String, dynamic> toJson() => {
    'teamName': teamName,
    'members': members.map((m) => m.toJson()).toList(),
    'projectTitle': projectTitle,
    'problemStatement': problemStatement,
  };

  factory Team.fromJson(Map<String, dynamic> json) => Team(
    teamId: json['teamId'],
    teamName: json['teamName'] ?? '',
    members: (json['members'] as List?)?.map((m) => Member.fromJson(m)).toList() ?? [],
    projectTitle: json['projectTitle'] ?? '',
    problemStatement: json['problemStatement'] ?? '',
  );
}
