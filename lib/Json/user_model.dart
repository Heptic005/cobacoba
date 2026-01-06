class UserModel {
  final int? id;
  final String username;
  final String password;
  final String role;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    id: json['id'],
    username: json['username'],
    password: json['password'],
    role: json['role'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'username': username,
    'password': password,
    'role': role,
  };
}
