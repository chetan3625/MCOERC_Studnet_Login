class AdminModel {
  String? id;
  String? username;
  String? name;
  String? role;
  String? password; // Only used for creation/update

  AdminModel({this.id, this.username, this.name, this.role, this.password});

  factory AdminModel.fromJson(Map<String, dynamic> json) {
    return AdminModel(
      id: json['_id'],
      username: json['username'],
      name: json['name'],
      role: json['role'],
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'username': username,
      'name': name,
      'role': role,
    };
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    return data;
  }
}
